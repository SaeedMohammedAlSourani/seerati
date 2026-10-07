import 'package:flutter/material.dart';
import '../localization/app_language.dart';
import '../localization/app_strings.dart';
import '../theme/app_theme.dart';
import 'cv_screen.dart';
import 'map_screen.dart';
import 'reports_screen.dart';
import 'scanner_screen.dart';

class HomeMenuScreen extends StatelessWidget {
  final AppLanguage language;
  final VoidCallback onToggleLanguage;

  const HomeMenuScreen({
    super.key,
    required this.language,
    required this.onToggleLanguage,
  });

  AppStrings get t => AppStrings(language);
  bool get _isArabic => language == AppLanguage.ar;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.appTitle),
          actions: [
            TextButton(
              onPressed: onToggleLanguage,
              child: Text(
                _isArabic ? 'English' : 'عربي',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.homeSubtitle,
                  style: const TextStyle(color: AppColors.subtitle, fontSize: 13),
                ),
                const SizedBox(height: 20),
                _FeatureCard(
                  title: t.cvCardTitle,
                  subtitle: t.cvCardSubtitle,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CvScreen(language: language)),
                  ),
                ),
                const SizedBox(height: 14),
                _FeatureCard(
                  title: t.reportsCardTitle,
                  subtitle: t.reportsCardSubtitle,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReportsScreen(language: language)),
                  ),
                ),
                const SizedBox(height: 14),
                _FeatureCard(
                  title: t.scannerCardTitle,
                  subtitle: t.scannerCardSubtitle,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ScannerScreen(language: language)),
                  ),
                ),
                const SizedBox(height: 14),
                _FeatureCard(
                  title: t.mapCardTitle,
                  subtitle: t.mapCardSubtitle,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MapScreen(language: language)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.subtitle)),
            ],
          ),
        ),
      ),
    );
  }
}