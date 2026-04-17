// To parse this JSON data, do
//
//     final getMarketStats = getMarketStatsFromJson(jsonString);

import 'dart:convert';

GetMarketStats getMarketStatsFromJson(String str) => GetMarketStats.fromJson(json.decode(str));

String getMarketStatsToJson(GetMarketStats data) => json.encode(data.toJson());

class GetMarketStats {
  String status;
  DailyStats? dailyStats;
  MonthlyStats? monthlyStats;

  GetMarketStats({
    required this.status,
    required this.dailyStats,
    required this.monthlyStats,
  });

  factory GetMarketStats.fromJson(Map<String, dynamic> json) => GetMarketStats(
    status: json["status"],
    dailyStats: DailyStats.fromJson(json["daily_stats"]),
    monthlyStats: MonthlyStats.fromJson(json["monthly_stats"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "daily_stats": dailyStats!.toJson(),
    "monthly_stats": monthlyStats!.toJson(),
  };
}

class DailyStats {
  String? paidMarket;
  String? totalAmount;

  DailyStats({
    required this.paidMarket,
    required this.totalAmount,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) => DailyStats(
    paidMarket: json["paid_market"] != null ? json["paid_market"].toString() : "0.00",
    totalAmount: json["total_amount"] != null ? json["total_amount"].toString() : "0.00",
  );

  Map<String, dynamic> toJson() => {
    "total_amount": totalAmount,
    "paid_market": paidMarket,
  };
}

class MonthlyStats {
  String? paidMarket;
  String? totalAmount;

  MonthlyStats({
    required this.paidMarket,
    required this.totalAmount,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) => MonthlyStats(
    paidMarket: json["paid_market"].toString(),
    totalAmount: json["total_amount"].toString(),
  );

  Map<String, dynamic> toJson() => {
    "total_amount": totalAmount,
    "paid_market": paidMarket,
  };
}
