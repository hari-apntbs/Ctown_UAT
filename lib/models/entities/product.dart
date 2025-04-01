import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:quiver/strings.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../services/service_config.dart';
import '../serializers/product.dart';
import '../vendor/store_model.dart';
import 'booking_info.dart';
import 'listing_slots.dart';
import 'menu_price.dart';
import 'product_attribute.dart';
import 'product_variation.dart';

class Product {
  String? id;
  String? notes;
  String note = '';
  String? sku;
  String? name;
  bool? status;
  String? vendor;
  String? description;
  String? permalink;
  String? price;
  int? qty;
  int? maxSaleQty;
  String? regularPrice;
  String? salePrice;
  bool? onSale;
  String? delivery_date;
  String? delivery_from;
  String? unit_of_measurement;
  String? package_info;
  String? brand;
  String? country_of_manufacture;
  bool? inStock;
  double? averageRating;
  int? totalSales;
  String? dateOnSaleFrom;
  String? dateOnSaleTo;
  int? ratingCount;
  String? productImage;
  List<String?>? images;
  String? imageFeature;
  String? imageFeature2;
  List<ProductAttribute>? attributes;
  Map<String?, String?> attributeSlugMap = {};
  List<Attribute>? defaultAttributes;
  List<ProductAttribute> infors = [];
  String? categoryId;
  String? videoUrl;
  List<dynamic>? groupedProducts;
  List<String?>? files;
  int? stockQuantity;
  int? minQuantity;
  int? maxQuantity;
  bool? manageStock;
  bool backOrdered = false;
  Store? store;
  int? max_sale_qty;

  /// is to check the type affiliate, simple, variant
  String? type;
  bool variableprice = false;
  String? affiliateUrl;
  List<ProductVariation>? variations;

  List<Map<String, dynamic>>? options; //for opencart

  BookingInfo? bookingInfo; // for booking

  String? idShop; //for prestashop

  ///----store LISTING----///

  String? distance;
  Map? pureTaxonomies;
  List? reviews;
  String? featured;
  String? verified;
  String? tagLine;
  String? priceRange;
  String? categoryName;
  String? hours;
  String? location;
  String? phone;
  String? facebook;
  String? email;
  String? website;
  String? skype;
  String? whatsapp;
  String? youtube;
  String? twitter;
  String? instagram;
  String? eventDate;
  String? rating;
  int? totalReview = 0;
  double? lat;
  double? long;
  List<dynamic>? listingMenu = [];
  ListingSlots? slots;

  ///----store LISTING----///

  Product.empty(this.id) {
    name = '';
    price = '0.0';
    imageFeature = '';
  }

  bool isEmptyProduct() {
    return name == '' && price == '0.0' && imageFeature == '';
  }

  Product.copyWith(Product p) {
    id = p.id;
    note = p.note;
    notes = p.notes;
    max_sale_qty = p.max_sale_qty;
    sku = p.sku;
    name = p.name;
    description = p.description;
    permalink = p.permalink;
    price = p.price;
    regularPrice = p.regularPrice;
    salePrice = p.salePrice;
    onSale = p.onSale;
    delivery_date = p.delivery_date;
    delivery_from = p.delivery_from;
    unit_of_measurement = p.unit_of_measurement;
    package_info = p.package_info;
    brand = p.brand;
    country_of_manufacture = p.country_of_manufacture;
    inStock = p.inStock;
    averageRating = p.averageRating;
    ratingCount = p.ratingCount;
    totalSales = p.totalSales;
    dateOnSaleFrom = p.dateOnSaleFrom;
    dateOnSaleTo = p.dateOnSaleTo;
    images = p.images;
    imageFeature = p.imageFeature;
    attributes = p.attributes;
    infors = p.infors;
    categoryId = p.categoryId;
    videoUrl = p.videoUrl;
    groupedProducts = p.groupedProducts;
    files = p.files;
    stockQuantity = p.stockQuantity;
    minQuantity = p.minQuantity;
    maxQuantity = p.maxQuantity;
    manageStock = p.manageStock;
    backOrdered = p.backOrdered;
    type = p.type;
    affiliateUrl = p.affiliateUrl;
    variations = p.variations;
    options = p.options;
    idShop = p.idShop;
  }

  Product.fromJson(Map<String, dynamic> parsedJson) {
    try {
      id = parsedJson["id"].toString();

      max_sale_qty = parsedJson["max_sale_qty"];
      sku = parsedJson['sku'];
      notes = parsedJson['notes'];

      name = parsedJson["name"];
      type = parsedJson["type"];
      unit_of_measurement = parsedJson['unit_of_measurement'];
      package_info = parsedJson['package_info'];
      country_of_manufacture = parsedJson['country_of_manufacture'];
      brand = parsedJson['brand'];
      delivery_date = parsedJson['delivery_date'];
      delivery_from = parsedJson['delivery_from'];
      qty = parsedJson["qty"];
      status = parsedJson["status"];
      description = isNotBlank(parsedJson["description"])
          ? parsedJson["description"]
          : parsedJson["short_description"];
      permalink = parsedJson["permalink"];
      price = parsedJson["price"] != null ? parsedJson["price"].toString() : "";

      regularPrice = parsedJson["regular_price"] != null
          ? parsedJson["regular_price"].toString()
          : null;
      salePrice = parsedJson["sale_price"] != null
          ? parsedJson["sale_price"].toString()
          : null;

      if (type == 'variable') {
        onSale = parsedJson["on_sale"];
      } else {
        onSale = parsedJson["price"] != parsedJson["regular_price"] &&
            isNotBlank(parsedJson["regular_price"]) &&
            double.parse(parsedJson["regular_price"]) >
                double.parse(parsedJson["price"]);
      }

      inStock =
          parsedJson["in_stock"] ?? parsedJson["stock_status"] == "instock";
      backOrdered = parsedJson["backordered"] ?? false;

      averageRating = parsedJson["average_rating"] ?? 0;
      ratingCount = parsedJson["rating_count"] ?? 0;
      totalSales = parsedJson["total_sales"] ?? 0;
      dateOnSaleFrom = parsedJson["date_on_sale_from"];
      dateOnSaleTo = parsedJson["date_on_sale_to"];
      categoryId = parsedJson["categoryId"];

      manageStock = parsedJson['manage_stock'] ?? false;

      // add stock limit
      if (parsedJson['manage_stock'] == true) {
        stockQuantity = parsedJson['stock_quantity'];
      }

      //minQuantity = parsedJson['meta_data']['']

      parsedJson["attributes"]?.forEach((item) {
        if (item['visible'] ?? true) {
          infors.add(ProductAttribute.fromLocalJson(item));
        }
      });

      List<ProductAttribute> attributeList = [];
      parsedJson["attributes"]?.forEach((item) {
        // if (item['visible'] ?? true && item['variation'] ?? true) {
        //
        // }
        final ProductAttribute attr = ProductAttribute.fromJson(item);
        attributeList.add(attr);

        /// Custom attributes not appeared in ["attributesData"].
        if (attr.options!.isEmpty) {
          /// Need to take from ["attributes"].
          // attr.options!.addAll(
          //   infors.firstWhereOrNull(
          //           (ProductAttribute productAttribute) =>
          //               productAttribute.id == attr.id)?.options?.map((option) => {"name": option}),
          // );
          attr.options!.addAll(
            infors.firstWhereOrNull(
                  (ProductAttribute productAttribute) => productAttribute.id == attr.id,
            )?.options?.map((option) => {"name": option}) ?? [],
          );

        }

        for (var option in attr.options!) {
          if (option['slug'] != null && option['slug'] != "") {
            attributeSlugMap[option['slug']] = option['name'];
          }
        }
      });
      attributes = attributeList.toList();

      List<Attribute> _defaultAttributes = [];
      parsedJson["default_attributes"]?.forEach((item) {
        _defaultAttributes.add(Attribute.fromJson(item));
      });
      defaultAttributes = _defaultAttributes.toList();

      List<String?> list = [];
      if (parsedJson["images"] != null) {
        for (var item in parsedJson["images"]) {
          list.add(item);
        }
      }

      images = list;
      printLog("Setting image feature 1");
      imageFeature = images!.isNotEmpty ? images![0] : null;
      imageFeature2 = parsedJson["imageFeature2"] ?? "";

      /// get video links, support following plugins
      /// - WooFeature Video: https://wordpress.org/plugins/woo-featured-video/
      ///- Yith Feature Video: https://wordpress.org/plugins/yith-woocommerce-featured-video/
      var video;
      if(parsedJson['meta_data'] != null){
        video = parsedJson['meta_data'].firstWhere(
              (item) =>
          item['key'] == '_video_url' || item['key'] == '_woofv_video_embed',
          orElse: () => null,
        );
      }
      if (video != null) {
        videoUrl = video['value'] is String
            ? video['value']
            : video['value']['url'] ?? '';
      }

      affiliateUrl = parsedJson['external_url'];

      List<int> groupedProductList = [];
      parsedJson['grouped_products']?.forEach((item) {
        groupedProductList.add(item);
      });
      groupedProducts = groupedProductList;
      List<String?> files = [];
      parsedJson['downloads']?.forEach((item) {
        files.add(item['file']);
      });
      this.files = files;

      if (parsedJson['meta_data'] != null) {
        for (var item in parsedJson['meta_data']) {
          try {
            if (item['key'] == '_minmax_product_max_quantity') {
              int quantity = int.parse(item['value']);
              quantity == 0 ? maxQuantity = null : maxQuantity = quantity;
            }
          } catch (e) {
            printLog('maxQuantity $e');
          }

          try {
            if (item['key'] == '_minmax_product_min_quantity') {
              int quantity = int.parse(item['value']);
              quantity == 0 ? minQuantity = null : minQuantity = quantity;
            }
          } catch (e) {
            printLog('minQuantity $e');
          }
        }
      }
    } catch (e, trace) {
      printLog(trace);
      printLog(e.toString());
    }
  }

  Product.fromMagentoJson(Map<String, dynamic> parsedJson) {
    try {
      // status= parsedJson["extension_attributes"]["stock_item"]!=null?true:false;
      status = parsedJson["extension_attributes"].containsKey("stock_item");
      if (!status!) {
        printLog(parsedJson["name"]);
      }
      //  print(parsedJson["extension_attributes"].containsKey("stock_item"));
      // if(parsedJson["name"]=="18+55 Iii Kit, 18Mp, Cmos Sens"){
      //   status=false;
      //        }
      // if(parsedJson["name"].contains("Warehouse Product")){
      //   print(parsedJson["name"]);
      //   print(parsedJson["extension_attributes"]["stock_item"]["is_in_stock"]);
      // }
      qty =
      status! ? parsedJson["extension_attributes"]["stock_item"]["qty"] : 0;
      maxSaleQty = status!
          ? parsedJson["extension_attributes"]["stock_item"]["max_sale_qty"]
          : 0;
      id = "${parsedJson["id"]}";
      max_sale_qty = status!
          ? parsedJson["extension_attributes"]["stock_item"]["max_sale_qty"]
          : 1;
      sku = parsedJson["sku"];
      notes = parsedJson["notes"];
      name = parsedJson["name"] ?? "";
      unit_of_measurement = parsedJson['unit_of_measurement'];
      package_info = parsedJson['package_info'];
      country_of_manufacture = parsedJson['country_of_manufacture'];
      brand = parsedJson['brand'];
      delivery_date = parsedJson['delivery_date'];
      delivery_from = parsedJson['delivery_from'];
      permalink = parsedJson["permalink"];
      inStock = status! ? true : false;
      //  parsedJson["status"] == 1;
      averageRating = 0.0;
      ratingCount = 0;
      // productImage= "https://up.ctown.jo/pub/media/catalog/product"+parsedJson["custom_attributes"][2]["value"];
      // productImage= "https://up.ctown.jo/pub/media/catalog/product"+   parsedJson["custom_attributes"].forEach((e){
      //   if(e["attribute_code"]=="image"){
      //     return e["value"];
      //   }
      // });

      categoryId = "${parsedJson["category_id"]}";
      attributes = [];
    } catch (e) {
      debugPrintStack();
      printLog(e.toString());
    }
  }

  Map<String, dynamic> toDynamicLinkJson() {
    return {
      "id": id,
      "notes": notes,
      "note": note,
      "sku" : sku,
      "name": name,
      "status": status,
      "vendor": vendor,
      "description": description,
      "permalink": permalink,
      "price": price,
      "qty": qty,
      "max_sale_qty": maxSaleQty,
      "regularPrice": regularPrice,
      "salePrice": salePrice,
      "onSale": onSale,
      "delivery_date": delivery_date,
      "delivery_from": delivery_from,
      "unit_of_measurement": unit_of_measurement,
      "package_info": package_info,
      "brand": brand,
      "country_of_manufacture": country_of_manufacture,
      "inStock": inStock,
      "averageRating": averageRating,
      "totalSales": totalSales,
      "dateOnSaleFrom": dateOnSaleFrom,
      "dateOnSaleTo": dateOnSaleTo,
      "ratingCount": ratingCount,
      "productImage": productImage,
      "images": images,
      "imageFeature": imageFeature,
      "imageFeature2": imageFeature2,
      "attributes": attributes?.map((e) => e.toJson()).toList(),
      "attributeSlugMap": attributeSlugMap,
      "defaultAttributes": defaultAttributes?? [],
      "infors": infors,
      "categoryId": categoryId,
      "videoUrl": videoUrl,
      "groupedProducts": groupedProducts ?? [],
      "files": files ?? [],
      "stockQuantity": stockQuantity,
      "minQuantity": minQuantity,
      "maxQuantity": maxQuantity,
      "manageStock": manageStock,
      "backOrdered": backOrdered,
      "store": store?.toJson(),
      "type": type,
      "variableprice": variableprice,
      "affiliateUrl": affiliateUrl,
      "variations": variations ?? [],
      "options": options,
      "bookingInfo": bookingInfo,
      "idShop": idShop,

      'distance': distance,
      'pureTaxonomies': pureTaxonomies,
      'reviews': reviews,
      'featured': featured,
      'verified': verified,
      'tagLine': tagLine,
      'priceRange': priceRange,
      'categoryName': categoryName,
      'hours': hours,
      'location': location,
      'phone': phone,
      'facebook': facebook,
      'email': email,
      'website': website,
      'skype': skype,
      'whatsapp': whatsapp,
      'youtube': youtube,
      'twitter': twitter,
      'instagram': instagram,
      'eventDate': eventDate,
      'rating': rating,
      'totalReview': totalReview,
      'lat': lat,
      'long': long,
      'prices': listingMenu,
      'slots': slots,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notes': notes,
      'note': note,
      'sku': sku,
      'name': name,
      'status': status,
      'vendor': vendor,
      'description': description,
      'permalink': permalink,
      'price': price,
      'qty': qty,
      'max_sale_qty': maxSaleQty,
      'regular_price': regularPrice,
      'sale_price': salePrice,
      'on_sale': onSale,
      'delivery_date': delivery_date,
      'delivery_from': delivery_from,
      'unit_of_measurement': unit_of_measurement,
      'package_info': package_info,
      'brand': brand,
      'country_of_manufacture': country_of_manufacture,
      'in_stock': inStock,
      'average_rating': averageRating,
      'total_sales': totalSales,
      'date_on_sale_from': dateOnSaleFrom,
      'date_on_sale_to': dateOnSaleTo,
      'rating_count': ratingCount,
      'productImage': productImage,
      'images': images,
      'imageFeature': imageFeature,
      'imageFeature2': imageFeature2,
      'attributes': attributes?.map((attr) => attr.toJson()).toList(),
      'attributeSlugMap': attributeSlugMap,
      'default_attributes': defaultAttributes?.map((attr) => attr.toJson()).toList(),
      'infors': infors.map((attr) => attr.toJson()).toList(),
      'categoryId': categoryId,
      'videoUrl': videoUrl,
      'grouped_products': groupedProducts,
      'files': files,
      'stock_quantity': stockQuantity,
      '_minmax_product_min_quantity': minQuantity,
      '_minmax_product_max_quantity': maxQuantity,
      'manage_stock': manageStock,
      'backOrdered': backOrdered,
      'store': store?.toJson(),
      'type': type,
      'variableprice': variableprice,
      'external_url': affiliateUrl,
      'variations': variations?.map((variation) => variation.toJson()).toList(),
      'options': options,
      'bookingInfo': bookingInfo?.toJson(),
      'idShop': idShop,
      'distance': distance,
      'pureTaxonomies': pureTaxonomies,
      'reviews': reviews,
      'featured': featured,
      'verified': verified,
      'tagLine': tagLine,
      'priceRange': priceRange,
      'categoryName': categoryName,
      'hours': hours,
      'location': location,
      'phone': phone,
      'facebook': facebook,
      'email': email,
      'website': website,
      'skype': skype,
      'whatsapp': whatsapp,
      'youtube': youtube,
      'twitter': twitter,
      'instagram': instagram,
      'eventDate': eventDate,
      'rating': rating,
      'totalReview': totalReview,
      'lat': lat,
      'long': long,
      'listingMenu': listingMenu,
      'slots': slots?.toJson(),
    };
  }

  Product.fromLocalJson(Map<String, dynamic> json) {
    try {
      id = json['id'].toString();
      sku = json['sku'];
      name = json['name'];
      status = json["status"];
      delivery_date = json['delivery_date'];
      delivery_from = json['delivery_from'];
      unit_of_measurement = json['unit_of_measurement'];
      country_of_manufacture = json['country_of_manufacture'];
      brand = json['brand'];
      description = json['description'];
      permalink = json['permalink'];

      price = json['price'];
      regularPrice = json['regularPrice'];
      salePrice = json['salePrice'];
      onSale = json['onSale'];
      inStock = json['inStock'];
      averageRating = json['averageRating'];
      ratingCount = json['ratingCount'];
      totalSales = json['total_sales'];
      dateOnSaleFrom = json["date_on_sale_from"];
      dateOnSaleTo = json["date_on_sale_to"];
      idShop = json['idShop'];
      type = json['sku'] != null && json['sku'].contains('config') ? 'configurable' : 'simple';
      List<String?> imgs = [];

      if (json['images'] != null) {
        for (var item in json['images']) {
          imgs.add(item);
        }
      }
      images = imgs;
      imageFeature = json['imageFeature'];
      List<ProductAttribute> attrs = [];

      if (json['attributes'] != null) {
        for (var item in json['attributes']) {
          attrs.add(ProductAttribute.fromLocalJson(item));
        }
      }

      attributes = attrs;
      categoryId = "${json['categoryId']}";
      stockQuantity = json['stock_quantity'];
      if (json['store'] != null) {
        store = Store.fromLocalJson(json['store']);
      }

      ///----store Listing----///

      distance = json['distance'];
      pureTaxonomies = json['pureTaxonomies'];
      reviews = json['reviews'];
      featured = json['featured'];
      verified = json['verified'];
      tagLine = json['tagLine'];
      priceRange = json['priceRange'];
      categoryName = json['categoryName'];
      hours = json['hours'];
      location = json['location'];
      phone = json['phone'];
      facebook = json['facebook'];
      email = json['email'];
      website = json['website'];
      skype = json['skype'];
      whatsapp = json['whatsapp'];
      youtube = json['youtube'];
      twitter = json['twitter'];
      instagram = json['instagram'];
      eventDate = json['eventDate'];
      rating = json['rating'];
      totalReview = json['totalReview'];
      lat = json['lat'];
      long = json['long'];
      listingMenu = json['prices'];
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
    }
  }

  @override
  String toString() => 'Product { id: $id name: $name }';

  /// Get product ID from mix String productID-ProductVariantID
  static String cleanProductID(productString) {
    if (productString.contains("-")) {
      return productString.split("-")[0].toString();
    } else {
      return productString.toString();
    }
  }

  ///----store LISTING----////
  Product.fromListingJson(Map<String, dynamic> json) {
    try {
      id = Tools.getValueByKey(json, DataMapping().ProductDataMapping["id"])
          .toString();
      name = HtmlUnescape().convert(
          Tools.getValueByKey(json, DataMapping().ProductDataMapping["title"]));
      description = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["description"]);
      delivery_date = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["delivery_date"]);
      delivery_from = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["delivery_from"]);
      unit_of_measurement = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["unit_of_measurement"]);
      country_of_manufacture = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["country_of_manufacture"]);
      brand =
          Tools.getValueByKey(json, DataMapping().ProductDataMapping["brand"]);
      permalink =
          Tools.getValueByKey(json, DataMapping().ProductDataMapping["link"]);

      distance = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["distance"]);

      pureTaxonomies = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["pureTaxonomies"]);

      final rate =
      Tools.getValueByKey(json, DataMapping().ProductDataMapping["rating"]);

      averageRating = rate != null
          ? double.parse(double.parse(double.parse(rate.toString()).toString())
          .toStringAsFixed(1))
          : 0.0;

      regularPrice = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["regularPrice"]);
      price = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["priceRange"]);

      type =
          Tools.getValueByKey(json, DataMapping().ProductDataMapping["type"]);
      categoryName = type;
      rating =
          Tools.getValueByKey(json, DataMapping().ProductDataMapping["rating"]);
      rating = rating ?? '0.0';

      final reviews = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["totalReview"]);
      totalReview = reviews != null && reviews != false
          ? int.parse(reviews.toString())
          : 0;
      ratingCount = totalReview;

      location = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["address"]);
      final la =
      Tools.getValueByKey(json, DataMapping().ProductDataMapping["lat"]);
      final lo =
      Tools.getValueByKey(json, DataMapping().ProductDataMapping["lng"]);
      lat = la != null ? double.parse(la.toString()) : null;
      long = lo != null ? double.parse(lo.toString()) : null;

      phone =
          Tools.getValueByKey(json, DataMapping().ProductDataMapping["phone"]);
      email =
          Tools.getValueByKey(json, DataMapping().ProductDataMapping["email"]);
      skype =
          Tools.getValueByKey(json, DataMapping().ProductDataMapping["skype"]);
      website = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["website"]);
      whatsapp = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["whatsapp"]);
      facebook = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["facebook"]);
      twitter = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["twitter"]);
      youtube = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["youtube"]);
      instagram = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["instagram"]);
      tagLine = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["tagLine"]);
      eventDate = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["eventDate"]);
      priceRange = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["priceRange"]);
      featured = 'off';
      if (DataMapping().ProductDataMapping["featured"] != null) {
        featured = Tools.getValueByKey(
            json, DataMapping().ProductDataMapping["featured"]);
      }
      verified = 'off';
      if (DataMapping().ProductDataMapping["verified"] != null) {
        verified = Tools.getValueByKey(
            json, DataMapping().ProductDataMapping["verified"]);
      }
      List<String?> list = [];
      final gallery = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["gallery"]);
      if (gallery != null) {
        if (gallery is Map) {
          var keys = List<String>.from(gallery.keys);
          for (var item in keys) {
            if (gallery['$item'].contains('http')) {
              list.add(gallery['$item']);
            } else {
              list.add(item);
            }
          }
        } else {
          gallery.forEach((item) {
            if (item is Map) {
              list.add(item['media_details']['sizes']['medium']['source_url']);
            } else {
              list.add(item);
            }
          });
        }
      }
      var defaultImages = Tools.getValueByKey(
          json, DataMapping().ProductDataMapping["featured_media"]);
      if (defaultImages is String) {
        if (defaultImages == null) {
          printLog("Setting image feature 3");
          imageFeature = list.isNotEmpty ? list[0] : kDefaultImage;
        } else {
          printLog("Setting image feature 4");
          imageFeature = defaultImages.isEmpty
              ? list.isNotEmpty
              ? list[0]
              : kDefaultImage
              : defaultImages;
        }
      } else {
        if (defaultImages != null) {
          printLog("Setting image feature 5");
          imageFeature = defaultImages.isNotEmpty
              ? defaultImages[0]
              : list.isNotEmpty
              ? list[0]
              : kDefaultImage;
        } else {
          printLog("Setting image feature 6");
          imageFeature = list.isNotEmpty ? list[0] : kDefaultImage;
        }
      }

      images = list;
      final items =
      Tools.getValueByKey(json, DataMapping().ProductDataMapping["menu"]);
      if (items != null && items.length > 0) {
        for (var i = 0; i < items.length; i++) {
          var item = ListingMenu.fromJson(items[i]);
          if (item.menu.isNotEmpty) {
            listingMenu!.add(item);
          }
        }
      }

      /// Remember to check if the theme is listeo
      /// This is for testing only
      if (json['_slots_status'] == 'on') {
        if (json['_slots'] != null) {
          slots = ListingSlots.fromJson(json['_slots']);
        }
      }

      ///Set other attributes that not relate to Listing to be unusable

    } catch (err) {
      printLog('err when parsed json Listing $err');
    }
  }

  // rough

  Product.fromOpencartJson(Map<String, dynamic> parsedJson) {
    try {
      id = parsedJson["product_id"] != null ? parsedJson["product_id"] : '0';
      name = HtmlUnescape().convert(parsedJson["name"]);
      description = parsedJson["description"];
      unit_of_measurement = parsedJson['unit_of_measurement'];
      brand = parsedJson['brand'];
      country_of_manufacture = parsedJson['country_of_manufacture'];
      delivery_date = parsedJson['delivery_date'];
      delivery_from = parsedJson['delivery_from'];
      permalink = serverConfig["url"]! +
          "/index.php?route=product/product&product_id=$id";
      regularPrice = parsedJson["price"];
      salePrice = parsedJson["special"];
      price = salePrice ?? regularPrice;
      onSale = salePrice != null;
      inStock = parsedJson["stock_status"] == "In Stock" ||
          int.parse(parsedJson["quantity"]) > 0;
      averageRating = parsedJson["rating"] != null
          ? double.parse(parsedJson["rating"].toString())
          : 0.0;
      ratingCount = parsedJson["reviews"] != null
          ? int.parse(parsedJson["reviews"].toString())
          : 0.0 as int?;
      attributes = [];

      List<String?> list = [];
      if (parsedJson["images"] != null && parsedJson["images"].length > 0) {
        for (var item in parsedJson["images"]) {
          list.add(item);
        }
      }
      if (list.isEmpty && parsedJson['image'] != null) {
        list.add('${Config().url}/image/${parsedJson['image']}');
      }
      images = list;
      imageFeature = images!.isNotEmpty ? images![0] : "";
      options = List<Map<String, dynamic>>.from(parsedJson['options']);
    } catch (e) {
      debugPrintStack();
      printLog(e.toString());
    }
  }
  Product.fromShopify(Map<String, dynamic> json) {
    try {
      var priceV2 = json['variants']['edges'][0]['node']['priceV2'];
      var compareAtPriceV2 =
      json['variants']['edges'][0]['node']['compareAtPriceV2'];
      var compareAtPrice =
      compareAtPriceV2 != null ? compareAtPriceV2['amount'] : null;
      var categories =
      json['collections'] != null ? json['collections']['edges'] : null;
      var defaultCategory = categories != null ? categories[0]['node'] : null;

      categoryId = json['categoryId'] ?? defaultCategory['id'];
      id = json['id'];
      sku = json['sku'];
      name = json['title'];
      unit_of_measurement = json['unit_of_measurement'];
      country_of_manufacture = json['country_of_manufacture'];
      brand = json['brand'];
      delivery_date = json['delivery_date'];
      delivery_from = json['delivery_from'];
      vendor = json['vendor'];
      description = json['description'];
      price = priceV2 != null ? priceV2['amount'] : null;
      regularPrice = compareAtPrice ?? price;
      onSale = compareAtPrice != null && compareAtPrice != price;
      inStock = json['availableForSale'];
      ratingCount = 0;
      averageRating = 0;
      permalink = json['onlineStoreUrl'];

      List<String?> imgs = [];

      if (json['images']['edges'] != null) {
        for (var item in json['images']['edges']) {
          imgs.add(item['node']['src']);
        }
      }

      images = imgs;
      imageFeature = images![0];

      List<ProductAttribute> attrs = [];

      if (json['options'] != null) {
        for (var item in json['options']) {
          attrs.add(ProductAttribute.fromShopify(item));
        }
      }

      attributes = attrs;
      List<ProductVariation> variants = [];

      if (json['variants']['edges'] != null) {
        for (var item in json['variants']['edges']) {
          variants.add(ProductVariation.fromShopifyJson(item['node']));
        }
      }

      variations = variants;
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
    }
  }


  Product.fromPresta(Map<String, dynamic> parsedJson, apiLink) {
    try {
      id = parsedJson["id"] != null ? parsedJson["id"].toString() : '0';
      name = parsedJson["name"];
      unit_of_measurement = parsedJson['unit_of_measurement'];
      country_of_manufacture = parsedJson['country_of_manufacture'];
      brand = parsedJson['brand'];
      delivery_date = parsedJson['delivery_date'];
      delivery_from = parsedJson['delivery_from'];
      description =
      parsedJson["description"] is String ? parsedJson["description"] : '';
      permalink = parsedJson["link_rewrite"];
      regularPrice = (double.parse((parsedJson["price"] ?? 0.0).toString()))
          .toStringAsFixed(2);
      salePrice =
          (double.parse((parsedJson["wholesale_price"] ?? 0.0).toString()))
              .toStringAsFixed(2);
      price = (double.parse((parsedJson["wholesale_price"] ?? 0.0).toString()))
          .toStringAsFixed(2);
      idShop = parsedJson["id_shop_default"] != null
          ? parsedJson["id_shop_default"].toString()
          : null;
      ratingCount = 0;
      averageRating = 0.0;
      if (salePrice != regularPrice) {
        onSale = true;
      } else {
        onSale = false;
      }
      imageFeature = parsedJson["id_default_image"] != null
          ? apiLink('images/products/$id/${parsedJson["id_default_image"]}')
          : null;
      images = [];
      if (parsedJson["associations"] != null &&
          parsedJson["associations"]["images"] != null) {
        for (var item in parsedJson["associations"]["images"]) {
          images!.add(apiLink('images/products/$id/${item["id"]}'));
        }
      } else {
        images!.add(imageFeature);
      }
      if (parsedJson["associations"] != null &&
          parsedJson["associations"]["stock_availables"] != null) {
        sku = parsedJson["associations"]["stock_availables"][0]["id"];
      }
      type = parsedJson['type'];
      if (parsedJson['quantity'] != null &&
          parsedJson['quantity'].toString().isNotEmpty) {
        stockQuantity = int.parse(parsedJson['quantity']);
        if (stockQuantity! > 0) inStock = true;
      }
      if (inStock == null) inStock = false;
      if (parsedJson["associations"] != null &&
          parsedJson["associations"]["product_bundle"] != null) {
        groupedProducts = parsedJson["associations"]["product_bundle"];
      }
      List<ProductAttribute> attrs = [];
      if (parsedJson['attributes'] != null) {
        var res = Map<String, dynamic>.from(parsedJson['attributes']);
        var keys = res.keys.toList();
        for (var i = 0; i < keys.length; i++) {
          attrs.add(ProductAttribute.fromPresta(
              {'id': i, 'name': keys[i], 'options': res[keys[i]]}));
        }
        attributes = attrs;
      } else {
        attributes = [];
      }
    } catch (e, trace) {
      printLog(trace);
      printLog(e.toString());
    }
  }

  Product.fromJsonStrapi(SerializerProduct model, apiLink) {
    try {
      id = model.id.toString();
      name = model.title;
      inStock = !model.isOutOfStock!;
      stockQuantity = model.inventory;
      images = [];
      if (model.images != null) {
        for (var item in model.images!) {
          images!.add(apiLink(item.url));
        }
      }
      imageFeature =
      images!.isNotEmpty ? images![0] : apiLink(model.thumbnail!.url);

      averageRating = model.review == null ? 0 : model.review!.toDouble();
      ratingCount = 0;
      price = model.price.toString();
      regularPrice = model.price.toString();
      salePrice = model.salePrice.toString();

      if (model.productCategories != null) {
        categoryId = model.productCategories!.isNotEmpty
            ? model.productCategories![0].id.toString()
            : '0';
      } else {
        categoryId = '0';
      }
      onSale = model.isSale;
    } catch (e, trace) {
      printLog(e);
      printLog(trace);
    }
  }

///----store LISTING----////
}

class BookingDate1 {
  int? value;
  String? unit;

  BookingDate1.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    unit = json['unit'];
  }
}
