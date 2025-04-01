import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:quiver/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/entities/card_details.dart';
import '../../../models/entities/states.dart';
import '../../../models/index.dart'
    show Address, BlogNews, CartModel, Category, Coupons, Order, PaymentMethod, Product, ProductAttribute, ProductModel, ProductVariation, Review, ShippingMethod, User, UserModel;
import '../../../services/base_services.dart';
import '../../../widgets/home/clickandcollect_provider.dart';
import '../../../widgets/orders/tracking.dart';
import 'magento_helper.dart';

class MagentoApi with EmptyServiceMixin implements BaseServices {
  static final MagentoApi _instance = MagentoApi._internal();

  factory MagentoApi() => _instance;

  MagentoApi._internal();
  String? domain;
  String? accessToken;
  String? guestQuoteId;
  Map<String, ProductAttribute>? attributes;

  getSavedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore') ?? "";
    if(result != "") {
      return jsonDecode(result);
    }
    else {
      return null;
    }
  }

  getSavedStoregroupid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('setSavedStoregroupid')!;

    return jsonDecode(result);
  }
  // @override
  // BlogNewsApi blogApi;

  void setAppConfig(appConfig) async {
    domain = appConfig["url"];
    printLog("Appconfig url $domain");
    // blogApi = BlogNewsApi(appConfig["blog"] ?? 'http://demo.ist.io');
    accessToken = appConfig["accessToken"];

    attributes = null;
    guestQuoteId = null;
  }

  // @override
  // Future<List<BlogNews>> fetchBlogLayout({config, lang}) async {
  //   try {
  //     List<BlogNews> list = [];

  //     var endPoint = "posts?_embed&lang=$lang";
  //     if (config.containsKey("category")) {
  //       endPoint += "&categories=${config["category"]}";
  //     }
  //     if (config.containsKey("limit")) {
  //       endPoint += "&per_page=${config["limit"] ?? 20}";
  //     }
  //     printLog("Blog");
  //     printLog(endPoint);

  //     var response = await blogApi.getAsync(endPoint);

  //     for (var item in response) {
  //       if (BlogNews.fromJson(item) != null) {
  //         list.add(BlogNews.fromJson(item));
  //       }
  //     }

  //     return list;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<BlogNews> getPageById(int pageId) async {
  //   var response = await blogApi.getAsync("pages/$pageId?_embed");
  //   return BlogNews.fromJson(response);
  // }

  Product parseProductFromJson(item) {
    final dateSaleFrom = MagentoHelper.getCustomAttribute(
        item["custom_attributes"], "special_from_date");
    final delivery_date = MagentoHelper.getCustomAttribute(
        item["custom_attributes"], "delivery_date");
    final unit_of_measurement = MagentoHelper.getCustomAttribute(
        item["custom_attributes"], "unit_of_measurement");
    final package_info = MagentoHelper.getCustomAttribute(
        item["custom_attributes"], "package_info");
    final country_of_manufacture = MagentoHelper.getCustomAttribute(
        item["custom_attributes"], "country_of_origin");
    final brand =
    MagentoHelper.getCustomAttribute(item["custom_attributes"], "brand");
    final delivery_from = MagentoHelper.getCustomAttribute(
        item["custom_attributes"], "delivery_from");

    final dateSaleTo = MagentoHelper.getCustomAttribute(
        item["custom_attributes"], "special_to_date");
    bool onSale = false;
    var price = item["price"];
    // var price = MagentoHelper.getCustomAttribute(
    //         item["custom_attributes"], "old_price") ??
    //     "0.0";
    var salePrice = MagentoHelper.getCustomAttribute(
        item["custom_attributes"], "special_price") ??
        "0.0";
    ////// var salePrice = "${item["price"]}";
    if (dateSaleFrom != null && dateSaleTo != null) {
      final now = DateTime.now();
      DateTime dateSaleTo1 = DateTime.parse(dateSaleTo);
      printLog(dateSaleTo1);
      printLog("fajhfhafafgaggfga");
      var newDate =
      DateTime(dateSaleTo1.year, dateSaleTo1.month, dateSaleTo1.day + 1);
      printLog(newDate);

      onSale = now.isAfter(DateTime.parse(dateSaleFrom)) &&
          now.isBefore(DateTime.parse(newDate.toString()));
      printLog("jhashdshahhdajhaddh");
      printLog(onSale);

      if (onSale) {}
    } else {
      // onSale = double.parse(
      //     "${MagentoHelper.getCustomAttribute(item["custom_attributes"], "old_price")}",
      //         (_) => 0.0) >
      //     double.parse("$salePrice");
      try {
        double oldPrice = double.parse(
            "${MagentoHelper.getCustomAttribute(item["custom_attributes"], "old_price")}");
        double salePriceDouble = double.parse("$salePrice");

        onSale = oldPrice > salePriceDouble;
      } catch (e) {
        // Handle parsing error if necessary (optional)
        onSale = false;
      }
    }
    final mediaGalleryEntries = item["media_gallery_entries"];
    var images = [MagentoHelper.getProductImageUrl(domain, item, "thumbnail")];
    Product product = Product.fromMagentoJson(item);
    final description = MagentoHelper.getCustomAttribute(
        item["custom_attributes"], "description");
    product.unit_of_measurement =
    unit_of_measurement != null ? unit_of_measurement : '';
    product.package_info = package_info != null ? package_info : '';
    product.country_of_manufacture =
    country_of_manufacture != null ? country_of_manufacture : '';
    product.brand = brand != null ? brand : '';
    product.delivery_date = delivery_date != null ? delivery_date : '';
    product.delivery_from = delivery_from != null ? delivery_from : '';
    product.description = description != null
        ? description
        : MagentoHelper.getCustomAttribute(
        item["custom_attributes"], "short_description");

    if (item["type_id"] == "configurable") {
      product.price = MagentoHelper.getCustomAttribute(
          item["custom_attributes"], "minimal_price");
      product.regularPrice = product.price;
    } else {
      product.price = "${item["price"]}";
      // product.regularPrice = "${item["price"]}";
      var oldPrice = double.parse(MagentoHelper.getCustomAttribute(
          item["custom_attributes"], "old_price") ??
          '0.0');
      product.regularPrice = "${oldPrice == 0.0 ? item["price"] : oldPrice}";
    }

    ///
    ///
    // product.price=item["price"].toString();
    // product.regularPrice=item["price"].toString();
    ///
    ///

    /*product.salePrice = MagentoHelper.getCustomAttribute(
        item["custom_attributes"], "special_price");*/
    printLog("getCustomAttribute");
    printLog(MagentoHelper.getCustomAttribute(
        item["custom_attributes"], "special_price"));
    //
    //// product.salePrice = "${item["price"]}";
    product.salePrice = "$salePrice";
    product.onSale = onSale;
    product.images = images;
    String? newImageFeature = images[0];
    if (images[0].contains("/cache")) {
      var cut = images[0].split("/cache/");
      int cut2 = cut[1].indexOf("/");
      product.imageFeature2 = cut[0] + cut[1].substring(cut2);
    }
    printLog("dgerhtghsdgs");
    printLog(images);
    printLog(images[0]);
    printLog(newImageFeature);
    printLog("Product imageFeature2: ${product.imageFeature2}");
    product.imageFeature = newImageFeature;
// product.imageFeature = images[0];
    List<dynamic>? categoryIds;
    if (item["custom_attributes"] != null &&
        item["custom_attributes"].length > 0) {
      for (var item in item["custom_attributes"]) {
        if (item["attribute_code"] == "category_ids") {
          categoryIds = item["value"];
          break;
        }
      }
    }
    product.categoryId = categoryIds!.isNotEmpty ? "${categoryIds[0]}" : "0";
    product.permalink = "";

    List<ProductAttribute> attrs = [];
    final options = item["extension_attributes"] != null &&
        item["extension_attributes"]["configurable_product_options"] != null
        ? item["extension_attributes"]["configurable_product_options"]
        : [];

    List? attrsList = kAdvanceConfig["EnableAttributesConfigurableProduct"] as List<dynamic>?;
    List? attrsLabelList =
    kAdvanceConfig["EnableAttributesLabelConfigurableProduct"] as List<dynamic>?;
    for (var i = 0; i < options.length; i++) {
      final option = options[i];

      for (var j = 0; j < attrsList!.length; j++) {
        final item = attrsList[j];
        printLog("Natblida");
        printLog(item);
        final itemLabel = attrsLabelList![j];
        printLog(itemLabel);
        if (option["label"].toLowerCase() ==
            itemLabel.toString().toLowerCase()) {
          List? values = option["values"];
          List optionAttr = [];
          if (attributes![item] != null) {
            for (var f in attributes![item]!.options!) {
              final value = values!.firstWhere(
                      (o) => o["value_index"].toString() == f["value"],
                  orElse: () => null);
              if (value != null) {
                optionAttr.add(f);
              }
            }
            attrs.add(ProductAttribute.fromMagentoJson({
              "attribute_id": attributes![item]!.id,
              "attribute_code": attributes![item]!.name,
              "options": optionAttr
            }));
          }
        }
      }
      attrsList.forEach((item) {});
    }

    product.attributes = attrs;
    product.type = item["type_id"];
    return product;
  }

  Future updatePaymentMethod(String? orderId,
      {String paymentMethod = "cashondelivery"}) async {
    Uri uri = Uri.parse('https://up.ctown.jo/api/reinitiatepayment.php');

    try {
      final client = http.Client();
      final response = await client.post(
        uri,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: json.encode({
          "order_id": orderId,
          "payment_method": paymentMethod,
        }),
      );
      printLog("resp ${response.body}");
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if ((body as Map).containsKey('success')) {
          if (body['success'] == "1") {
            return body["message"];
          } else {
            return '0';
          }
        } else {
          return '0';
        }
      } else {
        return '0';
      }
    } catch (e) {
      printLog(e.toString());
      return '0';
    }
  }

  Future<bool?> getStockStatus(sku) async {
    try {
      // var response = await http.get(
      //     MagentoHelper.buildUrl(domain, "stockItems/$sku"),
      //     headers: {'Authorization': 'Bearer ' + accessToken});
      // printLog(MagentoHelper.buildUrl(domain, "stockItems/$sku"));
      // final body = convert.jsonDecode(response.body);
      var response = jsonEncode({
        "item_id": 29658,
        "product_id": 18849,
        "stock_id": 1,
        "qty": 10000000,
        "is_in_stock": true,
        "is_qty_decimal": false,
        "show_default_notification_message": false,
        "use_config_min_qty": true,
        "min_qty": 0,
        "use_config_min_sale_qty": 1,
        "min_sale_qty": 1,
        "use_config_max_sale_qty": true,
        "max_sale_qty": 10000,
        "use_config_backorders": true,
        "backorders": 0,
        "use_config_notify_stock_qty": true,
        "notify_stock_qty": 10,
        "use_config_qty_increments": true,
        "qty_increments": 0,
        "use_config_enable_qty_inc": true,
        "enable_qty_increments": false,
        "use_config_manage_stock": true,
        "manage_stock": true,
        "low_stock_date": null,
        "is_decimal_divided": false,
        "stock_status_changed_auto": 0
      });
      final body = convert.jsonDecode(response);

      return body["is_in_stock"] != null ? body["is_in_stock"] : false;
    } catch (e) {
      rethrow;
    }
  }

  Future getAllAttributes(String lang) async {
    try {
      attributes = <String, ProductAttribute>{};
      List attrs = kAdvanceConfig["EnableAttributesConfigurableProduct"] as List<dynamic>;
      attrs.forEach((item) async {
        ProductAttribute attrsItem = await getProductAttributes(item, lang);
        attributes![item] = attrsItem;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductAttribute> getProductAttributes(String attributeCode, String lang) async {
    try {
      printLog(
          MagentoHelper.buildUrl(domain, "products/attributes/$attributeCode", ""));

      var response = await http.get(Uri.parse(MagentoHelper.buildUrl(domain, "products/attributes/$attributeCode", "")),
          headers: {'Authorization': 'Bearer ' + accessToken!});
      printLog(response.body);
      final body = convert.jsonDecode(response.body);
      if (body["message"] != null) {
        throw Exception(MagentoHelper.getErrorMessage(body));
      } else {
        return ProductAttribute.fromMagentoJson(body);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategories({lang}) async {
    try {
      printLog("categorieslang $lang");
      try {
        var store1 = await getSavedStore();
        var storeCode = lang == "en"
            ? store1["store_en"]["code"]
            : store1["store_ar"]["code"];
        printLog("store1 $store1 inside categories");
        printLog(storeCode + " gcode");
        printLog("categories");
        printLog(MagentoHelper.buildCategoryUrl(domain, "ist/categories", lang));
        printLog(MagentoHelper.buildCategoryUrl(domain, "ist/categories", lang));
        printLog(MagentoHelper.buildCategoryUrl(
            domain, storeCode, "ist/categories", "en"));
        var response = await http.get(
            Uri.parse(lang == "en"
                ? MagentoHelper.buildCategoryUrl(
                domain, storeCode, "ist/categories", "en")
                : MagentoHelper.buildCategoryUrl(
                domain, storeCode, "ist/categories", "ar")),
            headers: {'Authorization': 'Bearer ' + accessToken!});
        printLog(response);

        printLog("resp $lang fddfg  ");
        printLog(accessToken);
        // printLog(response.statusCode);
        // printLog(response.body);
        List<Category> list = [];
        if (response.statusCode == 200) {
          for (var item in convert.jsonDecode(response.body)["children_data"]) {
            if (item["is_active"] == true) {
              var category = Category.fromMagentoJson(item);
              category.parent = '0';
              if (item["image"] != null) {
                category.image = item["image"].toString().contains("media/")
                    ? "$domain/${item["image"]}"
                    : "$domain/pub/media/catalog/category/${item["image"]}";
              }
              list.add(category);

              for (var item1 in item["children_data"]) {
                if (item1["is_active"] == true) {
                  list.add(Category.fromMagentoJson(item1));

                  for (var item2 in item1["children_data"]) {
                    if (item1["is_active"] == true) {
                      list.add(Category.fromMagentoJson(item2));
                    }

                    //
                    if (item2["children_data"].isNotEmpty) {
                      for (var item3 in item2["children_data"]) {
                        if (item1["is_active"] == true) {
                          list.add(Category.fromMagentoJson(item3));
                        }
                        if (item3["children_data"].isNotEmpty) {
                          for (var item4 in item3["children_data"]) {
                            if (item1["is_active"] == true) {
                              list.add(Category.fromMagentoJson(item4));
                            }
                          }
                        }
                      }
                    }

                    //

                    //
                  }
                }
              }
            }
          }
        }
        printLog(list);
        return list;
      } catch (e) {
        printLog("that is for the first time");
        printLog("catch $e");

        var response = await http.get(
            Uri.parse(MagentoHelper.buildCategoryUrl(
                domain, "ctown_7th_en", "ist/categories", "en")),
            headers: {'Authorization': 'Bearer ' + accessToken!});

        printLog("resp $lang fddfg  ");
        printLog(accessToken);
        // printLog(response.statusCode);
        // printLog(response.body);
        List<Category> list = [];
        if (response.statusCode == 200) {
          for (var item in convert.jsonDecode(response.body)["children_data"]) {
            if (item["is_active"] == true) {
              var category = Category.fromMagentoJson(item);
              category.parent = '0';
              if (item["image"] != null) {
                category.image = item["image"].toString().contains("media/")
                    ? "$domain/${item["image"]}"
                    : "$domain/pub/media/catalog/category/${item["image"]}";
              }
              list.add(category);

              for (var item1 in item["children_data"]) {
                if (item1["is_active"] == true) {
                  list.add(Category.fromMagentoJson(item1));

                  for (var item2 in item1["children_data"]) {
                    if (item1["is_active"] == true) {
                      list.add(Category.fromMagentoJson(item2));
                    }

                    //
                    if (item2["children_data"].isNotEmpty) {
                      for (var item3 in item2["children_data"]) {
                        if (item1["is_active"] == true) {
                          list.add(Category.fromMagentoJson(item3));
                        }
                        if (item3["children_data"].isNotEmpty) {
                          for (var item4 in item3["children_data"]) {
                            if (item1["is_active"] == true) {
                              list.add(Category.fromMagentoJson(item4));
                            }
                          }
                        }
                      }
                    }

                    //

                    //
                  }
                }
              }
            }
          }
        }
        return list;
      }
    } catch (e) {
      printLog("category error $e");
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    printLog("get details pages");
    var store = await getSavedStore();
    var storeCode = store["store_en"]["code"];
    printLog(MagentoHelper.buildUrl(
        domain, "ist/products&searchCriteria[pageSize]=$ApiPageSize", storeCode));
    try {
      var response = await http.get(
          Uri.parse(MagentoHelper.buildUrl(
              domain, "ist/products&searchCriteria[pageSize]=$ApiPageSize", storeCode)),
          headers: {'Authorization': 'Bearer ${accessToken!}'});
      List<Product> list = [];
      if (response.statusCode == 200) {
        printLog(response.body);
        for (var item in convert.jsonDecode(response.body)["items"]) {
          Product product = parseProductFromJson(item);
          list.add(product);
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  reorderFunction(orderId) async {
    String apiUrl = "https://up.ctown.jo/api/reorder.php";

    Map body = {"order_id": orderId, "token": accessToken};

    var response = await http
        .post(Uri.parse(apiUrl), body: jsonEncode(body));
    printLog({
      "order_id": orderId,
    });
    printLog("open");
    printLog(response.body);
    printLog("close");
    var responseBody = jsonDecode(response.body);
    return responseBody;
  }

  Future<List<Product>> getProductsonDeal(
      {int? page,
        int? categoryId,
        orderBy,
        order,
        featured,
        onSale,
        lang,
        filter}) async {
    try {
      String date = DateFormat("yyyy-MM-dd", "en").format(DateTime.now());

      var store1 = await getSavedStore();
      printLog("second store id $store1");
      printLog("Store inside deals page");
      printLog(filter);

      String? id = lang == "en"
          ? store1["store_en"]["id"]
          : store1["store_ar"]["id"] ?? "";
      var storeCode = lang == "en"
          ? store1["store_en"]["code"]
          : store1["store_ar"]["code"];
      printLog(id);
      var endPoint =
          "ist/products?searchCriteria[filter_groups][0][filters][0][field]=store_id&searchCriteria[filter_groups][0][filters][0][value]=$id&searchCriteria[filter_groups][0][filters][0][condition_type]=eq&searchCriteria[filter_groups][1][filters][0][field]=special_to_date&searchCriteria[filter_groups][1][filters][0][value]=$date";
      endPoint +=
      "&searchCriteria[filter_groups][1][filters][0][condition_type]=gteq";
      // &searchCriteria[currentPage]=$page&searchCriteria[page_size]=$ApiPageSize&searchCriteria[filter_groups][0][filters][0][field]=special_to_date&searchCriteria[filter_groups][0][filters][0][value]=$date&searchCriteria[filter_groups][0][filters][0][condition_type]=gteq";

      if (orderBy != null) {
        endPoint +=
        "&searchCriteria[sortOrders][1][field]=${orderBy == "date" ? "created_at" : orderBy}";
      } else {
        endPoint += "&searchCriteria[sortOrders][0][field]=sku";
      }
      if (order != null) {
        endPoint +=
        "&searchCriteria[sortOrders][1][direction]=${(order as String).toUpperCase()}";
      } else {
        endPoint += "&searchCriteria[sortOrders][0][direction]=ASC";
      }

      if (categoryId != null) {
        endPoint +=
        "&searchCriteria[filter_groups][3][filters][0][field]=category_id&searchCriteria[filter_groups][3][filters][0][value]=$categoryId&searchCriteria[filter_groups][3][filters][0][condition_type]=eq";
      }
      endPoint +=
      "&searchCriteria[currentPage]=$page&searchCriteria[page_size]=40&searchCriteria[filter_groups][1][filters][0][field]=visibility&searchCriteria[filter_groups][1][filters][0][value]=4";

      printLog(endPoint);
      printLog("get products on deal url");
      printLog(MagentoHelper.buildUrl(domain, endPoint, storeCode));
      printLog(accessToken);
      var response = await http.get(Uri.parse(MagentoHelper.buildUrl(domain, endPoint, storeCode)),
          headers: {'Authorization': 'Bearer ${accessToken!}'});
      printLog("products on deal response");
      printLog(response.body);
      List<Product> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["items"]) {
          Product product = parseProductFromJson(item);
          list.add(product);
        }
      }
      if(list.isNotEmpty) {
        list.removeWhere((element) => element.qty!  <= 0);
        // list.removeWhere((element) => element.qty! == 0 && !(element.sku?.contains("config"))!);
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Product>> newArrival({config, page, lang}) async {
    try {
      var endPoint =
          "ist/products?searchCriteria[filterGroups][0][filters][0][field]=entity_id&searchCriteria[filterGroups][0][filters][0][condition_type]=in&searchCriteria[filterGroups][0][filters][0][value]=$config&searchCriteria[currentPage]=$page&searchCriteria[pageSize]=40";

      var store1 = await getSavedStore();
      String? storeCode = lang == "en"
          ? store1['store_en']['code']
          : store1['store_ar']['code'] ?? "";
      printLog(endPoint);
      printLog("get products on new arrival url");
      printLog(MagentoHelper.buildUrl(domain, endPoint, storeCode));
      printLog(accessToken);
      var response = await http.get(
          Uri.parse(MagentoHelper.buildUrl(domain, endPoint, storeCode)),
          headers: {'Authorization': 'Bearer ' + accessToken!});
      printLog("get products on new arrival response");
      printLog(response.body);
      List<Product> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["items"]) {
          Product product = parseProductFromJson(item);
          list.add(product);
        }
      }
      if(list.isNotEmpty) {
        list.removeWhere((element) => element.qty!  <= 0);
        // list.removeWhere((element) => element.qty! == 0 && !(element.sku?.contains("config"))!);
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Product>> getProductsonDeal2(
      {int? page,
        int? categoryId,
        orderBy,
        order,
        featured,
        onSale,
        lang,
        filter}) async {
    try {
      String date = DateFormat("yyyy-MM-dd", "en").format(DateTime.now());

      var store1 = await getSavedStore();

      printLog("filter$filter");

      String? id = lang == "en"
          ? store1["store_en"]["id"]
          : store1["store_ar"]["id"] ?? "";
      var storeCode = lang == "en"
          ? store1["store_en"]["code"]
          : store1["store_ar"]["code"];
      printLog(id);
      var endPoint =
          "ist/products?searchCriteria[filter_groups][0][filters][0][field]=store_id&searchCriteria[filter_groups][0][filters][0][value]=$id&searchCriteria[filter_groups][0][filters][0][condition_type]=eq";
      // endPoint +=
      //     "&searchCriteria[filter_groups][1][filters][0][condition_type]=gteq";
      // &searchCriteria[currentPage]=$page&searchCriteria[page_size]=$ApiPageSize&searchCriteria[filter_groups][0][filters][0][field]=special_to_date&searchCriteria[filter_groups][0][filters][0][value]=$date&searchCriteria[filter_groups][0][filters][0][condition_type]=gteq";

      // var endPoint =
      //     "ist/products?searchCriteria[filter_groups][0][filters][0][field]=store_id&searchCriteria[filter_groups][0][filters][0][value]=$id&searchCriteria[filter_groups][0][filters][0][condition_type]=eq&searchCriteria[filter_groups][1][filters][0][field]=special_to_date&searchCriteria[filter_groups][1][filters][0][value]=$date";
      // endPoint +=
      //     "&searchCriteria[filter_groups][1][filters][0][condition_type]=gteq";
      // &searchCriteria[currentPage]=$page&searchCriteria[page_size]=$ApiPageSize&searchCriteria[filter_groups][0][filters][0][field]=special_to_date&searchCriteria[filter_groups][0][filters][0][value]=$date&searchCriteria[filter_groups][0][filters][0][condition_type]=gteq";

      if (orderBy != null) {
        endPoint +=
        "&searchCriteria[sortOrders][1][field]=${orderBy == "date" ? "created_at" : orderBy}";
      } else {
        endPoint += "&searchCriteria[sortOrders][0][field]=name";
      }
      if (order != null) {
        endPoint +=
        "&searchCriteria[sortOrders][1][direction]=${(order as String).toUpperCase()}";
      } else {
        endPoint += "&searchCriteria[sortOrders][0][direction]=ASC";
      }

      if (categoryId != null) {
        endPoint +=
        "&searchCriteria[filter_groups][2][filters][0][field]=category_id&searchCriteria[filter_groups][2][filters][0][value]=$categoryId&searchCriteria[filter_groups][2][filters][0][condition_type]=eq";
      }
      endPoint +=
      "&searchCriteria[currentPage]=$page&searchCriteria[page_size]=$ApiPageSize&searchCriteria[filter_groups][1][filters][0][field]=visibility&searchCriteria[filter_groups][1][filters][0][value]=4";
      if (filter == 'شهري') {
        endPoint += "&type=monthly";
      } else if (filter == 'اسبوعي') {
        endPoint += "&type=weekly";
      } else {
        endPoint += "&type=$filter";
      }

      //

      printLog(MagentoHelper.buildUrl(domain, endPoint, storeCode));
      printLog(accessToken);
      var response = await http.get(Uri.parse(MagentoHelper.buildUrl(domain, endPoint, storeCode)),
          headers: {'Authorization': 'Bearer ${accessToken!}'});

      List<Product> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["items"]) {
          Product product = parseProductFromJson(item);
          list.add(product);
        }
      }
      if(list.isNotEmpty) {
        list.removeWhere((element) => element.qty!  <= 0);
        // list.removeWhere((element) => element.qty! == 0 && !(element.sku?.contains("config"))!);
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Data>> getStatenCities() async {
    try {
      var response = await http.get(Uri.parse("https://up.ctown.jo/api/city.php"),
          headers: {'Authorization': 'Bearer ' + accessToken!});
      List<Data> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["data"]) {
          Data state = Data.fromJson(item);
          list.add(state);
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> fetchProductsLayout({required config, lang}) async {
    String formattedDate =
    DateFormat("yyyy-MM-dd", "en").format(DateTime.now());
    List<Product> list = [];
    try {
      if (config["layout"] == "imageBanner" ||
          config["layout"] == "circleCategory") {
        return list;
      }
      var store1 = await getSavedStore();
      printLog("second store id $store1");
      printLog("Store inside deals page");

      String? id = lang == "en"
          ? store1["store_en"]["id"]
          : store1["store_ar"]["id"] ?? "";
      printLog("check deggalsss");
      printLog(config['name']);
      printLog(S.current.deals);
      String name = lang == 'en' ? 'New Arrival'.toUpperCase() : "قادم جديد";

      var endPoint = "?";
      if (config['name1'] == 'Deals') {
        printLog("check dealsss");
        endPoint +=
        "searchCriteria[filter_groups][0][filters][0][field]=store_id&searchCriteria[filter_groups][0][filters][0][value]=$id&searchCriteria[filter_groups][0][filters][0][condition_type]=eq&searchCriteria[filter_groups][1][filters][0][field]=special_to_date&searchCriteria[filter_groups][1][filters][0][value]=$formattedDate&searchCriteria[filter_groups][1][filters][0][condition_type]=gteq&searchCriteria[sortOrders][0][field]=sku&searchCriteria[sortOrders][0][direction]=ASC&searchCriteria[currentPage]=1&searchCriteria[page_size]=20&searchCriteria[filter_groups][1][filters][0][field]=visibility&searchCriteria[filter_groups][1][filters][0][value]=4";
      } else if (config['name1'] == 'New Arrival') {
        printLog("My Success 1");
        final id = config['category'][0]["product_id"];
        endPoint +=
        "searchCriteria[filterGroups][0][filters][0][field]=entity_id&searchCriteria[filterGroups][0][filters][0][condition_type]=in&searchCriteria[filterGroups][0][filters][0][value]=$id&searchCriteria[currentPage]=1&searchCriteria[pageSize]=20";
      } else if (config != null) {
        printLog("My Success 2");
        if (config['name1'] == 'mobcategory') {
          printLog("My Success 3");
          endPoint +=
          "searchCriteria[filter_groups][0][filters][0][field]=category_id&searchCriteria[filter_groups][0][filters][0][value]=${config["category"]}&searchCriteria[filter_groups][0][filters][0][condition_type]=eq&searchCriteria[currentPage]=1&searchCriteria[pageSize]=20";
        }
        /*if (config.containsKey("category") && Platform.isIOS == false) {
          endPoint +=
              "searchCriteria[filter_groups][0][filters][0][field]=category_id&searchCriteria[filter_groups][0][filters][0][value]=${config["category"]}&searchCriteria[filter_groups][0][filters][0][condition_type]=eq&searchCriteria[pageSize]=$ApiPageSize";
        }*/
        endPoint +=
        "&searchCriteria[filter_groups][1][filters][0][field]=visibility&searchCriteria[filter_groups][1][filters][0][value]=4";
      }
      // printLog("Product layout url");
      // printLog(MagentoHelper.buildUrl(domain, "ist/products$endPoint", lang));
      String? storecode = lang == "en"
          ? store1['store_en']['code']
          : store1['store_ar']['code'] ?? "";
      String url = config['name1'] == 'New Arrival'
          ? MagentoHelper.buildUrl(
          domain, "ist/products$endPoint", storecode)
          : MagentoHelper.buildUrl(
          domain, "ist/products$endPoint", storecode);
      var response = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer ' + accessToken!});
      printLog("Fetch products layout");
      printLog("plus print lang $lang");
      printLog(accessToken);
      printLog(MagentoHelper.buildUrl(
          domain, "ist/products$endPoint", storecode));
      if (response.statusCode == 200) {
        // printLog(response.body);
        for (var item in convert.jsonDecode(response.body)["items"]) {
          Product product = parseProductFromJson(item);
          list.add(product);
        }
      }
      if(list.isNotEmpty) {
        list.removeWhere((element) => element.qty! == 0 && !(element.sku?.contains("config"))!);
      }
      return list;
    } catch (e) {
      printLog(e.toString());
      return list;
    }
  }

  optiopnid(String optionid) async {
    try {
      if (optionid != null) {
        return optionid;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> fetchProductsByCategory({
    categoryId,
    tagId,
    page,
    minPrice,
    maxPrice,
    lang,
    orderBy,
    order,
    featured,
    onSale,
    attribute,
    sort,
    attributeTerm,
  }) async {
    List<Product> list = [];
    try {
      printLog(page);
      printLog("sort$sort");
      var sortid = sort == null ? "position" : sort;
      var endPoint = "?";
      if (categoryId != null) {
        endPoint +=
        "searchCriteria[filter_groups][0][filters][0][field]=category_id&searchCriteria[filter_groups][0][filters][0][value]=$categoryId&searchCriteria[filter_groups][0][filters][0][condition_type]=eq";
      }
      if (maxPrice != null) {
        endPoint +=
        "&searchCriteria[filter_groups][0][filters][1][field]=price&searchCriteria[filter_groups][0][filters][1][value]=$maxPrice&searchCriteria[filter_groups][0][filters][1][condition_type]=lteq";
      }
      if (page != null) {
        endPoint += "&searchCriteria[currentPage]=$page";
      }
      if (orderBy != null) {
        endPoint +=
        "&searchCriteria[sortOrders][1][field]=${orderBy == "date" ? "created_at" : orderBy}";
      } else {
        endPoint += "&searchCriteria[sortOrders][0][field]=name";
      }
      if (order != null) {
        endPoint +=
        "&searchCriteria[sortOrders][1][direction]=${(order as String).toUpperCase()}";
      } else {
        endPoint += "&searchCriteria[sortOrders][0][direction]=ASC";
      }
      endPoint += "&searchCriteria[pageSize]=50";

      endPoint +=
      "&searchCriteria[filter_groups][1][filters][0][field]=visibility&searchCriteria[filter_groups][1][filters][0][value]=4";
      if (sortid == 'barcode') {
        endPoint += "&sort=sku";
      } else if (sortid == 'الرمز الشريطي') {
        endPoint += "&sort=sku";
      } else if (sortid == 'موقع') {
        endPoint += "&sort=position";
      } else if (sortid == 'position') {
        endPoint += "&sort=position";
      } else if (sortid == 'السعر') {
        endPoint += "&sort=price";
      } else if (sortid == 'price') {
        endPoint += "&sort=price";
      } else if (sortid == 'اسم') {
        endPoint += "&sort=name";
      } else if (sortid == 'name') {
        endPoint += "&sort=name";
      } else {
        "&sort=$sortid";
      }
      printLog("===================================////////========");
      // printLog(MagentoHelper.buildUrl(
      //     domain, "ist/products$endPoint", lang, storeDetails));
      var store1 = await getSavedStore();
      String? storecode = lang == "en"
          ? store1['store_en']['code']
          : store1['store_ar']['code'] ?? "";
      printLog("Fetch By Category Test");
      printLog(MagentoHelper.buildUrl(
          domain, "ist/products$endPoint", storecode));
      var response = await http.get(
          Uri.parse(MagentoHelper.buildUrl(
              domain, "ist/products$endPoint", storecode)),
          // MagentoHelper.buildfetchProductsByCategoryUrl(
          //     domain, storecode, "ist/products$endPoint", lang),
          headers: {'Authorization': 'Bearer ' + accessToken!});
      if (response.statusCode == 200) {
        printLog(response.body);
        for (var item in convert.jsonDecode(response.body)["items"]) {
          Product product = parseProductFromJson(item);
          list.add(product);
        }
      }
      // if(list.length > 0) {
      //   if(list.any((element) => (element.sku?.contains("config"))!)) {}
      //   else {
      //     List<Product> itemsWithNonZeroQty = list.where((item) => (item.qty ?? 0) != 0).toList();
      //     List<Product> itemsWithZeroQty = list.where((item) => (item.qty ?? 0) == 0).toList();
      //     List<Product> result = itemsWithNonZeroQty + itemsWithZeroQty;
      //     list.clear();
      //     list.addAll(result);
      //   }
      // }
      if(list.isNotEmpty) {
        list.removeWhere((element) => element.qty!  <= 0);
        // list.removeWhere((element) => element.qty! == 0 && !(element.sku?.contains("config"))!);
      }
      return list;
    } catch (e) {
      printLog(e.toString());
      return list;
    }
  }

  @override
  Future<User> loginFacebook({String? token, String? lang}) async {
    try {
      var store = await getSavedStore();
      var storeCode =
      lang == "en" ? store["store_en"]["code"] : store["store_ar"]["code"];
      var response = await http.post(
          Uri.parse(MagentoHelper.buildUrl(domain, "ist/social_login", storeCode)),
          body: convert.jsonEncode({"token": token, "type": "facebook"}),
          headers: {"content-type": "application/json"});

      if (response.statusCode == 200) {
        final token = convert.jsonDecode(response.body);
        User user = (await getUserInfo(token))!;
        user.isSocial = true;
        return user;
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(body["message"] != null
            ? MagentoHelper.getErrorMessage(body)
            : "Can not get token");
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<User> loginSMS({String? token, String? lang}) async {
    try {
      var store = await getSavedStore();
      var storeCode =
      lang == "en" ? store["store_en"]["code"] : store["store_ar"]["code"];
      var response = await http.post(
        Uri.parse(MagentoHelper.buildUrl(domain, "ist/social_login", storeCode)),
        body: convert.jsonEncode({"token": token, "type": "firebase_sms"}),
        headers: {"content-type": "application/json"},
      );

      if (response.statusCode == 200) {
        final token = convert.jsonDecode(response.body);
        User user = (await getUserInfo(token))!;
        user.isSocial = true;
        return user;
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(body["message"] != null
            ? MagentoHelper.getErrorMessage(body)
            : "Can not get token");
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<Review>> getReviews(productId) async {
    //return Future.delayed(const Duration(seconds: 1), () => List());
    try {
      final res = await http.post(
        Uri.parse('https://up.ctown.jo/api/review.php'),
        headers: {
          'Authorization': 'Bearer ' + accessToken!,
          "content-type": "application/json"
        },
        body: convert.jsonEncode({"product_id": productId}),
      );
      if (res.statusCode == 200) {
        List<Review> reviews = [];
        var body = convert.jsonDecode(res.body);
        for (var review in body) {
          reviews.add(Review.fromMagentoJson(review));
        }
        return reviews;
      } else {
        return [];
      }
    } catch (err) {
      rethrow;
    }
  }

  // added as part of submit review changes
  @override
  Future createReview({String? productId, Map<String, dynamic>? data}) async {
    try {
      printLog("review api");
      printLog(data);
      final res = await http.post(
        Uri.parse('https://up.ctown.jo/api/addreview.php'),
        headers: {
          'Authorization': 'Bearer ' + accessToken!,
          "content-type": "application/json"
        },
        body: convert.jsonEncode(data),
      );
      printLog("response review ${res.body}");
      if (res.statusCode == 200) {
        var responseBody = convert.jsonDecode(res.body);
        return responseBody;
      }
      if (res.statusCode != 200) {
        throw Exception(res.reasonPhrase);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not
      //return the correct JSON format, please double check the document
      rethrow;
    }
  }

  @override
  Future<List<ProductVariation>> getProductVariations(
      Product product, String? lang) async {
    try {
      var store1 = await getSavedStore();
      var storeCode = lang == "en"
          ? store1["store_en"]["code"]
          : store1["store_ar"]["code"];
      printLog("getProductVariations++" "https://up.ctown.jo/index.php/rest/$storeCode/V1/configurable-products/${product.sku}/children");
      final res = await http.get(
        // MagentoHelper.buildUrl(
        //     domain, "configurable-products/${product.sku}/children"),
          Uri.parse("https://up.ctown.jo/index.php/rest/$storeCode/V1/configurable-products/${product.sku}/children"),
          headers: {
            'Authorization': 'Bearer ' + accessToken!,
            "content-type": "application/json"
          });
      printLog("url getted");
      List<ProductVariation> list = [];
      if (res.statusCode == 200) {
        //////
        ///
        var items = convert.jsonDecode(res.body);

        String id = "";
        for (int i = 0; i < items.length; i++) {
          id += items[i]["id"].toString();
          if (i < items.length - 1) {
            id += ",";
          }
        }
        // try {
        var responseItems = await getStockStatusForAllItemsAtOnce(id);
        // } catch (e) {
        //   printLog("err $e");
        // }

        for (var item in convert.jsonDecode(res.body)) {
          ProductVariation prod =
          ProductVariation.fromMagentoJson(item, product);

          var respectiveId =
          responseItems.indexWhere((e) => e["product_id"] == prod.id);
          // printLog(respectiveId);
          printLog(responseItems[respectiveId]["is_in_stock"]);
          // printLog("}}}}}}}}}}");
          prod.inStock = responseItems[respectiveId]["is_in_stock"] == "true"
              ? true
              : false;
          ;

          prod.stockQuantity = int.tryParse(responseItems[respectiveId]["qty"]);

          if(prod.attributes.length > 1) {
            prod.attributes.removeWhere((element) => element.name != "product_weight");
          }
          list.add(prod);
        }

        // ProductVariation prod = ProductVariation.fromMagentoJson(item, product);
        // printLog("inside loop");
        // prod.inStock = await getStockStatus(prod.sku);
        // prod.stockQuantity = 97887;

        printLog("ids $id");
        // ///

        // for (var item in convert.jsonDecode(res.body)) {
        //   ProductVariation prod =
        //       ProductVariation.fromMagentoJson(item, product);
        //   printLog("inside loop");
        //   prod.inStock = await getStockStatus(prod.sku);
        //   prod.stockQuantity = 97887;
        //   list.add(prod);
        // }
      }
      printLog("url setted");
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future getStockStatusForAllItemsAtOnce(ids) async {
    try {
      printLog(ids);
      printLog("=========");
      printLog(jsonEncode({"product_id": ids}));
      var response = await http.post(Uri.parse("https://up.ctown.jo/api/stockitem.php"),
          body: jsonEncode({"product_id": ids}));
      if (response.statusCode == 200) {
        printLog("resp ${response.body}");
        return jsonDecode(response.body)["data"];
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods({
    CartModel? cartModel,
    String? token,
    String? checkoutId,
    ClickNCollectProvider? clickNCollectProvider,
    String? lang
  }) async {
    try {
      var store1 = await getSavedStore();
      String? storecode = lang == "en"
          ? store1['store_en']['code']
          : store1['store_ar']['code'] ?? "";
      List<ShippingMethod> list = [];
      Address? address = cartModel!.address;
      String url = token != null
          ? MagentoHelper.buildUrl(domain,
          "carts/mine/estimate-shipping-methods?type=${clickNCollectProvider!.deliveryType}&address_id=${address?.id}&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}", storecode)
          : MagentoHelper.buildUrl(
          domain, "guest-carts/$guestQuoteId/estimate-shipping-methods", storecode);
      printLog("shiiping methos url $url");
      printLog(convert.jsonEncode({
        "address": {"country_id": address?.country}
      }));

      final res = await http.post(Uri.parse(url),
          body: convert.jsonEncode({
            "address": {"country_id": address?.country}
          }),
          headers: token != null
              ? {
            'Authorization': 'Bearer ' + token,
            "content-type": "application/json"
          }
              : {"content-type": "application/json"});
      if (res.statusCode == 200) {
        printLog(convert.jsonDecode(res.body));
        if (res.body.isNotEmpty) {
          for (var item in convert.jsonDecode(res.body)) {
            if (item["carrier_code"] == "freeshipping") {
              list.add(ShippingMethod.fromMagentoJson(item));
              return list;
            }
          }
          for (var item in convert.jsonDecode(res.body)) {
            list.add(ShippingMethod.fromMagentoJson(item));
          }
        } else {
          final body = convert.jsonDecode(res.body);
          throw Exception(body["message"] != null
              ? MagentoHelper.getErrorMessage(body)
              : "Can not get shipping methods");
        }
      }
      return list;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {CartModel? cartModel,
        ShippingMethod? shippingMethod,
        String? token, required String lang}) async {
    try {
      var store1 = await getSavedStore();
      var storeCode = lang == "en"
          ? store1["store_en"]["code"]
          : store1["store_ar"]["code"];
      Address? address = cartModel!.address;
      Address ad;
      final params = {
        "addressInformation": {
          "shipping_address": address?.toMagentoJson()["address"],
          "billing_address": address?.toMagentoJson()["address"],
          "shipping_carrier_code": shippingMethod!.id,
          "shipping_method_code": shippingMethod.methodId
        }
      };
      printLog("params$params");
      printLog(address?.id);

      printLog(address?.toMagentoJson()["address"]["id"]);
      printLog("running");
      printLog(convert.jsonEncode(params));
      String url = token != null
          ? MagentoHelper.buildUrl(domain,
          "carts/mine/shipping-information?address_id=${address?.id}&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}", storeCode)
          : MagentoHelper.buildUrl(
          domain, "guest-carts/$guestQuoteId/shipping-information", storeCode);
      printLog(url);
      final res = await http.post(Uri.parse(url),
          body: convert.jsonEncode(params),
          headers: token != null
              ? {
            'Authorization': 'Bearer ' + token,
            "content-type": "application/json"
          }
              : {"content-type": "application/json"});
      final body = convert.jsonDecode(res.body);
      printLog('resi$body');
      if (res.statusCode == 200) {
        List<PaymentMethod> list = [];
        for (var item in body["payment_methods"]) {
          list.add(PaymentMethod.fromMagentoJson(item));
        }
        return list;
      } else if (body["message"] != null) {
        throw Exception(MagentoHelper.getErrorMessage(body));
      } else {
        throw Exception("Can not get payment methods");
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<Order>> getMyOrders({UserModel? userModel, int? page, String? lang}) async {
    try {
      var store1 = await getSavedStore();
      String? storeCode = lang == "en"
          ? store1['store_en']['code']
          : store1['store_ar']['code'] ?? "";
      var endPoint = "?";
      endPoint +=
      "searchCriteria[filter_groups][0][filters][0][field]=customer_email&searchCriteria[filter_groups][0][filters][0][value]=${userModel!.user!.email}&searchCriteria[filter_groups][0][filters][0][condition_type]=eq&searchCriteria[sortOrders][1][field]=created_at&searchCriteria[sortOrders][1][direction]=DESC";
      endPoint += "&searchCriteria[currentPage]=$page";
      endPoint += "&searchCriteria[pageSize]=$ApiPageSize";
      printLog(
          "order history url####################################################################################################################################################################################################################################################################################################################3");

      printLog(MagentoHelper.buildUrl(domain, "orders$endPoint", storeCode));
      printLog(accessToken);
      var response = await http.get(
          Uri.parse(MagentoHelper.buildUrl(domain, "orders$endPoint", storeCode)),
          // "https://up.ctown.jo/index.php/rest/V1/orders?searchCriteria[filter_groups][0][filters][0][field]=customer_email&searchCriteria[filter_groups][0][filters][0][value]=samuel@apntbs.com&searchCriteria[filter_groups][0][filters][0][condition_type]=eq&searchCriteria[sortOrders][1][field]=created_at&searchCriteria[sortOrders][1][direction]=DESC&searchCriteria[currentPage]=0&searchCriteria[pageSize]=20",
          headers: {'Authorization': 'Bearer ' + accessToken!});
      List<Order> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["items"]) {
          list.add(Order.fromMagentoJson(item));
        }
      }

      return list;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Order> createOrder({
    CartModel? cartModel,
    UserModel? user,
    bool? paid,
    ClickNCollectProvider? clickNCollectProvider,
    String? lang,
  }) async {
    Address? address = cartModel!.address;
    printLog("create order delivery type");
    printLog(clickNCollectProvider!.deliveryType);
    try {
      var store = await getSavedStore();
      String storeId = lang == "en"
          ? store["store_en"]["id"]
          : store["store_ar"]["id"] ?? "";
      var storeCode =
      lang == "en" ? store["store_en"]["code"] : store["store_ar"]["code"];
      bool isGuest = user!.user == null || user.user?.cookie == null;
      String url = !isGuest
          ? MagentoHelper.buildUrl(
          domain,
          "carts/mine/payment-information?address_id=${address?.id}&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}",
          storeCode)
          : MagentoHelper.buildUrl(
          domain,
          "guest-carts/$guestQuoteId/payment-information?nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}",
          storeCode);
      printLog(url);
      var params = Order().toMagentoJson(cartModel, null, paid);
      printLog("total $params");
      if (isGuest) {
        params["email"] = cartModel.address?.email;
        params["firstname"] = cartModel.address?.firstName;
        params["lastname"] = cartModel.address?.lastName;
      }
      printLog("payment infor");
      printLog(convert.jsonEncode(params));
      final res = await http.post(Uri.parse(url),
          body: convert.jsonEncode(params),
          headers: !isGuest
              ? {
            'Authorization': 'Bearer ' + user.user!.cookie!,
            "content-type": "application/json"
          }
              : {"content-type": "application/json"});
      printLog("payment infor ${res.body}");
      printLog(user.user!.cookie);
      final body = convert.jsonDecode(res.body);
      printLog("running");
      printLog(res.statusCode);
      if (res.statusCode == 200) {
        printLog("running");
        // send delivery date selected data to server
        String? slot_id = '0';
        List<Map<String, String?>> items = [];
        printLog("1st part");
        cartModel.productsInCart.keys.forEach((key) {
          String productId = Product.cleanProductID(key);
          Product product = cartModel.getProductById(productId);

          if (product.options != null) {
            printLog(product.note);
            printLog(product.id);
            product.options!.forEach((element) {
              if (element.containsKey('slot_id')) {
                slot_id = element['slot_id'];
              }
            });
          }
          items.add({
            'product_id': product.id,
            'delivery_date': product.delivery_date!.trim(),
            'delivery_from': product.delivery_from,
            'product_note': product.note,
            'sku': product.sku,
          });
        });

        printLog("2nd part");
        params = Map();
        params["order_id"] = body.toString();
        params["slot_id"] = slot_id;
        params["item"] = items;
        params["general_notes"] = cartModel.notes;
        params["delivery_type"] = clickNCollectProvider.deliveryType;
        params["store_id"] = clickNCollectProvider.storeId;
        printLog("order.php body");
        printLog(convert.jsonEncode(params));
        final response = await http.post(Uri.parse('https://up.ctown.jo/api/order.php'),
            body: convert.jsonEncode(
              params,
            ),
            headers: !isGuest
                ? {
              'Authorization': 'Bearer ' + user.user!.cookie!,
              "content-type": "application/json"
            }
                : {"content-type": "application/json"});
        printLog(response.body);
        if (response.statusCode != 200) {
          var body = convert.jsonDecode(response.body);
          if (body["message"] != null) {
            throw Exception(MagentoHelper.getErrorMessage(body));
          } else {
            throw Exception("Can not create order");
          }
        }
        var order = Order();
        order.id = body.toString();
        order.number = body.toString();
        order.increment_id = response.body;
        return order;
      } else {
        if (body["message"] != null) {
          printLog(body["message"]);
          throw Exception(MagentoHelper.getErrorMessage(body));
        } else {
          throw Exception("Can not create order");
        }
      }
    } catch (e) {
      rethrow;
    }
  }

/*
  @override
  Future<Order> createOrder(
      {CartModel cartModel, UserModel user, bool paid}) async {
    try {
      bool isGuest = user.user == null || user.user.cookie == null;
      String url = !isGuest
          ? MagentoHelper.buildUrl(domain, "carts/mine/payment-information")
          : MagentoHelper.buildUrl(
              domain, "guest-carts/$guestQuoteId/payment-information");
              printLog(url);
      var params = Order().toMagentoJson(cartModel, null, paid);
      if (isGuest) {
        params["email"] = cartModel.address.email;
        params["firstname"] = cartModel.address.firstName;
        params["lastname"] = cartModel.address.lastName;
      }
printLog(params);
      final res = await http.post(url,
          body: convert.jsonEncode(params),
          headers: !isGuest
              ? {
                  'Authorization': 'Bearer ' + user.user.cookie,
                  "content-type": "application/json"
                }
              : {"content-type": "application/json"});
              printLog("res ${res.body}");
      final body = convert.jsonDecode(res.body);
      if (res.statusCode == 200) {
        // send delivery date selected data to server
        var slot_id = '0';
        List<Map<String, String>> items = List();

        cartModel.productsInCart.keys.forEach((key) {
          String productId = Product.cleanProductID(key);
          Product product = cartModel.getProductById(productId);
          if (product.options != null) {
            product.options.forEach((element) {
              if (element.containsKey('slot_id')) {
                slot_id = element['slot_id'];
              }
            });
          }
          items.add({
            'product_id': product.id,
            'delivery_date': product.delivery_date.trim(),
            'delivery_from': product.delivery_from
          });
        });

        params = Map();
        params["order_id"] = body.toString();
        params["slot_id"] = slot_id;
        params["item"] = items;
        params["general_notes"] = cartModel.notes;
        printLog("2nd part");
        printLog(params);
        final response =
            await http.post('https://up.ctown.jo/api/order.php',
                body: convert.jsonEncode(params),
                headers: !isGuest
                    ? {
                        'Authorization': 'Bearer ' + user.user.cookie,
                        "content-type": "application/json"
                      }
                    : {"content-type": "application/json"});
                    printLog(response.body);
        if (response.statusCode != 200) {
          var body = convert.jsonDecode(response.body);
          if (body["message"] != null) {
            throw Exception(MagentoHelper.getErrorMessage(body));
          } else {
            throw Exception("Can not create order");
          }
        }
        var order = Order();
        order.id = body.toString();
        order.number = body.toString();
        order.increment_id = response.body;
        return order;
      } else {
        if (body["message"] != null) {
          throw Exception(MagentoHelper.getErrorMessage(body));
        } else {
          throw Exception("Can not create order");
        }
      }
    } catch (e) {
      rethrow;Fsearc
    }
  }*/

  @override
  Future updateOrder(orderId, lang, {status, token}) async {
    try {
      var store1 = await getSavedStore();
      String? storecode = lang == "en"
          ? store1['store_en']['code']
          : store1['store_ar']['code'] ?? "";
      printLog(
        MagentoHelper.buildUrl(domain, "ist/me/orders/$orderId/cancel", storecode),
      );
      var response = await http.post(
        Uri.parse(MagentoHelper.buildUrl(domain, "ist/me/orders/$orderId/cancel", storecode)),
        body: convert.jsonEncode({}),
        headers: {
          'Authorization': 'Bearer ' + token,
          "content-type": "application/json"
        },
      );
      final body = convert.jsonDecode(response.body);
      if (body is Map && body["message"] != null) {
        throw Exception(MagentoHelper.getErrorMessage(body));
      } else {
        return;
      }
    } catch (err) {
      rethrow;
    }
  }

  // @override
  // Future<List<Product>> searchProducts(
  //     {name,
  //     categoryId,
  //     tag,
  //     attribute,
  //     attributeId,
  //     page,
  //     lang,
  //     isBarcode}) async {
  //   try {
  //     var endPoint = "?";
  //     if (lang == 'ar') {
  //       endPoint +=
  //           "searchCriteria[filter_groups][0][filters][0][field]=store_id&searchCriteria[filter_groups][0][filters][0][value]=56&searchCriteria[filter_groups][0][filters][0][condition_type]=eq";
  //       if (name != null) {
  //         endPoint +=
  //             "&searchCriteria[filter_groups][1][filters][0][field]=name&searchCriteria[filter_groups][1][filters][0][value]=%25$name%&searchCriteria[filter_groups][1][filters][0][condition_type]=like";
  //       }
  //     } else {
  //       if (name != null) {
  //         if (isBarcode) {
  //           endPoint +=
  //               "searchCriteria[filter_groups][0][filters][1][field]=item_barcode&searchCriteria[filter_groups][0][filters][1][value]=$name&searchCriteria[filter_groups][0][filters][1][condition_type]=eq";
  //         } else {
  //           endPoint +=
  //               "searchCriteria[filter_groups][0][filters][0][field]=name&searchCriteria[filter_groups][0][filters][0][value]=%25$name%&searchCriteria[filter_groups][0][filters][0][condition_type]=like";
  //         }
  //       }
  //       endPoint +=
  //           "&searchCriteria[filter_groups][2][filters][0][field]=store_id&searchCriteria[filter_groups][2][filters][0][value]=56&searchCriteria[filter_groups][2][filters][0][condition_type]=eq";
  //     }
  //     if (page != null) {
  //       endPoint += "&searchCriteria[currentPage]=$page";
  //     }
  //     if (categoryId != null) {
  //       if (lang == 'ar') {
  //         endPoint +=
  //             "&searchCriteria[filter_groups][3][filters][0][field]=category_id&searchCriteria[filter_groups][3][filters][0][value]=$categoryId&searchCriteria[filter_groups][3][filters][0][condition_type]=eq";
  //       } else {
  //         endPoint +=
  //             "&searchCriteria[filter_groups][1][filters][0][field]=category_id&searchCriteria[filter_groups][1][filters][0][value]=$categoryId&searchCriteria[filter_groups][1][filters][0][condition_type]=eq";
  //       }
  //     }

  //     endPoint += "&searchCriteria[pageSize]=$ApiPageSize";
  //     endPoint +=
  //         "&searchCriteria[filter_groups][2][filters][0][field]=visibility&searchCriteria[filter_groups][2][filters][0][value]=4";

  //     var response = await http.get(
  //         MagentoHelper.buildUrl(domain, "ist/products$endPoint"),
  //         headers: {'Authorization': 'Bearer ' + accessToken});
  //     List<Product> list = [];
  //     if (response.statusCode == 200) {
  //       final body = convert.jsonDecode(response.body);
  //       if (!MagentoHelper.isEndLoadMore(body)) {
  //         for (var item in body["items"]) {
  //           Product product = parseProductFromJson(item);
  //           list.add(product);
  //         }
  //       }
  //     }
  //     return list;
  //   } catch (err, trace) {
  //     printLog(trace);
  //     rethrow;
  //   }
  // }

  Future<List<Product>> getWishlistProducts(String name, String lang) async {
    List<Product> wishList = [];
    try {
      var endPoint = "?";
      var store1 = await getSavedStore();
      String? storecode = lang == "en"
          ? store1['store_en']['code']
          : store1['store_ar']['code'] ?? "";
      if(lang == "ar") {
        endPoint +=
        'searchCriteria[filter_groups][0][filters][0][field]=store_id&searchCriteria[filter_groups][0][filters][0][value]=${store1['store_ar']['id']}&'
            'searchCriteria[filterGroups][0][filters][0][field]=sku&'
            'searchCriteria[filterGroups][0][filters][0][condition_type]=in&'
            'searchCriteria[filterGroups][0][filters][0][value]=$name';
      }
      else {
        endPoint +=
        "searchCriteria[filter_groups][2][filters][0][field]=store_id&searchCriteria[filter_groups][2][filters][0][value]=${store1['store_en']['id']}&"
            'searchCriteria[filterGroups][0][filters][0][field]=sku&'
            'searchCriteria[filterGroups][0][filters][0][condition_type]=in&'
            'searchCriteria[filterGroups][0][filters][0][value]=$name';
      }
      // endPoint += "&searchCriteria[currentPage]=1&searchCriteria[pageSize]=20";
      // endPoint +=
      // "&searchCriteria[filter_groups][2][filters][0][field]=visibility&searchCriteria[filter_groups][2][filters][0][value]=4";
      printLog("ist/products$endPoint");
      var response = await http.get(
          Uri.parse(MagentoHelper.buildUrl(domain, "ist/products$endPoint", storecode)),
          headers: {'Authorization': 'Bearer ' + accessToken!});
      List<Product> list = [];
      if (response.statusCode == 200) {
        printLog("Search query generated");
        printLog(
          MagentoHelper.buildUrl(domain, "ist/products$endPoint", storecode),
        );
        printLog(accessToken);
        final body = convert.jsonDecode(response.body);
        printLog(body);
        printLog("response body");
        if(body["items"].isNotEmpty) {
          for (var item in body["items"]) {
            Product product = parseProductFromJson(item);
            list.add(product);
          }
        }
      }
      wishList = list;
    }
    catch(e) {
      printLog(e.toString());
    }
    return wishList;
  }

  Future<List<Product>> getShoppingListProducts(String name, String lang) async {
    List<Product> shoppingList = [];
    try {
      var endPoint = "?";
      var store1 = await getSavedStore();
      String? storecode = lang == "en"
          ? store1['store_en']['code']
          : store1['store_ar']['code'] ?? "";
      List<String> names = name.split(",");
      if(lang == "ar") {
        endPoint +=
        'searchCriteria[filter_groups][0][filters][0][field]=store_id&searchCriteria[filter_groups][0][filters][0][value]=${store1['store_ar']['id']}';
        for (int i = 0; i < names.length; i++) {
          endPoint +=
          '&searchCriteria[filter_groups][$i][filters][0][field]=name&'
              'searchCriteria[filter_groups][$i][filters][0][value]=%25${names[i]}%25&'
              'searchCriteria[filter_groups][$i][filters][0][condition_type]=like';
        }
      }
      else {
        endPoint +=
        "searchCriteria[filter_groups][2][filters][0][field]=store_id&searchCriteria[filter_groups][2][filters][0][value]=${store1['store_en']['id']}";
        for (int i = 0; i < names.length; i++) {
          endPoint +=
          '&searchCriteria[filter_groups][$i][filters][0][field]=name&'
              'searchCriteria[filter_groups][$i][filters][0][value]=%25${names[i]}%25&'
              'searchCriteria[filter_groups][$i][filters][0][condition_type]=like';
        }
      }
      // endPoint += "&searchCriteria[currentPage]=1&searchCriteria[pageSize]=20";
      // endPoint +=
      // "&searchCriteria[filter_groups][2][filters][0][field]=visibility&searchCriteria[filter_groups][2][filters][0][value]=4";
      printLog("ist/products$endPoint");
      var response = await http.get(
          Uri.parse(MagentoHelper.buildUrl(domain, "ist/products$endPoint", storecode)),
          headers: {'Authorization': 'Bearer ' + accessToken!});
      List<Product> list = [];
      if (response.statusCode == 200) {
        printLog("Search query generated");
        printLog(
          MagentoHelper.buildUrl(domain, "ist/products$endPoint", storecode),
        );
        printLog(accessToken);
        final body = convert.jsonDecode(response.body);
        printLog(body);
        printLog("response body");
        // printLog(body["items"]);
        if(body["items"].isNotEmpty) {
          for (var item in body["items"]) {
            Product product = parseProductFromJson(item);
            list.add(product);
          }
        }
      }
      shoppingList = list;
    }
    catch(e) {
      printLog(e.toString());
    }
    return shoppingList;
  }


  @override
  Future<List<Product>> searchProducts(
      {name,
        categoryId,
        tag,
        attribute,
        attributeId,
        page,
        lang,
        isBarcode}) async {
    var store1 = await getSavedStore();
    String storecode = lang == "en"
        ? store1['store_en']['code']
        : store1['store_ar']['code'] ?? "";
    try {
      var endPoint = "?";
      if (lang == 'ar') {
        endPoint +=
        "&searchCriteria[filter_groups][0][filters][0][field]=store_id&searchCriteria[filter_groups][0][filters][0][value]=${store1['store_ar']['id']}&searchCriteria[filter_groups][0][filters][0][condition_type]=eq&";
        // "&searchCriteria[filter_groups][0][filters][0][field]=store_id&searchCriteria[filter_groups][0][filters][0][value]=${store1['store_ar']['id']}&searchCriteria[filter_groups][0][filters][0][condition_type]=eq";
        if (name != null) {
          String newSearchString = "";
          List? newName = name.split(",");
          if (isBarcode) {
            for (int i = 0; i < newName!.length; i++) {
              newSearchString +=
              "&searchCriteria[filter_groups][1][filters][$i][field]=sku&searchCriteria[filter_groups][1][filters][$i][value]=%25${newName[i]}%&searchCriteria[filter_groups][1][filters][$i][condition_type]=like&&searchCriteria[filter_groups][0][filters][1][field]=sku&searchCriteria[filter_groups][0][filters][1][value]=${newName[i]}&searchCriteria[sortOrders][0][field]=category_id&searchCriteria[sortOrders][0][direction]=ASC";
              // "searchCriteria[filter_groups][0][filters][$i][field]=name&searchCriteria[filter_groups][0][filters][$i][value]=%25${newName[i]}%&searchCriteria[filter_groups][0][filters][$i][condition_type]=like";
              if (i != newName.length - 1) {
                newSearchString += "&";
              }
            }
          } else {
            for (int i = 0; i < newName!.length; i++) {
              newSearchString +=
              "searchCriteria[filter_groups][1][filters][0][field]=name&searchCriteria[filter_groups][1][filters][0][value]=%25${newName[i]}%&searchCriteria[filter_groups][1][filters][0][condition_type]=like&searchCriteria[filter_groups][1][filters][1][field]=sku&searchCriteria[filter_groups][1][filters][1][value]=${newName[i]}&searchCriteria[filter_groups][1][filters][1][condition_type]=eq&searchCriteria[sortOrders][0][field]=category_id&searchCriteria[sortOrders][0][direction]=ASC";
              // "&searchCriteria[filter_groups][1][filters][$i][field]=name&searchCriteria[filter_groups][1][filters][$i][value]=%25${newName[i]}%&searchCriteria[filter_groups][1][filters][$i][condition_type]=like&searchCriteria[sortOrders][0][field]=category_id&searchCriteria[sortOrders][0][direction]=ASC";
              // "searchCriteria[filter_groups][0][filters][$i][field]=name&searchCriteria[filter_groups][0][filters][$i][value]=%25${newName[i]}%&searchCriteria[filter_groups][0][filters][$i][condition_type]=like";
              if (i != newName.length - 1) {
                newSearchString += "&";
              }
            }
          }
          printLog("new string " + newSearchString);
          endPoint += newSearchString;
// old query
          // endPoint +=
          //     "&searchCriteria[filter_groups][1][filters][0][field]=name&searchCriteria[filter_groups][1][filters][0][value]=$name%&searchCriteria[filter_groups][1][filters][0][condition_type]=like";
        }
      } else {
        endPoint +=
        "&searchCriteria[filter_groups][2][filters][0][field]=store_id&searchCriteria[filter_groups][2][filters][0][value]=${store1['store_en']['id']}&searchCriteria[filter_groups][2][filters][0][condition_type]=eq&";
        // "&searchCriteria[filter_groups][2][filters][0][field]=store_id&searchCriteria[filter_groups][2][filters][0][value]=${store1['store_en']['id']}&searchCriteria[filter_groups][2][filters][0][condition_type]=eq&";

        if (name != null) {
          if (isBarcode) {
            endPoint +=
                "searchCriteria[filter_groups][0][filters][1][field]=item_barcode&searchCriteria[filter_groups][0][filters][1][value]=${name.toString()}" +
                    "&searchCriteria[filter_groups][0][filters][1][condition_type]=eq&searchCriteria[sortOrders][0][direction]=ASC";
          } else {
            String newSearchString = "";
            List newName = name.split(",");

            for (int i = 0; i < newName.length; i++) {
              newSearchString +=
              "searchCriteria[filter_groups][0][filters][$i][field]=name&searchCriteria[filter_groups][0][filters][$i][value]=%25${newName[i]}%&searchCriteria[filter_groups][0][filters][$i][condition_type]=like&searchCriteria[filter_groups][0][filters][1][field]=sku&searchCriteria[filter_groups][0][filters][1][value]=${newName[i]}&searchCriteria[filter_groups][0][filters][1][condition_type]=eq&searchCriteria[sortOrders][0][field]=category_id&searchCriteria[sortOrders][0][direction]=ASC";
              if (i != newName.length - 1) {
                newSearchString += "&";
              }
            }
            printLog("new string " + newSearchString);
            endPoint += newSearchString;
          }
        }
      }
      if (page != null) {
        endPoint += "&searchCriteria[currentPage]=$page";
      }
      if (categoryId != null) {
        if (lang == 'ar') {
          endPoint +=
          "&searchCriteria[filter_groups][3][filters][0][field]=category_id&searchCriteria[filter_groups][3][filters][0][value]=$categoryId&searchCriteria[filter_groups][3][filters][0][condition_type]=eq";
        } else {
          endPoint +=
          "&searchCriteria[filter_groups][1][filters][0][field]=category_id&searchCriteria[filter_groups][1][filters][0][value]=$categoryId&searchCriteria[filter_groups][1][filters][0][condition_type]=eq";
        }
      }

      endPoint += "&searchCriteria[pageSize]=40";
      endPoint +=
      "&searchCriteria[filter_groups][2][filters][0][field]=visibility&searchCriteria[filter_groups][2][filters][0][value]=4";
      printLog("ist/products$endPoint");
      var response = await http.get(
          Uri.parse(MagentoHelper.buildUrl(domain, "ist/products$endPoint", storecode)),
          headers: {'Authorization': 'Bearer ' + accessToken!});
      List<Product> list = [];
      if (response.statusCode == 200) {
        printLog("Search query generated");
        printLog(
          MagentoHelper.buildUrl(domain, "ist/products$endPoint", storecode),
        );
        printLog(accessToken);
        final body = convert.jsonDecode(response.body);
        printLog(body);
        printLog("response body");
        // printLog(body["items"]);
        if (!MagentoHelper.isEndLoadMore(body)) {
          for (var item in body["items"]) {
            Product product = parseProductFromJson(item);
            // printLog(product.name + "   " + product.categoryId);
            list.add(product);
          }
        }
      }
      return list;
    } catch (err, trace) {
      printLog(trace);
      rethrow;
    }
  }

  Future<List<Product>> brand(config, page, lang) async {
    try {
      var store1 = await getSavedStore();
      String? id = lang == "en"
          ? store1["store_en"]["id"]
          : store1["store_ar"]["id"] ?? "";
      String storecode = lang == "en"
          ? store1['store_en']['code']
          : store1['store_ar']['code'] ?? "";
      String endPoint =
          "ist/products?searchCriteria[filter_groups][0][filters][0][field]=store_id&searchCriteria[filter_groups][0][filters][0][value]=$id&searchCriteria[filter_groups][0][filters][0][condition_type]=eq&searchCriteria[filter_groups][1][filters][0][field]=category_id&searchCriteria[filter_groups][1][filters][0][value]=$config&searchCriteria[filter_groups][1][filters][0][condition_type]=eq&searchCriteria[currentPage]=$page&searchCriteria[sortOrders][0][field]=name&searchCriteria[sortOrders][0][direction]=ASC&searchCriteria[pageSize]=$ApiPageSize&searchCriteria[filter_groups][2][filters][0][field]=visibility&searchCriteria[filter_groups][2][filters][0][value]=4";
      // "ist/products?searchCriteria[filter_groups][0][filters][0][field]=category_id&searchCriteria[filter_groups][0][filters][0][value]=$config&searchCriteria[filter_groups][0][filters][0][condition_type]=eq&searchCriteria[currentPage]=$page&searchCriteria[sortOrders][0][field]=name&searchCriteria[sortOrders][0][direction]=ASC&searchCriteria[pageSize]=$ApiPageSize&searchCriteria[filter_groups][1][filters][0][field]=visibility&searchCriteria[filter_groups][1][filters][0][value]=4";
      printLog(
        MagentoHelper.buildUrl(domain, endPoint, storecode),
      );

      var response = await http.get(Uri.parse(MagentoHelper.buildUrl(domain, endPoint, storecode)),
          headers: {'Authorization': 'Bearer ${accessToken!}'});
      List<Product> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["items"]) {
          printLog(item);
          Product product = parseProductFromJson(item);

          list.add(product);
          printLog(product);
        }
      }
      printLog(list);
      if(list.isNotEmpty) {
        list.removeWhere((element) => element.qty!  <= 0);
        // list.removeWhere((element) => element.qty! == 0 && !(element.sku?.contains("config"))!);
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Product>> blog(config, page, String lang) async {
    try {
      var store = await getSavedStore();
      var storeCode =
      lang == "en" ? store["store_en"]["code"] : store["store_ar"]["code"];
      String endPoint =
          "ist/products?searchCriteria[filterGroups][0][filters][0][field]=entity_id&searchCriteria[filterGroups][0][filters][0][condition_type]=in&searchCriteria[filterGroups][0][filters][0][value]=$config&searchCriteria[currentPage]=$page&searchCriteria[pageSize]=$ApiPageSize";
      printLog(
        MagentoHelper.buildUrl(domain, endPoint, storeCode),
      );

      var response = await http.get(Uri.parse(MagentoHelper.buildUrl(domain, endPoint, storeCode)),
          headers: {'Authorization': 'Bearer ${accessToken!}'});
      List<Product> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["items"]) {
          printLog(item);
          Product product = parseProductFromJson(item);

          list.add(product);
          printLog(product);
        }
      }
      printLog(list);
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Product>> brandfilter(config, page, optionid, String? lang) async {
    try {
      var store = await getSavedStore();
      var storeCode = lang == "en"
          ? store["store_en"]["code"] ?? ""
          : store["store_ar"]["code"] ?? "";
      String endPoint =
          "ist/products?searchCriteria[filter_groups][0][filters][0][field]=category_id&searchCriteria[filter_groups][0][filters][0][value]=$config&searchCriteria[filter_groups][0][filters][0][condition_type]=eq&searchCriteria[filter_groups][0][filters][1][field]=price&searchCriteria[filter_groups][0][filters][1][value]=500.0&searchCriteria[filter_groups][0][filters][1][condition_type]=lteq&searchCriteria[filter_groups][2][filters][0][field]=brand&searchCriteria[filter_groups][2][filters][0][value]=$optionid&searchCriteria[filter_groups][2][filters][0][condition_type]=eq&searchCriteria[currentPage]=$page&searchCriteria[sortOrders][0][field]=name&searchCriteria[sortOrders][0][direction]=ASC&searchCriteria[pageSize]=20&searchCriteria[filter_groups][1][filters][0][field]=visibility&searchCriteria[filter_groups][1][filters][0][value]=4";
      printLog("fghghsdsadsdg");
      printLog(MagentoHelper.buildUrl(domain, endPoint, storeCode));
      printLog(accessToken);

      var response = await http.get(Uri.parse(MagentoHelper.buildUrl(domain, endPoint, storeCode)),
          headers: {'Authorization': 'Bearer ' + accessToken!});
      List<Product> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["items"]) {
          printLog(item);
          Product product = parseProductFromJson(item);

          list.add(product);
          printLog(product);
        }
      }
      printLog(list);
      if(list.isNotEmpty) {
        list.removeWhere((element) => element.qty!  <= 0);
        // list.removeWhere((element) => element.qty! == 0 && !(element.sku?.contains("config"))!);
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }
  // List<Product> list = [];
  // if (response.statusCode == 200) {
  //   printLog("brand api running");
  //   printLog(
  //     MagentoHelper.buildUrl(domain, "ist/products$endPoint"),
  //   );

  //   printLog(accessToken);
  //   final body = convert.jsonDecode(response.body);
  //   printLog(body);
  //   printLog("response body");
  //   // printLog(body["items"]);

  //     for (var item in body["items"]) {
  //       Product product = parseProductFromJson(item);
  //       // printLog(product.name + "   " + product.categoryId);
  //       list.add(product);

  //   }
  // }

  /*     // Comparator<Product> nameComparator = (b, a) => b.name.compareTo(a.name);

      // list.sort(nameComparator);

      List namesList = name.split(",");
      List newList = list;
      List generalList;
      // for (int i = 0; i < namesList.length; i++) {
      List l = list.where((element) => element.name.contains("Tiger")).toList();
      // printLog(namesList[i]);
      printLog("lengtg");
      printLog(l.length);
      l.forEach((element) {
        printLog(element);
      });

      // }
      // printLog("new list");
      // printLog(newList.length);
      int i = 0;
      newList.sort((a, b) {
        // Sort results by matching name with keyword position in name

        if (a.name.toLowerCase().indexOf(namesList[i].toLowerCase()) >
            b.name.toLowerCase().indexOf(namesList[i].toLowerCase())) {
          return 1;
        } else if (a.name.toLowerCase().indexOf(namesList[i].toLowerCase()) <
            b.name.toLowerCase().indexOf(namesList[i].toLowerCase())) {
          return -1;
        } else {
          // if (a.name.compareTo(b.name) != null) {
          if (a.name.length < b.name.length) {
            return 1;
          } else {
            return -1;
          }
        }
      });
      // generalList.addAll(newList);
      // }
*/
  /*  List<Product> newList = list;
      newList.sort((a, b) {
        // Sort results by matching name with keyword position in name
        if (a.name.toLowerCase().indexOf(name.toLowerCase()) >
            b.name.toLowerCase().indexOf(name.toLowerCase())) {
          return 1;
        } else if (a.name.toLowerCase().indexOf(name.toLowerCase()) <
            b.name.toLowerCase().indexOf(name.toLowerCase())) {
          return -1;
        } else {
          if (a.name.length > b.name.length) {
            return 1;
          } else {
            return -1;
          }
        }
      });
*/
  /**
      List<Product> newList = list;
      newList.sort((a, b) {
      // Sort results by matching name with keyword position in name
      if (a.name.toLowerCase().indexOf(name.toLowerCase()) >
      b.name.toLowerCase().indexOf(name.toLowerCase())) {
      return 1;
      } else if (a.name.toLowerCase().indexOf(name.toLowerCase()) <
      b.name.toLowerCase().indexOf(name.toLowerCase())) {
      return -1;
      } else {
      if (a.name.compareTo(b.name) != null) {
      return 1;
      } else {
      return -1;
      }
      }
      });
   */
  // printLog("comparator");

  // newList.forEach((element) {
  //   printLog(element.categoryId);
  // });
  // for (int i = 0; i < list.length; i++) {
  //   if (list[i].name.startsWith(name)) {
  //     printLog(name);
  //   } else {
  //     printLog(list[i].name);
  //     printLog(false);
  //   }
  // }

  //     return list;
  //     // return newList;
  //   } catch (err, trace) {
  //     printLog(trace);
  //     rethrow;
  //   }
  // }

  /*
  @override
  Future<List<Product>> searchProducts(
      {name,
      categoryId,
      tag,
      attribute,
      attributeId,
      page,
      lang,
      isBarcode}) async {
    try {
      var endPoint = "?";
      if (lang == 'ar') {
        endPoint +=
            "searchCriteria[filter_groups][0][filters][0][field]=store_id&searchCriteria[filter_groups][0][filters][0][value]=11&searchCriteria[filter_groups][0][filters][0][condition_type]=eq";
        if (name != null) {
          String newSearchString = "";
          List newName = name.split(",");

          for (int i = 0; i < newName.length; i++) {
            newSearchString +=
                "searchCriteria[filter_groups][0][filters][$i][field]=name&searchCriteria[filter_groups][0][filters][$i][value]=${newName[i]}%&searchCriteria[filter_groups][0][filters][$i][condition_type]=like";
            if (i != newName.length - 1) {
              newSearchString += "&";
            }
          }
          printLog("new string " + newSearchString);
          endPoint += newSearchString;
// old query
          // endPoint +=
          //     "&searchCriteria[filter_groups][1][filters][0][field]=name&searchCriteria[filter_groups][1][filters][0][value]=$name%&searchCriteria[filter_groups][1][filters][0][condition_type]=like";
        }
      } else {
        if (name != null) {
          if (isBarcode) {
            endPoint +=
                "searchCriteria[filter_groups][0][filters][1][field]=item_barcode&searchCriteria[filter_groups][0][filters][1][value]=$name&searchCriteria[filter_groups][0][filters][1][condition_type]=eq";
          } else {
            String newSearchString = "";
            List newName = name.split(",");

            for (int i = 0; i < newName.length; i++) {
              newSearchString +=
                  "searchCriteria[filter_groups][0][filters][$i][field]=name&searchCriteria[filter_groups][0][filters][$i][value]=${newName[i]}%&searchCriteria[filter_groups][0][filters][$i][condition_type]=like";
              if (i != newName.length - 1) {
                newSearchString += "&";
              }
            }
            printLog("new string " + newSearchString);
            endPoint += newSearchString;
            // old query
            // endPoint +=
            //     "searchCriteria[filter_groups][0][filters][0][field]=name&searchCriteria[filter_groups][0][filters][0][value]=$name%&searchCriteria[filter_groups][0][filters][0][condition_type]=like";
          }
        }
        endPoint +=
            "&searchCriteria[filter_groups][2][filters][0][field]=store_id&searchCriteria[filter_groups][2][filters][0][value]=1&searchCriteria[filter_groups][2][filters][0][condition_type]=eq";
      }
      if (page != null) {
        endPoint += "&searchCriteria[currentPage]=$page";
      }
      if (categoryId != null) {
        if (lang == 'ar') {
          endPoint +=
              "&searchCriteria[filter_groups][3][filters][0][field]=category_id&searchCriteria[filter_groups][3][filters][0][value]=$categoryId&searchCriteria[filter_groups][3][filters][0][condition_type]=eq";
        } else {
          endPoint +=
              "&searchCriteria[filter_groups][1][filters][0][field]=category_id&searchCriteria[filter_groups][1][filters][0][value]=$categoryId&searchCriteria[filter_groups][1][filters][0][condition_type]=eq";
        }
      }

      endPoint += "&searchCriteria[pageSize]=$ApiPageSize";
      endPoint +=
          "&searchCriteria[filter_groups][2][filters][0][field]=visibility&searchCriteria[filter_groups][2][filters][0][value]=4";

      var response = await http.get(
          MagentoHelper.buildUrl(domain, "ist/products$endPoint"),
          headers: {'Authorization': 'Bearer ' + accessToken});
      List<Product> list = [];
      if (response.statusCode == 200) {
        printLog("Search query generated");
        printLog(
          MagentoHelper.buildUrl(domain, "ist/products$endPoint"),
        );

        final body = convert.jsonDecode(response.body);

        // printLog(body["items"]);
        if (!MagentoHelper.isEndLoadMore(body)) {
          for (var item in body["items"]) {
            Product product = parseProductFromJson(item);
            list.add(product);
          }
        }
      }
      return list;
    } catch (err, trace) {
      printLog(trace);
      rethrow;
    }
  }
  */

  @override
  Future<User?> createUser({
    String? firstName,
    String? lastName,
    String? countryCode,
    String? username,
    String? password,
    String? phoneNumber,
    String? otp = "",
    String? loyalty_card_number,
    bool isVendor = false,
  }) async {
    printLog("JSONENCODE");
    printLog((MagentoHelper.buildUrl(domain, "customers", "")));
    try {
      var response =
      await http.post(Uri.parse(MagentoHelper.buildUrl(domain, "customers", "")),
          body: convert.jsonEncode({
            "customer": {
              "email": username,
              "firstname": firstName,
              "lastname": lastName,
              "store_id": 57,
              // "store_id": store['store_en']['id'],
              "extension_attributes": {"is_subscribed": false},
              "custom_attributes": [
                {"attribute_code": "phone_number", "value": phoneNumber},
                {
                  "attribute_code": "loyalty_card_number",
                  "value": loyalty_card_number
                }
              ]
            },
            "password": password,
            "otp": otp,
            "phone_number": countryCode! + phoneNumber!,
            // "country_code": countryCode,
            "loyalty_card_number": loyalty_card_number,
          }),
          headers: {"content-type": "application/json"});
      if (response.statusCode == 200) {
        printLog("body ${response.body}");

        return await login(username: username, password: password);
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(body["message"] != null
            ? MagentoHelper.getErrorMessage(body)
            : "Can not get token");
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<User?> getUserInfo(cookie) async {
    var res = await http.get(Uri.parse(MagentoHelper.buildUrl(domain, "customers/me", "")),
        headers: {'Authorization': 'Bearer ' + cookie});
    User? user;
    printLog(
      MagentoHelper.buildUrl(domain, "customers/me", ""),
    );
    printLog("user info cookie");
    printLog(cookie);
    if (res.statusCode == 200) {
      user = User.fromMagentoJson(convert.jsonDecode(res.body), cookie);
      printLog(user.id);
    }
    return user;
  }

//   Future  dynamiclink() async {
//      printLog("api dynamic");
//      printLog(accessToken);
//      printLog("https://up.ctown.jo/rest/V1/ist/products?searchCriteria[filterGroups][0][filters][0][field]=entity_id&searchCriteria[filterGroups][0][filters][0][value]=10302&searchCriteria[filterGroups][0][filters][0][condition_type]=eq");
//     //  printLog(MagentoHelper.buildUrl(domain,
//     //         "searchCriteria[filterGroups][0][filters][0][field]=entity_id&searchCriteria[filterGroups][0][filters][0][value]=10302&searchCriteria[filterGroups][0][filters][0][condition_type]=eq"));
//     var res = await http.get(Uri.parse(
//       "https://up.ctown.jo/rest/V1/ist/products?searchCriteria[filterGroups][0][filters][0][field]=entity_id&searchCriteria[filterGroups][0][filters][0][value]=10302&searchCriteria[filterGroups][0][filters][0][condition_type]=eq"),
//         // MagentoHelper.buildUrl(domain,
//         //     "searchCriteria[filterGroups][0][filters][0][field]=entity_id&searchCriteria[filterGroups][0][filters][0][value]=10302&searchCriteria[filterGroups][0][filters][0][condition_type]=eq"),
//         headers: {
//           'Authorization': 'Bearer ' + accessToken,
//           "content-type": "application/json"
//         });

//         var response;
//     if (res.statusCode == 200) {

//        response = convert.jsonDecode(res.body)["items"];

//  printLog("dynamic link");
//        printLog(response);
//        printLog("===========");
//        Product product = parseProductFromJson(response[0]);
//       //
//        printLog(product);
//       //  printLog(product);
//         printLog("===========");
//       // return response;
// return product;

//     }

//   }

  @override
  Future<User?> login({username, password, lang}) async {
    try {
      String id = lang == "ar" ? '76' : '75';

      printLog(MagentoHelper.buildUrl(
          domain, "integration/customer/token?store_id=$id", ""));
      printLog(convert.jsonEncode({"username": username, "password": password}));

      var response = await http.post(
          Uri.parse(MagentoHelper.buildUrl(
              domain, "integration/customer/token?store_id=$id", "")),
          body:
          convert.jsonEncode({"username": username, "password": password}),
          headers: {"content-type": "application/json"});
      if (response.statusCode == 200) {
        final token = convert.jsonDecode(response.body);

        printLog(token);
        User? user = await getUserInfo(token);
        return user;
      } else {
        final body = convert.jsonDecode(response.body);
        throw (body["message"] != null
            ? MagentoHelper.getErrorMessage(body)
            : "Can not get token")!;
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<User> loginApple({String? email, String? fullName, String? lang}) async {
    try {
      var store = await getSavedStore();
      var storeCode =
      lang == "en" ? store["store_en"]["code"] : store["store_ar"]["code"];
      final lastName =
      (fullName?.split(" ").length)! > 1 ? fullName?.split(" ")[1] : "store";
      var response = await http.post(
        Uri.parse(MagentoHelper.buildUrl(domain, "ist/appleLogin", storeCode)),
        body: convert.jsonEncode({
          "email": email,
          "firstName": fullName?.split(" ")[0],
          "lastName": lastName
        }),
        headers: {"content-type": "application/json"},
      );

      if (response.statusCode == 200) {
        final token = convert.jsonDecode(response.body);
        User user = (await getUserInfo(token))!;
        user.isSocial = true;
        return user;
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(body["message"] != null
            ? MagentoHelper.getErrorMessage(body)
            : "Can not get token");
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Product> getProduct(id, {lang}) async {
    try {
      var store = await getSavedStore();
      var storeCode =
      lang == "en" ? store["store_en"]["code"] : store["store_ar"]["code"];
      printLog("Get product ${MagentoHelper.buildUrl(domain, "products/$id", storeCode)}");
      Product product = Product.empty(id);
      return product;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> clearCart({required String token, required String lang}) async {
    var store1 = await getSavedStore();
    var storeCode =
    lang == "en" ? store1["store_en"]["code"] : store1["store_ar"]["code"];
    var res = await http.get(Uri.parse(MagentoHelper.buildUrl(domain, "carts/mine", storeCode)),
        headers: {'Authorization': 'Bearer ' + token});
    final cartInfo = convert.jsonDecode(res.body);
    printLog("cart info status");
    printLog(res.statusCode);
    printLog(res.body);
    if (res.statusCode == 401) {
      throw Exception("Token expired. Please logout then login again");
    } else if (res.statusCode == 404) {
      throw Exception(MagentoHelper.getErrorMessage(cartInfo));
    } else if (res.statusCode == 200) {
      String url = "https://up.ctown.jo/api/clearcart.php";
      Map body = {"quote_id": cartInfo["id"]};
      printLog("clear cart body $body");
      var response = await http.post(Uri.parse(url), body: convert.jsonEncode(body));
      if (response.statusCode == 200) {
        return true;
      }
    }
    return false;
  }

  Future<String> getQuoteId({token, String? lang}) async {
    String quoteId = "";
    try {
      var store1 = await getSavedStore();
      var storeCode = lang == "en"
          ? store1["store_en"]["code"]
          : store1["store_ar"]["code"];
      printLog(MagentoHelper.buildUrl(domain, "carts/mine", storeCode));
      var res = await http.get(Uri.parse(MagentoHelper.buildUrl(domain, "carts/mine", storeCode)),
          headers: {'Authorization': 'Bearer ' + token});
      final cartInfo = convert.jsonDecode(res.body);
      printLog(
          "6666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666");
      printLog(cartInfo);
      //  quoteId = cartInfo["id"];
      printLog("nah$quoteId");
      if (res.statusCode == 200) {
        quoteId = cartInfo["id"].toString();
        printLog("nah$quoteId");
      }
      if (res.statusCode == 401) {
        throw Exception("Token expired. Please logout then login again");
      } else if (res.statusCode == 404) {
        throw Exception(MagentoHelper.getErrorMessage(cartInfo));
      }
    } catch (e) {}
    return quoteId;
  }

  Future<bool> deleteItemFromCart(List<String?> keys, String? token, String? lang) async {
    if (token != null) {
      try {
        var store1 = await getSavedStore();
        var storeCode = lang == "en"
            ? store1["store_en"]["code"]
            : store1["store_ar"]["code"];
        //get cart info
        var res = await http.get(Uri.parse(MagentoHelper.buildUrl(domain, "carts/mine", storeCode)),
            headers: {'Authorization': 'Bearer ' + token});
        final cartInfo = convert.jsonDecode(res.body);
        if (res.statusCode == 401) {
          throw Exception("Token expired. Please logout then login again");
        } else if (res.statusCode == 404) {
          throw Exception(MagentoHelper.getErrorMessage(cartInfo));
        }
        var params = [];
        keys.forEach((key) async {
          String productId = Product.cleanProductID(key);
          params.add({
            "quote_id": cartInfo['id'],
            "product_id": productId,
            "token": token,
          });
        });
        printLog("delete from cart");
        printLog(params);
        res = await http.post(
          Uri.parse("https://up.ctown.jo/api/deleteitem.php"),
          headers: {'Authorization': 'Bearer $token'},
          body: convert.jsonEncode(params),
        );
        printLog(res.body);
        return true;
      } catch (e) {
        rethrow;
      }
    }
    return true;
  }

  // Future addToCartConfigurable(
  //     CartModel cartModel, String id, String token, quoteId, sku, qty,
  //     {isDelete = false, guestCartId, List configurations}) async {
  //   try {
  //     Map<String, dynamic> params = Map<String, dynamic>();
  //     // params["qty"] = cartModel.productsInCart[id];
  //     params["qty"] = qty;
  //     params["quote_id"] = quoteId;
  //     // params["sku"] = cartModel.productSkuInCart[id];
  //     params["sku"] = sku;
  //     printLog(guestCartId == null
  //         ? MagentoHelper.buildUrl(domain, "carts/mine/items")
  //         : MagentoHelper.buildUrl(domain, "guest-carts/$quoteId/items"));
  //     List hard = [
  //       {"option_id": "93", "option_value": 15},
  //       {"option_id": "170", "option_value": 7}
  //     ];
  //     printLog(convert.jsonEncode({
  //       "cartItem": params,
  //       "product_option": {
  //         "extension_attributes": {"configurable_item_options": configurations}
  //       },
  //       "extension_attributes": {}
  //     }));
  //     printLog(cartModel.productsInCart);
  //     final res = await http.post(
  //         guestCartId == null
  //             ? MagentoHelper.buildUrl(domain, "carts/mine/items")
  //             : MagentoHelper.buildUrl(domain, "guest-carts/$quoteId/items"),
  //         body: convert.jsonEncode({
  //           "cartItem": params,
  //         }),
  //         headers: token != null
  //             ? {
  //                 'Authorization': 'Bearer ' + token,
  //                 "content-type": "application/json"
  //               }
  //             : {"content-type": "application/json"});
  //     final body = convert.jsonDecode(res.body);
  //     printLog("ADDTOCARTBODY $body");
  //     if (body["messages"] != null &&
  //         body["messages"]["error"] != null &&
  //         body["messages"]["error"][0].length > 0) {
  //       throw Exception(
  //           MagentoHelper.getErrorMessage(body["messages"]["error"][0]));
  //     } else if (body["message"] != null) {
  //       throw Exception(MagentoHelper.getErrorMessage(body));
  //     } else {
  //       // printLog(body);
  //       //return;
  //     }
  //     //});
  //     return true;
  //   } catch (err) {
  //     rethrow;
  //   }
  // }


  Future<bool> addConfigProduct(
      CartModel cartModel, String? id, String token, sku, qty, String? lang,
      {isDelete = false, guestCartId, List? configurations}) async {
    bool addedToCart = false;
    Map<String, dynamic> params = <String, dynamic>{};
    String quoteId = "";
    var store1 = await getSavedStore();
    var storeCode = lang == "en"
        ? store1["store_en"]["code"]
        : store1["store_ar"]["code"];
    try {
      if(token != "") {
        if(cartModel.cartId != null) {
          quoteId = "${cartModel.cartId}";
        }
        else {
          String url = token != null
              ? MagentoHelper.buildUrl(domain, "carts/mine", storeCode)
              : MagentoHelper.buildUrl(domain, "guest-carts", storeCode);
          var cartResponse = await http.post(Uri.parse(url),
              headers: token != null ? {'Authorization': 'Bearer ' + token} : {});
          if(cartResponse.statusCode == 200) {
            quoteId = convert.jsonDecode(cartResponse.body).toString();
            cartModel.cartId = int.parse(quoteId);
          }
          else {
            addedToCart = false;
          }
        }

        if(quoteId != "") {
          params["qty"] = qty;
          params["quote_id"] = quoteId;
          params["sku"] = sku;
          params["product_option"] = {
            "extension_attributes": {"configurable_item_options": configurations},
          };
          printLog(guestCartId == null
              ? MagentoHelper.buildUrl(domain,
              "carts/mine/items?nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}", storeCode)
              : MagentoHelper.buildUrl(domain,
              "guest-carts/$quoteId/items?nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}", storeCode));
          printLog(convert.jsonEncode({
            "cartItem": params,
          }));
          printLog("/////////////////////////////Start");
          printLog(DateTime.now());
          final resp = await http.post(
              Uri.parse(guestCartId == null
                  ? MagentoHelper.buildUrl(domain,
                  "carts/mine/items?nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}", storeCode)
                  : MagentoHelper.buildUrl(domain,
                  "guest-carts/$quoteId/items?nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}", storeCode)),
              body: convert.jsonEncode({
                "cartItem": params,
              }),
              headers:
              token != null
                  ? {
                'Authorization': 'Bearer ' + token,
                "content-type": "application/json"
              }
                  : {"content-type": "application/json"});
          final body = convert.jsonDecode(resp.body);
          if(resp.statusCode == 200) {
            printLog(DateTime.now());
            printLog("/////////////////////////////End");
            addedToCart = true;
          }
          else {
            addedToCart = false;
            if (body["messages"] != null &&
                body["messages"]["error"] != null &&
                body["messages"]["error"][0].length > 0) {
              throw Exception(
                  MagentoHelper.getErrorMessage(body["messages"]["error"][0]));
            } else if (body["message"] != null) {
              throw Exception(MagentoHelper.getErrorMessage(body));
            }
          }
        }
      }
    }
    catch(e) {
      printLog(e.toString());
      return false;
    }
    return addedToCart;
  }

  Future<bool> addToCart(CartModel cartModel, String? id, String? token, quoteId,
      sku, qty, String? lang,
      {isDelete = false, guestCartId}) async {
    try {
      var store1 = await getSavedStore();
      var storeCode = lang == "en"
          ? store1["store_en"]["code"]
          : store1["store_ar"]["code"];
      //delete items in cart
      if (isDelete) {
        var params = [];
        //await Future.forEach(cartModel.productsInCart.keys, (key) async {
        String productId = Product.cleanProductID(id);

        // await http.delete(MagentoHelper.buildUrl(domain, "carts/mine/items/$productId"),
        //     headers: {'Authorization': 'Bearer $token'});
        params.add({
          "quote_id": quoteId,
          "product_id": productId,
          "token": token,
        });
        //});

        printLog("addt o cart delete");
        printLog(params);
        await http.post(
          Uri.parse("https://up.ctown.jo/api/deleteitem.php"),
          headers: {'Authorization': 'Bearer $token'},
          body: convert.jsonEncode(params),
        );
        // await http.delete(MagentoHelper.buildUrl(domain, "carts/mine/coupons"),
        //     headers: {'Authorization': 'Bearer $token'});
      }
      //add items to cart
      //await Future.forEach(cartModel.productsInCart.keys, (key) async {
      Map<String, dynamic> params = <String, dynamic>{};
      // params["qty"] = cartModel.productsInCart[id];
      params["qty"] = qty;
      params["quote_id"] = quoteId;
      // params["sku"] = cartModel.productSkuInCart[id];
      params["sku"] = sku;
      printLog(guestCartId == null
          ? MagentoHelper.buildUrl(
          domain,
          "carts/mine/items?nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}",
          storeCode)
          : MagentoHelper.buildUrl(
          domain,
          "guest-carts/$quoteId/items?nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}",
          storeCode));
      printLog(convert.jsonEncode({
        "cartItem": params,
      }));
      printLog(cartModel.productsInCart);
      final res = await http.post(
          guestCartId == null
              ? Uri.parse(MagentoHelper.buildUrl(
              domain,
              "carts/mine/items?nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}",
              storeCode))
              : Uri.parse(MagentoHelper.buildUrl(
              domain,
              "guest-carts/$quoteId/items?nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}",
              storeCode)),
          body: convert.jsonEncode({
            "cartItem": params,
          }),
          headers: token != null
              ? {
            'Authorization': 'Bearer ' + token,
            "content-type": "application/json"
          }
              : {"content-type": "application/json"});
      printLog("vxfgnsfgdf");
      final body = convert.jsonDecode(res.body);
      if (body["messages"] != null &&
          body["messages"]["error"] != null &&
          body["messages"]["error"][0].length > 0) {
        throw Exception(
            MagentoHelper.getErrorMessage(body["messages"]["error"][0]));
      } else if (body["message"] != null) {
        throw Exception(MagentoHelper.getErrorMessage(body));
      } else {
        // printLog(body);
        //return;
      }
      //});
      return true;
    } catch (err) {
      printLog('err');
      rethrow;
    }
  }



  Future<bool?> addItemsToCart(
      String? lang,
      CartModel cartModel,
      String? id,
      String? token,
      String? sku,
      int? qty,) async {
    try {
      final store = await getSavedStore();
      final storeCode = lang == "en"
          ? store["store_en"]["code"]
          : store["store_ar"]["code"];

      if (token == null) {
        throw Exception("Token expired. Please logout then login again");
      }

      final cartUrl = MagentoHelper.buildUrl(domain, "carts/mine", storeCode);
      printLog("add to cart quote");
      printLog(token);
      printLog(cartUrl);

      if(cartModel.cartId != null && cartModel.productsInCart.isNotEmpty) {
        if(cartModel.productsInCart.containsKey(id)) {
          return await addToCart(
            cartModel,
            id,
            token,
            cartModel.cartId,
            sku,
            qty,
            lang,
            isDelete: true,
          );
        }
        else {
          return await addToCart(
            cartModel,
            id,
            token,
            cartModel.cartId,
            sku,
            qty,
            lang,
          );
        }
      }
      else {
        printLog("quote id generate");
        final quoteUrl = token != null
            ? "https://up.ctown.jo/index.php/rest/$storeCode/V1/carts/mine"
            : MagentoHelper.buildUrl(domain, "guest-carts", storeCode);
        printLog(quoteUrl);
        final quoteResponse = await http.post(
          Uri.parse(quoteUrl),
          headers: token != null ? {'Authorization': 'Bearer $token'} : {},
        );

        if (quoteResponse.statusCode == 200) {
          final quoteId = convert.jsonDecode(quoteResponse.body);

          if (token != null) {
            cartModel.cartId = int.parse("$quoteId");
            return await addToCart(
              cartModel,
              id,
              token,
              quoteId,
              sku,
              qty,
              lang!
            );
          } else {
            final guestCartResponse = await http.get(
              Uri.parse(MagentoHelper.buildUrl(domain, "guest-carts/$quoteId", storeCode)),
            );

            if (guestCartResponse.statusCode == 200) {
              final guestCartInfo = convert.jsonDecode(guestCartResponse.body);
              final cartId = guestCartInfo["id"];
              guestQuoteId = quoteId;

              return await addToCart(
                cartModel,
                id,
                token,
                quoteId,
                sku,
                qty,
                lang,
                guestCartId: cartId,
              );
            } else {
              final error = convert.jsonDecode(guestCartResponse.body);
              throw Exception(MagentoHelper.getErrorMessage(error));
            }
          }
        } else {
          final error = convert.jsonDecode(quoteResponse.body);
          throw Exception(MagentoHelper.getErrorMessage(error));
        }
      }
    } catch (err, stackTrace) {
      printLog(stackTrace);
      rethrow;
    }
  }


  Future<String> getConfigImage(String lang, String sku) async {
    String imageFeature = "";
    try {
      var store1 = await getSavedStore();
      if(store1 != null) {
        String? storecode = lang == "en"
            ? store1['store_en']['code']
            : store1['store_ar']['code'] ?? "";
        printLog("Fetch By Category Test");
        String apiUrl = "https://ctown.jo/index.php/$storecode/rokanthemes_searchsuiteautocomplete/ajax/index/?q=$sku";
        var response = await http.get(Uri.parse(apiUrl));
        printLog(response.body);
        if(response.statusCode == 200) {
          var responseBody = jsonDecode(response.body);
          imageFeature = responseBody["result"][0]["data"][0]["image"];
        }
        else {
          imageFeature = "https://up.ctown.jo/pub/media/catalog/product/placeholder/default/CTOWN-LOGO_1_2.png";
        }
      }
    }
    catch(e) {
      printLog(e.toString());
    }
    return imageFeature;
  }


  Future<List<Product>> getListOfProductsForCartSync(String ids, String lang) async {
    String apiUrl =
        "?searchCriteria[filterGroups][0][filters][0][field]=sku&searchCriteria[filterGroups][0][filters][0][condition_type]=in&searchCriteria[filterGroups][0][filters][0][value]=$ids";
    List<Product> products = [];
    try {
      var store1 = await getSavedStore();
      if(store1 != null) {
        String? storecode = lang == "en"
            ? store1['store_en']['code']
            : store1['store_ar']['code'] ?? "";
        printLog("Fetch By Category Test");
        var response = await http
            .get(Uri.parse(MagentoHelper.buildUrl(
            domain, "ist/products$apiUrl", storecode)), headers: {'Authorization': 'Bearer ${accessToken!}'});
        printLog("Get product$apiUrl");
        printLog(accessToken);
        printLog("getLostOfProductsResponse");
        printLog(response.body);
        if (response.statusCode == 200) {
          var responseBody = jsonDecode(response.body);
          responseBody["items"].forEach((e) {
            Product product = parseProductFromJson(e);

            products.add(product);
          });

          //  = Product.empty(id);
          // product.id==
          // if (response.statusCode == 200) {
          //   var a = parseProductFromJson(convert.jsonDecode(response.body));
          // }
        }
      }

      return products;
    } catch (e) {
      rethrow;
    }
  }

  Future<double> applyCoupon(String? token, String? coupon, String? lang) async {
    try {
      var store = await getSavedStore();
      var storeCode =
      lang == "en" ? store["store_en"]["code"] : store["store_ar"]["code"];
      String url = token != null
          ? MagentoHelper.buildUrl(domain, "carts/mine/coupons/$coupon", storeCode)
          : MagentoHelper.buildUrl(
          domain, "guest-carts/$guestQuoteId/coupons/$coupon", storeCode);
      printLog("fdgsfhgfgjadsgfdfghj");
      printLog(url);
      printLog(token ?? "");
      var res = await http.put(Uri.parse(url),
          headers: token != null ? {'Authorization': 'Bearer $token'} : {});
      var body = convert.jsonDecode(res.body);
      if (res.statusCode == 200) {
        String totalUrl = token != null
            ? MagentoHelper.buildUrl(domain, "carts/mine/totals", storeCode)
            : MagentoHelper.buildUrl(
            domain, "guest-carts/$guestQuoteId/totals", storeCode);
        var res = await http.get(Uri.parse(totalUrl),
            headers: token != null ? {'Authorization': 'Bearer $token'} : {});
        body = convert.jsonDecode(res.body);
        if (body['message'] != null) {
          throw Exception(MagentoHelper.getErrorMessage(body));
        } else {
          double discount = double.parse("${body['discount_amount']}");
          return discount < 0 ? discount * (-1) : discount;
        }
      } else {
        throw Exception(MagentoHelper.getErrorMessage(body));
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Coupons> getCoupons() async {
    try {
      return Coupons.getListCoupons([]);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> loginGoogle({String? token, String? lang}) async {
    try {
      var store = await getSavedStore();
      var storeCode =
      lang == "en" ? store["store_en"]["code"] : store["store_ar"]["code"];
      var response = await http.post(
          Uri.parse(MagentoHelper.buildUrl(domain, "ist/social_login", storeCode)),
          body: convert.jsonEncode({"token": token, "type": "google"}),
          headers: {"content-type": "application/json"});

      if (response.statusCode == 200) {
        final token = convert.jsonDecode(response.body);
        User user = (await getUserInfo(token))!;
        user.isSocial = true;
        return user;
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(body["message"] != null
            ? MagentoHelper.getErrorMessage(body)
            : "Can not get token");
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserInfo(
      Map<String, dynamic> json, User? user) async {
    try {
      var store = await getSavedStore();
      var storeCode = store["store_en"]["code"] ?? "";
      if (isNotBlank(json["user_email"])) {
        var response = await http.post(
          Uri.parse(MagentoHelper.buildUrl(domain, "ist/customers/me/changeEmail", storeCode)),
          body: convert.jsonEncode({
            "new_email": json["user_email"],
            "current_password": json["current_pass"]
          }),
          headers: {
            'Authorization': 'Bearer ${(user?.cookie)!}',
            "content-type": "application/json"
          },
        );
        final body = convert.jsonDecode(response.body);
        if (body is Map && body["message"] != null) {
          throw Exception(MagentoHelper.getErrorMessage(body));
        }
      }
      if (isNotBlank(json["user_pass"])) {
        var response = await http.post(
          Uri.parse(MagentoHelper.buildUrl(domain, "ist/customers/me/changePassword", storeCode)),
          body: convert.jsonEncode({
            "new_password": json["user_pass"],
            "confirm_password": json["user_pass"],
            "current_password": json["current_pass"]
          }),
          headers: {
            'Authorization': 'Bearer ' + (user?.cookie)!,
            "content-type": "application/json"
          },
        );
        final body = convert.jsonDecode(response.body);
        if (body is Map && body["message"] != null) {
          throw Exception(MagentoHelper.getErrorMessage(body));
        }
      }
      if (isNotBlank(json["deviceToken"])) {
        var deviceId;
        var deviceType;
        var processor;
        var deviceOS;
        var userId = user?.id;
        var deviceToken = json["deviceToken"];

        if (Platform.isAndroid) {
          var deviceInfo = await DeviceInfoPlugin().androidInfo;
          deviceId = deviceInfo.id;
          deviceType = deviceInfo.manufacturer;
          processor = deviceInfo.hardware;
          deviceOS = 'android';
        } else {
          var deviceInfo = await DeviceInfoPlugin().iosInfo;
          deviceId = deviceInfo.identifierForVendor;
          deviceType = deviceInfo.systemName;
          processor = "";
          deviceOS = 'iOS';
        }
        printLog("update user info");
        printLog(
          convert.jsonEncode({
            "device_id": deviceId, // "123456",
            "user_id": userId, //"12",
            "token": deviceToken, //"Adffd45345hdh",
            "device_type": deviceType, //"android",
            "processor": processor, //"",
            "device_os": deviceOS, //"OS"
          }),
        );
        var response = await http.post(
          Uri.parse('https://up.ctown.jo/api/customerdevicetoken.php'),
          headers: {
            'Authorization': 'Bearer ' + (user?.cookie)!,
            "content-type": "application/json"
          },
          body: convert.jsonEncode({
            "device_id": deviceId, // "123456",
            "user_id": userId, //"12",
            "token": deviceToken, //"Adffd45345hdh",
            "device_type": deviceType, //"android",
            "processor": processor, //"",
            "device_os": deviceOS, //"OS"
          }),
        );
        if (response.statusCode != 200) {
          final body = convert.jsonDecode(response.body);
          if (body is Map && body["message"] != null) {
            throw Exception(MagentoHelper.getErrorMessage(body));
          }
        }
      }
      return json;
    } catch (err) {
      rethrow;
    }
  }

  Future getCountries() async {
    var response =
    await http.get(Uri.parse(MagentoHelper.buildUrl(domain, "directory/countries", "")));
    final body = convert.jsonDecode(response.body);
    return body;
  }

  Future<bool> forgotPasswordEmail(String email) async {
    try {
      var response = await http.post(
        //MagentoHelper.buildUrl(domain, "customers/password"),
        Uri.parse('https://up.ctown.jo/api/forgotpasswordemail.php'),
        body: convert.jsonEncode({"email": email}),
        headers: {
          'Authorization': 'Bearer ' + accessToken!,
          "content-type": "application/json"
        },
      );
      if (response.statusCode == 200) {
        //final body = convert.jsonDecode(response.body);
        if (response.body == "success") {
          return true;
        } else {
          return false;
          //throw Exception(body["message"] != null ? MagentoHelper.getErrorMessage(body) : "Could not send OTP");
        }
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(body["message"] != null
            ? MagentoHelper.getErrorMessage(body)
            : "Could not send OTP");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> forgotPasswordMobile(
      String phone, String? countryCode, String? storeid) async {
    try {
      String id = storeid == "en" ? '75' : '76';
      printLog(
        convert.jsonEncode(
            {"mobile_no": phone, "country_code": countryCode, "store_id": id}),
      );

      var response = await http.post(
        //MagentoHelper.buildUrl(domain, "customers/password"),
        Uri.parse('https://up.ctown.jo/api/forgotpasswordmobile.php'),
        body: convert.jsonEncode(
            {"mobile_no": phone, "country_code": countryCode, "store_id": id}),
        headers: {
          'Authorization': 'Bearer ' + accessToken!,
          "content-type": "application/json"
        },
      );
      if (response.statusCode == 200) {
        final body = convert.jsonDecode(response.body);
        if (body['success'] == 1) {
          return body['customer_id'];
        } else {
          throw (body["message"] != null
              ? MagentoHelper.getErrorMessage(body)
              : "Could not send OTP")!;
        }
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(body["message"] != null
            ? MagentoHelper.getErrorMessage(body)
            : "Could not send OTP");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyOTP(String? customerId, String otp) async {
    try {
      var response = await http.post(
        //MagentoHelper.buildUrl(domain, "customers/password"),
        Uri.parse('https://up.ctown.jo/api/mobileotpcheck.php'),
        body: convert.jsonEncode({"customer_id": customerId, "otp": otp}),
        headers: {
          'Authorization': 'Bearer ' + accessToken!,
          "content-type": "application/json"
        },
      );
      if (response.statusCode == 200) {
        final body = convert.jsonDecode(response.body);
        if (body['success'] == 1) {
          return true;
        } else {
          throw Exception(
            body["message"] != null
                ? MagentoHelper.getErrorMessage(body)
                : "Could not verify OTP",
          );
        }
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(body["message"] != null
            ? MagentoHelper.getErrorMessage(body)
            : "Could not verify OTP");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> resetPasswordMobile(String? customerId, String password) async {
    try {
      var response = await http.post(
        //MagentoHelper.buildUrl(domain, "customers/password"),
        Uri.parse('https://up.ctown.jo/api/resetpassword.php'),
        body: convert
            .jsonEncode({"customer_id": customerId, "password": password}),
        headers: {
          'Authorization': 'Bearer ' + accessToken!,
          "content-type": "application/json"
        },
      );
      if (response.statusCode == 200) {
        // final body = convert.jsonDecode(response.body);
        // if (body['success'] == 1) {
        return true;
        // } else {
        //   throw Exception(
        //     body["message"] != null ? MagentoHelper.getErrorMessage(body) : "Could not reset password",
        //   );
        // }
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(body["message"] != null
            ? MagentoHelper.getErrorMessage(body)
            : "Could not reset password");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>>? getCustomerInfo(String? id, String? cookie, String? lang) async {
    // TODO: implement getCustomerInfo
    //return super.getCustomerInfo(id);
    // var res = await http.get(MagentoHelper.buildUrl(domain, "customers/$id"),
    //     headers: {'Authorization': 'Bearer ' + accessToken});
    // return convert.jsonDecode(
    //     res.body); //User.fromMagentoJson(convert.jsonDecode(res.body), cookie);
    Map<String, dynamic> data = {};
    try {
      var store = await getSavedStore();
      String storeId = lang == "en"
          ? store["store_en"]["id"]
          : store["store_ar"]["id"] ?? "";
      var storeCode =
      lang == "en" ? store["store_en"]["code"] : store["store_ar"]["code"];
      printLog("GET CUSTOMER INFOO APi");
      printLog(MagentoHelper.buildUrl(domain, "customers/$id", storeCode));
      printLog("Token $accessToken");
      final http.Response response = await http.get(
          Uri.parse(MagentoHelper.buildUrl(domain, "customers/$id", storeCode)),
          headers: {'Authorization': 'Bearer ${accessToken!}'});
      printLog("Sucess");
      var body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body != null && body is Map) {
        data = Map.from(body);
      }
    } catch (err) {
      printLog("error");
      return data;
    }
    return data;
  }

  @override
  Future<void> addAddress(
      Address address, User? user, String? lang, String? lati, String? lan) async {
    try {
      var store1 = await getSavedStore();
      String? id = lang == "en"
          ? store1["store_en"]["id"]
          : store1["store_ar"]["id"] ?? "";
      //Provider.of<UserModel>(context, listen: false);
      printLog("add address api body");
      printLog(convert.jsonEncode({
        "customer_id": user?.id, //"89",
        "firstname": user?.firstName, //"test",
        "lastname": user?.lastName, //"test1",
        "city": address.city, //"Ajman",
        "area": address.state, //"Ajman",
        "phone_number": address.phoneNumber!.isNotEmpty
            ? address.phoneNumber
            : "0", // "6756789876",
        "street": address.street //"writers",
        //"postcode": address.zipCode ?? "0", //"600001"
        ,
        "building_name": address.apartment
        //  ?? "d"
        ,
        "flat_no": address.block
        // ?? "d"
        ,
        "landmark": address.landmark,
        "unit_no": address.unitNo,

        "zone_no": address.zoneNo, "building_no": address.buildingNo,
        "street_no": address.streetNo,
        "latitude": lati,
        "longitude": lan,
        "store_id": id

        //  ?? "d"
      }));

      var response = await http.post(Uri.parse('https://up.ctown.jo/api/addaddress.php'),
          body: convert.jsonEncode({
            "customer_id": user?.id, //"89",
            "firstname": user?.firstName, //"test",
            "lastname": user?.lastName, //"test1",
            "city": address.city, //"Ajman",
            "area": address.state, //"Ajman",
            "phone_number": address.phoneNumber!.isNotEmpty
                ? address.phoneNumber
                : "0", // "6756789876",
            "street": address.street //"writers",
            //"postcode": address.zipCode ?? "0", //"600001"
            ,
            "building_name": address.apartment
            //  ?? "d"
            ,
            "flat_no": address.block
            // ?? "d"
            ,
            "landmark": address.landmark,
            "unit_no": address.unitNo,

            "zone_no": address.zoneNo, "building_no": address.buildingNo,
            "street_no": address.streetNo,
            "store_id": id,
            "latitude": lati,
            "longitude": lan

            //  ?? "d"
          }),
          headers: {"content-type": "application/json"});
      printLog("add address");
      printLog(response.body);
      printLog(response.statusCode);
      printLog("response finish");
      if (response.statusCode == 200) {
        printLog(response.body);

        return;
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<void> editAddress(
      Address address, User? user, String? lang, String? lat, String? lan) async {
    try {
      var store1 = await getSavedStore();
      String? id = lang == "en"
          ? store1["store_en"]["id"]
          : store1["store_ar"]["id"] ?? "";

      printLog(
        convert.jsonEncode({
          "customer_id": user?.id, //"89",
          "firstname": user?.firstName, //"test",
          "lastname": user?.lastName, //"test1",
          "address_id": address.id, //"24",
          "city": address.city, //"Ajman",
          "area": address.state, //"Ajman",
          "phone_number": address.phoneNumber!.isNotEmpty
              ? address.phoneNumber
              : 0, // "6756789876",
          "street": address.street //"writers",
          //"postcode": address.zipCode ?? "0" //"600001"
          ,
          "building_name": address.apartment ?? "",
          "flat_no": address.block ?? "",
          "landmark": address.landmark ?? "",

          "zone_no": address.zoneNo, "building_no": address.buildingNo,
          "street_no": address.streetNo,
          "unit_no": address.unitNo,
          "store_id": id,
          "latitude": lat,
          "longitude": lan
        }),
      );
      var response = await http.post(Uri.parse('https://up.ctown.jo/api/editaddress.php'),
          body: convert.jsonEncode({
            "customer_id": user?.id, //"89",
            "firstname": user?.firstName, //"test",
            "lastname": user?.lastName, //"test1",
            "address_id": address.id, //"24",
            "city": address.city, //"Ajman",
            "area": address.state, //"Ajman",
            "phone_number": address.phoneNumber!.isNotEmpty
                ? address.phoneNumber
                : 0, // "6756789876",
            "street": address.street //"writers",
            //"postcode": address.zipCode ?? "0" //"600001"
            ,
            "building_name": address.apartment ?? "",
            "flat_no": address.block ?? "",
            "landmark": address.landmark ?? "",

            "zone_no": address.zoneNo, "building_no": address.buildingNo,
            "street_no": address.streetNo,
            "unit_no": address.unitNo,
            "store_id": id,
            "latitude": lat,
            "longitude": lan
          }),
          headers: {"content-type": "application/json"});
      printLog(response.body);
      if (response.statusCode == 200) {
        return;
      }
    } catch (err) {
      rethrow;
    }
  }

  Future addAddressWithResponse(Address address, User user) async {
    try {
      //Provider.of<UserModel>(context, listen: false);
      printLog("add address api body");
      printLog(convert.jsonEncode({
        "customer_id": user.id, //"89",
        "firstname": user.firstName, //"test",
        "lastname": user.lastName, //"test1",
        "city": address.city, //"Ajman",
        "area": address.state, //"Ajman",
        "phone_number": address.phoneNumber!.isNotEmpty
            ? address.phoneNumber
            : "0", // "6756789876",
        "street": address.street //"writers",
        //"postcode": address.zipCode ?? "0", //"600001"
        ,
        "building_name": address.apartment
        //  ?? "d"
        ,
        "flat_no": address.block
        // ?? "d"
        ,
        "landmark": address.landmark
        //  ?? "d"
      }));
      printLog("add address");
      var response = await http.post(Uri.parse('https://up.ctown.jo/api/addaddress.php'),
          body: convert.jsonEncode({
            "customer_id": user.id, //"89",
            "firstname": user.firstName, //"test",
            "lastname": user.lastName, //"test1",
            "city": address.city, //"Ajman",
            "area": address.state, //"Ajman",
            "phone_number": address.phoneNumber!.isNotEmpty
                ? address.phoneNumber
                : "0", // "6756789876",
            "street": address.street //"writers",
            //"postcode": address.zipCode ?? "0", //"600001"
            ,
            "building_name": address.apartment
            //  ?? "d"
            ,
            "flat_no": address.block
            // ?? "d"
            ,
            "landmark": address.landmark
            //  ?? "d"
          }),
          headers: {"content-type": "application/json"});
      printLog("add address");
      printLog(response.body);
      printLog(response.statusCode);
      printLog("response finish");
      if (response.statusCode == 200) {
        printLog(response.body);
        var responseBody = response.body;
        printLog(responseBody);
        return responseBody;
      }
    } catch (err) {
      rethrow;
    }
  }

  Future editAddressWithResponse(Address address, User user) async {
    try {
      printLog(convert.jsonEncode({
        "customer_id": user.id, //"89",
        "firstname": user.firstName, //"test",
        "lastname": user.lastName, //"test1",
        "address_id": address.id, //"24",
        "city": address.city, //"Ajman",
        "area": address.state, //"Ajman",
        "phone_number": address.phoneNumber!.isNotEmpty
            ? address.phoneNumber
            : 0, // "6756789876",
        "street": address.street //"writers",
        //"postcode": address.zipCode ?? "0" //"600001"
        ,
        "building_name": address.apartment ?? "",
        "flat_no": address.block ?? "",
        "landmark": address.landmark ?? ""
      }));

      var response = await http.post(Uri.parse('https://up.ctown.jo/api/editaddress.php'),
          body: convert.jsonEncode({
            "customer_id": user.id, //"89",
            "firstname": user.firstName, //"test",
            "lastname": user.lastName, //"test1",
            "address_id": address.id, //"24",
            "city": address.city, //"Ajman",
            "area": address.state, //"Ajman",
            "phone_number": address.phoneNumber!.isNotEmpty
                ? address.phoneNumber
                : 0, // "6756789876",
            "street": address.street //"writers",
            //"postcode": address.zipCode ?? "0" //"600001"
            ,
            "building_name": address.apartment ?? "",
            "flat_no": address.block ?? "",
            "landmark": address.landmark ?? ""
          }),
          headers: {"content-type": "application/json"});
      printLog(response.body);
      if (response.statusCode == 200) {
        var responseBody = response.body;
        return responseBody;
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAddress(Address address) async {
    try {
      var response = await http.post(Uri.parse('https://up.ctown.jo/api/deleteaddress.php'),
          body: convert.jsonEncode({
            "address_id": address.id, //"24",
          }),
          headers: {"content-type": "application/json"});

      if (response.statusCode == 200) {
        return;
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future getCartInfo(String token) async {
    try {
      final http.Response response = await http.get(
        // MagentoHelper.buildUrl(domain, "carts/mine/items"),
        Uri.parse(MagentoHelper.buildUrl(domain,
            "carts/mine?nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}", "")),
        headers: {'Authorization': 'Bearer $token'},
      );

      final body = convert.jsonDecode(response.body);
      printLog("getting cart info");
      printLog(MagentoHelper.buildUrl(domain,
          "carts/mine?nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}", ""));
      printLog(body);
      if (response.statusCode == 200) {
        return {"cartId": body["id"], "items": body["items"]};
      } else if (body["message"]
      // .contains('Current customer does not have an active cart 122343')) {
          .contains('No such entity')) {
        return null;
      } else if (body["message"] != null) {
        throw Exception(body["message"]);
      }
      return null;
    } catch (err) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getContactDetails() async {
    try {
      var response = await http.get(
        Uri.parse('https://up.ctown.jo/api/helpandsupport.php'),
        headers: {'Authorization': 'Bearer ' + accessToken!},
      );
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return body['data'][0];
      } else if (body["message"] != null) {
        throw Exception(body["message"]);
      }
      return null;
    } catch (err) {
      rethrow;
    }
  }

  Future<bool> submitFeedback(
      String? name, String? mobileNo, String? subject, String? feedback) async {
    try {
      printLog(convert.jsonEncode({
        "name": name,
        "mobile_no": mobileNo,
        "subject": subject,
        "feedback": feedback,
      }));
      var response = await http.post(Uri.parse('https://up.ctown.jo/api/feedback.php'),
          body: convert.jsonEncode({
            "name": name,
            "mobile_no": mobileNo,
            "subject": subject,
            "feedback": feedback,
          }),
          headers: {"content-type": "application/json"});
      printLog("Feedback respo");
      printLog(response.body);
      if (response.statusCode == 200) {
        // final body = convert.jsonDecode(response.body);
        // if (body['success'] == 1) {
        return true;
        // } else {
        //   throw Exception(
        //     body["message"] != null ? MagentoHelper.getErrorMessage(body) : "Could not reset password",
        //   );
        // }
      } else {
        final body = convert.jsonDecode(response.body);
        throw Exception(body["message"] != null
            ? MagentoHelper.getErrorMessage(body)
            : "Could not reset password");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<String>>? getProductAddtionalInfo(productId) async {
    try {
      List<String> attributes = [];
      var res = await http.post(
        Uri.parse('https://up.ctown.jo/api/moreinformation.php'),
        headers: {
          'Authorization': 'Bearer ' + accessToken!,
          "content-type": "application/json"
        },
        body: convert.jsonEncode({"product_id": productId}),
      );
      if (res.statusCode == 200) {
        // printLog(convert.jsonEncode({"product_id": productId}));
        var body = convert.jsonDecode(res.body);
        // printLog("Attr resp ${body}");
        // printLog("Attr resp ${body.runtimeType}");
        for (var ele in body) {
          // printLog(ele["attribute"]);
          // printLog(ele["attribute"].runtimeType);
          int index = ele["attribute"].toString().indexOf(":");
          // printLog("check empty" +
          //     "  " +
          //     ele["attribute"][index + 1] +
          //     " " +
          //     (ele["attribute"][index + 2] == null).toString());
          String substring = ele["attribute"].toString().substring(index);
          // printLog("Substring (${substring}) ====${substring.length}");
          if (substring.length > 2) {
            attributes.add(ele["attribute"]);
          } else {
            printLog("Removed detail ${ele["attribute"]}");
          }
        }
      }
      return attributes;
    } catch (err) {
      rethrow;
    }
  }

  Future<List<OrderHistory>> getOrderHistory(orderId) async {
    try {
      List<OrderHistory> orderHistory = [];
      printLog("order h");
      printLog(accessToken);
      var res = await http.post(
        Uri.parse('https://up.ctown.jo/api/orderstatus.php'),
        headers: {
          'Authorization': 'Bearer ' + accessToken!,
          "content-type": "application/json"
        },
        body: convert.jsonEncode({"order_id": orderId}),
      );
      if (res.statusCode == 200) {
        var body = convert.jsonDecode(res.body)['data'];
        for (var ele in body) {
          orderHistory.add(OrderHistory.fromMap(ele));
        }
      }
      return orderHistory;
    } catch (err) {
      rethrow;
    }
  }

  Future<List<Map?>> getCouponCodes(String lang) async {
    try {
      var store = await getSavedStore();
      var storeCode =
      lang == "en" ? store["store_en"]["code"] : store["store_ar"]["code"];
      printLog(MagentoHelper.buildUrl(
          domain, "coupons/search?searchCriteria[pageSize]=0", storeCode));
      printLog("Token: $accessToken");
      var response = await http.get(
          Uri.parse(MagentoHelper.buildUrl(
              domain, "coupons/search?searchCriteria[pageSize]=0", storeCode)),
          headers: {'Authorization': 'Bearer ${accessToken!}'});
      List<Map?> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["items"]) {
          //Product product = parseProductFromJson(item);
          list.add(item);
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CardDetails>> getCardDetails(String? customerId) async {
    try {
      List<CardDetails> cardDetails = [];

      var res = await http.post(
        Uri.parse( 'https://up.ctown.jo/api/existingcard.php'),
        headers: {
          'Authorization': 'Bearer ' + accessToken!,
          "content-type": "application/json"
        },
        body: convert.jsonEncode({"customer_id": customerId}),
      );
      if (res.statusCode == 200) {
        var body = convert.jsonDecode(res.body);
        for (var ele in body) {
          cardDetails.add(CardDetails.fromJson(ele));
        }
      }
      return cardDetails;
    } catch (e) {
      rethrow;
    }
  }

  Future getDealsCategoryList(lang) async {
    try {
      List<String?> categoryIdList = [];
      var store1 = await getSavedStore();
      String? id = lang == "en"
          ? store1["store_en"]["id"]
          : store1["store_ar"]["id"] ?? "";
      printLog("get deals store id store1");
      printLog("id $id");
      var res = await http.get(
        Uri.parse('https://up.ctown.jo/api/dealscategoryfilter.php?store_id=$id'),
        headers: {
          'Authorization': 'Bearer ' + accessToken!,
          "content-type": "application/json"
        },
      );
      printLog("get deals list");
      printLog(accessToken);
      printLog('https://up.ctown.jo/api/dealscategoryfilter.php?store_id=$id');
      if (res.statusCode == 200) {
        var body = convert.jsonDecode(res.body);
        for (var ele in body['data']) {
          categoryIdList.add(ele['category_id']);
        }
      }
      return categoryIdList;
    } catch (e) {
      printLog("deal filter error $e");
      return Future.error(e.toString());
    }
  }

  Future getSearchCategoryList(String? searchStr, String? langcode) async {
    try {
      var store1 = await getSavedStore();
      List<String?> categoryIdList = [];
      // var url = langcode == 'ar'
      //     ? 'https://up.ctown.jo/api/searchcategoryfilter.php?search=$searchStr&store_id=58'
      //     : 'https://up.ctown.jo/api/searchcategoryfilter.php?search=$searchStr&store_id=57';

      var url = langcode == 'ar'
          ? 'https://up.ctown.jo/api/searchcategoryfilter.php?search=$searchStr&store_id=${store1["store_ar"]["id"]}'
          : 'https://up.ctown.jo/api/searchcategoryfilter.php?search=$searchStr&store_id=${store1["store_en"]["id"]}';

      printLog("get search category list $url");
      var res = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ' + accessToken!,
          "content-type": "application/json"
        },
      );
      if (res.statusCode == 200) {
        var body = convert.jsonDecode(res.body);
        for (var ele in body['data']) {
          categoryIdList.add(ele['category_id']);
        }
      }
      return categoryIdList;
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<Map> postOrderDetails(double amount,
      {String? orderId = "1", String? cardId = "0"}) async {
    try {
      var res = await http.post(
        // 'https://up.ctown.jo/api/mobilepayment.php',
        Uri.parse('https://up.ctown.jo/api/qatardebitcardpayment.php'),
        headers: {
          'Authorization': 'Bearer ' + accessToken!,
          "content-type": "application/json"
        },
        body: convert.jsonEncode({
          "amount": amount.toStringAsFixed(2),
          "order_id": orderId,
          "card_id": cardId,
        }),
      );
      printLog("mnie");
      printLog(accessToken);
      printLog(convert.jsonEncode({
        "amount": amount.toStringAsFixed(2),
        "order_id": orderId,
        "card_id": cardId,
      }));
      printLog(res.body);
      if (res.statusCode == 200) {
        var body = convert.jsonDecode(res.body);
        return {
          // "paymentUrl": body['data'],
          'merchentId': body['data']['merchant_id'],
          'amount': body['data']['amount'],
          'currency': body['data']['currency'],
          'orderId': body['data']['order_id'],
          'session': body['data']['session'],
          'successIndicator': body['data']['successIndicator'],
          // "paymentUrl": body['data']['_links']['payment']['href'],
          // "redirectUrl": body['data']['merchantAttributes']['redirectUrl'],
          // "cancelUrl": body['data']['merchantAttributes']['cancelUrl']
        };
      }
      throw Exception(res.reasonPhrase);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> postOrderDetailsForCreditCard(double amount,
      {String? orderId = "1", String? cardId = "0"}) async {
    try {
      var res = await http.post(
        // 'https://up.ctown.jo/api/mobilepayment.php',
        Uri.parse('https://up.ctown.jo/api/qatarcreditcardpayment.php'),
        headers: {
          'Authorization': 'Bearer ' + accessToken!,
          "content-type": "application/json"
        },
        body: convert.jsonEncode({
          "amount": amount.toStringAsFixed(2),
          "order_id": orderId,
          "card_id": cardId,
        }),
      );
      printLog("mnie");
      printLog(accessToken);
      printLog(convert.jsonEncode({
        "amount": amount.toStringAsFixed(2),
        "order_id": orderId,
        "card_id": cardId,
      }));
      printLog(res.body);
      if (res.statusCode == 200) {
        var body = convert.jsonDecode(res.body);
        return {
          // "paymentUrl": body['data'],
          'merchentId': body['data']['merchant_id'],
          'amount': body['data']['amount'],
          'currency': body['data']['currency'],
          'orderId': body['data']['order_id'],
          'session': body['data']['session'],
          'successIndicator': body['data']['successIndicator'],
          // "paymentUrl": body['data']['_links']['payment']['href'],
          // "redirectUrl": body['data']['merchantAttributes']['redirectUrl'],
          // "cancelUrl": body['data']['merchantAttributes']['cancelUrl']
        };
      }
      throw Exception(res.reasonPhrase);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> matchDelivery(
      double latitude, double longitude, String? lang) async {
    try {
      var store = await getSavedStore();

      String? id = lang == "en"
          ? store["store_en"]["id"]
          : store["store_ar"]["id"] ?? "";
      var store1 = await getSavedStoregroupid();
      printLog(
        convert.jsonEncode({
          "lat": latitude.toString(),
          "long": longitude.toString(),
          "store_id": id,
          "store_group_id": store1
        }),
      );
      printLog(convert.jsonEncode(
          {"lat": latitude.toString(), "long": longitude.toString()}));
      var res = await http.post(
        Uri.parse('https://up.ctown.jo/api/matchdelivery.php'),
        headers: {
          'Authorization': 'Bearer ' + accessToken!,
          "content-type": "application/json"
        },
        body: convert.jsonEncode({
          "lat": latitude.toString(),
          "long": longitude.toString(),
          "store_id": id,
          "store_group_id": store1
        }),
      );

      printLog(res.body);
      printLog(res.statusCode);
      printLog(lang);
      if (res.statusCode == 200) {
        var body = convert.jsonDecode(res.body);
        printLog(body);
        return body["success"] == 1 ? true : false;
      }

      throw Exception(res.reasonPhrase);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> matchDeliveryHwi(String state, String city, String? lang) async {
    try {
      var store = await getSavedStore();

      String? storeId = lang == "en"
          ? store["store_en"]["id"]
          : store["store_ar"]["id"] ?? "";
      var storeGroupId = await getSavedStoregroupid();

      printLog("My Test Huawei");
      printLog("State & City: $state $city");
      printLog("Store Id & Store Group Id: $storeId $storeGroupId");
      var res = await http.post(
        Uri.parse("https://up.ctown.jo/api/matchdeliveryhuawei.php"),
        body: json.encode({
          "state_area": state,
          "city": city,
          "store_id": storeId,
          "store_group_id": storeGroupId
        }),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          "Authorization": "Bearer " + "h1oe6s65wunppubhvxq8hrnki9raobt1"
        },
      );

      printLog(res.body);
      printLog(res.statusCode);
      printLog(lang);
      if (res.statusCode == 200) {
        printLog("Success...");
        var body = json.decode(res.body);
        printLog(body);
        return body["success"] == 1 ? true : false;
      }
      throw Exception(res.reasonPhrase);
    } catch (e) {
      rethrow;
    }
  }

  // Future<bool> matchDelivery(double latitude, double longitude) async {
  //   try {
  //     printLog(convert.jsonEncode({"lat": latitude, "long": longitude}));

  //     printLog(accessToken);

  //     var res = await http.post(
  //     Uri.parse('https://up.ctown.jo/api/matchdelivery.php'),
  //       headers: {
  //         'Authorization': 'Bearer ' + accessToken,
  //         "content-type": "application/json"
  //       },
  //       body: convert.jsonEncode({"lat": latitude, "long": longitude}),
  //     );

  //     if (res.statusCode == 200) {
  //        printLog("body");

  //         printLog("rgghffes.body");
  //       var body = convert.jsonDecode(res.body);

  //       return body ['success'] == 1 ? true : false;

  //     }
  //     throw Exception(res.reasonPhrase);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future getPaymentStatus(ref) async {
    try {
      var res = await http.post(
        Uri.parse('https://api.ctown.jo/orderreference.php'),
        headers: {
          'Authorization': 'Bearer ' + accessToken!,
          "content-type": "application/json"
        },
        body: convert.jsonEncode({"reference": ref}),
      );
      if (res.statusCode == 200) {
        var body = convert.jsonDecode(res.body);
        printLog(body['data']['_embedded']['payment'][0]['state']);
        return body['data']['_embedded']['payment'][0]['state'];
      }
      throw Exception(res.reasonPhrase);
    } catch (e) {
      rethrow;
    }
  }

  Future getMinimumOrderValue(String qoute) async {
    try {
      printLog(
          'https://up.ctown.jo/api/minimumorderamount.php?qoute_id=$qoute&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}');
      var res = await http.get(
        Uri.parse('https://up.ctown.jo/api/minimumorderamount.php?qoute_id=$qoute&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}'),
        headers: {
          'Authorization': 'Bearer ' + accessToken!,
          "content-type": "application/json"
        },
      );
      if (res.statusCode == 200) {
        var body = convert.jsonDecode(res.body);
        return int.parse(body['amount']);
      } else {
        return 0;
      }
    } catch (e) {
      printLog(e.toString());
      return -1;
    }
  }

  Future getCheckoutTime() async {
    try {
      var res = await http.get(
        Uri.parse('https://up.ctown.jo/api/checkout_time.php'),
        headers: {
          'Authorization': 'Bearer ' + accessToken!,
          "content-type": "application/json"
        },
      );
      if (res.statusCode == 200) {
        var body = convert.jsonDecode(res.body);
        if (int.parse(body['success']) == 1) {
          return int.parse(body['minutes']);
        } else {
          return 0;
        }
      } else {
        return 0;
      }
    } catch (e) {
      printLog(e.toString());
      return 0;
    }
  }

  Future submitPaymentSuccess(String? orderId) async {
    try {
      var res = await http.post(
        Uri.parse('https://up.ctown.jo/api/paymentsuccess.php'),
        headers: {
          'Authorization': 'Bearer ' + accessToken!,
          "content-type": "application/json"
        },
        body: convert.jsonEncode({"order_id": orderId}),
      );
      printLog("payment success resp ${res.body}");
      if (res.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

// Future getWishlist(String userId) {}

}