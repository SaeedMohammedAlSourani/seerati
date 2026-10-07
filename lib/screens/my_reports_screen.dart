import 'package:flutter/material.dart';
import '../localization/app_language.dart';
import '../localization/app_strings.dart';
import '../services/reports_history_service.dart';
import '../services/word_report_service.dart';
import '../theme/app_theme.dart';
import 'report_preview_screen.dart';

class MyReportsScreen extends StatefulWidget {
  final AppLanguage language;
  const MyReportsScreen({super.key, required this.language});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  List<SavedReport> _reports = [];
  bool _loading = true;

  AppStrings get t => AppStrings(widget.language);
  bool get _isArabic => widget.language == AppLanguage.ar;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final reports = await ReportsHistoryService.loadAll();
    if (mounted) setState(() {
      _reports = reports;
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    await ReportsHistoryService.delete(id);
    _load();
  }

  Future<void> _export(SavedReport saved) async {
    await WordReportService.buildAndShareReport(data: saved.report, logoBytes: null);
  }

  String _formatDate(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(t.myReportsTitle)),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _reports.isEmpty
              ? Center(
            child: Text(t.myReportsEmpty,
                style: const TextStyle(color: AppColors.subtitle, fontSize: 14)),
          )
              : ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: _reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final saved = _reports[i];
              return Material(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportPreviewScreen(
                        language: widget.language,
                        report: saved.report,
                        logoBytes: null,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(saved.report.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                              const SizedBox(height: 4),
                              Text(_formatDate(saved.savedAt),
                                  style: const TextStyle(fontSize: 11, color: AppColors.subtitle)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.ios_share, size: 20, color: AppColors.accent),
                          tooltip: t.exportFromHere,
                          onPressed: () => _export(saved),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                          tooltip: t.deleteReport,
                          onPressed: () => _delete(saved.id),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}