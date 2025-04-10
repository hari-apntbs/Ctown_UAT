import '../../common/config.dart';
import '../../common/constants/general.dart';
import '../../services/service_config.dart';
import 'product.dart';
import 'product_attribute.dart';

class ProductVariation {
  String? id;
  String? sku;
  String? price;
  String? name;
  String? regularPrice;
  String? salePrice;
  String? dateOnSaleFrom;
  String? dateSaleFrom;
  String? dateSaleTo;
  String? dateOnSaleTo;
  bool? onSale = false;
  bool? inStock;
  int? stockQuantity;
  String? imageFeature;
  String? imageFeature2;
  List<Attribute> attributes = [];
  Map<String?, Attribute> attributeMap = {};

  ProductVariation();

  ProductVariation.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"].toString();
    price = parsedJson["price"].toString();
    regularPrice = parsedJson["regular_price"].toString();
    salePrice = parsedJson["sale_price"].toString();
    dateOnSaleFrom = parsedJson["date_on_sale_from"];
    dateOnSaleTo = parsedJson["date_on_sale_to"];
    onSale = parsedJson["on_sale"];
    inStock = parsedJson["in_stock"];
    inStock! ? stockQuantity = parsedJson["stock_quantity"] : stockQuantity = 0;
    imageFeature = parsedJson["image"]["src"];

    List<Attribute> attributeList = [];
    parsedJson["attributes"]?.forEach((item) {
      final Attribute attribute = Attribute.fromJson(item);
      attributeList.add(attribute);
      attributeMap[attribute.name] = attribute;
    });
    attributes = attributeList;
  }

  ProductVariation.fromMagentoJson(
      Map<String, dynamic> parsedJson, Product product) {
    var getCustomAttribute = (customAttributes, attribute) {
      String? value;
      if (customAttributes != null && customAttributes.length > 0) {
        for (var item in customAttributes) {
          if (item["attribute_code"] == attribute) {
            value = item["value"];
            break;
          }
        }
      }
      return value;
    };

    var getProductImageUrlByName = (domain, imageName) {
      return "$domain/pub/media/catalog/product/$imageName";
    };

    id = parsedJson["id"].toString();
    sku = parsedJson["sku"];
    stockQuantity = parsedJson["qty"];
    name = parsedJson["name"];
    price = parsedJson["price"].toString();
    regularPrice = parsedJson["price"].toString();
    // salePrice = parsedJson["price"].toString();
    // onSale = false;
    inStock = parsedJson["status"] == 1;

    final imageUrl =
        getCustomAttribute(parsedJson["custom_attributes"], "image");
    imageFeature = imageUrl != null
        ? getProductImageUrlByName(Config().url, imageUrl)
        : product.imageFeature;
    imageFeature2 = imageUrl != null
        ? getProductImageUrlByName(Config().url, imageUrl)
        : product.imageFeature2;

    final dateSaleFrom1 = getCustomAttribute(
        parsedJson["custom_attributes"], "special_from_date");
    final dateSaleTo1 =
        getCustomAttribute(parsedJson["custom_attributes"], "special_to_date");

    if (dateSaleFrom1 != null && dateSaleTo1 != null) {
      final now = DateTime.now();
      DateTime dateSaleTo2 = DateTime.parse(dateSaleTo1);

      var newDate =
          DateTime(dateSaleTo2.year, dateSaleTo2.month, dateSaleTo2.day + 1);
      printLog(newDate);

      onSale = now.isAfter(DateTime.parse(dateSaleFrom1)) &&
          now.isBefore(DateTime.parse(newDate.toString()));

      printLog("onSale");
      printLog(onSale);

      // if (onSale && salePrice != null) {
      //   price = salePrice;
      // }

    }
    final salePrice1 =
        getCustomAttribute(parsedJson["custom_attributes"], "special_price");
    salePrice = salePrice1;

    List<Attribute> attributeList = [];
    List attributesConfig =
        kAdvanceConfig["EnableAttributesConfigurableProduct"] as List<dynamic>;
    attributesConfig.forEach((element) {
      final item = getCustomAttribute(parsedJson["custom_attributes"], element);
      if (item != null) {
        attributeList.add(Attribute.fromMagentoJson(
            {"value": item, "attribute_code": element}));
      }
    });
    attributes = attributeList;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sku": sku,
      "price": price,
      "regularPrice": regularPrice,
      "sale_price": salePrice,
      "date_on_sale_from": dateOnSaleFrom,
      "date_on_sale_to": dateOnSaleTo,
      "on_sale": onSale,
      "in_stock": inStock,
      "stock_quantity": stockQuantity,
      "image": {"src": imageFeature},
      "attributes": attributes.map((item) {
        return item.toJson();
      }).toList()
    };
  }

  ProductVariation.fromLocalJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      sku = json["sku"];
      price = json['price'];
      regularPrice = json['regularPrice'];
      onSale = json['onSale'];
      salePrice = json['salePrice'];
      dateOnSaleFrom = json["date_on_sale_from"];
      dateOnSaleTo = json["date_on_sale_to"];
      inStock = json['inStock'];
      inStock! ? stockQuantity = json["stock_quantity"] : stockQuantity = 0;
      imageFeature = json['image']["src"];
      List<Attribute> attributeList = [];

      if (json['attributes'] != null) {
        for (var item in json['attributes']) {
          attributeList.add(Attribute.fromLocalJson(item));
        }
      }

      attributes = attributeList;
    } catch (_) {}
  }

  ProductVariation.fromShopifyJson(Map<String, dynamic> parsedJson) {
    var priceV2 = parsedJson['priceV2'];
    var compareAtPriceV2 = parsedJson['compareAtPriceV2'];
    var compareAtPrice =
        compareAtPriceV2 != null ? compareAtPriceV2['amount'] : null;

    id = parsedJson["id"];
    price = priceV2 != null ? priceV2['amount'] : null;
    regularPrice = compareAtPrice ?? price;
    onSale = compareAtPrice != null && compareAtPrice != price;
    inStock = parsedJson['availableForSale'];
    salePrice = compareAtPrice;
    imageFeature = parsedJson["image"]["src"];

    List<Attribute> attributeList = [];
    parsedJson["selectedOptions"]?.forEach((item) {
      attributeList.add(Attribute.fromShopifyJson(item));
    });
    attributes = attributeList;
  }

  ProductVariation.fromPrestaJson(Map<String, dynamic> json) {
    id = json["id"].toString();
    regularPrice =
        (double.parse((json["price"] ?? 0.0).toString())).toStringAsFixed(2);
    salePrice = (double.parse((json["wholesale_price"] ?? 0.0).toString()))
        .toStringAsFixed(2);
    price = (double.parse((json["wholesale_price"] ?? 0.0).toString()))
        .toStringAsFixed(2);
    if (salePrice != regularPrice) {
      onSale = true;
    } else {
      onSale = false;
    }
    stockQuantity =
        json["quantity"].isNotEmpty ? int.parse(json["quantity"]) : 0;
    if (stockQuantity! > 0) {
      inStock = true;
    } else {
      inStock = false;
    }
    imageFeature = json['image'];
    List<Attribute> attributeList = [];
    json["attributes"]?.forEach((item) {
      attributeList.add(Attribute.fromPrestaJson(item));
    });
    attributes = attributeList;
  }

  /// Get product ID from mix String productID-ProductVariantID
  static String? cleanProductVariantID(productString) {
    return productString.contains('-') ? productString.split('-')[1] : null;
  }

  /// Return true if [attributeMap] includes [attributes]
  bool hasSameAttributes(Map<String, String> attributes) {
    bool isSame = true;
    final keys = attributes.keys.toList(growable: false);
    final values = attributes.values.toList(growable: false);
    for (var i = 0; i < attributes.length; i++) {
      if (attributeMap[keys[i]] == null || values[i] == null) {
        /// In case this attribute can be any option, don't need to check.
        continue;
      }
      if (attributeMap[keys[i]]!.option != values[i]) {
        isSame = false;
      }
    }
    return isSame;
  }
}
