// To parse this JSON data, do
//
//     final getPenaltyRates = getPenaltyRatesFromJson(jsonString);

import 'dart:convert';

GetPenaltyRates getPenaltyRatesFromJson(String str) => GetPenaltyRates.fromJson(json.decode(str));

String getPenaltyRatesToJson(GetPenaltyRates data) => json.encode(data.toJson());

class GetPenaltyRates {
  int? data;
  String status;
  String? message;

  GetPenaltyRates({
    required this.data,
    required this.status,
    required this.message,

  });

  factory GetPenaltyRates.fromJson(Map<String, dynamic> json) => GetPenaltyRates(
    data: json["data"],
    status: json["status"],
    message: json["message"] ?? "N/A",
  );

  Map<String, dynamic> toJson() => {
    "data": data,
    "status": status,
  };
}
