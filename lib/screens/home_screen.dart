import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../localization/app_language.dart';
import '../localization/app_strings.dart';
import '../models/resume_data.dart';
import '../services/api_service.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/labeled_text_field.dart';

enum ViewState { idle, loading, result, error }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _jobController = TextEditingController();
  final _cvController = TextEditingController();

  AppLanguage _language = AppLanguage.ar;
  ViewState _state = ViewState.idle;
  ResumeData? _resume;
  ApiErrorType? _errorType;
  bool _isExportingPdf = false;

  AppStrings get t => AppStrings(_language);
  bool get _isArabic => _language == AppLanguage.ar;

  void _toggleLanguage() {
    setState(() {
      _language = _language == AppLanguage.ar ? AppLanguage.en : AppLanguage.ar;
    });
  }

  Future<void> _submit() async {
    if (_jobController.text.trim().isEmpty || _cvController.text.trim().isEmpty) {
      setState(() {
        _state = ViewState.error;
        _errorType = null;
      });
      return;
    }

    setState(() => _state = ViewState.loading);

    try {
      final resume = await ApiService.tailorResume(
        jobPosting: _jobController.text.trim(),
        currentCv: _cvController.text.trim(),
        language: _language,
      );
      setState(() {
        _resume = resume;
        _state = ViewState.result;
      });
    } on ApiException catch (e) {
      setState(() {
        _state = ViewState.error;
        _errorType = e.type;
      });
    }
  }

  String _errorMessage() {
    if (_errorType == null) return t.emptyFieldsError;
    switch (_errorType!) {
      case ApiErrorType.emptyResponse:
        return t.emptyResponseError;
      case ApiErrorType.rateLimited:
        return t.rateLimitError;
      case ApiErrorType.serverError:
        return t.genericError;
      case ApiErrorType.network:
        return t.connectionError;
    }
  }

  void _reset() => setState(() => _state = ViewState.idle);

  void _copyResult() {
    if (_resume == null) return;
    Clipboard.setData(ClipboardData(text: _resume!.toPlainText(isArabic: _isArabic)));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.copiedMessage)));
  }

  Future<void> _exportPdf() async {
    if (_resume == null || _isExportingPdf) return;
    setState(() => _isExportingPdf = true);
    try {
      final bytes = await PdfService.buildResumePdf(_resume!, isArabic: _isArabic);
      await PdfService.shareResumePdf(bytes, fileName: 'seerati_resume.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.pdfErrorMessage)));
      }
    } finally {
      if (mounted) setState(() => _isExportingPdf = false);
    }
  }

  @override
  void dispose() {
    _jobController.dispose();
    _cvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = _isArabic;
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.appTitle),
          actions: [
            TextButton(
              onPressed: _toggleLanguage,
              child: Text(isRtl ? 'English' : 'عربي', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: _state == ViewState.result ? _buildResultView() : _buildInputView(),
          ),
        ),
      ),
    );
  }

  Widget _buildInputView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.subtitle, style: const TextStyle(color: AppColors.subtitle, fontSize: 13)),
        const SizedBox(height: 18),
        LabeledTextField(label: t.jobLabel, hint: t.jobHint, controller: _jobController),
        const SizedBox(height: 16),
        LabeledTextField(label: t.cvLabel, hint: t.cvHint, controller: _cvController),
        const SizedBox(height: 20),
        if (_state == ViewState.error) ...[
          Text(_errorMessage(), style: const TextStyle(color: AppColors.error, fontSize: 13)),
          const SizedBox(height: 10),
        ],
        ElevatedButton(
          onPressed: _state == ViewState.loading ? null : _submit,
          child: _state == ViewState.loading
              ? const SizedBox(
            height: 20, width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
              : Text(t.submitButton),
        ),
        if (_state == ViewState.loading) ...[
          const SizedBox(height: 20),
          _buildLoadingSkeleton(),
        ],
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: [
        Text(t.loadingText, style: const TextStyle(color: AppColors.subtitle, fontSize: 13)),
        const SizedBox(height: 12),
        Shimmer.fromColors(
          baseColor: AppColors.line,
          highlightColor: AppColors.background,
          child: Column(
            children: List.generate(
              4,
                  (i) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                height: 14,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeading(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.accent)),
  );

  Widget _buildResultView() {
    final r = _resume!;
    final crossAlign = _isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final textAlign = _isArabic ? TextAlign.right : TextAlign.left;

    return Column(
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
              Text(r.name, textAlign: textAlign, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accent)),
              if (r.contact.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(r.contact, textAlign: textAlign, style: const TextStyle(fontSize: 12, color: AppColors.subtitle)),
              ],

              if (r.summary.isNotEmpty) ...[
                _sectionHeading(t.summaryHeading),
                Text(r.summary, textAlign: textAlign, style: const TextStyle(height: 1.6, fontSize: 13)),
              ],

              if (r.experience.isNotEmpty) ...[
                _sectionHeading(t.experienceHeading),
                ...r.experience.map((exp) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: crossAlign,
                    children: [
                      Text(
                        exp.company.isNotEmpty ? '${exp.title} — ${exp.company}' : exp.title,
                        textAlign: textAlign,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      if (exp.dateRange.isNotEmpty)
                        Text(exp.dateRange, textAlign: textAlign, style: const TextStyle(fontSize: 11, color: AppColors.subtitle)),
                      const SizedBox(height: 4),
                      ...exp.bullets.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text('• $b', textAlign: textAlign, style: const TextStyle(fontSize: 12.5, height: 1.5)),
                      )),
                    ],
                  ),
                )),
              ],

              if (r.skills.isNotEmpty) ...[
                _sectionHeading(t.skillsHeading),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: _isArabic ? WrapAlignment.end : WrapAlignment.start,
                  children: r.skills
                      .map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Text(s, style: const TextStyle(fontSize: 11.5)),
                  ))
                      .toList(),
                ),
              ],

              if (r.education.isNotEmpty) ...[
                _sectionHeading(t.educationHeading),
                ...r.education.map((edu) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    crossAxisAlignment: crossAlign,
                    children: [
                      Text(
                        edu.institution.isNotEmpty ? '${edu.degree} — ${edu.institution}' : edu.degree,
                        textAlign: textAlign,
                        style: const TextStyle(fontSize: 12.5),
                      ),
                      if (edu.dateRange.isNotEmpty)
                        Text(edu.dateRange, textAlign: textAlign, style: const TextStyle(fontSize: 11, color: AppColors.subtitle)),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: OutlinedButton(onPressed: _copyResult, child: Text(t.copyButton))),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: _isExportingPdf ? null : _exportPdf,
                child: _isExportingPdf
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(t.exportPdfButton),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        OutlinedButton(onPressed: _reset, child: Text(t.resetButton)),
      ],
    );
  }
}