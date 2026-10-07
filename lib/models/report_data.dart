class ReportSection {
  final String heading;
  final String body;
  ReportSection({required this.heading, required this.body});

  factory ReportSection.fromJson(Map<String, dynamic> json) => ReportSection(
    heading: json['heading'] as String? ?? '',
    body: json['body'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {'heading': heading, 'body': body};
}

class ReportData {
  final String title;
  final List<ReportSection> sections;
  ReportData({required this.title, required this.sections});

  factory ReportData.fromJson(Map<String, dynamic> json) => ReportData(
    title: json['title'] as String? ?? '',
    sections: (json['sections'] as List?)
        ?.map((e) => ReportSection.fromJson(e as Map<String, dynamic>))
        .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'sections': sections.map((s) => s.toJson()).toList(),
  };

  /// يجمع كل الأقسام بنص واحد متعدد الفقرات، جاهز لحقل "body" بقالب الـ Word
  String toTemplateBody() {
    final buffer = StringBuffer();
    for (final s in sections) {
      buffer.writeln(s.heading);
      buffer.writeln(s.body);
      buffer.writeln();
    }
    return buffer.toString().trim();
  }
}