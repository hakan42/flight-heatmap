import gpxpy
import gpxpy.gpx
import pandas as pd
import folium
import os
import json
from folium.plugins import HeatMap


def read_gpx_files(directory):
    data = []
    for file in os.listdir(directory):
        if file.endswith(".gpx"):
            with open(os.path.join(directory, file), 'r') as gpx_file:
                gpx = gpxpy.parse(gpx_file)
                for track in gpx.tracks:
                    for segment in track.segments:
                        segment_points = []
                        for point in segment.points:
                            data.append([point.latitude, point.longitude, point.elevation, point.time])
                            segment_points.append([point.latitude, point.longitude])
                        if segment_points:
                            yield segment_points  # Yield each segment's points to be plotted as lines

def generate_heatmap(data, line_segments, output_file='heatmap.html', bounds_file='bounds.json'):
    # Calculate the bounds
    bounds = [[data['lat'].min(), data['lon'].min()], [data['lat'].max(), data['lon'].max()]]

    folium_map = folium.Map()
    folium_map.fit_bounds(bounds)

    # Add tracks as thin lines
    for segment in line_segments:
        folium.PolyLine(segment, color="blue", weight=1.5, opacity=0.7).add_to(folium_map)

    # Add heatmap layer
    heat_data = [[row['lat'], row['lon']] for index, row in data.iterrows()]
    HeatMap(heat_data).add_to(folium_map)
    folium_map.save(output_file)

    # Save bounds to a pretty-printed JSON file
    with open(bounds_file, 'w') as f:
        json.dump({'bounds': bounds}, f, indent=4)

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Generate a heatmap from GPX files")
    parser.add_argument(
        'directory',
        type=str,
        nargs='?',
        default='/app/gpx_files',
        help='Directory containing GPX files (default: /app/gpx_files)'
    )
    parser.add_argument(
        'output_html',
        type=str,
        nargs='?',
        default='/app/output/heatmap.html',
        help='Output HTML file for the heatmap (default: /app/output/heatmap.html)'
    )
    parser.add_argument(
        'bounds_file',
        type=str,
        nargs='?',
        default='/app/output/bounds.json',
        help='Output JSON file for the bounds (default: /app/output/bounds.json)'
    )
    args = parser.parse_args()

    line_segments = list(read_gpx_files(args.directory))
    data = pd.DataFrame([point for segment in line_segments for point in segment], columns=['lat', 'lon'])
    generate_heatmap(data, line_segments, args.output_html, args.bounds_file)
