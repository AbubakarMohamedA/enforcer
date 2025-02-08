// To parse this JSON data, do
//
//     final getOffloadingItems = getOffloadingItemsFromJson(jsonString);

import 'dart:convert';

GetOffloadingItems getOffloadingItemsFromJson(String str) => GetOffloadingItems.fromJson(json.decode(str));

String getOffloadingItemsToJson(GetOffloadingItems data) => json.encode(data.toJson());

class GetOffloadingItems {
  Map<String, List<OffLoadingItemsDatum>> data;
  String status;

  GetOffloadingItems({
    required this.data,
    required this.status,
  });

  factory GetOffloadingItems.fromJson(Map<String, dynamic> json) => GetOffloadingItems(
    data: Map.from(json["data"]).map((k, v) => MapEntry<String, List<OffLoadingItemsDatum>>(k, List<OffLoadingItemsDatum>.from(v.map((x) => OffLoadingItemsDatum.fromJson(x))))),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": Map.from(data).map((k, v) => MapEntry<String, dynamic>(k, List<dynamic>.from(v.map((x) => x.toJson())))),
    "status": status,
  };
}

class OffLoadingItemsDatum {
  String? uom;
  int? rate;
  int? itemId;
  String? itemName;

  OffLoadingItemsDatum({
    required this.uom,
    required this.rate,
    required this.itemId,
    required this.itemName,
  });

  factory OffLoadingItemsDatum.fromJson(Map<String, dynamic> json) => OffLoadingItemsDatum(
    uom: json["uom"],
    rate: json["rate"],
    itemId: json["itemId"],
    itemName: json["itemName"],
  );

  Map<String, dynamic> toJson() => {
    "uom": uom,
    "rate": rate,
    "itemId": itemId,
    "itemName": itemName,
  };
}
