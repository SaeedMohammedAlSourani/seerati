class ResumeExperience {
  final String title;
  final String company;
  final String dateRange;
  final List<String> bullets;

  ResumeExperience({
    required this.title,
    required this.company,
    required this.dateRange,
    required this.bullets,
  });

  factory ResumeExperience.fromJson(Map<String, dynamic> json) {
    return ResumeExperience(
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      dateRange: json['dateRange'] as String? ?? '',
      bullets: (json['bullets'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class ResumeEducation {
  final String degree;
  final String institution;
  final String dateRange;

  ResumeEducation({
    required this.degree,
    required this.institution,
    required this.dateRange,
  });

  factory ResumeEducation.fromJson(Map<String, dynamic> json) {
    return ResumeEducation(
      degree: json['degree'] as String? ?? '',
      institution: json['institution'] as String? ?? '',
      dateRange: json['dateRange'] as String? ?? '',
    );
  }
}

class ResumeData {
  final String name;
  final String contact;
  final String summary;
  final List<ResumeExperience> experience;
  final List<String> skills;
  final List<ResumeEducation> education;

  ResumeData({
    required this.name,
    required this.contact,
    required this.summary,
    required this.experience,
    required this.skills,
    required this.education,
  });

  factory ResumeData.fromJson(Map<String, dynamic> json) {
    return ResumeData(
      name: json['name'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      experience: (json['experience'] as List?)
          ?.map((e) => ResumeExperience.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      skills: (json['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
      education: (json['education'] as List?)
          ?.map((e) => ResumeEducation.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  /// نسخة نصية بسيطة (تستخدم بزر النسخ)
  String toPlainText({required bool isArabic}) {
    final buffer = StringBuffer();
    buffer.writeln(name);
    if (contact.isNotEmpty) buffer.writeln(contact);
    buffer.writeln();
    buffer.writeln(summary);
    buffer.writeln();
    for (final exp in experience) {
      buffer.writeln('${exp.title} — ${exp.company} (${exp.dateRange})');
      for (final b in exp.bullets) {
        buffer.writeln('• $b');
      }
      buffer.writeln();
    }
    if (skills.isNotEmpty) {
      buffer.writeln(isArabic ? 'المهارات: ${skills.join('، ')}' : 'Skills: ${skills.join(', ')}');
      buffer.writeln();
    }
    for (final edu in education) {
      buffer.writeln('${edu.degree} — ${edu.institution} (${edu.dateRange})');
    }
    return buffer.toString().trim();
  }
}