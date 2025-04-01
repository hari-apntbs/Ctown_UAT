// To parse this JSON data, do
//
//     final SuggestedProduct = SuggestedProductFromJson(jsonString);

import 'dart:convert';

List<SuggestedProduct> suggestedProductFromJson(String str) =>
    List<SuggestedProduct>.from(
        json.decode(str).map((x) => SuggestedProduct.fromJson(x)));

String suggestedProductToJson(List<SuggestedProduct> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SuggestedProduct {
  SuggestedProduct({
    this.orderId,
    this.outofstockProductDetails,
    this.replacementProductDetails,
    this.outofstockQty,
  });
 
  var orderId;
  List<ProductDetail>? outofstockProductDetails;
  List<ProductDetail>? replacementProductDetails;
  String? outofstockQty;

  factory SuggestedProduct.fromJson(Map<String, dynamic> json) =>
      SuggestedProduct(
        orderId: json["order_id"],
        outofstockProductDetails: List<ProductDetail>.from(
            json["outofstock_product_details"]
                .map((x) => ProductDetail.fromJson(x))),
        replacementProductDetails: List<ProductDetail>.from(
            json["replacement_product_details"]
                .map((x) => ProductDetail.fromJson(x))),
        outofstockQty: json["outofstock_qty"],
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "outofstock_product_details":
            List<dynamic>.from(outofstockProductDetails!.map((x) => x.toJson())),
        "replacement_product_details": List<dynamic>.from(
            replacementProductDetails!.map((x) => x.toJson())),
        "outofstock_qty": outofstockQty,
      };
}

class ProductDetail {
  ProductDetail({
    this.productId,
    this.productType = "Grocery", 
    this.productName,
    this.selectedQtty = 1,
    this.barcode,
    this.productPrice,
    this.productImage,
  });

  String? productId;
  String productType;
  String? productName;
  int selectedQtty;
  String? barcode;
  String? productPrice;
  String? productImage;

  factory ProductDetail.fromJson(Map<String, dynamic> json) => ProductDetail(
        productId: json["product_id"] ?? "",
        productName: json["product_name"] ?? "",
        productType: json["product_type"] ?? "Grocery",
        barcode: json["barcode"] ?? "",
        selectedQtty: json["selected_qty"] ?? 1,
        productPrice: json["product_price"] ?? "",
        productImage: json["product_image"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "product_type": productType,
        "product_name": productName,
        "barcode": barcode,
        "selected_qty": selectedQtty,
        "product_price": productPrice,
        "product_image": productImage,
      };
}

// // To parse this JSON data, do
// //
// //     final SuggestedProduct = SuggestedProductFromJson(jsonString);

// import 'dart:convert';

// List<SuggestedProduct> SuggestedProductFromJson(String str) => List<SuggestedProduct>.from(json.decode(str).map((x) => SuggestedProduct.fromJson(x)));

// String SuggestedProductToJson(List<SuggestedProduct> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class SuggestedProduct {
//     SuggestedProduct({
//         this.orderId,
//         this.outofstockProductId,
//         this.outofstockBarcode,
//         this.replacementProductId,
//         this.replacementBarcode,
//         this.productType,
//         this.outofstockQty,
//     });

//     int orderId;
//     String outofstockProductId;
//     String outofstockBarcode;
//     String replacementProductId;
//     String replacementBarcode;
//     String productType;
//     String outofstockQty;

//     factory SuggestedProduct.fromJson(Map<String, dynamic> json) => SuggestedProduct(
//         orderId: json["order_id"],
//         outofstockProductId: json["outofstock_product_id"],
//         outofstockBarcode: json["outofstock_barcode"],
//         replacementProductId: json["replacement_product_id"],
//         replacementBarcode: json["replacement_barcode"],
//         productType: json["product_type"],
//         outofstockQty: json["outofstock_qty"],
//     );

//     Map<String, dynamic> toJson() => {
//         "order_id": orderId,
//         "outofstock_product_id": outofstockProductId,
//         "outofstock_barcode": outofstockBarcode,
//         "replacement_product_id": replacementProductId,
//         "replacement_barcode": replacementBarcode,
//         "product_type": productType,
//         "outofstock_qty": outofstockQty,
//     };
// }
