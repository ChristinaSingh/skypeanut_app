// ─────────────────────────────────────────────────────────────────────────────
// get_find_routes_model.dart
// Supports: flight-search API + flight-details API
// ─────────────────────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════════════════════
//  FLIGHT-SEARCH  →  /api/v1/flight-search
// ══════════════════════════════════════════════════════════════════════════════

class FindRoutesModel {
  String? status;
  String? message;
  FindRoutesData? data;

  FindRoutesModel({this.status, this.message, this.data});

  factory FindRoutesModel.fromJson(Map<String, dynamic> json) =>
      FindRoutesModel(
        status: json['status']?.toString(),
        message: json['message'],
        data: json['data'] != null ? FindRoutesData.fromJson(json['data']) : null,
      );
}

class FindRoutesData {
  FlightInformation? flightInformation;
  ResolvedLocations? resolvedLocations;
  RouteInfo? routeInfo;
  ArrivalWeather? arrivalWeather;
  DepartureForecast? departureForecast;

  FindRoutesData({
    this.flightInformation,
    this.resolvedLocations,
    this.routeInfo,
    this.arrivalWeather,
    this.departureForecast,
  });

  factory FindRoutesData.fromJson(Map<String, dynamic> json) => FindRoutesData(
    flightInformation: json['flight_information'] != null
        ? FlightInformation.fromJson(json['flight_information'])
        : null,
    resolvedLocations: json['resolved_locations'] != null
        ? ResolvedLocations.fromJson(json['resolved_locations'])
        : null,
    routeInfo:
    json['route_info'] != null ? RouteInfo.fromJson(json['route_info']) : null,
    arrivalWeather: json['arrival_weather'] != null
        ? ArrivalWeather.fromJson(json['arrival_weather'])
        : null,
    departureForecast: json['departure_forecast'] != null
        ? DepartureForecast.fromJson(json['departure_forecast'])
        : null,
  );
}

class FlightInformation {
  String? carrierCode;
  String? flightNumber;
  String? fullFlightNumber;
  bool? available;

  FlightInformation(
      {this.carrierCode, this.flightNumber, this.fullFlightNumber, this.available});

  factory FlightInformation.fromJson(Map<String, dynamic> json) =>
      FlightInformation(
        carrierCode: json['carrier_code'],
        flightNumber: json['flight_number']?.toString(),
        fullFlightNumber: json['full_flight_number'],
        available: json['available'],
      );
}

class ResolvedLocations {
  ResolvedAirport? from;
  ResolvedAirport? to;

  ResolvedLocations({this.from, this.to});

  factory ResolvedLocations.fromJson(Map<String, dynamic> json) =>
      ResolvedLocations(
        from: json['from'] != null ? ResolvedAirport.fromJson(json['from']) : null,
        to: json['to'] != null ? ResolvedAirport.fromJson(json['to']) : null,
      );
}

class ResolvedAirport {
  String? input;
  String? airportCode;
  String? icaoCode;
  String? airportName;
  String? city;
  String? country;
  String? matchedBy;

  ResolvedAirport(
      {this.input,
        this.airportCode,
        this.icaoCode,
        this.airportName,
        this.city,
        this.country,
        this.matchedBy});

  factory ResolvedAirport.fromJson(Map<String, dynamic> json) => ResolvedAirport(
    input: json['input'],
    airportCode: json['airport_code'],
    icaoCode: json['icao_code'],
    airportName: json['airport_name'],
    city: json['city'],
    country: json['country'],
    matchedBy: json['matched_by'],
  );
}

class RouteInfo {
  String? from;
  String? to;
  String? departureDate;

  RouteInfo({this.from, this.to, this.departureDate});

  factory RouteInfo.fromJson(Map<String, dynamic> json) => RouteInfo(
    from: json['from'],
    to: json['to'],
    departureDate: json['departure_date'],
  );
}

/// Shared weather model – used by both arrival_weather and arrival_city_weather
class ArrivalWeather {
  String? location;
  double? temperature;
  double? feelsLike;
  double? tempMin;
  double? tempMax;
  String? condition;
  String? description;
  int? humidity;
  int? pressure;
  double? windSpeedMs;
  double? windSpeedKmh;
  int? visibilityKm;
  int? clouds;

  ArrivalWeather({
    this.location,
    this.temperature,
    this.feelsLike,
    this.tempMin,
    this.tempMax,
    this.condition,
    this.description,
    this.humidity,
    this.pressure,
    this.windSpeedMs,
    this.windSpeedKmh,
    this.visibilityKm,
    this.clouds,
  });

  factory ArrivalWeather.fromJson(Map<String, dynamic> json) => ArrivalWeather(
    location: json['location'],
    temperature: (json['temperature'] as num?)?.toDouble(),
    feelsLike: (json['feels_like'] as num?)?.toDouble(),
    tempMin: (json['temp_min'] as num?)?.toDouble(),
    tempMax: (json['temp_max'] as num?)?.toDouble(),
    condition: json['condition'],
    description: json['description'],
    humidity: (json['humidity'] as num?)?.toInt(),
    pressure: (json['pressure'] as num?)?.toInt(),
    windSpeedMs: (json['wind_speed_ms'] as num?)?.toDouble(),
    windSpeedKmh: (json['wind_speed_kmh'] as num?)?.toDouble(),
    visibilityKm: (json['visibility_km'] as num?)?.toInt(),
    clouds: (json['clouds'] as num?)?.toInt(),
  );
}

class DepartureForecast {
  int? punctualityPercentage;
  int? avgDepartureDelayMinutes;
  double? avgDepartureDelayHours;
  DelayCategories? delayCategories;
  Past30FlightsSummary? past30FlightsSummary;

  DepartureForecast({
    this.punctualityPercentage,
    this.avgDepartureDelayMinutes,
    this.avgDepartureDelayHours,
    this.delayCategories,
    this.past30FlightsSummary,
  });

  factory DepartureForecast.fromJson(Map<String, dynamic> json) =>
      DepartureForecast(
        punctualityPercentage: (json['punctuality_percentage'] as num?)?.toInt(),
        avgDepartureDelayMinutes:
        (json['avg_departure_delay_minutes'] as num?)?.toInt(),
        avgDepartureDelayHours:
        (json['avg_departure_delay_hours'] as num?)?.toDouble(),
        delayCategories: json['delay_categories'] != null
            ? DelayCategories.fromJson(json['delay_categories'])
            : null,
        past30FlightsSummary: json['past_30_flights_summary'] != null
            ? Past30FlightsSummary.fromJson(json['past_30_flights_summary'])
            : null,
      );
}

class DelayCategories {
  int? early;
  int? onTime;
  int? late30Min;
  int? late60Min;
  int? late90Min;
  int? cancelled;

  DelayCategories(
      {this.early,
        this.onTime,
        this.late30Min,
        this.late60Min,
        this.late90Min,
        this.cancelled});

  factory DelayCategories.fromJson(Map<String, dynamic> json) =>
      DelayCategories(
        early: (json['early'] as num?)?.toInt(),
        onTime: (json['on_time'] as num?)?.toInt(),
        late30Min: (json['late_30_min'] as num?)?.toInt(),
        late60Min: (json['late_60_min'] as num?)?.toInt(),
        late90Min: (json['late_90_min'] as num?)?.toInt(),
        cancelled: (json['cancelled'] as num?)?.toInt(),
      );
}

class Past30FlightsSummary {
  int? total;
  int? onTime;
  int? delayed;
  int? cancelled;

  Past30FlightsSummary({this.total, this.onTime, this.delayed, this.cancelled});

  factory Past30FlightsSummary.fromJson(Map<String, dynamic> json) =>
      Past30FlightsSummary(
        total: (json['total'] as num?)?.toInt(),
        onTime: (json['on_time'] as num?)?.toInt(),
        delayed: (json['delayed'] as num?)?.toInt(),
        cancelled: (json['cancelled'] as num?)?.toInt(),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
//  FLIGHT-DETAILS  →  /api/v1/flight-details
// ══════════════════════════════════════════════════════════════════════════════

class FlightDetailsModel {
  String? status;
  String? message;
  FlightDetailsData? data;

  FlightDetailsModel({this.status, this.message, this.data});

  factory FlightDetailsModel.fromJson(Map<String, dynamic> json) =>
      FlightDetailsModel(
        status: json['status']?.toString(),
        message: json['message'],
        data: json['data'] != null ? FlightDetailsData.fromJson(json['data']) : null,
      );
}

class FlightDetailsData {
  FlightSchedule? flightSchedule;
  ArrivalWeather? arrivalCityWeather; // reuses ArrivalWeather model
  PassengerInfo? passengerInfo;

  FlightDetailsData(
      {this.flightSchedule, this.arrivalCityWeather, this.passengerInfo});

  factory FlightDetailsData.fromJson(Map<String, dynamic> json) =>
      FlightDetailsData(
        flightSchedule: json['flight_schedule'] != null
            ? FlightSchedule.fromJson(json['flight_schedule'])
            : null,
        arrivalCityWeather: json['arrival_city_weather'] != null
            ? ArrivalWeather.fromJson(json['arrival_city_weather'])
            : null,
        passengerInfo: json['passenger_info'] != null
            ? PassengerInfo.fromJson(json['passenger_info'])
            : null,
      );
}

class FlightSchedule {
  String? flightNumber;
  String? status;
  ScheduleEndpoint? departure;
  ScheduleEndpoint? arrival;

  FlightSchedule(
      {this.flightNumber, this.status, this.departure, this.arrival});

  factory FlightSchedule.fromJson(Map<String, dynamic> json) => FlightSchedule(
    flightNumber: json['flight_number'],
    status: json['status'],
    departure: json['departure'] != null
        ? ScheduleEndpoint.fromJson(json['departure'])
        : null,
    arrival: json['arrival'] != null
        ? ScheduleEndpoint.fromJson(json['arrival'])
        : null,
  );
}

class ScheduleEndpoint {
  String? airport;
  String? city;
  String? country;
  String? terminal;
  String? gate;
  String? scheduledTime;
  String? checkInTime;
  String? checkInOpens;
  String? baggageClaim;

  ScheduleEndpoint({
    this.airport,
    this.city,
    this.country,
    this.terminal,
    this.gate,
    this.scheduledTime,
    this.checkInTime,
    this.checkInOpens,
    this.baggageClaim,
  });

  factory ScheduleEndpoint.fromJson(Map<String, dynamic> json) =>
      ScheduleEndpoint(
        airport: json['airport'],
        city: json['city'],
        country: json['country'],
        terminal: json['terminal'],
        gate: json['gate'],
        scheduledTime: json['scheduled_time'],
        checkInTime: json['check_in_time'],
        checkInOpens: json['check_in_opens'],
        baggageClaim: json['baggage_claim'],
      );

  /// "20:45" from ISO datetime string
  String get displayTime {
    if (scheduledTime == null || scheduledTime!.isEmpty) return "--";
    try {
      final dt = DateTime.parse(scheduledTime!);
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      final parts = scheduledTime!.split('T');
      if (parts.length > 1) return parts[1].substring(0, 5);
      return scheduledTime!;
    }
  }

  /// "Feb 26, 2026" from ISO datetime string
  String get displayDate {
    if (scheduledTime == null || scheduledTime!.isEmpty) return "--";
    try {
      final dt = DateTime.parse(scheduledTime!);
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      return "${months[dt.month - 1]} ${dt.day}, ${dt.year}";
    } catch (_) {
      return scheduledTime!.split('T').first;
    }
  }

  /// Clean check-in display time
  String get checkInDisplayTime {
    if (checkInTime == null || checkInTime!.isEmpty) return "--";
    try {
      final dt = DateTime.parse(checkInTime!);
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return checkInTime!;
    }
  }
}

class PassengerInfo {
  String? checkInOpens;
  String? boardingGate;
  String? baggageAllowance;
  String? baggageClaimBelt;

  PassengerInfo(
      {this.checkInOpens,
        this.boardingGate,
        this.baggageAllowance,
        this.baggageClaimBelt});

  factory PassengerInfo.fromJson(Map<String, dynamic> json) => PassengerInfo(
    checkInOpens: json['check_in_opens'],
    boardingGate: json['boarding_gate'],
    baggageAllowance: json['baggage_allowance'],
    baggageClaimBelt: json['baggage_claim_belt'],
  );
}

// ── Legacy stubs (kept so other screens don't break) ─────────────────────────
class From {
  String? iataCode;
  String? name;
  String? city;
  String? country;
  From({this.iataCode, this.name, this.city, this.country});
  factory From.fromJson(Map<String, dynamic> json) => From(
      iataCode: json['iata_code'], name: json['name'],
      city: json['city'], country: json['country']);
}

class FlightInfo {
  dynamic distanceKm;
  dynamic distanceMiles;
  String? estimatedFlightTime;
  String? routeType;
  FlightInfo({this.distanceKm, this.distanceMiles, this.estimatedFlightTime, this.routeType});
  factory FlightInfo.fromJson(Map<String, dynamic> json) => FlightInfo(
      distanceKm: json['distance_km'], distanceMiles: json['distance_miles'],
      estimatedFlightTime: json['estimated_flight_time'], routeType: json['route_type']);
}

class FlightTimes {
  Departure? departure;
  Departure? arrival;
  String? flightDuration;
  FlightTimes({this.departure, this.arrival, this.flightDuration});
  factory FlightTimes.fromJson(Map<String, dynamic> json) => FlightTimes(
      departure: json['departure'] != null ? Departure.fromJson(json['departure']) : null,
      arrival: json['arrival'] != null ? Departure.fromJson(json['arrival']) : null,
      flightDuration: json['flight_duration']);
}

class Departure {
  String? date;
  String? time;
  String? day;
  Departure({this.date, this.time, this.day});
  factory Departure.fromJson(Map<String, dynamic> json) =>
      Departure(date: json['date'], time: json['time'], day: json['day']);
}

class CurrentInfo {
  String? currentDate;
  String? currentTime;
  String? dayOfWeek;
  CurrentInfo({this.currentDate, this.currentTime, this.dayOfWeek});
  factory CurrentInfo.fromJson(Map<String, dynamic> json) => CurrentInfo(
      currentDate: json['current_date'], currentTime: json['current_time'],
      dayOfWeek: json['day_of_week']);
}