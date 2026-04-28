class NotamAirportModel {
  List<Notams>? notams;

  NotamAirportModel({this.notams});

  NotamAirportModel.fromJson(Map<String, dynamic> json) {
    if (json['notams'] != null) {
      notams = <Notams>[];
      json['notams'].forEach((v) {
        notams!.add(Notams.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (notams != null) {
      data['notams'] = notams!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Notams {
  String? format;
  String? title;
  String? description;
  String? imageUrl;

  // ── Fields from the nearby/list API response ──────────────────────────────
  String? location;
  String? startTime;
  String? endTime;
  String? criticality;

  Notams({
    this.format,
    this.title,
    this.description,
    this.imageUrl,
    this.location,
    this.startTime,
    this.endTime,
    this.criticality,
  });

  Notams.fromJson(Map<String, dynamic> json) {
    format      = json['format'];
    title       = json['title'];
    description = json['description'];
    imageUrl    = json['image_url'];
    location    = json['location'];
    startTime   = json['start_time'];
    endTime     = json['end_time'];
    criticality = json['criticality'];
  }

  Map<String, dynamic> toJson() {
    return {
      'format':      format,
      'title':       title,
      'description': description,
      'image_url':   imageUrl,
      'location':    location,
      'start_time':  startTime,
      'end_time':    endTime,
      'criticality': criticality,
    };
  }
}