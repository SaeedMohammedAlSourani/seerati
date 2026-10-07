import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../localization/app_language.dart';
import '../localization/app_strings.dart';
import '../services/geojson_export_service.dart';
import '../services/saved_points_service.dart';
import '../theme/app_theme.dart';
import 'saved_points_screen.dart';

class MapScreen extends StatefulWidget {
  final AppLanguage language;
  const MapScreen({super.key, required this.language});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  Position? _position;
  bool _loading = true;
  String? _error;
  bool _drawMode = false;
  final List<LatLng> _polygonPoints = [];
  bool _isTracking = false;
  StreamSubscription<Position>? _positionStream;

  AppStrings get t => AppStrings(widget.language);
  bool get _isArabic => widget.language == AppLanguage.ar;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        setState(() {
          _error = t.locationServiceOffError;
          _loading = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _error = t.locationDeniedError;
          _loading = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _position = pos;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = t.locationDeniedError;
        _loading = false;
      });
    }
  }

  void _onMapTap(TapPosition tapPos, LatLng point) {
    if (_drawMode) {
      setState(() => _polygonPoints.add(point));
    }
  }

  void _toggleDrawMode() {
    setState(() => _drawMode = !_drawMode);
  }

  void _clearDrawing() {
    setState(() => _polygonPoints.clear());
  }

  void _undoLastPoint() {
    if (_polygonPoints.isNotEmpty) {
      setState(() => _polygonPoints.removeLast());
    }
  }

  void _toggleTracking() {
    if (_isTracking) {
      _positionStream?.cancel();
      setState(() => _isTracking = false);
      return;
    }
    setState(() => _isTracking = true);
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
    ).listen((pos) {
      setState(() => _position = pos);
      _mapController.move(LatLng(pos.latitude, pos.longitude), _mapController.camera.zoom);
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _exportBoundary() async {
    if (_polygonPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.needAtLeast3Points)));
      return;
    }
    await GeoJsonExportService.exportPolygon(_polygonPoints);
  }

  Future<void> _copyLocation() async {
    if (_position == null) return;
    final text = '${_position!.latitude}, ${_position!.longitude}';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.locationCopied)));
    }
  }

  Future<void> _savePoint() async {
    if (_position == null) return;
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(hintText: t.pointNameHint),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
            child: Text(t.save),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await SavedPointsService.save(name, _position!.latitude, _position!.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.mapCardTitle.replaceAll('🗺️ ', '')),
          actions: [
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              tooltip: t.myPointsTitle,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SavedPointsScreen(language: widget.language)),
              ),
            ),
          ],
        ),
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(t.locatingMessage, style: const TextStyle(color: AppColors.subtitle)),
          ],
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 14),
              ElevatedButton(onPressed: _initLocation, child: const Icon(Icons.refresh)),
            ],
          ),
        ),
      );
    }

    final center = LatLng(_position!.latitude, _position!.longitude);

    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 16,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.seerati',
              ),
              if (_polygonPoints.length >= 2)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _polygonPoints,
                      color: AppColors.accent.withOpacity(0.25),
                      borderColor: AppColors.accent,
                      borderStrokeWidth: 3,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 24,
                    height: 24,
                    child: const Icon(Icons.my_location, color: Colors.blue, size: 24),
                  ),
                  ..._polygonPoints.map(
                        (p) => Marker(
                      point: p,
                      width: 14,
                      height: 14,
                      child: Container(
                        decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _toggleDrawMode,
                      child: Text(_drawMode ? t.drawModeStop : t.drawModeStart),
                    ),
                  ),
                  if (_drawMode && _polygonPoints.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _undoLastPoint,
                      icon: const Icon(Icons.undo, color: AppColors.accent),
                      tooltip: t.undoPointButton,
                    ),
                  ],
                  if (_polygonPoints.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: _clearDrawing,
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      tooltip: t.clearDrawingButton,
                    ),
                  ],
                ],
              ),
              if (_polygonPoints.length >= 3) ...[
                const SizedBox(height: 8),
                ElevatedButton(onPressed: _exportBoundary, child: Text(t.exportBoundaryButton)),
              ],
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _toggleTracking,
                style: _isTracking
                    ? OutlinedButton.styleFrom(backgroundColor: AppColors.accent.withOpacity(0.1))
                    : null,
                child: Text(_isTracking ? t.stopTrackingButton : t.startTrackingButton),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(onPressed: _savePoint, child: Text(t.savePointButton)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(onPressed: _copyLocation, child: Text(t.copyLocationButton)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}