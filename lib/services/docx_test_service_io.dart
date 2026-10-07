import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cleartec_docx_template/cleartec_docx_template.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// نسخة الموبايل/سطح المكتب: بتحفظ الملف مؤقتاً وتفتح شاشة المشاركة.
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

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/seerati_test_report.docx');
    await file.writeAsBytes(generated);

    await Share.shareXFiles([XFile(file.path)], text: 'اختبار قالب Word');
  }
}