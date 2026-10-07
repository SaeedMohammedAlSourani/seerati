// اختبار بسيط للتأكد إن التطبيق بيفتح على الشاشة الرئيسية الجديدة بدون كراش

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seerati/main.dart';

void main() {
  testWidgets('يفتح التطبيق ويظهر شاشة سيرتي الرئيسية بمربعيها',
          (WidgetTester tester) async {
        await tester.pumpWidget(const SeeratiApp());

        expect(find.text('سيرتي'), findsOneWidget);
        expect(find.text('📄 السيرة الذاتية'), findsOneWidget);
        expect(find.text('📊 التقارير'), findsOneWidget);
      });
}