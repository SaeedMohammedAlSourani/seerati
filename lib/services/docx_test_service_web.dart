import 'dart:html' as html;
import 'package:flutter/services.dart' show rootBundle;
import 'package:cleartec_docx_template/cleartec_docx_template.dart';

/// نسخة الويب: بتنزّل الملف مباشرة عن طريق المتصفح (بدون path_provider/share_plus
/// لأنهم غير مدعومين على الويب).
class DocxTestService {
  static Future<void> fillAndShareTestTemplate() async {
    final data = await rootBundle.load('assets/templates/template_test.docx');
    final bytes = data.buffer.asUint8List();
    final docx = await DocxTemplate.fromBytes(bytes);

    final content = Content();
    content.add(TextContent('title', 'تقرير تجريبي — اختبار القالب'));

    final generated = await docx.generate(content);
    if (generated == null) {
      throw Exception('فشل توليد الملف');
    }

    final blob = html.Blob(
      [generated],
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    );
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'seerati_test_report.docx')
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}