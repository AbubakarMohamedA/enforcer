// To parse this JSON data, do
//
//     final getDailyOffloadingApplications = getDailyOffloadingApplicationsFromJson(jsonString);

import 'dart:convert';

GetDailyOffloadingApplications getDailyOffloadingApplicationsFromJson(String str) => GetDailyOffloadingApplications.fromJson(json.decode(str));

String getDailyOffloadingApplicationsToJson(GetDailyOffloadingApplications data) => json.encode(data.toJson());

class GetDailyOffloadingApplications {
  List<GetDailyOffloadingApplicationDatum> data;
  String status;

  GetDailyOffloadingApplications({
    required this.data,
    required this.status,
  });

  factory GetDailyOffloadingApplications.fromJson(Map<String, dynamic> json) => GetDailyOffloadingApplications(
    data: List<GetDailyOffloadingApplicationDatum>.from(json["data"].map((x) => GetDailyOffloadingApplicationDatum.fromJson(x))),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "status": status,
  };
}

class GetDailyOffloadingApplicationDatum {
  int id;
  DateTime? createdDate;
  String fullName;
  String? phoneNumber;
  String? vehicleType;
  String? plateNo;
  String? origin;
  String? destination;
  int? zone;
  String? status;
  String? totalAmount;
  DateTime? updatedDate;
  int? createdBy;
  String? enforcerName;
  String? vehicleTypeName;
  DateTime? receiptDate;
  String? zoneName;
  String? penalty;
  String? receiptId;
  List<Item>? items; // Add this field

  GetDailyOffloadingApplicationDatum({
    required this.id,
    required this.receiptId,
    required this.createdDate,
    required this.fullName,
    required this.penalty,
    required this.phoneNumber,
    required this.vehicleType,
    required this.plateNo,
    required this.origin,
    required this.destination,
    required this.zone,
    required this.status,
    required this.totalAmount,
    required this.updatedDate,
    required this.createdBy,
    required this.enforcerName,
    required this.vehicleTypeName,
    required this.zoneName,
    required this.receiptDate,
    this.items,
  });

  factory GetDailyOffloadingApplicationDatum.fromJson(Map<String, dynamic> json) => GetDailyOffloadingApplicationDatum(
    id: json["id"],
    receiptId: json["receipt_id"] == null ? null : json["receipt_id"].toString(),
    createdDate: json["created_date"] == null ? null : DateTime.parse(json["created_date"]),
    receiptDate: json["receipt_date"] == null ? null : DateTime.parse(json["receipt_date"]),
    fullName: json["full_name"],
    phoneNumber: json["phone_number"],
    vehicleType: json["vehicle_type"],
    plateNo: json["plate_no"],
    penalty: json['penalty'].toString(),
    origin: json["origin"],
    destination: json["destination"],
    zone: json["zone"],
    status: json["status"],
    totalAmount: json["total_amount"],
    updatedDate: json["updated_date"] == null ? null : DateTime.parse(json["updated_date"]),
    createdBy: json["created_by"],
    enforcerName: json["enforcer_name"],
    vehicleTypeName: json["vehicle_type_name"],
    zoneName: json["zone_name"],
    items: json["items"] == null
        ? null
        : List<Item>.from(json["items"].map((x) => Item.fromJson(x))), // Handle nullable

  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_date": createdDate?.toIso8601String(),
    "full_name": fullName,
    "phone_number": phoneNumber,
    "vehicle_type": vehicleType,
    "plate_no": plateNo,
    "origin": origin,
    "destination": destination,
    "zone": zone,
    "status": status,
    "total_amount": totalAmount,
    "updated_date": updatedDate?.toIso8601String(),
    "created_by": createdBy,
    "enforcer_name": enforcerName,
    "vehicle_type_name": vehicleTypeName,
    "zone_name": zoneName,
    "items": items == null
        ? [] // Return an empty list if items is null
        : List<dynamic>.from(items!.map((x) => x.toJson())), // Handle non-null items

  };
}

class Item {
  int? id;
  int? itemId;
  String? amount;
  int? quantity;
  String? totalAmount;
  int? applicationId;
  int? createdBy;
  DateTime? createdAt;
  String? itemName;
  String? uom;

  Item({
    required this.id,
    required this.itemId,
    required this.amount,
    required this.quantity,
    required this.totalAmount,
    required this.applicationId,
    required this.createdBy,
    required this.createdAt,
    required this.itemName,
    required this.uom,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"],
    itemId: json["item_id"],
    amount: json["amount"],
    quantity: json["quantity"],
    totalAmount: json["total_amount"],
    applicationId: json["application_id"],
    createdBy: json["created_by"],
    createdAt:json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    itemName: json["item_name"],
    uom: json["uom"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "item_id": itemId,
    "amount": amount,
    "quantity": quantity,
    "total_amount": totalAmount,
    "application_id": applicationId,
    "created_by": createdBy,
    "created_at": createdAt?.toIso8601String(),
    "item_name": itemName,
    "uom": uom,
  };
}
