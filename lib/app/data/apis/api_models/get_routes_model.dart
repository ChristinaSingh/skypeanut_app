class RoutesAirportModel {
  String? status;
  List<Routes1>? routes;
  FromAirport1? fromAirport1;
  var totalRoutes;

  RoutesAirportModel(
      {this.status, this.routes, this.fromAirport1, this.totalRoutes});

  RoutesAirportModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['routes'] != null) {
      routes = <Routes1>[];
      json['routes'].forEach((v) {
        routes!.add(Routes1.fromJson(v));
      });
    }
    fromAirport1 = json['from_airport1'] != null
        ? FromAirport1.fromJson(json['from_airport1'])
        : null;
    totalRoutes = json['total_routes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (routes != null) {
      data['routes'] = routes!.map((v) => v.toJson()).toList();
    }
    if (fromAirport1 != null) {
      data['from_airport1'] = fromAirport1!.toJson();
    }
    data['total_routes'] = totalRoutes;
    return data;
  }
}

class Routes1 {
  String? name;
  String? summary;
  var distanceKm;
  var distanceNm;
  FromAirport? fromAirport;
  FromAirport? toAirport;
  RouteInfo? routeInfo;

  Routes1(
      {this.name,
        this.summary,
        this.distanceKm,
        this.distanceNm,
        this.fromAirport,
        this.toAirport,
        this.routeInfo});

  Routes1.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    summary = json['summary'];
    distanceKm = json['distance_km'];
    distanceNm = json['distance_nm'];
    fromAirport = json['from_airport'] != null
        ? FromAirport.fromJson(json['from_airport'])
        : null;
    toAirport = json['to_airport'] != null
        ? FromAirport.fromJson(json['to_airport'])
        : null;
    routeInfo = json['route_info'] != null
        ? RouteInfo.fromJson(json['route_info'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['summary'] = summary;
    data['distance_km'] = distanceKm;
    data['distance_nm'] = distanceNm;
    if (fromAirport != null) {
      data['from_airport'] = fromAirport!.toJson();
    }
    if (toAirport != null) {
      data['to_airport'] = toAirport!.toJson();
    }
    if (routeInfo != null) {
      data['route_info'] = routeInfo!.toJson();
    }
    return data;
  }
}

class FromAirport {
  String? icao;
  String? name;
  String? city;
  Coordinates? coordinates;

  FromAirport({this.icao, this.name, this.city, this.coordinates});

  FromAirport.fromJson(Map<String, dynamic> json) {
    icao = json['icao'];
    name = json['name'];
    city = json['city'];
    coordinates = json['coordinates'] != null
        ? Coordinates.fromJson(json['coordinates'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['icao'] = icao;
    data['name'] = name;
    data['city'] = city;
    if (coordinates != null) {
      data['coordinates'] = coordinates!.toJson();
    }
    return data;
  }
}

class Coordinates {
  var latitude;
  var longitude;

  Coordinates({this.latitude, this.longitude});

  Coordinates.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class RouteInfo {
  var estimatedFlightTimeMinutes;
  var bearingDegrees;

  RouteInfo({this.estimatedFlightTimeMinutes, this.bearingDegrees});

  RouteInfo.fromJson(Map<String, dynamic> json) {
    estimatedFlightTimeMinutes = json['estimated_flight_time_minutes'];
    bearingDegrees = json['bearing_degrees'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['estimated_flight_time_minutes'] = estimatedFlightTimeMinutes;
    data['bearing_degrees'] = bearingDegrees;
    return data;
  }
}

class FromAirport1 {
  String? icao;
  String? name;
  var latitude;
  var longitude;

  FromAirport1({this.icao, this.name, this.latitude, this.longitude});

  FromAirport1.fromJson(Map<String, dynamic> json) {
    icao = json['icao'];
    name = json['name'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['icao'] = icao;
    data['name'] = name;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
