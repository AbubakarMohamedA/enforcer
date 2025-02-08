// To parse this JSON data, do
//
//     final getOffloadingVehicleType = getOffloadingVehicleTypeFromJson(jsonString);

import 'dart:convert';

GetOffloadingVehicleType getOffloadingVehicleTypeFromJson(String str) => GetOffloadingVehicleType.fromJson(json.decode(str));

String getOffloadingVehicleTypeToJson(GetOffloadingVehicleType data) => json.encode(data.toJson());

class GetOffloadingVehicleType {
  List<OffLoadingVehcleDatum> data;
  String status;

  GetOffloadingVehicleType({
    required this.data,
    required this.status,
  });

  factory GetOffloadingVehicleType.fromJson(Map<String, dynamic> json) => GetOffloadingVehicleType(
    data: List<OffLoadingVehcleDatum>.from(json["data"].map((x) => OffLoadingVehcleDatum.fromJson(x))),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "status": status,
  };
}

class OffLoadingVehcleDatum {
  int id;
  String? name;
  int? createdBy;
  DateTime? createdAt;
  dynamic updatedBy;
  dynamic updatedAt;

  OffLoadingVehcleDatum({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
  });

  factory OffLoadingVehcleDatum.fromJson(Map<String, dynamic> json) => OffLoadingVehcleDatum(
    id: json["id"],
    name: json["name"],
    createdBy: json["created_by"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedBy: json["updated_by"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "created_by": createdBy,
    "created_at": createdAt!.toIso8601String(),
    "updated_by": updatedBy,
    "updated_at": updatedAt,
  };
}
