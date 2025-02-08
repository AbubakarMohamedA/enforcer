// To parse this JSON data, do
//
//     final getMyZones = getMyZonesFromJson(jsonString);

import 'dart:convert';

Map<String, GetMyZones> getMyZonesFromJson(String str) => Map.from(json.decode(str)).map((k, v) => MapEntry<String, GetMyZones>(k, GetMyZones.fromJson(v)));

String getMyZonesToJson(Map<String, GetMyZones> data) => json.encode(Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())));

class GetMyZones {
  String zoneId;
  String zoneName;
  List<Location> locations;

  GetMyZones({
    required this.zoneId,
    required this.zoneName,
    required this.locations,
  });

  factory GetMyZones.fromJson(Map<String, dynamic> json) => GetMyZones(
    zoneId: json["zoneId"],
    zoneName: json["zoneName"],
    locations: List<Location>.from(json["locations"].map((x) => Location.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "zoneId": zoneId,
    "zoneName": zoneName,
    "locations": List<dynamic>.from(locations.map((x) => x.toJson())),
  };
}

class Location {
  String zoneId;
  String locationId;
  String locationName;

  Location({
    required this.zoneId,
    required this.locationId,
    required this.locationName,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    zoneId: json["zoneId"],
    locationId: json["locationId"],
    locationName: json["locationName"],
  );

  Map<String, dynamic> toJson() => {
    "zoneId": zoneId,
    "locationId": locationId,
    "locationName": locationName,
  };
}
