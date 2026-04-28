class UpcomingForecastModel {
  String? type;
  List<Forecast>? forecast;

  UpcomingForecastModel({this.type, this.forecast});

  UpcomingForecastModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['forecast'] != null) {
      forecast = <Forecast>[];
      json['forecast'].forEach((v) {
        forecast!.add(Forecast.fromJson(v));
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

class Forecast {
  int? timestamp;
  double? temperature;
  double? feelsLike;
  String? condition;
  String? description;
  String? windSpeed;
  int? humidity;
  int? pressure;
  double? pop;
  String? uvi;
  int? visibility;

  Forecast(
      {this.timestamp,
        this.temperature,
        this.feelsLike,
        this.condition,
        this.description,
        this.windSpeed,
        this.humidity,
        this.pressure,
        this.pop,
        this.uvi,
        this.visibility});

  Forecast.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
    temperature = json['temperature'];
    feelsLike = json['feels_like'];
    condition = json['condition'];
    description = json['description'];
    windSpeed = json['wind_speed'];
    humidity = json['humidity'];
    pressure = json['pressure'];
    pop = json['pop'];
    uvi = json['uvi'];
    visibility = json['visibility'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['timestamp'] = timestamp;
    data['temperature'] = temperature;
    data['feels_like'] = feelsLike;
    data['condition'] = condition;
    data['description'] = description;
    data['wind_speed'] = windSpeed;
    data['humidity'] = humidity;
    data['pressure'] = pressure;
    data['pop'] = pop;
    data['uvi'] = uvi;
    data['visibility'] = visibility;
    return data;
  }
}
