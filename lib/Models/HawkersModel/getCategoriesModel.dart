// To parse this JSON data, do
//
//     final getCategories = getCategoriesFromJson(jsonString);

import 'dart:convert';

GetCategories getCategoriesFromJson(String str) => GetCategories.fromJson(json.decode(str));

String getCategoriesToJson(GetCategories data) => json.encode(data.toJson());

class GetCategories {
  String status;
  List<CategoriesDatum> data;

  GetCategories({
    required this.status,
    required this.data,
  });

  factory GetCategories.fromJson(Map<String, dynamic> json) => GetCategories(
    status: json["status"],
    data: List<CategoriesDatum>.from(json["data"].map((x) => CategoriesDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class CategoriesDatum {
  int? id;
  String? name;
  DateTime? createdAt;
  int? createdBy;
  DateTime? updatedAt;
  dynamic updatedBy;

  CategoriesDatum({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory CategoriesDatum.fromJson(Map<String, dynamic> json) => CategoriesDatum(
    id: json["id"],
    name: json["name"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    createdBy: json["created_by"],
    updatedAt:json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    updatedBy: json["updated_by"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "created_at": createdAt!.toIso8601String(),
    "created_by": createdBy,
    "updated_at": updatedAt?.toIso8601String(),
    "updated_by": updatedBy,
  };
}
