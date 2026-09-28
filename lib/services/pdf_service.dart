import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/resume_data.dart';

/// نسخة PDF متوافقة مع أنظمة تتبع المتقدمين (ATS): تصميم بسيط أبيض وأسود،
/// بدون ألوان أو أشكال مزخرفة، عمود واحد، وعناوين وبنود واضحة نصياً.
class PdfService {
  static Future<Uint8List> buildResumePdf(
      ResumeData resume, {
        required bool isArabic,
      }) async {
    final regularFontData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    final boldFontData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
    final regularFont = pw.Font.ttf(regularFontData);
    final boldFont = pw.Font.ttf(boldFontData);

    const black = PdfColors.black;
    final subtitleColor = PdfColor.fromInt(0xFF444444);
    final lineColor = PdfColor.fromInt(0xFF999999);

    final direction = isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final align = isArabic ? pw.TextAlign.right : pw.TextAlign.left;
    final crossAlign =
    isArabic ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start;

    String sectionTitle(String ar, String en) => isArabic ? ar : en;

    // عنوان قسم: نص عريض بخط أكبر شوي + خط سفلي رفيع بدل اللون، ATS-friendly
    pw.Widget heading(String text) => pw.Column(
      crossAxisAlignment: crossAlign,
      children: [
        pw.Text(
          text,
          style: pw.TextStyle(font: boldFont, fontSize: 13, color: black),
          textAlign: align,
        ),
        pw.SizedBox(height: 3),
        pw.Container(height: 0.8, width: double.infinity, color: lineColor),
        pw.SizedBox(height: 6),
      ],
    );

    // بند (نقطة) نصي بسيط بدل الأشكال/الفقاعات
    pw.Widget bulletLine(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('•  ', style: pw.TextStyle(font: regularFont, fontSize: 10, color: black)),
          pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(font: regularFont, fontSize: 10, lineSpacing: 2, color: black),
              textAlign: align,
            ),
          ),
        ],
      ),
    );

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: direction,
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        margin: const pw.EdgeInsets.all(36),
        build: (context) => [
          // الاسم وبيانات التواصل
          pw.Column(
            crossAxisAlignment: crossAlign,
            children: [
              pw.Text(
                resume.name,
                style: pw.TextStyle(font: boldFont, fontSize: 20, color: black),
                textAlign: align,
              ),
              if (resume.contact.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  resume.contact,
                  style: pw.TextStyle(font: regularFont, fontSize: 10.5, color: subtitleColor),
                  textAlign: align,
                ),
              ],
              pw.SizedBox(height: 12),
            ],
          ),

          // الملخص المهني
          if (resume.summary.isNotEmpty) ...[
            heading(sectionTitle('الملخص المهني', 'Professional Summary')),
            pw.Text(
              resume.summary,
              style: pw.TextStyle(font: regularFont, fontSize: 10.5, lineSpacing: 3, color: black),
              textAlign: align,
            ),
            pw.SizedBox(height: 14),
          ],

          // الخبرات
          if (resume.experience.isNotEmpty) ...[
            heading(sectionTitle('الخبرات المهنية', 'Experience')),
            ...resume.experience.map(
                  (exp) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Column(
                  crossAxisAlignment: crossAlign,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          '${exp.title}${exp.company.isNotEmpty ? " — ${exp.company}" : ""}',
                          style: pw.TextStyle(font: boldFont, fontSize: 11, color: black),
                        ),
                        if (exp.dateRange.isNotEmpty)
                          pw.Text(
                            exp.dateRange,
                            style: pw.TextStyle(font: regularFont, fontSize: 9.5, color: subtitleColor),
                          ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    ...exp.bullets.map(bulletLine),
                  ],
                ),
              ),
            ),
          ],

          // المهارات — بنود نصية بسيطة بدل الفقاعات، متوافقة مع ATS
          if (resume.skills.isNotEmpty) ...[
            heading(sectionTitle('المهارات', 'Skills')),
            ...resume.skills.map(bulletLine),
            pw.SizedBox(height: 10),
          ],

          // التعليم
          if (resume.education.isNotEmpty) ...[
            heading(sectionTitle('التعليم', 'Education')),
            ...resume.education.map(
                  (edu) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '${edu.degree}${edu.institution.isNotEmpty ? " — ${edu.institution}" : ""}',
                      style: pw.TextStyle(font: regularFont, fontSize: 10.5, color: black),
                    ),
                    if (edu.dateRange.isNotEmpty)
                      pw.Text(
                        edu.dateRange,
                        style: pw.TextStyle(font: regularFont, fontSize: 9.5, color: subtitleColor),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }

  /// يفتح شاشة المشاركة/الحفظ الأصلية بالنظام (تعمل على أندرويد وiOS)
  static Future<void> shareResumePdf(Uint8List bytes, {required String fileName}) async {
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }
}