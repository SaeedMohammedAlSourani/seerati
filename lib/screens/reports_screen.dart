import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../localization/app_language.dart';
import '../localization/app_strings.dart';
import '../services/excel_reader.dart';
import '../services/report_api_service.dart';
import '../theme/app_theme.dart';
import 'my_reports_screen.dart';
import 'report_preview_screen.dart';

class ReportsScreen extends StatefulWidget {
  final AppLanguage language;
  const ReportsScreen({super.key, required this.language});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _notesController = TextEditingController();
  final _picker = ImagePicker();

  List<XFile> _tableImages = [];
  PlatformFile? _excelFile;
  XFile? _logoImage;
  String? _error;
  bool _isGenerating = false;

  AppStrings get t => AppStrings(widget.language);
  bool get _isArabic => widget.language == AppLanguage.ar;

  Future<void> _pickTableImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _tableImages = images;
        _error = null;
      });
    }
  }

  Future<void> _pickExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _excelFile = result.files.single;
        _error = null;
      });
    }
  }

  Future<void> _pickLogo() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _logoImage = image);
    }
  }

  String _mimeTypeFor(XFile file) {
    if (file.mimeType != null) return file.mimeType!;
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> _generate() async {
    if (_tableImages.isEmpty && _excelFile == null) {
      setState(() => _error = t.noDataError);
      return;
    }

    setState(() {
      _isGenerating = true;
      _error = null;
    });

    try {
      // 1. جهّز الصور كـ base64
      final images = <Map<String, String>>[];
      for (final img in _tableImages) {
        final bytes = await img.readAsBytes();
        images.add({'mimeType': _mimeTypeFor(img), 'data': base64Encode(bytes)});
      }

      // 2. اقرأ بيانات الإكسل كنص (لو موجود)
      String excelText = '';
      if (_excelFile != null && _excelFile!.bytes != null) {
        excelText = excelBytesToText(_excelFile!.bytes!);
      }

      // 3. اطلب من الذكاء الاصطناعي يبني التقرير
      final report = await ReportApiService.generateReport(
        images: images,
        excelText: excelText,
        notes: _notesController.text.trim(),
        language: widget.language,
      );

      // 4. جهّز الشعار (لو موجود) وروح لشاشة المعاينة
      final logoBytes = _logoImage != null ? await _logoImage!.readAsBytes() : null;
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportPreviewScreen(
              language: widget.language,
              report: report,
              logoBytes: logoBytes,
            ),
          ),
        );
      }
    } on ReportApiException catch (e) {
      String msg;
      switch (e.type) {
        case ReportErrorType.noData:
          msg = t.noDataError;
          break;
        case ReportErrorType.rateLimited:
          msg = t.reportRateLimitError;
          break;
        case ReportErrorType.network:
          msg = t.reportConnectionError;
          break;
        default:
          msg = t.reportServerError;
      }
      if (mounted) setState(() => _error = msg);
    } catch (e) {
      if (mounted) setState(() => _error = t.reportServerError);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.reportsCardTitle.replaceAll('📊 ', '')),
          actions: [
            IconButton(
              icon: const Icon(Icons.folder_open),
              tooltip: t.myReportsTitle,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MyReportsScreen(language: widget.language)),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t.reportsSubtitle, style: const TextStyle(color: AppColors.subtitle, fontSize: 13)),
                const SizedBox(height: 20),

                _PickerCard(
                  label: t.pickImagesButton,
                  detail: _tableImages.isNotEmpty ? '${_tableImages.length} ${t.imagesSelected}' : null,
                  onTap: _isGenerating ? null : _pickTableImages,
                ),
                const SizedBox(height: 10),
                _PickerCard(
                  label: t.pickExcelButton,
                  detail: _excelFile != null ? _excelFile!.name : null,
                  onTap: _isGenerating ? null : _pickExcelFile,
                ),
                const SizedBox(height: 10),
                _PickerCard(
                  label: t.pickLogoButton,
                  detail: _logoImage != null ? t.logoSelected : null,
                  onTap: _isGenerating ? null : _pickLogo,
                ),

                const SizedBox(height: 18),
                Text(t.notesLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: _notesController,
                  minLines: 3,
                  maxLines: 6,
                  enabled: !_isGenerating,
                  decoration: InputDecoration(hintText: t.notesHint),
                ),

                const SizedBox(height: 20),
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                  const SizedBox(height: 10),
                ],
                ElevatedButton(
                  onPressed: _isGenerating ? null : _generate,
                  child: _isGenerating
                      ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(t.generateReportButton),
                ),
                if (_isGenerating) ...[
                  const SizedBox(height: 10),
                  Text(t.generatingReport,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: AppColors.subtitle)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerCard extends StatelessWidget {
  final String label;
  final String? detail;
  final VoidCallback? onTap;

  const _PickerCard({required this.label, required this.detail, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
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
                    Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    if (detail != null) ...[
                      const SizedBox(height: 4),
                      Text(detail!, style: const TextStyle(fontSize: 11.5, color: AppColors.subtitle)),
                    ],
                  ],
                ),
              ),
              if (detail != null)
                const Icon(Icons.check_circle, color: AppColors.accent, size: 20)
              else
                const Icon(Icons.chevron_right, color: AppColors.subtitle, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}