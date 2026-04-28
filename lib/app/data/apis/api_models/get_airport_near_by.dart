class NearbyAirportModel {
  String? status;
  String? message;
  int? requestedCount;
  int? actualCount;
  List<Airports>? airports;

  NearbyAirportModel(
      {this.status,
        this.message,
        this.requestedCount,
        this.actualCount,
        this.airports});

  NearbyAirportModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    requestedCount = json['requested_count'];
    actualCount = json['actual_count'];
    if (json['airports'] != null) {
      airports = <Airports>[];
      json['airports'].forEach((v) {
        airports!.add(Airports.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['requested_count'] = requestedCount;
    data['actual_count'] = actualCount;
    if (airports != null) {
      data['airports'] = airports!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Airports {
  int? rank;
  String? icaoCode;
  String? iataCode;
  String? name;
  String? city;
  String? state;
  String? country;
  double? latitude;
  double? longitude;
  int? elevationFt;
  double? distanceKm;
  double? distanceMiles;
  String? stationType;
  String? website;
  String? wiki;

  Airports(
      {this.rank,
        this.icaoCode,
        this.iataCode,
        this.name,
        this.city,
        this.state,
        this.country,
        this.latitude,
        this.longitude,
        this.elevationFt,
        this.distanceKm,
        this.distanceMiles,
        this.stationType,
        this.website,
        this.wiki});

  Airports.fromJson(Map<String, dynamic> json) {
    rank = json['rank'];
    icaoCode = json['icao_code'];
    iataCode = json['iata_code'];
    name = json['name'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    elevationFt = json['elevation_ft'];
    distanceKm = json['distance_km'];
    distanceMiles = json['distance_miles'];
    stationType = json['station_type'];
    website = json['website'];
    wiki = json['wiki'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rank'] = rank;
    data['icao_code'] = icaoCode;
    data['iata_code'] = iataCode;
    data['name'] = name;
    data['city'] = city;
    data['state'] = state;
    data['country'] = country;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['elevation_ft'] = elevationFt;
    data['distance_km'] = distanceKm;
    data['distance_miles'] = distanceMiles;
    data['station_type'] = stationType;
    data['website'] = website;
    data['wiki'] = wiki;
    return data;
  }
}
