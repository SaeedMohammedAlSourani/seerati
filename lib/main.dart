import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SeeratiApp());
}

class SeeratiApp extends StatelessWidget {
  const SeeratiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سيرتي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}