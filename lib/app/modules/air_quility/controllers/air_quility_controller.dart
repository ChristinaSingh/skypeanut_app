import 'dart:ui';

import 'package:get/get.dart';

class AirQuilityController extends GetxController {
  final count = 0.obs;

  // ─── Data from arguments ───────────────────────────────────────────────────
  final aqiUs = 0.obs;
  final aqiCategory = ''.obs;
  final aqiPm25 = 0.0.obs;
  final aqiPm10 = 0.0.obs;
  final city = ''.obs;
  final temperature = ''.obs;
  final humidity = ''.obs;
  final windSpeed = ''.obs;
  final windDirection = ''.obs;
  final condition = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
  }

  void _loadArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    aqiUs.value = args['aqi_us'] ?? 0;
    aqiCategory.value = args['category'] ?? '';
    aqiPm25.value = (args['pm25'] as num?)?.toDouble() ?? 0.0;
    aqiPm10.value = (args['pm10'] as num?)?.toDouble() ?? 0.0;
    city.value = args['city'] ?? '';
    temperature.value = args['temperature'] ?? '';
    humidity.value = args['humidity'] ?? '';
    windSpeed.value = args['wind_speed'] ?? '';
    windDirection.value = args['wind_direction'] ?? '';
    condition.value = args['condition'] ?? '';

    increment();
  }

  // ─── AQI helpers ───────────────────────────────────────────────────────────

  String get aqiLevel {
    final v = aqiUs.value;
    if (v <= 50) return 'Good';
    if (v <= 100) return 'Moderate';
    if (v <= 150) return 'Unhealthy for Sensitive Groups';
    if (v <= 200) return 'Unhealthy';
    if (v <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  String get aqiDescription {
    final v = aqiUs.value;
    if (v <= 50) {
      return 'Air quality is satisfactory, and air pollution poses little or no risk. '
          'Ideal conditions for outdoor activities including aviation operations.';
    }
    if (v <= 100) {
      return 'Air quality is acceptable. However, there may be a risk for some people, '
          'particularly those who are unusually sensitive to air pollution. '
          'Visibility may be slightly reduced.';
    }
    if (v <= 150) {
      return 'Members of sensitive groups may experience health effects. '
          'The general public is less likely to be affected. '
          'Pilots should note potential visibility reduction.';
    }
    if (v <= 200) {
      return 'Some members of the general public may experience health effects. '
          'Sensitive groups may experience more serious effects. '
          'Significant visibility reduction possible — check METARs.';
    }
    if (v <= 300) {
      return 'Health alert: The risk of health effects is increased for everyone. '
          'Visibility likely severely impacted. '
          'Review TAFs and NOTAMs before flight operations.';
    }
    return 'Health warning of emergency conditions. '
        'The entire population is likely to be affected. '
        'Aviation operations may be significantly impacted.';
  }

  String get healthAdvice {
    final v = aqiUs.value;
    if (v <= 50) return 'No precautions needed. Enjoy outdoor activities.';
    if (v <= 100) {
      return 'Unusually sensitive individuals should consider reducing '
          'prolonged outdoor exertion.';
    }
    if (v <= 150) {
      return 'Sensitive groups should reduce prolonged outdoor exertion. '
          'Consider wearing a mask outdoors.';
    }
    if (v <= 200) {
      return 'Everyone should reduce prolonged outdoor exertion. '
          'Use air purifiers indoors. Wear N95 mask outdoors.';
    }
    if (v <= 300) {
      return 'Everyone should avoid all outdoor exertion. '
          'Keep windows closed. Use air purifiers.';
    }
    return 'EMERGENCY: Remain indoors. Avoid all physical activity. '
        'Seek medical attention if experiencing symptoms.';
  }

  String get aviationImpact {
    final v = aqiUs.value;
    if (v <= 50) return 'No impact on flight operations. Clear visibility expected.';
    if (v <= 100) return 'Minimal impact. Monitor visibility reports.';
    if (v <= 150) {
      return 'Possible haze reducing visibility below 5km. '
          'Check METAR/TAF for current conditions.';
    }
    if (v <= 200) {
      return 'Likely visibility reduction. IFR conditions possible. '
          'File alternate airport plans.';
    }
    if (v <= 300) {
      return 'Severe visibility reduction expected. '
          'IFR/LIFR conditions likely. Delays and diversions possible.';
    }
    return 'CRITICAL: Visibility near zero possible. '
        'Airport closures likely. Do not attempt VFR operations.';
  }

  // Returns 0.0 to 1.0
  double get aqiProgress => (aqiUs.value / 500).clamp(0.0, 1.0);

  List<AqiScaleItem> get aqiScale => const [
    AqiScaleItem(0, 50, 'Good', Color(0xFF00E676)),
    AqiScaleItem(51, 100, 'Moderate', Color(0xFFFFEB3B)),
    AqiScaleItem(101, 150, 'Sensitive', Color(0xFFFF9800)),
    AqiScaleItem(151, 200, 'Unhealthy', Color(0xFFFF5252)),
    AqiScaleItem(201, 300, 'Very Unhealthy', Color(0xFF9C27B0)),
    AqiScaleItem(301, 500, 'Hazardous', Color(0xFF880E4F)),
  ];

  int get currentScaleIndex {
    final v = aqiUs.value;
    if (v <= 50) return 0;
    if (v <= 100) return 1;
    if (v <= 150) return 2;
    if (v <= 200) return 3;
    if (v <= 300) return 4;
    return 5;
  }

  void increment() => count.value++;
}

class AqiScaleItem {
  final int min;
  final int max;
  final String label;
  final Color color;

  const AqiScaleItem(this.min, this.max, this.label, this.color);
}