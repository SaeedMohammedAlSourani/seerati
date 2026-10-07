import 'app_language.dart';

/// كل نصوص الواجهة بلغتين، بدون الحاجة لمكتبة flutter_localizations
/// الثقيلة — مناسب لتطبيق بسيط بشاشة أو شاشتين.
class AppStrings {
  final AppLanguage language;
  const AppStrings(this.language);

  bool get _ar => language == AppLanguage.ar;

  String get appTitle => _ar ? 'سيرتي' : 'Seerati';

  String get homeSubtitle =>
      _ar ? 'اختر الأداة اللي بدك تستخدمها' : 'Choose the tool you want to use';
  String get cvCardTitle => _ar ? '📄 السيرة الذاتية' : '📄 Resume';
  String get cvCardSubtitle =>
      _ar ? 'عدّل سيرتك حسب أي إعلان وظيفة' : 'Tailor your CV to any job posting';
  String get reportsCardTitle => _ar ? '📊 التقارير' : '📊 Reports';
  String get reportsCardSubtitle =>
      _ar ? 'حوّل صور الجداول لملف إكسل' : 'Turn table photos into an Excel file';
  String get comingSoon => _ar ? 'قريباً' : 'Coming soon';
  String get comingSoonDetail => _ar
      ? 'هاي الميزة لسا قيد التطوير، رح تكون جاهزة قريباً'
      : 'This feature is still being built and will be ready soon';

  // شاشة التقارير
  String get reportsSubtitle => _ar
      ? 'أضف صور الجداول أو ملف إكسل، وشعار منظمتك، ومنولّدلك تقرير Word احترافي'
      : 'Add table photos or an Excel file, plus your organization logo, and we\'ll generate a professional Word report';
  String get pickImagesButton => _ar ? '📷 اختر صور الجداول' : '📷 Pick Table Photos';
  String get pickExcelButton => _ar ? '📊 اختر ملف إكسل' : '📊 Pick Excel File';
  String get pickLogoButton => _ar ? '🖼️ شعار المنظمة' : '🖼️ Organization Logo';
  String get notesLabel => _ar ? '📝 ملاحظات إضافية (اختياري)' : '📝 Additional Notes (optional)';
  String get notesHint =>
      _ar ? 'أي تعليمات إضافية بدك الذكاء الاصطناعي يراعيها...' : 'Any extra instructions for the AI...';
  String get generateReportButton => _ar ? '✨ ولّد التقرير' : '✨ Generate Report';
  String get imagesSelected => _ar ? 'صورة مختارة' : 'images selected';
  String get excelSelected => _ar ? 'ملف إكسل مختار' : 'Excel file selected';
  String get logoSelected => _ar ? 'شعار مختار' : 'Logo selected';
  String get noDataError =>
      _ar ? 'أضف صور أو ملف إكسل على الأقل قبل المتابعة' : 'Add at least photos or an Excel file first';
  String get generatingReport =>
      _ar ? 'جاري تحليل البيانات وبناء التقرير...' : 'Analyzing data and building the report...';
  String get reportReady => _ar ? 'جاهز! افتح شاشة المشاركة' : 'Ready! Opening the share sheet';
  String get reportServerError =>
      _ar ? 'صار خطأ أثناء توليد التقرير، حاول مرة ثانية' : 'Something went wrong generating the report, try again';
  String get reportRateLimitError =>
      _ar ? 'في ضغط كبير حالياً، جرب بعد شوي' : 'High demand right now, try again shortly';
  String get reportConnectionError => _ar
      ? 'تأكد من الاتصال بالإنترنت وحاول مرة ثانية'
      : 'Check your internet connection and try again';

  // شاشة المعاينة
  String get previewTitle => _ar ? 'معاينة التقرير' : 'Report Preview';
  String get saveToDeviceButton => _ar ? '💾 حفظ على الجهاز' : '💾 Save to Device';
  String get keepInAppButton => _ar ? '📱 احتفظ بالتطبيق' : '📱 Keep in App';
  String get savedInAppMessage => _ar ? 'تم الحفظ جوا التطبيق!' : 'Saved in the app!';
  String get myReportsTitle => _ar ? 'تقاريري' : 'My Reports';
  String get myReportsEmpty =>
      _ar ? 'ما في تقارير محفوظة لسا' : 'No saved reports yet';
  String get deleteReport => _ar ? 'حذف' : 'Delete';
  String get exportFromHere => _ar ? 'صدّر Word' : 'Export Word';

  // شاشة السكانر
  String get scannerCardTitle => _ar ? '📑 مسح المستندات' : '📑 Scan Documents';
  String get scannerCardSubtitle =>
      _ar ? 'صوّر أوراق وحولها PDF واحد مرتب' : 'Scan papers into one tidy PDF';
  String get scanNewPageButton => _ar ? '📷 سكان صفحة جديدة' : '📷 Scan New Page';
  String get noPagesYet => _ar ? 'ما في صفحات لسا، ابدأ بالسكان' : 'No pages yet, start scanning';
  String get pageWord => _ar ? 'صفحة' : 'page';
  String get exportScanPdfButton => _ar ? '📄 صدّر PDF' : '📄 Export PDF';
  String get scannerWebUnsupported => _ar
      ? 'المسح الضوئي متوفر بس على تطبيق الموبايل، مش عالويب'
      : 'Scanning is only available on the mobile app, not on web';
  String get scanError =>
      _ar ? 'صار خطأ أثناء المسح، حاول مرة ثانية' : 'Something went wrong while scanning, try again';

  // شاشة الخريطة
  String get mapCardTitle => _ar ? '🗺️ الخريطة' : '🗺️ Map';
  String get mapCardSubtitle =>
      _ar ? 'موقعك، ارسم حدود، واحفظ نقاط مهمة' : 'Your location, draw boundaries, save points';
  String get locatingMessage => _ar ? 'جاري تحديد موقعك...' : 'Finding your location...';
  String get locationDeniedError => _ar
      ? 'الرجاء السماح بصلاحية الموقع من إعدادات الجهاز'
      : 'Please allow location permission from device settings';
  String get locationServiceOffError =>
      _ar ? 'خدمة الموقع (GPS) مطفأة، فعّلها من الإعدادات' : 'Location service (GPS) is off, enable it in settings';
  String get drawModeStart => _ar ? '✏️ ابدأ رسم حدود' : '✏️ Start Drawing';
  String get drawModeStop => _ar ? '⏹️ أنهِ الرسم' : '⏹️ Stop Drawing';
  String get exportBoundaryButton => _ar ? '📤 صدّر الحدود' : '📤 Export Boundary';
  String get clearDrawingButton => _ar ? '🗑️ امسح الرسم' : '🗑️ Clear Drawing';
  String get savePointButton => _ar ? '📍 احفظ هاي النقطة' : '📍 Save This Point';
  String get copyLocationButton => _ar ? '📋 انسخ موقعي الحالي' : '📋 Copy My Location';
  String get locationCopied => _ar ? 'تم نسخ الموقع!' : 'Location copied!';
  String get myPointsTitle => _ar ? 'نقاطي المحفوظة' : 'My Saved Points';
  String get noPointsYet => _ar ? 'ما في نقاط محفوظة لسا' : 'No saved points yet';
  String get pointNameHint => _ar ? 'اسم النقطة (مثلاً: المخيم أ)' : 'Point name (e.g. Camp A)';
  String get save => _ar ? 'حفظ' : 'Save';
  String get cancel => _ar ? 'إلغاء' : 'Cancel';
  String get needAtLeast3Points => _ar
      ? 'لازم 3 نقاط على الأقل لرسم حدود'
      : 'Need at least 3 points to draw a boundary';
  String get undoPointButton => _ar ? '↩️ تراجع عن آخر نقطة' : '↩️ Undo Last Point';
  String get startTrackingButton => _ar ? '▶️ ابدأ التتبع المباشر' : '▶️ Start Live Tracking';
  String get stopTrackingButton => _ar ? '⏸️ أوقف التتبع' : '⏸️ Stop Tracking';

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