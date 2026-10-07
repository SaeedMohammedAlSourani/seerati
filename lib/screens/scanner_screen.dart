import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../localization/app_language.dart';
import '../localization/app_strings.dart';
import '../theme/app_theme.dart';

class ScannerScreen extends StatefulWidget {
  final AppLanguage language;
  const ScannerScreen({super.key, required this.language});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final List<String> _pagePaths = [];
  bool _isExporting = false;
  String? _error;

  AppStrings get t => AppStrings(widget.language);
  bool get _isArabic => widget.language == AppLanguage.ar;

  Future<void> _scanNewPage() async {
    setState(() => _error = null);
    try {
      final paths = await CunningDocumentScanner.getPictures(
        scannerSource: ScannerSource.cameraAndGallery,
      );
      if (paths != null && paths.isNotEmpty) {
        setState(() => _pagePaths.addAll(paths));
      }
    } catch (e) {
      setState(() => _error = t.scanError);
    }
  }

  void _removePage(int index) {
    setState(() => _pagePaths.removeAt(index));
  }

  Future<void> _exportPdf() async {
    if (_pagePaths.isEmpty) return;
    setState(() => _isExporting = true);
    try {
      final doc = pw.Document();
      for (final path in _pagePaths) {
        final bytes = await File(path).readAsBytes();
        final image = pw.MemoryImage(bytes);
        doc.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.zero,
            build: (context) => pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
          ),
        );
      }
      final bytes = await doc.save();
      await Printing.sharePdf(bytes: bytes, filename: 'seerati_scan.pdf');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(t.scannerCardTitle.replaceAll('📑 ', ''))),
        body: SafeArea(
          child: kIsWeb ? _buildWebUnsupported() : _buildScannerBody(),
        ),
      ),
    );
  }

  Widget _buildWebUnsupported() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          t.scannerWebUnsupported,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.subtitle, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildScannerBody() {
    return Column(
      children: [
        Expanded(
          child: _pagePaths.isEmpty
              ? Center(
            child: Text(t.noPagesYet,
                style: const TextStyle(color: AppColors.subtitle, fontSize: 14)),
          )
              : GridView.builder(
            padding: const EdgeInsets.all(14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.7,
            ),
            itemCount: _pagePaths.length,
            itemBuilder: (context, i) => Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(_pagePaths[i]), fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () => _removePage(i),
                    child: const CircleAvatar(
                      radius: 11,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  left: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                const SizedBox(height: 10),
              ],
              OutlinedButton(onPressed: _scanNewPage, child: Text(t.scanNewPageButton)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: (_pagePaths.isEmpty || _isExporting) ? null : _exportPdf,
                child: _isExporting
                    ? const SizedBox(
                    height: 18, width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(t.exportScanPdfButton),
              ),
            ],
          ),
        ),
      ],
    );
  }
}