import 'dart:convert';

GetMarketTollCategories getMarketTollCategoriesFromJson(String str) => GetMarketTollCategories.fromJson(json.decode(str));

String getMarketTollCategoriesToJson(GetMarketTollCategories data) => json.encode(data.toJson());

class GetMarketTollCategories {
  String status;
  List<MarketTollCategoryDatum> data;

  GetMarketTollCategories({
    required this.status,
    required this.data,
  });

  factory GetMarketTollCategories.fromJson(Map<String, dynamic> json) => GetMarketTollCategories(
    status: json["status"] ?? 'success',
    data: json["data"] != null ? List<MarketTollCategoryDatum>.from(json["data"].map((x) => MarketTollCategoryDatum.fromJson(x))) : [],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class MarketTollCategoryDatum {
  int? id;
  String? name;
  double? amount;
  int? isIdNumber;

  MarketTollCategoryDatum({
    required this.id,
    required this.name,
    required this.amount,
    this.isIdNumber,
  });

  factory MarketTollCategoryDatum.fromJson(Map<String, dynamic> json) => MarketTollCategoryDatum(
    id: json["id"],
    name: json["title"] ?? json["name"], // Mapping "title" from new API to "name"
    amount: json["charge"] != null ? double.tryParse(json["charge"].toString()) : (json["amount"] != null ? double.tryParse(json["amount"].toString()) : null),
    isIdNumber: json["isIdNumber"] != null ? int.tryParse(json["isIdNumber"].toString()) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "amount": amount,
    "isIdNumber": isIdNumber,
  };
}
