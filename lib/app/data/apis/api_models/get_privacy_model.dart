class PrivacyModel {
  final String status;
  final String appName;
  final String company;
  final String lastUpdated;
  final String contactEmail;
  final List<PrivacySection> sections;

  PrivacyModel({
    required this.status,
    required this.appName,
    required this.company,
    required this.lastUpdated,
    required this.contactEmail,
    required this.sections,
  });

  factory PrivacyModel.fromJson(Map<String, dynamic> json) {
    return PrivacyModel(
      status: json['status']?.toString() ?? '',
      appName: json['app_name']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      lastUpdated: json['last_updated']?.toString() ?? '',
      contactEmail: json['contact_email']?.toString() ?? '',
      sections: (json['sections'] as List<dynamic>? ?? [])
          .map((e) => PrivacySection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PrivacySection {
  final String section;
  final String title;
  final String content;
  final List<PrivacySubSection> subsections;

  PrivacySection({
    required this.section,
    required this.title,
    required this.content,
    required this.subsections,
  });

  factory PrivacySection.fromJson(Map<String, dynamic> json) {
    return PrivacySection(
      section: json['section']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      subsections: (json['subsections'] as List<dynamic>? ?? [])
          .map((e) => PrivacySubSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PrivacySubSection {
  final String subsection;
  final String title;
  final String content;

  PrivacySubSection({
    required this.subsection,
    required this.title,
    required this.content,
  });

  factory PrivacySubSection.fromJson(Map<String, dynamic> json) {
    return PrivacySubSection(
      subsection: json['subsection']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
    );
  }
}