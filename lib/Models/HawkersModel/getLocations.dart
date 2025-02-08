// To parse this JSON data, do
//
//     final getLocations = getLocationsFromJson(jsonString);

import 'dart:convert';

GetLocations getLocationsFromJson(String str) => GetLocations.fromJson(json.decode(str));

String getLocationsToJson(GetLocations data) => json.encode(data.toJson());

class GetLocations {
  String status;
  List<LocationsDatum> data;

  GetLocations({
    required this.status,
    required this.data,
  });

  factory GetLocations.fromJson(Map<String, dynamic> json) => GetLocations(
    status: json["status"],
    data: List<LocationsDatum>.from(json["data"].map((x) => LocationsDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class LocationsDatum {
  int? zoneId;
  String? zoneName;
  int? locationId;
  String? locationName;

  LocationsDatum({
    required this.zoneId,
    required this.zoneName,
    required this.locationId,
    required this.locationName,
  });

  factory LocationsDatum.fromJson(Map<String, dynamic> json) => LocationsDatum(
    zoneId: json["zoneId"],
    zoneName: json['zoneName'],
    locationId: json["locationId"],
    locationName: json["locationName"],
  );

  Map<String, dynamic> toJson() => {
    "zoneId": zoneId,
    "zoneName": zoneName,
    "locationId": locationId,
    "locationName": locationName,
  };
}
