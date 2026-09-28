// اختبار بسيط للتأكد إن التطبيق بيفتح بدون كراش
// (استبدل اختبار العداد الافتراضي اللي كان موجود بالقالب، لأنه ما إلو علاقة بتطبيقنا)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seerati/main.dart';

void main() {
  testWidgets('يفتح التطبيق ويظهر شاشة سيرتي الرئيسية',
          (WidgetTester tester) async {
        await tester.pumpWidget(const SeeratiApp());

        // نتأكد إن عنوان الشاشة الرئيسية "سيرتي" ظاهر
        expect(find.text('سيرتي'), findsOneWidget);

        // نتأكد إن زر التعديل موجود
        expect(find.text('✨ عدّل السيرة حسب الوظيفة'), findsOneWidget);
      });
}