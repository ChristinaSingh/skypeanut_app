class WeatherUnitConverter {
  /// Convert wind speed
  static String convertWind(double windSpeedMps, String unit) {
    if (unit == "Knots") {
      return (windSpeedMps * 1.94384).toStringAsFixed(1);
    } else {
      return windSpeedMps.toStringAsFixed(1); // m/s
    }
  }

  /// Convert visibility
  static String convertVisibility(double visibilityMeters, String unit) {
    if (unit == "KM") return (visibilityMeters / 1000).toStringAsFixed(1);
    if (unit == "SM") return (visibilityMeters / 1609.34).toStringAsFixed(1);
    if (unit == "NM") return (visibilityMeters / 1852).toStringAsFixed(1);
    return visibilityMeters.toStringAsFixed(1);
  }

  /// Convert temperature & dew point
  static String convertTemperature(double celsius, String unit) {
    if (unit == "°F") return ((celsius * 9 / 5) + 32).toStringAsFixed(1);
    return celsius.toStringAsFixed(1);
  }

  /// Convert pressure
  static String convertPressure(double hPa, String unit) {
    if (unit == "inHg") return (hPa * 0.02953).toStringAsFixed(2);
    return hPa.toStringAsFixed(1);
  }
}
