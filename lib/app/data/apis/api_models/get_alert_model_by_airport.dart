class AlertsModelByAirport {
  String? status;
  String? message;
  int? alertsCount;
  List<Alerts>? alerts;
  List<String>? sources;
  String? airport;
  String? timestamp;

  AlertsModelByAirport(
      {this.status,
        this.message,
        this.alertsCount,
        this.alerts,
        this.sources,
        this.airport,
        this.timestamp});

  AlertsModelByAirport.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    alertsCount = json['alerts_count'];
    if (json['alerts'] != null) {
      alerts = <Alerts>[];
      json['alerts'].forEach((v) {
        alerts!.add(Alerts.fromJson(v));
      });
    }
    sources = json['sources'].cast<String>();
    airport = json['airport'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['alerts_count'] = alertsCount;
    if (alerts != null) {
      data['alerts'] = alerts!.map((v) => v.toJson()).toList();
    }
    data['sources'] = sources;
    data['airport'] = airport;
    data['timestamp'] = timestamp;
    return data;
  }
}

class Alerts {
  String? type;
  String? title;
  String? description;
  String? severity;
  String? startTime;
  String? endTime;
  String? rawText;
  String? source;
  String? airport;
  String? issuedAt;
  Null expiresAt;

  Alerts(
      {this.type,
        this.title,
        this.description,
        this.severity,
        this.startTime,
        this.endTime,
        this.rawText,
        this.source,
        this.airport,
        this.issuedAt,
        this.expiresAt});

  Alerts.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    title = json['title'];
    description = json['description'];
    severity = json['severity'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    rawText = json['raw_text'];
    source = json['source'];
    airport = json['airport'];
    issuedAt = json['issued_at'];
    expiresAt = json['expires_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['title'] = title;
    data['description'] = description;
    data['severity'] = severity;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['raw_text'] = rawText;
    data['source'] = source;
    data['airport'] = airport;
    data['issued_at'] = issuedAt;
    data['expires_at'] = expiresAt;
    return data;
  }
}
