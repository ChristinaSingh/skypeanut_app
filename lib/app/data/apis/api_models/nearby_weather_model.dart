class NearbyWeatherModel {
  String? status;
  String? message;
  List<Cities>? cities;

  NearbyWeatherModel({this.status, this.message, this.cities});

  NearbyWeatherModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['cities'] != null) {
      cities = <Cities>[];
      json['cities'].forEach((v) {
        cities!.add(Cities.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (cities != null) {
      data['cities'] = cities!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cities {
  String? name;
  String? condition;
  double? temperature;
  double? temperatureC;
  double? temperatureF;
  double? dewPointC;
  double? dewPointF;
  String? visibility;
  double? visibilityKm;
  double? visibilitySm;
  double? visibilityNm;
  String? wind;
  double? windSpeedMs;
  double? windSpeedKnots;
  double? pressureHpa;
  double? pressureInhg;
  List<String>? alerts;

  Cities({
    this.name,
    this.condition,
    this.temperature,
    this.temperatureC,
    this.temperatureF,
    this.dewPointC,
    this.dewPointF,
    this.visibility,
    this.visibilityKm,
    this.visibilitySm,
    this.visibilityNm,
    this.wind,
    this.windSpeedMs,
    this.windSpeedKnots,
    this.pressureHpa,
    this.pressureInhg,
    this.alerts,
  });

  Cities.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    condition = json['condition'];
    temperature = (json['temperature'] as num?)?.toDouble();
    temperatureC = (json['temperature_c'] as num?)?.toDouble();
    temperatureF = (json['temperature_f'] as num?)?.toDouble();
    dewPointC = (json['dew_point_c'] as num?)?.toDouble();
    dewPointF = (json['dew_point_f'] as num?)?.toDouble();
    visibility = json['visibility'];
    visibilityKm = (json['visibility_km'] as num?)?.toDouble();
    visibilitySm = (json['visibility_sm'] as num?)?.toDouble();
    visibilityNm = (json['visibility_nm'] as num?)?.toDouble();
    wind = json['wind'];
    windSpeedMs = (json['wind_speed_ms'] as num?)?.toDouble();       // ✅ fixes int→double crash
    windSpeedKnots = (json['wind_speed_knots'] as num?)?.toDouble();
    pressureHpa = (json['pressure_hpa'] as num?)?.toDouble();
    pressureInhg = (json['pressure_inhg'] as num?)?.toDouble();
    alerts = (json['alerts'] as List?)?.map((e) => e.toString()).toList() ?? [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['condition'] = condition;
    data['temperature'] = temperature;
    data['temperature_c'] = temperatureC;
    data['temperature_f'] = temperatureF;
    data['dew_point_c'] = dewPointC;
    data['dew_point_f'] = dewPointF;
    data['visibility'] = visibility;
    data['visibility_km'] = visibilityKm;
    data['visibility_sm'] = visibilitySm;
    data['visibility_nm'] = visibilityNm;
    data['wind'] = wind;
    data['wind_speed_ms'] = windSpeedMs;
    data['wind_speed_knots'] = windSpeedKnots;
    data['pressure_hpa'] = pressureHpa;
    data['pressure_inhg'] = pressureInhg;
    data['alerts'] = alerts;
    return data;
  }
}