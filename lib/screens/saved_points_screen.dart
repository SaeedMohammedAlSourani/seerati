import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../localization/app_language.dart';
import '../localization/app_strings.dart';
import '../models/saved_point.dart';
import '../services/saved_points_service.dart';
import '../theme/app_theme.dart';

class SavedPointsScreen extends StatefulWidget {
  final AppLanguage language;
  const SavedPointsScreen({super.key, required this.language});

  @override
  State<SavedPointsScreen> createState() => _SavedPointsScreenState();
}

class _SavedPointsScreenState extends State<SavedPointsScreen> {
  List<SavedPoint> _points = [];
  bool _loading = true;

  AppStrings get t => AppStrings(widget.language);
  bool get _isArabic => widget.language == AppLanguage.ar;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final points = await SavedPointsService.loadAll();
    if (mounted) setState(() {
      _points = points;
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    await SavedPointsService.delete(id);
    _load();
  }

  void _copy(double lat, double lng) {
    Clipboard.setData(ClipboardData(text: '$lat, $lng'));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.locationCopied)));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(t.myPointsTitle)),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _points.isEmpty
              ? Center(child: Text(t.noPointsYet, style: const TextStyle(color: AppColors.subtitle)))
              : ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: _points.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final p = _points[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          const SizedBox(height: 4),
                          Text('${p.lat}, ${p.lng}',
                              style: const TextStyle(fontSize: 11, color: AppColors.subtitle)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18, color: AppColors.accent),
                      onPressed: () => _copy(p.lat, p.lng),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      onPressed: () => _delete(p.id),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}