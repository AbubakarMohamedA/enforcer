import 'dart:convert';

GetMarketTollTypes getMarketTollTypesFromJson(String str) => GetMarketTollTypes.fromJson(json.decode(str));

String getMarketTollTypesToJson(GetMarketTollTypes data) => json.encode(data.toJson());

class GetMarketTollTypes {
  String status;
  List<MarketTollTypeDatum> data;

  GetMarketTollTypes({
    required this.status,
    required this.data,
  });

  factory GetMarketTollTypes.fromJson(Map<String, dynamic> json) => GetMarketTollTypes(
    status: json["status"] ?? 'success',
    data: json["data"] != null ? List<MarketTollTypeDatum>.from(json["data"].map((x) => MarketTollTypeDatum.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class MarketTollTypeDatum {
  int? id;
  String? name;

  MarketTollTypeDatum({
    required this.id,
    required this.name,
  });

  factory MarketTollTypeDatum.fromJson(Map<String, dynamic> json) => MarketTollTypeDatum(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
