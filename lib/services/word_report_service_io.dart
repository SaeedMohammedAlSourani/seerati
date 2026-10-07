import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cleartec_docx_template/cleartec_docx_template.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/seerati_report.docx');
    await file.writeAsBytes(generated);

    await Share.shareXFiles([XFile(file.path)], text: data.title);
  }
}