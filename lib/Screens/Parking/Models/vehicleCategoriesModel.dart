// To parse this JSON data, do
//
//     final getVehicleCategoriesModel = getVehicleCategoriesModelFromJson(jsonString);

import 'dart:convert';

List<GetVehicleCategoriesModel> getVehicleCategoriesModelFromJson(String str) => List<GetVehicleCategoriesModel>.from(json.decode(str).map((x) => GetVehicleCategoriesModel.fromJson(x)));

String getVehicleCategoriesModelToJson(List<GetVehicleCategoriesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetVehicleCategoriesModel {
  int id;
  String title;

  GetVehicleCategoriesModel({
    required this.id,
    required this.title,
  });

  factory GetVehicleCategoriesModel.fromJson(Map<String, dynamic> json) => GetVehicleCategoriesModel(
    id: json["id"],
    title: json["title"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
  };
}
