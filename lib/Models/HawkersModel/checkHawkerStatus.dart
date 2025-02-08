// To parse this JSON data, do
//
//     final checkHawkerStatus = checkHawkerStatusFromJson(jsonString);

import 'dart:convert';

CheckHawkerStatus checkHawkerStatusFromJson(String str) => CheckHawkerStatus.fromJson(json.decode(str));

String checkHawkerStatusToJson(CheckHawkerStatus data) => json.encode(data.toJson());

class CheckHawkerStatus {
  String status;
  HawkerStatus hawkerStatus;

  CheckHawkerStatus({
    required this.status,
    required this.hawkerStatus,
  });

  factory CheckHawkerStatus.fromJson(Map<String, dynamic> json) => CheckHawkerStatus(
    status: json["status"],
    hawkerStatus: HawkerStatus.fromJson(json["hawker_status"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "hawker_status": hawkerStatus.toJson(),
  };
}

class HawkerStatus {
  String? status;
  int? hawkerId;
  int? paymentStatus;
  int? amount;
  String? message;

  HawkerStatus({
    required this.status,
    required this.hawkerId,
    required this.paymentStatus,
    required this.amount,
    required this.message,
  });

  factory HawkerStatus.fromJson(Map<String, dynamic> json) => HawkerStatus(
    status: json["status"],
    hawkerId: json["hawkerId"],
    paymentStatus: json["paymentStatus"],
    amount: json["amount"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "hawkerId": hawkerId,
    "paymentStatus": paymentStatus,
    "amount": amount,
    "message": message,
  };
}
