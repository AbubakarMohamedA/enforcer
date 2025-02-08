// To parse this JSON data, do
//
//     final getOffloadingZones = getOffloadingZonesFromJson(jsonString);

import 'dart:convert';

GetOffloadingZones getOffloadingZonesFromJson(String str) => GetOffloadingZones.fromJson(json.decode(str));

String getOffloadingZonesToJson(GetOffloadingZones data) => json.encode(data.toJson());

class GetOffloadingZones {
  List<OffLoadingZonesDatum> data;
  String status;

  GetOffloadingZones({
    required this.data,
    required this.status,
  });

  factory GetOffloadingZones.fromJson(Map<String, dynamic> json) => GetOffloadingZones(
    data: List<OffLoadingZonesDatum>.from(json["data"].map((x) => OffLoadingZonesDatum.fromJson(x))),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "status": status,
  };
}

class OffLoadingZonesDatum {
  int? id;
  String? name;
  int? createdBy;
  DateTime createdAt;
  dynamic updatedBy;
  DateTime? updatedAt;
  int? isActive;

  OffLoadingZonesDatum({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    required this.isActive,
  });

  factory OffLoadingZonesDatum.fromJson(Map<String, dynamic> json) => OffLoadingZonesDatum(
    id: json["id"],
    name: json["name"],
    createdBy: json["created_by"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedBy: json["updated_by"],
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    isActive: json["is_active"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "created_by": createdBy,
    "created_at": createdAt.toIso8601String(),
    "updated_by": updatedBy,
    "updated_at": updatedAt!.toIso8601String(),
    "is_active": isActive,
  };
}
