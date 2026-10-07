import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/report_data.dart';

class SavedReport {
  final String id;
  final ReportData report;
  final DateTime savedAt;

  SavedReport({required this.id, required this.report, required this.savedAt});

  Map<String, dynamic> toJson() => {
    'id': id,
    'report': report.toJson(),
    'savedAt': savedAt.toIso8601String(),
  };

  factory SavedReport.fromJson(Map<String, dynamic> json) => SavedReport(
    id: json['id'] as String,
    report: ReportData.fromJson(json['report'] as Map<String, dynamic>),
    savedAt: DateTime.parse(json['savedAt'] as String),
  );
}

class ReportsHistoryService {
  static const _key = 'saved_reports';

  static Future<List<SavedReport>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) => SavedReport.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList()
        .reversed
        .toList(); // الأحدث أول
  }

  static Future<void> save(ReportData report) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final saved = SavedReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      report: report,
      savedAt: DateTime.now(),
    );
    raw.add(jsonEncode(saved.toJson()));
    await prefs.setStringList(_key, raw);
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((e) => (jsonDecode(e) as Map<String, dynamic>)['id'] == id);
    await prefs.setStringList(_key, raw);
  }
}