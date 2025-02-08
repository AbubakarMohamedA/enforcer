// To parse this JSON data, do
//
//     final paidHawkers = paidHawkersFromJson(jsonString);

import 'dart:convert';

PaidHawkers paidHawkersFromJson(String str) => PaidHawkers.fromJson(json.decode(str));

String paidHawkersToJson(PaidHawkers data) => json.encode(data.toJson());

class PaidHawkers {
  String status;
  List<PaidHawkersDatum> data;

  PaidHawkers({
    required this.status,
    required this.data,
  });

  factory PaidHawkers.fromJson(Map<String, dynamic> json) => PaidHawkers(
    status: json["status"],
    data: List<PaidHawkersDatum>.from(json["data"].map((x) => PaidHawkersDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class PaidHawkersDatum {
  String? hawkerName;
  String? hawkerMobile;
  int? hawkerId;
  int? amount;
  String? zoneName;
  String? transactionCode;
  String? categories;
  String? location;

  PaidHawkersDatum({
    required this.hawkerName,
    required this.hawkerMobile,
    required this.hawkerId,
    required this.amount,
    required this.zoneName,
    required this.transactionCode,
    required this.categories,
    required this.location
  });

  factory PaidHawkersDatum.fromJson(Map<String, dynamic> json) => PaidHawkersDatum(
    hawkerName: json["hawkerName"],
    hawkerMobile: json["hawkerMobile"],
    hawkerId: json["hawkerId"] ?? "N/A",
    amount: json["amount"] ?? "N/A",
    zoneName: json["zone_name"] ?? "N/A",
    categories: json["category_name"] ?? "N/A",
    location: json["location_name"] ?? "N/A",
    transactionCode: json['transaction_code'] ?? "N/A",
  );

  Map<String, dynamic> toJson() => {
    "hawkerName": hawkerName,
    "hawkerMobile": hawkerMobile,
    "hawkerId": hawkerId,
    "amount": amount,
    "zone_name": zoneName,
  };
}
