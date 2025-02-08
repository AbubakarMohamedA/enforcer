import 'dart:convert';

GetVehicleLastPaymentCess getVehicleLastPaymentCessFromJson(String str) => GetVehicleLastPaymentCess.fromJson(json.decode(str));

String getVehicleLastPaymentCessToJson(GetVehicleLastPaymentCess data) => json.encode(data.toJson());

class GetVehicleLastPaymentCess {
  LastApplicationData? data;
  String status;
  String? message;

  GetVehicleLastPaymentCess({
    this.data,
    required this.status,
    this.message,
  });

  factory GetVehicleLastPaymentCess.fromJson(Map<String, dynamic> json) => GetVehicleLastPaymentCess(
    data: json["data"] != null ? LastApplicationData.fromJson(json["data"]) : null,
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "status": status,
    "message": message,
  };
}

class LastApplicationData {
  int id;
  DateTime? createdDate;
  DateTime? approvalDate;
  String? accountType;
  String? applicationType;
  String? createdBy;
  dynamic cashierId;
  String? receiptSource;
  String? receiptTotal;
  int? penalty;
  dynamic creditApplied;
  int? applicationId;
  String? goodsOrigin;
  String? goodsDestination;
  String? station;
  String? vehicleType;
  int? vehicleId;
  String? plateNo;
  String? paymentMode;
  String? transactionCode;
  String? paymentBank;
  int? userId;
  int? citizenId;
  String? citizenName;
  dynamic citizenAddress;
  String? citizenMobile;
  String? citizenEmail;
  int? isVoid;
  int? createdByStaffId;
  String? createdByStaffName;
  String? status;
  List<Item>? items;

  LastApplicationData({
    required this.id,
    required this.createdDate,
    required this.approvalDate,
    required this.accountType,
    required this.applicationType,
    required this.createdBy,
    required this.cashierId,
    required this.receiptSource,
    required this.receiptTotal,
    required this.penalty,
    required this.creditApplied,
    required this.applicationId,
    required this.goodsOrigin,
    required this.goodsDestination,
    required this.station,
    required this.vehicleType,
    required this.vehicleId,
    required this.plateNo,
    required this.paymentMode,
    required this.transactionCode,
    required this.paymentBank,
    required this.userId,
    required this.citizenId,
    required this.citizenName,
    required this.citizenAddress,
    required this.citizenMobile,
    required this.citizenEmail,
    required this.isVoid,
    required this.createdByStaffId,
    required this.createdByStaffName,
    required this.status,
    required this.items,
  });

  factory LastApplicationData.fromJson(Map<String, dynamic> json) => LastApplicationData(
    id: json["receipt_id"] ?? 0,
    createdDate:json["created_date"] == null ? null : DateTime.parse(json["created_date"]),
    approvalDate:json["application_approval_date"] == null ? null : DateTime.parse(json["application_approval_date"]),
    accountType: json["account_type"] ?? "N/A",
    applicationType: json["application_type"] ?? "N/A",
    createdBy: json["created_by"] ?? "N/A",
    cashierId: json["cashier_id"] ?? "N/A",
    receiptSource: json["receipt_source"] ?? "N/A",
    receiptTotal: json["receipt_total"] ?? "N/A",
    penalty: json["penalty"] ?? 0,
    creditApplied: json["credit_applied"] ?? "N/A",
    applicationId: json["application_id"] ?? 0,
    goodsOrigin: json["goods_origin"] ?? "N/A",
    goodsDestination: json["goods_destination"] ?? "N/A",
    station: json["station"] ?? "N/A",
    vehicleType: json["vehicle_type"] ?? "N/A",
    vehicleId : json["vehicle_type_id"],
    plateNo: json["plate_no"] ?? "N/A",
    paymentMode: json["payment_mode"] ?? "N/A",
    transactionCode: json["transaction_code"] ?? "N/A",
    paymentBank: json["payment_bank"] ?? "N/A",
    userId: json["user_id"] ?? 0,
    citizenId: json["citizen_id"] ?? 0,
    citizenName: json["citizen_name"] ?? "N/A",
    citizenAddress: json["citizen_address"] ?? "N/A",
    citizenMobile: json["citizen_mobile"],
    citizenEmail: json["citizen_email"] ?? "N/A",
    isVoid: json["is_void"] ?? 0,
    createdByStaffId: json["created_by_staff_id"] ?? 0,
    createdByStaffName: json["created_by_staff_name"] ?? "N/A",
    status: json["status"] ?? "N/A",
    items: List<Item>.from(json["items"]?.map((x) => Item.fromJson(x)) ?? []), // Parse items
  );

  get data => null;

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_date": createdDate!.toIso8601String(),
    "account_type": accountType,
    "application_type": applicationType,
    "created_by": createdBy,
    "cashier_id": cashierId,
    "receipt_source": receiptSource,
    "receipt_total": receiptTotal,
    "penalty": penalty,
    "credit_applied": creditApplied,
    "application_id": applicationId,
    "goods_origin": goodsOrigin,
    "goods_destination": goodsDestination,
    "station": station,
    "vehicle_type": vehicleType,
    "plate_no": plateNo,
    "payment_mode": paymentMode,
    "transaction_code": transactionCode,
    "payment_bank": paymentBank,
    "user_id": userId,
    "citizen_id": citizenId,
    "citizen_name": citizenName,
    "citizen_address": citizenAddress,
    "citizen_mobile": citizenMobile,
    "citizen_email": citizenEmail,
    "is_void": isVoid,
    "created_by_staff_id": createdByStaffId,
    "created_by_staff_name": createdByStaffName,
  };
}

class Item {
  int? id;
  int? quantity;
  String? item;
  String? uom;
  double? rate;
  double? total;
  String? totalQuantity;
  String? totalAmount;

  Item({
    required this.id,
    required this.quantity,
    required this.item,
    required this.uom,
    required this.rate,
    required this.total,
    required this.totalQuantity,
    required this.totalAmount,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json["id"],
    quantity: json["quantity"],
    item: json["item"],
    uom: json["uom"],
    rate: json["rate"].toDouble(),
    total: json["total"].toDouble(),
    totalQuantity: json["total_quantity"],
    totalAmount: json["total_amount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "quantity": quantity,
    "item": item,
    "uom": uom,
    "rate": rate,
    "total": total,
    "total_quantity": totalQuantity,
    "total_amount": totalAmount,
  };
}
