// To parse this JSON data, do
//
//     final SelectedStoreModel = SelectedStoreModelFromJson(jsonString);

import 'dart:convert';

List<SelectedStoreModel> selectedStoreModelFromJson(String str) =>
    List<SelectedStoreModel>.from(
        json.decode(str).map((x) => SelectedStoreModel.fromJson(x)));
// result = json['result'].map<Result>((j) => Result.fromJson(j).toList();
String selectedStoreModelToJson(List<SelectedStoreModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SelectedStoreModel {
  SelectedStoreModel({
    this.groupId,
    this.websiteId,
    this.name,
    this.rootCategoryId,
    this.defaultStoreId,
    this.code,
    this.lat,
    this.lng,
    this.defaultStoreIdEn,
    this.defaultStoreIdAr,
    this.defaultStoreCodeEn,
    this.defaultStoreCodeAr,
    this.currencyEn,
    this.currencyAr,
  });

  String? groupId;
  String? websiteId;
  String? name;
  String? rootCategoryId;
  String? defaultStoreId;
  String? code;
  dynamic lat;
  dynamic lng;
  String? defaultStoreIdEn;
  String? defaultStoreIdAr;
  String? defaultStoreCodeEn;
  String? defaultStoreCodeAr;
  String? currencyEn;
  String? currencyAr;

  factory SelectedStoreModel.fromJson(Map<String, dynamic> json) =>
      SelectedStoreModel(
        groupId: json["group_id"],
        websiteId: json["website_id"],
        name: json["name"],
        rootCategoryId: json["root_category_id"],
        defaultStoreId: json["default_store_id"],
        code: json["code"],
        lat: json["lat"],
        lng: json["lng"],
        defaultStoreIdEn: json["default_store_id_en"],
        defaultStoreIdAr: json["default_store_id_ar"],
        defaultStoreCodeEn: json["default_store_code_en"],
        defaultStoreCodeAr: json["default_store_code_ar"],
        currencyEn: json["currency_en"],
        currencyAr: json["currency_ar"],
      );

  Map<String, dynamic> toJson() => {
        "group_id": groupId,
        "website_id": websiteId,
        "name": name,
        "root_category_id": rootCategoryId,
        "default_store_id": defaultStoreId,
        "code": code,
        "lat": lat,
        "lng": lng,
        "default_store_id_en": defaultStoreIdEn,
        "default_store_id_ar": defaultStoreIdAr,
        "default_store_code_en": defaultStoreCodeEn,
        "default_store_code_ar": defaultStoreCodeAr,
        "currency_en": currencyEn,
        "currency_ar": currencyAr,
      };
}

/*
import 'dart:convert';

List<SelectedStoreModel> selectedStoreModelFromJson(String str) =>
    List<SelectedStoreModel>.from(
        json.decode(str).map((x) => SelectedStoreModel.fromJson(x)));

String selectedStoreModelToJson(List<SelectedStoreModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SelectedStoreModel {
  SelectedStoreModel({
    this.groupId,
    this.websiteId,
    this.name,
    this.rootCategoryId,
    this.defaultStoreId,
    this.code,
    this.lat,
    this.lng,
  });

  String groupId;
  String websiteId;
  String name;
  String rootCategoryId;
  String defaultStoreId;
  String code;
  dynamic lat;
  dynamic lng;

  factory SelectedStoreModel.fromJson(Map<String, dynamic> json) =>
      SelectedStoreModel(
        groupId: json["group_id"],
        websiteId: json["website_id"],
        name: json["name"],
        rootCategoryId: json["root_category_id"],
        defaultStoreId: json["default_store_id"],
        code: json["code"],
        lat: json["lat"],
        lng: json["lng"],
      );

  Map<String, dynamic> toJson() => {
        "group_id": groupId,
        "website_id": websiteId,
        "name": name,
        "root_category_id": rootCategoryId,
        "default_store_id": defaultStoreId,
        "code": code,
        "lat": lat,
        "lng": lng,
      };
}
*/
