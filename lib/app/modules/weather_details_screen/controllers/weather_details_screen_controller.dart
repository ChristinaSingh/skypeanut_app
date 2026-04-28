import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skypeanut/app/data/apis/api_models/city_weather_model.dart';

import '../../../data/apis/api_constants/api_key_constants.dart';
import '../../../data/apis/api_methods/api_methods.dart';

class WeatherDetailsScreenController extends GetxController {
  Map<String, String?> parameters = Get.parameters;
  final RxBool inAsyncCall = true.obs;

  // Add these observables near the other Rx fields:
  var aqiUs = 0.obs;
  var aqiCategory = "".obs;
  var aqiPm25 = 0.0.obs;
  var aqiPm10 = 0.0.obs;
  var windDirectionLabel = "".obs; // e.g. "WNW"

  var date = 'June 07'.obs;
  var city = 'Paris'.obs;
  var location = 'Konya, TURKEY'.obs;
  var name = 'Johan Wick'.obs;
  var temperature = 0.0.obs;
  var lowTemperature = 0.0.obs;
  var highTemperature = 0.0.obs;
  var visibility = 56.obs;
  var pressure = "1013.25".obs;
  var forecast = 56.obs;

  var windUnit = "Knots".obs;
  var visibilityUnit = "KM".obs;
  var temperatureUnit = "°C".obs;
  var dewPointUnit = "°C".obs;
  var pressureUnit = "hPa".obs;

  var cityNearby = 'Paris'.obs;
  var emoji = '☁️'.obs;

  /// UV Index
  var uvIndex = 2.obs;

  String get uvLevel {
    if (uvIndex.value < 3) return "Low";
    if (uvIndex.value < 6) return "Moderate";
    if (uvIndex.value < 8) return "High";
    if (uvIndex.value < 11) return "Very High";
    return "Extreme";
  }

  /// Sunrise/Sunset
  var sunrise = '5:28 AM'.obs;
  var sunset = '7:25 PM'.obs;
  var progress = 0.2.obs;

  /// Wind Info
  var windSpeed = "9.7".obs;
  var windDirection = 270.0.obs;

  /// Rainfall
  var lastHourRain = 0.0.obs;
  var next24hRain = 0.0.obs;

  /// Feels Like
  var feelsLikeTemp = 19.0.obs; // Changed to double for precision
  var note = "Similar to the actual temperature.".obs;

  /// Humidity
  var humidity = 90.obs;
  var dewPoint = 17.0.obs; // Changed to double for precision

  /// Visibility
  var visibilityKm = "8".obs;
  var description = "Similar to the actual temperature.".obs;

  /// Pressure - separate value for gauge (0.0 to 1.0) and display
  var pressurePercent = 0.5.obs; // For gauge only (normalized 0-1)

  void simulatePressure() async {
    for (double i = 0.1; i <= 0.85; i += 0.01) {
      await Future.delayed(const Duration(milliseconds: 30));
      pressurePercent.value = i;
    }
  }

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
    cityNearby.value = parameters[ApiKeyConstants.city] ?? 'Unknown';
    getWeatherApiCalling();

    ever(windDirection,
            (_) => print('Wind direction updated to $windDirection'));
  }

  // ============ HELPER METHODS FOR CONVERSION ============

  /// Convert Celsius to Fahrenheit
  double _celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  /// Convert hPa to inHg
  double _hpaToInhg(double hpa) {
    return hpa * 0.02953;
  }

  /// Convert inHg to hPa
  double _inhgToHpa(double inhg) {
    return inhg * 33.8639;
  }

  String fixUtf8(String text) {
    try {
      final latinBytes = latin1.encode(text);
      return utf8.decode(latinBytes);
    } catch (_) {
      return text;
    }
  }

  String extractEmoji(String text) {
    try {
      String fixed = utf8.decode(text.runes.toList());
      String emojiOnly = fixed.replaceAll(RegExp(r'[a-zA-Z0-9\s]'), '');
      return emojiOnly.trim();
    } catch (_) {
      return text;
    }
  }

  Future<void> getWeatherApiCalling() async {
    inAsyncCall.value = true;

    final bodyParameter = {
      ApiKeyConstants.city: cityNearby.value,
    };

    print("bodyParameter: $bodyParameter");

    try {
      final prefs = await SharedPreferences.getInstance();
      windUnit.value = prefs.getString("windUnit") ?? "Knots";
      visibilityUnit.value = prefs.getString("visibilityUnit") ?? "KM";
      temperatureUnit.value = prefs.getString("temperatureUnit") ?? "°C";
      dewPointUnit.value = prefs.getString("dewPointUnit") ?? "°C";
      pressureUnit.value = prefs.getString("pressureUnit") ?? "hPa";

      CityWeatherModel? cityWeatherModel =
      await ApiMethods.getCityWeatherApi(bodyParams: bodyParameter);

      if (cityWeatherModel != null) {
        cityNearby.value =
        "${cityWeatherModel.city}, ${cityWeatherModel.country}";
        emoji.value = cityWeatherModel.conditionEmoji ?? "";

        // ============ WIND DIRECTION LABEL ============
        windDirectionLabel.value = cityWeatherModel.windDirection ?? "";

// ============ AIR QUALITY ============
        final aq = cityWeatherModel.airQuality;
        if (aq != null) {
          aqiUs.value = aq.aqiUs ?? 0;
          aqiCategory.value = aq.category ?? "";
          aqiPm25.value = aq.pm25 ?? 0.0;
          aqiPm10.value = aq.pm10 ?? 0.0;
        }

        // ============ TEMPERATURE ============
        // Get base values in Celsius
        double tempC = (cityWeatherModel.temperatureC ?? cityWeatherModel.temperature ?? 0.0).toDouble();
        double highC = (cityWeatherModel.high ?? 0.0).toDouble();
        double lowC = (cityWeatherModel.low ?? 0.0).toDouble();
        double feelsLikeC = (cityWeatherModel.feelsLike ?? 0.0).toDouble();

        if (temperatureUnit.value == "°F") {
          // Use API's Fahrenheit value if available, otherwise convert
          temperature.value = cityWeatherModel.temperatureF != null
              ? (cityWeatherModel.temperatureF).toDouble()
              : _celsiusToFahrenheit(tempC);
          // API doesn't provide high/low in Fahrenheit, so convert
          highTemperature.value = _celsiusToFahrenheit(highC);
          lowTemperature.value = _celsiusToFahrenheit(lowC);
          feelsLikeTemp.value = _celsiusToFahrenheit(feelsLikeC);
        } else {
          temperature.value = tempC;
          highTemperature.value = highC;
          lowTemperature.value = lowC;
          feelsLikeTemp.value = feelsLikeC;
        }

        // ============ UV INDEX ============
        uvIndex.value = (cityWeatherModel.uvIndex ?? 0).round();

        // ============ SUNRISE/SUNSET ============
        sunrise.value = cityWeatherModel.sunrise ?? 'N/A';
        sunset.value = cityWeatherModel.sunset ?? 'N/A';

        // ============ WIND ============
        if (windUnit.value == "m/s") {
          windSpeed.value = (cityWeatherModel.windSpeedMs ?? 0).toStringAsFixed(1);
        } else if (windUnit.value == "KM/h") {
          // Convert from knots to km/h if needed
          double knots = (cityWeatherModel.windSpeedKnots ?? 0).toDouble();
          windSpeed.value = (knots * 1.852).toStringAsFixed(1);
        } else {
          // Knots (default)
          windSpeed.value = (cityWeatherModel.windSpeedKnots ?? 0).toStringAsFixed(1);
        }
        windDirection.value =
            _convertWindDirectionToDegrees(cityWeatherModel.windDirection);

        // ============ RAINFALL ============
        lastHourRain.value = (cityWeatherModel.rain1h ?? 0).toDouble();
        next24hRain.value = (cityWeatherModel.rain24h ?? 0).toDouble();

        // ============ DEW POINT ============
        if (dewPointUnit.value == "°F") {
          dewPoint.value = cityWeatherModel.dewPointF != null
              ? (cityWeatherModel.dewPointF).toDouble()
              : _celsiusToFahrenheit((cityWeatherModel.dewPointC ?? 0).toDouble());
        } else {
          dewPoint.value = (cityWeatherModel.dewPointC ?? cityWeatherModel.dewPoint ?? 0).toDouble();
        }

        // ============ HUMIDITY ============
        humidity.value = (cityWeatherModel.humidity ?? 0).toInt();

        // ============ VISIBILITY ============
        if (visibilityUnit.value == "SM") {
          visibilityKm.value = (cityWeatherModel.visibilitySm ?? 0).toStringAsFixed(1);
        } else if (visibilityUnit.value == "NM") {
          visibilityKm.value = (cityWeatherModel.visibilityNm ?? 0).toStringAsFixed(1);
        } else {
          // KM (default)
          visibilityKm.value = (cityWeatherModel.visibilityKm ?? 0).toStringAsFixed(1);
        }
        description.value = _getVisibilityNote(cityWeatherModel.visibility ?? 0);

        // ============ PRESSURE ============
        // Get the base pressure value in hPa
        double pressureHpa = (cityWeatherModel.pressureHpa ?? cityWeatherModel.pressure ?? 1013.25).toDouble();

        if (pressureUnit.value == "inHg") {
          // Use API's inHg value if available, otherwise convert
          double pressureInhg = cityWeatherModel.pressureInhg != null
              ? (cityWeatherModel.pressureInhg).toDouble()
              : _hpaToInhg(pressureHpa);
          pressure.value = pressureInhg.toStringAsFixed(2);
        } else {
          // hPa (default)
          pressure.value = pressureHpa.toStringAsFixed(0);
        }

        // Calculate normalized pressure for gauge (950-1050 hPa range)
        // Standard: 1013.25 hPa = 29.92 inHg (center of gauge)
        double normalized = ((pressureHpa - 950) / (1050 - 950)).clamp(0.0, 1.0);
        pressurePercent.value = normalized;

        // ============ FEELS LIKE NOTE ============
        note.value = _getFeelsLikeNote(feelsLikeC, tempC);

        inAsyncCall.value = false;
        increment();
      } else {
        inAsyncCall.value = false;
      }
    } catch (e) {
      print("getWeatherApiCalling error: ${e.toString()}");
      inAsyncCall.value = false;
    }
  }

  double _convertWindDirectionToDegrees(String? dir) {
    switch (dir?.toUpperCase()) {
      case 'N':
        return 0.0;
      case 'NNE':
        return 22.5;
      case 'NE':
        return 45.0;
      case 'ENE':
        return 67.5;
      case 'E':
        return 90.0;
      case 'ESE':
        return 112.5;
      case 'SE':
        return 135.0;
      case 'SSE':
        return 157.5;
      case 'S':
        return 180.0;
      case 'SSW':
        return 202.5;
      case 'SW':
        return 225.0;
      case 'WSW':
        return 247.5;
      case 'W':
        return 270.0;
      case 'WNW':
        return 292.5;
      case 'NW':
        return 315.0;
      case 'NNW':
        return 337.5;
      default:
        return 0.0;
    }
  }

  String _getFeelsLikeNote(double? feelsLike, double? actual) {
    if (feelsLike == null || actual == null) return "N/A";
    double diff = (feelsLike - actual).abs();
    if (diff < 2) return "Similar to the actual temperature.";
    return feelsLike > actual
        ? "Feels warmer due to humidity."
        : "Feels colder due to wind.";
  }

  String _getVisibilityNote(double? visibility) {
    if (visibility == null) return "N/A";
    if (visibility < 1) return "Very poor visibility. Fog likely.";
    if (visibility < 4) return "Poor visibility conditions.";
    if (visibility < 10) return "Moderate visibility.";
    return "Clear visibility conditions.";
  }

  void increment() => count.value++;
}