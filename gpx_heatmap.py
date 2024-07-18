import gpxpy
import gpxpy.gpx
import pandas as pd
import folium
import os
from folium.plugins import HeatMap

def read_gpx_files(directory):
    data = []
    for file in os.listdir(directory):
        if file.endswith(".gpx"):
            with open(os.path.join(directory, file), 'r') as gpx_file:
                gpx = gpxpy.parse(gpx_file)
                for track in gpx.tracks:
                    for segment in track.segments:
                        for point in segment.points:
                            data.append([point.latitude, point.longitude, point.elevation, point.time])
    return pd.DataFrame(data, columns=['lat', 'lon', 'elevation', 'time'])

def generate_heatmap(data, output_file='heatmap.html'):
    map_center = [data['lat'].mean(), data['lon'].mean()]
    folium_map = folium.Map(location=map_center, zoom_start=12)
    heat_data = [[row['lat'], row['lon']] for index, row in data.iterrows()]
    HeatMap(heat_data).add_to(folium_map)
    folium_map.save(output_file)

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
    args = parser.parse_args()

    data = read_gpx_files(args.directory)
    generate_heatmap(data, args.output_html)
