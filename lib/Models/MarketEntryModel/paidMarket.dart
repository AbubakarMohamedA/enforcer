import 'dart:convert';

PaidMarket paidMarketFromJson(String str) => PaidMarket.fromJson(json.decode(str));
String paidMarketToJson(PaidMarket data) => json.encode(data.toJson());

class PaidMarket {
  String status;
  List<PaidMarketDatum> data;

  PaidMarket({
    required this.status,
    required this.data,
  });

  factory PaidMarket.fromJson(Map<String, dynamic> json) => PaidMarket(
    status: json["status"] ?? "success",
    data: json["tickets"] == null  // 👈 was "data", now "tickets"
        ? []
        : List<PaidMarketDatum>.from(json["tickets"].map((x) => PaidMarketDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "tickets": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class PaidMarketDatum {
  String? marketName;   // → mobile
  String? marketMobile; // → mobile (reused)
  String? transactionCode; // → transactionId
  String? categories;   // → charge
  String? time;         // → time (new)

  PaidMarketDatum({
    this.marketName,
    this.marketMobile,
    this.transactionCode,
    this.categories,
    this.time,
  });

  factory PaidMarketDatum.fromJson(Map<String, dynamic> json) => PaidMarketDatum(
    marketName:      json["mobile"]?.toString() ?? "N/A",        // Plate/ID: shows mobile
    marketMobile:    json["mobile"]?.toString() ?? "N/A",        // Mobile
    transactionCode: json["transactionId"]?.toString() ?? "N/A", // Code
    categories:      json["charge"]?.toString() ?? "N/A",        // Category → shows charge
    time:            json["time"]?.toString() ?? "N/A",          // Time
  );

  Map<String, dynamic> toJson() => {
    "mobile":        marketMobile,
    "transactionId": transactionCode,
    "charge":        categories,
    "time":          time,
  };
}