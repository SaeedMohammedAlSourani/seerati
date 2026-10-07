import 'dart:convert';
import 'dart:html' as html;
import 'package:latlong2/latlong.dart';

class GeoJsonExportService {
  static Future<void> exportPolygon(List<LatLng> points) async {
    final coords = points.map((p) => [p.longitude, p.latitude]).toList();
    coords.add(coords.first);
    final geoJson = {
      'type': 'Feature',
      'properties': {},
      'geometry': {
        'type': 'Polygon',
        'coordinates': [coords],
      },
    };
    final text = jsonEncode(geoJson);

    final blob = html.Blob([text], 'application/geo+json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'seerati_boundary.geojson')
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}