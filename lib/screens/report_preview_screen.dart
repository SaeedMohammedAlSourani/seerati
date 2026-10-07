import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../localization/app_language.dart';
import '../localization/app_strings.dart';
import '../models/report_data.dart';
import '../services/reports_history_service.dart';
import '../services/word_report_service.dart';
import '../theme/app_theme.dart';

class ReportPreviewScreen extends StatefulWidget {
  final AppLanguage language;
  final ReportData report;
  final Uint8List? logoBytes;

  const ReportPreviewScreen({
    super.key,
    required this.language,
    required this.report,
    required this.logoBytes,
  });

  @override
  State<ReportPreviewScreen> createState() => _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends State<ReportPreviewScreen> {
  bool _isSaving = false;
  bool _savedInApp = false;

  AppStrings get t => AppStrings(widget.language);
  bool get _isArabic => widget.language == AppLanguage.ar;

  Future<void> _saveToDevice() async {
    setState(() => _isSaving = true);
    try {
      await WordReportService.buildAndShareReport(
        data: widget.report,
        logoBytes: widget.logoBytes,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _keepInApp() async {
    await ReportsHistoryService.save(widget.report);
    if (mounted) {
      setState(() => _savedInApp = true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.savedInAppMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final crossAlign = _isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = _isArabic ? TextAlign.right : TextAlign.left;

    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(t.previewTitle)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: crossAlign,
                    children: [
                      Text(
                        widget.report.title,
                        textAlign: textAlign,
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.accent),
                      ),
                      const SizedBox(height: 14),
                      ...widget.report.sections.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: crossAlign,
                          children: [
                            Text(s.heading,
                                textAlign: textAlign,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(s.body, textAlign: textAlign, style: const TextStyle(height: 1.6, fontSize: 13)),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveToDevice,
                  child: _isSaving
                      ? const SizedBox(
                      height: 18, width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(t.saveToDeviceButton),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _savedInApp ? null : _keepInApp,
                  child: Text(_savedInApp ? t.savedInAppMessage : t.keepInAppButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}