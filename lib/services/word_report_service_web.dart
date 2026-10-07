import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cleartec_docx_template/cleartec_docx_template.dart';
import '../models/report_data.dart';

class WordReportService {
  static Future<void> buildAndShareReport({
    required ReportData data,
    Uint8List? logoBytes,
  }) async {
    final templateData = await rootBundle.load('assets/templates/template_report.docx');
    final docx = await DocxTemplate.fromBytes(templateData.buffer.asUint8List());

    final content = Content();
    content.add(TextContent('title', data.title));
    content.add(TextContent('body', data.toTemplateBody()));
    if (logoBytes != null) {
      content.add(ImageContent('logo', logoBytes));
    }

    final generated = await docx.generate(content);
    if (generated == null) {
      throw Exception('فشل توليد ملف التقرير');
    }

    final blob = html.Blob(
      [generated],
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    );
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'seerati_report.docx')
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}