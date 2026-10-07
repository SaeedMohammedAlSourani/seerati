import 'dart:convert';
import 'dart:io';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class GeoJsonExportService {
  static Future<void> exportPolygon(List<LatLng> points) async {
    final coords = points.map((p) => [p.longitude, p.latitude]).toList();
    coords.add(coords.first); // إغلاق المضلع (أول نقطة = آخر نقطة) حسب معيار GeoJSON
    final geoJson = {
      'type': 'Feature',
      'properties': {},
      'geometry': {
        'type': 'Polygon',
        'coordinates': [coords],
      },
    };
    final text = jsonEncode(geoJson);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/seerati_boundary.geojson');
    await file.writeAsString(text);

    await Share.shareXFiles([XFile(file.path)], text: 'حدود مُصدَّرة من سيرتي');
  }
}