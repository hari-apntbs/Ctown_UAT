import 'dart:convert';
import 'dart:io' show HttpStatus;

import 'package:http/http.dart' as http;

import '../../common/constants.dart';
import '../../services/service_config.dart';
import '../cart/cart_base.dart';
import 'order.dart';

class Coupons {
  var coupons = [];

  static Future<Discount?> getDiscount({
    required CartModel cartModel,
    String? couponCode,
  }) async {
    try {
      final endpoint = "${Config().url}/wp-json/api/flutter_woo/coupon";
      var params = Order().toJson(
          cartModel, cartModel.user != null ? cartModel.user!.id : null, false);
      params["coupon_code"] = couponCode;
      printLog("Coupon Url: $endpoint");
      printLog("Params: $params");
      final response = await http.post(
        Uri.parse(endpoint),
        body: json.encode(params),
      );

      final body = json.decode(response.body) ?? {};
      if (response.statusCode == HttpStatus.ok) {
        return Discount.fromJson(body);
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
    } catch (err) {
      rethrow;
    }
    return null;
  }

  Coupons.getListCoupons(List a) {
    for (var i in a) {
      coupons.add(Coupon.fromJson(i));
    }
  }

  Coupons.getListCouponsOpencart(List a) {
    for (var i in a) {
      coupons.add(Coupon.fromOpencartJson(i));
    }
  }
}

class Discount {
  Coupon? coupon;
  double? discount;

  Discount({this.coupon, this.discount});

  Discount.fromJson(Map<String, dynamic> json) {
    coupon = json['coupon'] != null ? Coupon.fromJson(json['coupon']) : null;
    discount = double.parse("${(json['discount'] ?? 0.0)}");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (coupon != null) {
      data['coupon'] = coupon!.toJson();
    }
    data['discount'] = discount;
    return data;
  }
}

class Coupon {
  double? amount;
  var code;
  var message;
  var id;
  var discountType;
  var dateExpires;
  var description;
  double? minimumAmount;
  double? maximumAmount;
  int? usageCount;
  bool? individualUse;
  late List<String> productIds;
  late List<String> excludedProductIds;
  int? usageLimit;
  int? usageLimitPerUser;
  bool? freeShipping;
  late List<String> productCategories;
  late List<String> excludedProductCategories;
  bool? excludeSaleItems;
  late List<String> emailRestrictions;
  late List<String> usedBy;

  bool get isFixedCartDiscount => discountType == "fixed_cart";

  bool get isFixedProductDiscount => discountType == "fixed_product";

  bool get isPercentageDiscount => discountType == "percent";

  Coupon.fromJson(Map<String, dynamic> json) {
    try {
      amount = double.parse(json["amount"].toString());
      code = json["code"];
      id = json["id"];
      discountType = json["discount_type"];
      description = json["description"];
      minimumAmount = json["minimum_amount"] != null
          ? double.parse(json["minimum_amount"].toString())
          : 0.0;
      maximumAmount = json["maximum_amount"] != null
          ? double.parse(json["maximum_amount"].toString())
          : 0.0;
      dateExpires = json["date_expires"] != null
          ? DateTime.parse(json["date_expires"])
          : null;
      message = "";
      usageCount = json['usage_count'];
      individualUse = json['individual_use'] ?? false;
      usageLimit = json['usage_limit'];
      usageLimitPerUser = json['usage_limit_per_user'];
      freeShipping = json['free_shipping'] ?? false;
      excludeSaleItems = json['exclude_sale_items'] ?? false;

      if (json['product_ids'] != null) {
        productIds = <String>[];
        json['product_ids'].forEach((e) {
          productIds.add(e.toString());
        });
      }

      if (json['excluded_product_ids'] != null) {
        excludedProductIds = <String>[];
        json['excluded_product_ids'].forEach((e) {
          excludedProductIds.add(e.toString());
        });
      }

      if (json['product_categories'] != null) {
        productCategories = <String>[];
        json['product_categories'].forEach((e) {
          productCategories.add(e.toString());
        });
      }

      if (json['excluded_product_categories'] != null) {
        excludedProductCategories = <String>[];
        json['excluded_product_categories'].forEach((e) {
          excludedProductCategories.add(e.toString());
        });
      }

      if (json['email_restrictions'] != null) {
        emailRestrictions = <String>[];
        json['email_restrictions'].forEach((e) {
          emailRestrictions.add(e.toString());
        });
      }

      if (json['used_by'] != null) {
        usedBy = <String>[];
        json['used_by'].forEach((e) {
          usedBy.add(e.toString());
        });
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  Coupon.fromOpencartJson(Map<String, dynamic> json) {
    try {
      amount = double.parse(json["discount"].toString());
      code = json["code"];
      id = json["coupon_id"];
      discountType = json["type"] == "P" ? "percent" : "fixed_cart";
      description = json["name"];
      minimumAmount = 0.0;
      maximumAmount = 0.0;
      dateExpires = DateTime.parse(json["date_end"]);
      message = "";
    } catch (e) {
      printLog(e.toString());
    }
  }

  Coupon.fromShopify(Map<String, dynamic> json) {
    try {
      amount = double.parse(json["totalPrice"].toString());
      code = json["code"];
      id = json["code"];
      discountType = "fixed_cart";
      description = "";
      minimumAmount = 0.0;
      maximumAmount = 0.0;
      dateExpires = null;
      message = "Hello";
    } catch (e) {
      printLog(e.toString());
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "code": code,
      "discount_type": discountType,
      // "description": description,
      // "minimum_amount": minimumAmount,
      // "maximum_amount": maximumAmount,
      // "date_expires": dateExpires,
    };
  }
}
