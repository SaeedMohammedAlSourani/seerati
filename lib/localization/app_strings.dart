import 'app_language.dart';

/// كل نصوص الواجهة بلغتين، بدون الحاجة لمكتبة flutter_localizations
/// الثقيلة — مناسب لتطبيق بسيط بشاشة أو شاشتين.
class AppStrings {
  final AppLanguage language;
  const AppStrings(this.language);

  bool get _ar => language == AppLanguage.ar;

  String get appTitle => _ar ? 'سيرتي' : 'Seerati';

  String get subtitle => _ar
      ? 'الصق إعلان الوظيفة وسيرتك الحالية، ونعدّلها لتناسب الوظيفة'
      : "Paste the job posting and your current CV, and we'll tailor it to match the job";

  String get jobLabel => _ar ? '📋 إعلان الوظيفة' : '📋 Job Posting';
  String get jobHint =>
      _ar ? 'الصق هون نص إعلان الوظيفة كامل...' : 'Paste the full job posting here...';

  String get cvLabel => _ar ? '📄 سيرتك الذاتية الحالية' : '📄 Your Current CV';
  String get cvHint =>
      _ar ? 'الصق هون محتوى سيرتك الذاتية...' : 'Paste your current CV content here...';

  String get submitButton =>
      _ar ? '✨ عدّل السيرة حسب الوظيفة' : '✨ Tailor My CV';

  String get loadingText => _ar
      ? 'جاري تحليل الإعلان وتعديل السيرة...'
      : 'Analyzing the job and tailoring your CV...';

  String get resultTitle => _ar ? 'السيرة المعدّلة' : 'Tailored CV';
  String get summaryHeading => _ar ? 'الملخص المهني' : 'Professional Summary';
  String get experienceHeading => _ar ? 'الخبرات المهنية' : 'Experience';
  String get skillsHeading => _ar ? 'المهارات' : 'Skills';
  String get educationHeading => _ar ? 'التعليم' : 'Education';
  String get copyButton => _ar ? '📋 نسخ النص' : '📋 Copy Text';
  String get exportPdfButton => _ar ? '📄 تصدير PDF' : '📄 Export PDF';
  String get resetButton => _ar ? '↩ عدّل مرة ثانية' : '↩ Start Over';
  String get copiedMessage => _ar ? 'تم نسخ النص!' : 'Copied to clipboard!';
  String get pdfErrorMessage =>
      _ar ? 'تعذر إنشاء ملف PDF، حاول مرة ثانية' : 'Could not create the PDF, please try again';

  String get emptyFieldsError =>
      _ar ? 'الرجاء تعبئة الحقلين قبل المتابعة' : 'Please fill in both fields first';
  String get emptyResponseError =>
      _ar ? 'الرد فاضي، حاول مرة ثانية' : 'Got an empty response, please try again';
  String get rateLimitError =>
      _ar ? 'في ضغط كبير حالياً، جرب بعد شوي' : 'High demand right now, try again shortly';
  String get genericError =>
      _ar ? 'صار خطأ، حاول مرة ثانية' : 'Something went wrong, please try again';
  String get connectionError => _ar
      ? 'تأكد من الاتصال بالإنترنت وحاول مرة ثانية'
      : 'Check your internet connection and try again';
}