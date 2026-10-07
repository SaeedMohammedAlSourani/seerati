import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'localization/app_language.dart';
import 'screens/home_menu_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SeeratiApp());
}

class SeeratiApp extends StatefulWidget {
  const SeeratiApp({super.key});

  @override
  State<SeeratiApp> createState() => _SeeratiAppState();
}

class _SeeratiAppState extends State<SeeratiApp> {
  AppLanguage _language = AppLanguage.ar;

  void _toggleLanguage() {
    setState(() {
      _language = _language == AppLanguage.ar ? AppLanguage.en : AppLanguage.ar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سيرتي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: HomeMenuScreen(
        language: _language,
        onToggleLanguage: _toggleLanguage,
      ),
    );
  }
}