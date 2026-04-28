class UpcomingForecastWeeklyModel {
  var type;
  List<WeeklyForecast>? forecast;

  UpcomingForecastWeeklyModel({this.type, this.forecast});

  UpcomingForecastWeeklyModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['forecast'] != null) {
      forecast = <WeeklyForecast>[];
      json['forecast'].forEach((v) {
        forecast!.add(WeeklyForecast.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (forecast != null) {
      data['forecast'] = forecast!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WeeklyForecast {
  var timestamp;
  String? date;          // e.g. "2026-09-25" — present in monthly, weekly
  Temperature? temperature;
  Temperature? temperatureF;
  FeelsLike? feelsLike;
  var condition;
  var description;
  var windSpeed;
  var windSpeedKnots;
  var windSpeedMs;
  var humidity;
  var pressure;
  var pressureHpa;
  var pressureInhg;
  var pop;
  var uvi;

  WeeklyForecast({
    this.timestamp,
    this.date,
    this.temperature,
    this.temperatureF,
    this.feelsLike,
    this.condition,
    this.description,
    this.windSpeed,
    this.windSpeedKnots,
    this.windSpeedMs,
    this.humidity,
    this.pressure,
    this.pressureHpa,
    this.pressureInhg,
    this.pop,
    this.uvi,
  });

  WeeklyForecast.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
    date = json['date']?.toString();          // "2026-09-25" from monthly/weekly

    if (json['temperature'] is Map<String, dynamic>) {
      temperature = Temperature.fromJson(json['temperature'] as Map<String, dynamic>);
    } else if (json['temperature'] is num) {
      temperature = Temperature(day: (json['temperature'] as num).toDouble());
    }

    if (json['temperature_f'] is Map<String, dynamic>) {
      temperatureF = Temperature.fromJson(json['temperature_f'] as Map<String, dynamic>);
    } else if (json['temperature_f'] is num) {
      temperatureF = Temperature(day: (json['temperature_f'] as num).toDouble());
    } else {
      final tempMap = json['temperature'];
      if (tempMap is Map<String, dynamic>) {
        final minF = (tempMap['min_f'] as num?)?.toDouble();
        final maxF = (tempMap['max_f'] as num?)?.toDouble();
        final dayF = (tempMap['day_f'] as num?)?.toDouble();
        if (minF != null || maxF != null || dayF != null) {
          temperatureF = Temperature(min: minF, max: maxF, day: dayF);
        }
      }
    }

    if (json['feels_like'] is Map<String, dynamic>) {
      feelsLike = FeelsLike.fromJson(json['feels_like'] as Map<String, dynamic>);
    } else if (json['feels_like'] is num) {
      feelsLike = FeelsLike(day: (json['feels_like'] as num).toDouble());
    }

    condition = json['condition'];
    description = json['description'];
    windSpeed = json['wind_speed']?.toString();
    windSpeedKnots = (json['wind_speed_knots'] as num?)?.toDouble();
    windSpeedMs = (json['wind_speed_ms'] as num?)?.toDouble();
    humidity = json['humidity'];
    pressure = json['pressure'];
    pressureHpa = json['pressure_hpa'];
    pressureInhg = (json['pressure_inhg'] as num?)?.toDouble();
    pop = (json['pop'] as num?)?.toDouble() ??
        (json['precipitation_probability'] as num?)?.toDouble();
    uvi = json['uvi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['timestamp'] = timestamp;
    data['date'] = date;
    if (temperature != null) data['temperature'] = temperature!.toJson();
    if (temperatureF != null) data['temperature_f'] = temperatureF!.toJson();
    if (feelsLike != null) data['feels_like'] = feelsLike!.toJson();
    data['condition'] = condition;
    data['description'] = description;
    data['wind_speed'] = windSpeed;
    data['wind_speed_knots'] = windSpeedKnots;
    data['wind_speed_ms'] = windSpeedMs;
    data['humidity'] = humidity;
    data['pressure'] = pressure;
    data['pressure_hpa'] = pressureHpa;
    data['pressure_inhg'] = pressureInhg;
    data['pop'] = pop;
    data['uvi'] = uvi;
    return data;
  }
}

class Temperature {
  var min;
  var max;
  var day;

  Temperature({this.min, this.max, this.day});

  // The API sends keys in two formats depending on endpoint:
  //   weekly/monthly top-level: "min_c", "max_c", "day_c"
  //   nested temperature_f map:  "min",   "max",   "day"
  // We handle both here.
  Temperature.fromJson(Map<String, dynamic> json) {
    min = json['min_c'] ?? json['min'];
    max = json['max_c'] ?? json['max'];
    day = json['day_c'] ?? json['day'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['min'] = min;
    data['max'] = max;
    data['day'] = day;
    return data;
  }
}

class FeelsLike {
  var day;

  FeelsLike({this.day});

  FeelsLike.fromJson(Map<String, dynamic> json) {
    day = json['day'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    return data;
  }
}