// To parse this JSON data, do
//
//     final getZones = getZonesFromJson(jsonString);

import 'dart:convert';

GetZones getZonesFromJson(String str) => GetZones.fromJson(json.decode(str));

String getZonesToJson(GetZones data) => json.encode(data.toJson());

class GetZones {
  String status;
  List<Datum>? data;

  GetZones({
    required this.status,
    required this.data,
  });

  factory GetZones.fromJson(Map<String, dynamic> json) => GetZones(
    status: json["status"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  int? id;
  String? name;
  String? prefix;
  DateTime? createdAt;
  int? createdBy;
  DateTime? updatedAt;
  int? updatedBy;
  int? isActive;
  String? isDeleted;
  DateTime? deletedAt;
  dynamic deletedBy;

  Datum({
    required this.id,
    required this.name,
    required this.prefix,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.isActive,
    required this.isDeleted,
    required this.deletedAt,
    required this.deletedBy,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    name: json["name"],
    prefix: json["prefix"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    createdBy: json["createdBy"],
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    updatedBy: json["updatedBy"],
    isActive: json["is_active"],
    isDeleted: json["isDeleted"],
    deletedAt: json["deletedAt"] == null ? null : DateTime.parse(json["deletedAt"]),
    deletedBy: json["deletedBy"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "prefix": prefix,
    "createdAt": createdAt?.toIso8601String(),
    "createdBy": createdBy,
    "updatedAt": updatedAt?.toIso8601String(),
    "updatedBy": updatedBy,
    "is_active": isActive,
    "isDeleted": isDeleted,
    "deletedAt": deletedAt?.toIso8601String(),
    "deletedBy": deletedBy,
  };
}
