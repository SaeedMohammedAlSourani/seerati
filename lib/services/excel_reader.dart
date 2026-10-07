import 'dart:typed_data';
import 'package:excel/excel.dart';

/// يحوّل محتوى ملف إكسل لنص بسيط (شبيه بـ CSV) نقدر نبعته للذكاء الاصطناعي.
String excelBytesToText(Uint8List bytes) {
  final excel = Excel.decodeBytes(bytes);
  final buffer = StringBuffer();

  for (final sheetName in excel.tables.keys) {
    final sheet = excel.tables[sheetName];
    if (sheet == null) continue;
    buffer.writeln('# $sheetName');
    for (final row in sheet.rows) {
      final cells = row.map((cell) => cell?.value?.toString() ?? '').join(' | ');
      if (cells.trim().isNotEmpty) buffer.writeln(cells);
    }
    buffer.writeln();
  }

  return buffer.toString().trim();
}