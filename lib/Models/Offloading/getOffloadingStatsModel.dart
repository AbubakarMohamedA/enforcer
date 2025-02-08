// To parse this JSON data, do
//
//     final getOffLoadingStats = getOffLoadingStatsFromJson(jsonString);

import 'dart:convert';

GetOffLoadingStats getOffLoadingStatsFromJson(String str) => GetOffLoadingStats.fromJson(json.decode(str));

String getOffLoadingStatsToJson(GetOffLoadingStats data) => json.encode(data.toJson());

class GetOffLoadingStats {
  OffloadingStatsData data;
  String status;

  GetOffLoadingStats({
    required this.data,
    required this.status,
  });

  factory GetOffLoadingStats.fromJson(Map<String, dynamic> json) => GetOffLoadingStats(
    data: OffloadingStatsData.fromJson(json["data"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
    "status": status,
  };
}

class OffloadingStatsData {
  String? dailyCollection;
  String? monthlyCollection;
  String? dailyOffloadingCount;

  OffloadingStatsData({
    required this.dailyCollection,
    required this.monthlyCollection,
    required this.dailyOffloadingCount,
  });

  factory OffloadingStatsData.fromJson(Map<String, dynamic> json) => OffloadingStatsData(
    dailyCollection:  json["daily_collection"] != null ? json["daily_collection"].toString() : "0.00",
    monthlyCollection: json["monthly_collection"] != null ? json["monthly_collection"].toString() : "0.00",
    dailyOffloadingCount: json["daily_offloading_count"] != null ? json["daily_offloading_count"].toString() : "0",
  );

  Map<String, dynamic> toJson() => {
    "daily_collection": dailyCollection,
    "monthly_collection": monthlyCollection,
    "daily_offloading_count": dailyOffloadingCount,
  };
}
