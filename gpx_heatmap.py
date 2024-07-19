import gpxpy
import gpxpy.gpx
import pandas as pd
import folium
import os
import json
from folium.plugins import HeatMap
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.options import Options


def read_gpx_files(directory):
    data = []
    line_segments = []
    file_names = []
    for file in os.listdir(directory):
        if file.endswith(".gpx"):
            file_names.append(file)
            with open(os.path.join(directory, file), 'r') as gpx_file:
                gpx = gpxpy.parse(gpx_file)
                for track in gpx.tracks:
                    for segment in track.segments:
                        segment_points = []
                        for point in segment.points:
                            data.append([point.latitude, point.longitude, point.elevation, point.time])
                            segment_points.append([point.latitude, point.longitude])
                        if segment_points:
                            line_segments.append(segment_points)
    return pd.DataFrame(data, columns=['lat', 'lon', 'elevation', 'time']), line_segments, file_names

def generate_heatmap(data, line_segments, output_file='heatmap.html', bounds_file='bounds.json', title_file=None):
    # Load bounds from file if available
    if os.path.exists(bounds_file):
        with open(bounds_file, 'r') as f:
            bounds_data = json.load(f)
        bounds = bounds_data.get('bounds')
    else:
        # Calculate the bounds if file not available
        bounds = [[data['lat'].min(), data['lon'].min()], [data['lat'].max(), data['lon'].max()]]
        # Save bounds to a pretty-printed JSON file
        with open(bounds_file, 'w') as f:
            json.dump({'bounds': bounds}, f, indent=4)

    folium_map = folium.Map()
    folium_map.fit_bounds(bounds)

    # Add tracks as thin lines
    for segment in line_segments:
        folium.PolyLine(segment, color="blue", weight=1.5, opacity=0.7).add_to(folium_map)

    # Add heatmap layer
    heat_data = [[row['lat'], row['lon']] for index, row in data.iterrows()]
    HeatMap(heat_data).add_to(folium_map)

    # Add title to the map
    title = 'Map'
    if title_file and os.path.exists(title_file):
        with open(title_file, 'r') as f:
            title = f.read().strip()
    else:
        title = ', '.join(file_names)
    folium_map.get_root().html.add_child(folium.Element(f'<title>{title}</title>'))

    folium_map.save(output_file)

    # Save bounds to a pretty-printed JSON file
    with open(bounds_file, 'w') as f:
        json.dump({'bounds': bounds}, f, indent=4)

def create_screenshot(html_file, output_png):
    options = Options()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1280x800')
    options.add_argument('--remote-debugging-port=9222')
    options.add_argument('--disable-software-rasterizer')
    options.add_argument('--disable-features=VizDisplayCompositor')
    options.add_argument('--disable-features=NetworkService,NetworkServiceInProcess')

    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    driver.set_page_load_timeout(600)

    driver.save_screenshot(output_png)
    driver.quit()

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
        'output_png',
        type=str,
        nargs='?',
        default='/app/output/heatmap.png',
        help='Output PNG file for the screenshot (default: /app/output/heatmap.png)'
    )
    parser.add_argument(
        'bounds_file',
        type=str,
        nargs='?',
        default='/app/output/bounds.json',
        help='Output JSON file for the bounds (default: /app/output/bounds.json)'
    )
    parser.add_argument(
        'title_file',
        type=str,
        nargs='?',
        default='/app/output/title.txt',
        help='File containing the title for the HTML document (default: /app/output/title.txt)'
    )
    args = parser.parse_args()

    data, line_segments, file_names = read_gpx_files(args.directory)
    generate_heatmap(data, line_segments, args.output_html, args.bounds_file, args.title_file)
    # create_screenshot(args.output_html, args.output_png)
