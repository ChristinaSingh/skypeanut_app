// class GetWeatherAppModel {
//   Weather? weather;
//   List<Alerts>? alerts;
//   String? mode;
//   String? cacheTimestamp;
//
//   GetWeatherAppModel(
//       {this.weather, this.alerts, this.mode, this.cacheTimestamp});
//
//   GetWeatherAppModel.fromJson(Map<String, dynamic> json) {
//     weather =
//     json['weather'] != null ? new Weather.fromJson(json['weather']) : null;
//     if (json['alerts'] != null) {
//       alerts = <Alerts>[];
//       json['alerts'].forEach((v) {
//         alerts!.add(new Alerts.fromJson(v));
//       });
//     }
//     mode = json['mode'];
//     cacheTimestamp = json['cache_timestamp'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.weather != null) {
//       data['weather'] = this.weather!.toJson();
//     }
//     if (this.alerts != null) {
//       data['alerts'] = this.alerts!.map((v) => v.toJson()).toList();
//     }
//     data['mode'] = this.mode;
//     data['cache_timestamp'] = this.cacheTimestamp;
//     return data;
//   }
// }
//
// class Weather {
//   var location;
//   var timestamp;
//   var condition;
//   var temperature;
//   var feelsLike;
//   var windSpeed;
//   var visibility;
//   var dewPoint;
//   var pressure;
//   var humidity;
//   var forecast;
//
//   Weather(
//       {this.location,
//         this.timestamp,
//         this.condition,
//         this.temperature,
//         this.feelsLike,
//         this.windSpeed,
//         this.visibility,
//         this.dewPoint,
//         this.pressure,
//         this.humidity,
//         this.forecast});
//
//   Weather.fromJson(Map<String, dynamic> json) {
//     location = json['location'];
//     timestamp = json['timestamp'];
//     condition = json['condition'];
//     temperature = json['temperature'];
//     feelsLike = json['feels_like'];
//     windSpeed = json['wind_speed'];
//     visibility = json['visibility'];
//     dewPoint = json['dew_point'];
//     pressure = json['pressure'];
//     humidity = json['humidity'];
//     forecast = json['forecast'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['location'] = this.location;
//     data['timestamp'] = this.timestamp;
//     data['condition'] = this.condition;
//     data['temperature'] = this.temperature;
//     data['feels_like'] = this.feelsLike;
//     data['wind_speed'] = this.windSpeed;
//     data['visibility'] = this.visibility;
//     data['dew_point'] = this.dewPoint;
//     data['pressure'] = this.pressure;
//     data['humidity'] = this.humidity;
//     data['forecast'] = this.forecast;
//     return data;
//   }
// }
//
// class Alerts {
//   String? title;
//   String? description;
//   String? type;
//   String? severity;
//   String? issuedAt;
//
//   Alerts(
//       {this.title, this.description, this.type, this.severity, this.issuedAt});
//
//   Alerts.fromJson(Map<String, dynamic> json) {
//     title = json['title'];
//     description = json['description'];
//     type = json['type'];
//     severity = json['severity'];
//     issuedAt = json['issued_at'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['title'] = this.title;
//     data['description'] = this.description;
//     data['type'] = this.type;
//     data['severity'] = this.severity;
//     data['issued_at'] = this.issuedAt;
//     return data;
//   }
// }


class GetWeatherAppModel {
  Weather? weather;
  List<Alerts>? alerts;
  UpcomingForecast? upcomingForecast;
  String? alertsMessage;
  String? mode;
  String? cacheTimestamp;

  GetWeatherAppModel(
      {this.weather,
        this.alerts,
        this.upcomingForecast,
        this.alertsMessage,
        this.mode,
        this.cacheTimestamp});

  GetWeatherAppModel.fromJson(Map<String, dynamic> json) {
    weather =
    json['weather'] != null ? Weather.fromJson(json['weather']) : null;
    if (json['alerts'] != null) {
      alerts = <Alerts>[];
      json['alerts'].forEach((v) {
        alerts!.add(Alerts.fromJson(v));
      });
    }
    upcomingForecast = json['upcoming_forecast'] != null
        ? UpcomingForecast.fromJson(json['upcoming_forecast'])
        : null;
    alertsMessage = json['alerts_message'];
    mode = json['mode'];
    cacheTimestamp = json['cache_timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (weather != null) {
      data['weather'] = weather!.toJson();
    }
    if (alerts != null) {
      data['alerts'] = alerts!.map((v) => v.toJson()).toList();
    }
    if (upcomingForecast != null) {
      data['upcoming_forecast'] = upcomingForecast!.toJson();
    }
    data['alerts_message'] = alertsMessage;
    data['mode'] = mode;
    data['cache_timestamp'] = cacheTimestamp;
    return data;
  }
}

class Weather {
  String? location;
  String? timestamp;
  String? condition;
  var temperature;
  var temperatureC;
  var temperatureF;
  var feelsLike;
  String? windSpeed;
  var windSpeedKnots;
  var windSpeedMs;
  var visibility;
  var visibilityKm;
  var visibilitySm;
  var visibilityNm;
  String? dewPoint;
  var dewPointC;
  var dewPointF;
  String? pressure;
  var pressureHpa;
  var pressureInhg;
  String? humidity;
  String? forecast;
  String? windDirection;
  AirQuality? airQuality;

  Weather(
      {this.location,
        this.timestamp,
        this.condition,
        this.temperature,
        this.temperatureC,
        this.temperatureF,
        this.feelsLike,
        this.windSpeed,
        this.windSpeedKnots,
        this.windSpeedMs,
        this.visibility,
        this.visibilityKm,
        this.visibilitySm,
        this.visibilityNm,
        this.dewPoint,
        this.dewPointC,
        this.dewPointF,
        this.pressure,
        this.pressureHpa,
        this.pressureInhg,
        this.windDirection,
        this.airQuality,
        this.humidity,
        this.forecast});

  Weather.fromJson(Map<String, dynamic> json) {
    windDirection = json['wind_direction'];
    airQuality = json['air_quality'] != null
        ? AirQuality.fromJson(json['air_quality'])
        : null;
    location = json['location'];
    timestamp = json['timestamp'];
    condition = json['condition'];
    temperature = json['temperature'];
    temperatureC = json['temperature_c'];
    temperatureF = json['temperature_f'];
    feelsLike = json['feels_like'];
    windSpeed = json['wind_speed'];
    windSpeedKnots = json['wind_speed_knots'];
    windSpeedMs = json['wind_speed_ms'];
    visibility = json['visibility'];
    visibilityKm = json['visibility_km'];
    visibilitySm = json['visibility_sm'];
    visibilityNm = json['visibility_nm'];
    dewPoint = json['dew_point'];
    dewPointC = json['dew_point_c'];
    dewPointF = json['dew_point_f'];
    pressure = json['pressure'];
    pressureHpa = json['pressure_hpa'];
    pressureInhg = json['pressure_inhg'];
    humidity = json['humidity'];
    forecast = json['forecast'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['location'] = location;
    data['timestamp'] = timestamp;
    data['condition'] = condition;
    data['temperature'] = temperature;
    data['temperature_c'] = temperatureC;
    data['temperature_f'] = temperatureF;
    data['feels_like'] = feelsLike;
    data['wind_speed'] = windSpeed;
    data['wind_speed_knots'] = windSpeedKnots;
    data['wind_speed_ms'] = windSpeedMs;
    data['visibility'] = visibility;
    data['visibility_km'] = visibilityKm;
    data['visibility_sm'] = visibilitySm;
    data['visibility_nm'] = visibilityNm;
    data['dew_point'] = dewPoint;
    data['dew_point_c'] = dewPointC;
    data['dew_point_f'] = dewPointF;
    data['pressure'] = pressure;
    data['pressure_hpa'] = pressureHpa;
    data['pressure_inhg'] = pressureInhg;
    data['humidity'] = humidity;
    data['forecast'] = forecast;
    data['wind_direction'] = windDirection;
    data['air_quality'] = airQuality?.toJson();
    return data;
  }
}

class Alerts {
  String? title;
  String? description;
  String? type;
  String? severity;
  String? issuedAt;

  Alerts(
      {this.title, this.description, this.type, this.severity, this.issuedAt});

  Alerts.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    type = json['type'];
    severity = json['severity'];
    issuedAt = json['issued_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['type'] = type;
    data['severity'] = severity;
    data['issued_at'] = issuedAt;
    return data;
  }
}

class UpcomingForecast {
  List<String>? hourly;
  List<String>? daily;

  UpcomingForecast({this.hourly, this.daily});

  UpcomingForecast.fromJson(Map<String, dynamic> json) {
    hourly = (json['hourly'] as List?)
        ?.map((e) => e is String ? e : e.toString())
        .toList();
    daily = (json['daily'] as List?)
        ?.map((e) => e is String ? e : e.toString())
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hourly'] = hourly;
    data['daily'] = daily;
    return data;
  }
}


class AirQuality {
  int? aqiUs;
  String? category;
  double? pm25;
  double? pm10;

  AirQuality({this.aqiUs, this.category, this.pm25, this.pm10});

  AirQuality.fromJson(Map<String, dynamic> json) {
    aqiUs = json['aqi_us'];
    category = json['category'];
    pm25 = (json['pm2_5'] as num?)?.toDouble();
    pm10 = (json['pm10'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() => {
    'aqi_us': aqiUs,
    'category': category,
    'pm2_5': pm25,
    'pm10': pm10,
  };
}