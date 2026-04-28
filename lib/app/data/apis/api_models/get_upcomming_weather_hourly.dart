class UpcomingForecastHourlyModel {
  var type;
  List<HourlyForecast>? forecast;

  UpcomingForecastHourlyModel({this.type, this.forecast});

  UpcomingForecastHourlyModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['forecast'] != null) {
      forecast = <HourlyForecast>[];
      json['forecast'].forEach((v) {
        forecast!.add(HourlyForecast.fromJson(v));
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

class HourlyForecast {
  var timestamp;
  // Working display value — swapped by _applyHourlyUnits in the controller
  var temperature;
  // Raw Celsius and Fahrenheit values from the API
  var temperatureC;
  var temperatureF;
  // Feels-like working display value
  var feelsLike;
  var feelsLikeF;
  var condition;
  var description;
  // windSpeed is the KMH value (wind_speed from API); knots and m/s are separate
  var windSpeed;
  var windSpeedKnots;
  var windSpeedMs;
  var humidity;
  var pressure;
  var pressureHpa;
  var pressureInhg;
  var dewPointC;
  var dewPointF;
  var pop;
  var uvi;
  var visibility;
  var visibilityKm;
  var visibilitySm;
  var visibilityNm;

  HourlyForecast({
    this.timestamp,
    this.temperature,
    this.temperatureC,
    this.temperatureF,
    this.feelsLike,
    this.feelsLikeF,
    this.condition,
    this.description,
    this.windSpeed,
    this.windSpeedKnots,
    this.windSpeedMs,
    this.humidity,
    this.pressure,
    this.pressureHpa,
    this.pressureInhg,
    this.dewPointC,
    this.dewPointF,
    this.pop,
    this.uvi,
    this.visibility,
    this.visibilityKm,
    this.visibilitySm,
    this.visibilityNm,
  });

  HourlyForecast.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];

    // BUG FIX: The API sends "temperature_c" and "temperature_f", NOT "temperature".
    // We use temperature_c as the default working value; the controller swaps it to _f
    // when the user selects °F.
    temperatureC = json['temperature_c'];
    temperatureF = json['temperature_f'];
    // Initialise the working display field to Celsius by default
    temperature = temperatureC ?? json['temperature'];

    // feels_like from the API is Celsius (feels_like_c not present in JSON key).
    // feels_like_f is the Fahrenheit version.
    feelsLike = json['feels_like'] ?? json['feels_like_c'];
    feelsLikeF = json['feels_like_f'];

    condition = json['condition'];
    description = json['description'];

    // wind_speed from the API is in KMH (matches the "KMH" unit option)
    windSpeed = json['wind_speed']?.toString();
    windSpeedKnots = (json['wind_speed_knots'] as num?)?.toDouble();
    windSpeedMs = (json['wind_speed_ms'] as num?)?.toDouble();

    humidity = json['humidity'];
    pressure = json['pressure'];
    pressureHpa = json['pressure_hpa'];
    pressureInhg = json['pressure_inhg'];

    dewPointC = json['dew_point_c'];
    dewPointF = json['dew_point_f'];

    pop = (json['pop'] as num?)?.toDouble() ??
        (json['precipitation_probability'] as num?)?.toDouble();
    uvi = json['uvi'];

    visibility = json['visibility'];
    visibilityKm = json['visibility_km'];
    visibilitySm = json['visibility_sm'];
    visibilityNm = json['visibility_nm'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['timestamp'] = timestamp;
    data['temperature'] = temperature;
    data['temperature_c'] = temperatureC;
    data['temperature_f'] = temperatureF;
    data['feels_like'] = feelsLike;
    data['feels_like_f'] = feelsLikeF;
    data['condition'] = condition;
    data['description'] = description;
    data['wind_speed'] = windSpeed;
    data['wind_speed_knots'] = windSpeedKnots;
    data['wind_speed_ms'] = windSpeedMs;
    data['humidity'] = humidity;
    data['pressure'] = pressure;
    data['pressure_hpa'] = pressureHpa;
    data['pressure_inhg'] = pressureInhg;
    data['dew_point_c'] = dewPointC;
    data['dew_point_f'] = dewPointF;
    data['pop'] = pop;
    data['uvi'] = uvi;
    data['visibility'] = visibility;
    data['visibility_km'] = visibilityKm;
    data['visibility_sm'] = visibilitySm;
    data['visibility_nm'] = visibilityNm;
    return data;
  }
}