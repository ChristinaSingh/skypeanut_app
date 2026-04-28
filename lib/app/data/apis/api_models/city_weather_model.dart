class CityWeatherModel {
  String? city;
  String? country;
  var temperature;
  var temperatureC;
  var temperatureF;
  AirQuality? airQuality;
  var high;
  var low;
  String? condition;
  String? conditionEmoji;
  var uvIndex;
  String? uvLevel;
  String? sunrise;
  String? sunset;
  String? windSpeed;
  var windSpeedKnots;
  var windSpeedMs;
  String? windDirection;
  var rain1h;
  var rain24h;
  var feelsLike;
  var humidity;
  var dewPoint;
  var dewPointC;
  var dewPointF;
  double? visibility;
  var visibilityKm;
  var visibilitySm;
  var visibilityNm;
  var pressure;
  var pressureHpa;
  var pressureInhg;
  TurbulenceForecast? turbulenceForecast;

  CityWeatherModel(
      {this.city,
        this.country,
        this.temperature,
        this.temperatureC,
        this.temperatureF,
        this.high,
        this.low,
        this.condition,
        this.conditionEmoji,
        this.uvIndex,
        this.uvLevel,
        this.sunrise,
        this.sunset,
        this.windSpeed,
        this.windSpeedKnots,
        this.windSpeedMs,
        this.windDirection,
        this.rain1h,
        this.rain24h,
        this.feelsLike,
        this.humidity,
        this.dewPoint,
        this.dewPointC,
        this.dewPointF,
        this.visibility,
        this.visibilityKm,
        this.visibilitySm,
        this.visibilityNm,
        this.pressure,
        this.pressureHpa,
        this.airQuality,
        this.pressureInhg,
        this.turbulenceForecast});

  CityWeatherModel.fromJson(Map<String, dynamic> json) {
    city = json['city'];
    country = json['country'];
    temperature = json['temperature'];
    temperatureC = json['temperature_c'];
    temperatureF = json['temperature_f'];
    high = json['high'];
    low = json['low'];
    condition = json['condition'];
    conditionEmoji = json['condition_emoji'];
    uvIndex = json['uv_index'];
    uvLevel = json['uv_level'];
    sunrise = json['sunrise'];
    sunset = json['sunset'];
    windSpeed = json['wind_speed'];
    windSpeedKnots = json['wind_speed_knots'];
    windSpeedMs = json['wind_speed_ms'];
    windDirection = json['wind_direction'];
    rain1h = json['rain_1h'];
    rain24h = json['rain_24h'];
    feelsLike = json['feels_like'];
    humidity = json['humidity'];
    dewPoint = json['dew_point'];
    dewPointC = json['dew_point_c'];
    dewPointF = json['dew_point_f'];
    visibility = json['visibility'];
    visibilityKm = json['visibility_km'];
    visibilitySm = json['visibility_sm'];
    visibilityNm = json['visibility_nm'];
    pressure = json['pressure'];
    pressureHpa = json['pressure_hpa'];
    pressureInhg = json['pressure_inhg'];
    turbulenceForecast = json['turbulence_forecast'] != null
        ? TurbulenceForecast.fromJson(json['turbulence_forecast'])
        : null;
    airQuality = json['air_quality'] != null
        ? AirQuality.fromJson(json['air_quality'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['city'] = city;
    data['country'] = country;
    data['temperature'] = temperature;
    data['temperature_c'] = temperatureC;
    data['temperature_f'] = temperatureF;
    data['high'] = high;
    data['air_quality'] = airQuality?.toJson();
    data['low'] = low;
    data['condition'] = condition;
    data['condition_emoji'] = conditionEmoji;
    data['uv_index'] = uvIndex;
    data['uv_level'] = uvLevel;
    data['sunrise'] = sunrise;
    data['sunset'] = sunset;
    data['wind_speed'] = windSpeed;
    data['wind_speed_knots'] = windSpeedKnots;
    data['wind_speed_ms'] = windSpeedMs;
    data['wind_direction'] = windDirection;
    data['rain_1h'] = rain1h;
    data['rain_24h'] = rain24h;
    data['feels_like'] = feelsLike;
    data['humidity'] = humidity;
    data['dew_point'] = dewPoint;
    data['dew_point_c'] = dewPointC;
    data['dew_point_f'] = dewPointF;
    data['visibility'] = visibility;
    data['visibility_km'] = visibilityKm;
    data['visibility_sm'] = visibilitySm;
    data['visibility_nm'] = visibilityNm;
    data['pressure'] = pressure;
    data['pressure_hpa'] = pressureHpa;
    data['pressure_inhg'] = pressureInhg;
    if (turbulenceForecast != null) {
      data['turbulence_forecast'] = turbulenceForecast!.toJson();
    }
    return data;
  }
}

class TurbulenceForecast {
  var rainfall;
  String? note;

  TurbulenceForecast({this.rainfall, this.note});

  TurbulenceForecast.fromJson(Map<String, dynamic> json) {
    rainfall = json['rainfall'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rainfall'] = rainfall;
    data['note'] = note;
    return data;
  }
}

// Add this new class at the bottom of the file:
class AirQuality {
  int? aqiUs;
  String? category;
  double? pm25;
  double? pm10;
  double? co;
  double? no2;
  double? so2;
  double? o3;

  AirQuality({
    this.aqiUs,
    this.category,
    this.pm25,
    this.pm10,
    this.co,
    this.no2,
    this.so2,
    this.o3,
  });

  AirQuality.fromJson(Map<String, dynamic> json) {
    aqiUs = json['aqi_us'];
    category = json['category'];
    pm25 = (json['pm2_5'] as num?)?.toDouble();
    pm10 = (json['pm10'] as num?)?.toDouble();
    co = (json['co'] as num?)?.toDouble();
    no2 = (json['no2'] as num?)?.toDouble();
    so2 = (json['so2'] as num?)?.toDouble();
    o3 = (json['o3'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() => {
    'aqi_us': aqiUs,
    'category': category,
    'pm2_5': pm25,
    'pm10': pm10,
    'co': co,
    'no2': no2,
    'so2': so2,
    'o3': o3,
  };
}
