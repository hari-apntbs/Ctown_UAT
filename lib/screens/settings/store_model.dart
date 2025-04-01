// To parse this JSON data, do
//
//     final MyStoreModel = MyStoreModelFromJson(jsonString);

import 'dart:convert';

List<MyStoreModel> myStoreModelFromJson(String str) => List<MyStoreModel>.from(
    json.decode(str).map((x) => MyStoreModel.fromJson(x)));

String myStoreModelToJson(List<MyStoreModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MyStoreModel {
  MyStoreModel({
    this.countryName,
    this.countryCode,
  });

  String? countryName;
  String? countryCode;

  factory MyStoreModel.fromJson(Map<String, dynamic> json) => MyStoreModel(
        countryName: json["country_name"],
        countryCode: json["country_code"],
      );

  Map<String, dynamic> toJson() => {
        "country_name": countryName,
        "country_code": countryCode,
      };
}
