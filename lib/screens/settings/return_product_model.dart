// To parse this JSON data, do
//
//     final ReturnProductModel = ReturnProductModelFromJson(jsonString);

import 'dart:convert';

List<ReturnProductModel> returnProductModelFromJson(String str) =>
    List<ReturnProductModel>.from(
        json.decode(str).map((x) => ReturnProductModel.fromJson(x)));

String returnProductModelToJson(List<ReturnProductModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReturnProductModel {
  ReturnProductModel({
    this.id,
    this.name,
    this.selected = true,
    this.qty,
    this.originalQty,
    this.price,
  });

  int? id;
  String? name;
  int? originalQty;
  int? qty;
  bool? selected;
  String? price;

  factory ReturnProductModel.fromJson(Map<String, dynamic> json) =>
      ReturnProductModel(
        id: int.parse(json["product_id"]),
        name: json["name"],
        qty: int.parse(json["qty"].toString().split(".")[0]),
        originalQty: int.parse(json["qty"].toString().split(".")[0]),
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "product_id": id,
        "name": name,
        "qty": qty,
        "price": price,
      };
}
