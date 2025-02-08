// To parse this JSON data, do
//
//     final getHawkerStats = getHawkerStatsFromJson(jsonString);

import 'dart:convert';

GetHawkerStats getHawkerStatsFromJson(String str) => GetHawkerStats.fromJson(json.decode(str));

String getHawkerStatsToJson(GetHawkerStats data) => json.encode(data.toJson());

class GetHawkerStats {
  String status;
  DailyStats? dailyStats;
  MonthlyStats? monthlyStats;

  GetHawkerStats({
    required this.status,
    required this.dailyStats,
    required this.monthlyStats,
  });

  factory GetHawkerStats.fromJson(Map<String, dynamic> json) => GetHawkerStats(
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
  String? paidHawkers;
  String? totalAmount;

  DailyStats({
    required this.paidHawkers,
    required this.totalAmount,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) => DailyStats(
    paidHawkers: json["paid_hawkers"] != null ? json["paid_hawkers"].toString() : "0.00",
    totalAmount: json["total_amount"] != null ? json["total_amount"].toString() : "0.00",
  );

  Map<String, dynamic> toJson() => {
    "total_amount": totalAmount,
    "paid_hawkers": paidHawkers,
  };
}

class MonthlyStats {
  String? paidHawkers;
  String? totalAmount;

  MonthlyStats({
    required this.paidHawkers,
    required this.totalAmount,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) => MonthlyStats(
    paidHawkers: json["paid_hawkers"].toString(),
    totalAmount: json["total_amount"].toString(),
  );

  Map<String, dynamic> toJson() => {
    "total_amount": totalAmount,
    "paid_hawkers": paidHawkers,
  };
}
