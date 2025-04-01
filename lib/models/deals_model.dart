import 'dart:convert';
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../common/tools.dart';
import '../screens/products/products.dart';
import '../services/index.dart';
import '../services/service_config.dart';
import '../widgets/layout/adaptive.dart';
import 'app_model.dart';
import 'entities/product.dart';
import 'entities/product_variation.dart';

class DealsModel with ChangeNotifier {
  final Services _service = Services();
  List<List<Product>>? products;
  String? message;

  /// current select product id/name
  String? categoryId;
  String? categoryName;
  int? tagId;

  //list products for products screen
  bool isFetching = false;
  List<Product>? productsList;
  String? errMsg;
  bool? isEnd;

  bool isProductVariationLoading = true;
  ProductVariation? productVariation;
  List<Product>? lstGroupedProduct;
  String? cardPriceRange;
  String detailPriceRange = '';

  void setProductVariationLoading(bool value) {
    isProductVariationLoading = value;
    notifyListeners();
  }

  void changeProductVariation(ProductVariation variation) {
    productVariation = variation;
    notifyListeners();
  }

  Future<List<Product>?> fetchGroupedProducts({required Product product}) async {
    lstGroupedProduct = [];
    for (int productID in product.groupedProducts as Iterable<int>) {
      await _service.getProduct(productID).then((value) {
        lstGroupedProduct!.add(value!);
      });
    }
    return lstGroupedProduct;
  }

  void changeDetailPriceRange(String currency, Map<String, dynamic> rates) {
    if (lstGroupedProduct!.isNotEmpty) {
      double currentPrice = double.parse(lstGroupedProduct![0].price!);
      double max = currentPrice;
      double min = 0;
      for (var product in lstGroupedProduct!) {
        min = double.parse(product.price!);
        if (min > max) {
          double temp = min;
          max = min;
          min = temp;
        }
        detailPriceRange = currentPrice != max
            ? '${Tools.getCurrencyFormatted(currentPrice, rates, currency: currency)} - ${Tools.getCurrencyFormatted(max, rates, currency: currency)}'
            : '${Tools.getCurrencyFormatted(currentPrice, rates, currency: currency)}';
      }
    }
  }

  Future<List<Product>> fetchProductLayout(config, lang) async {
    return _service.fetchProductsLayout(config: config, lang: lang);
  }

  void fetchProductsByCategory({categoryId, categoryName}) {
    this.categoryId = categoryId;
    this.categoryName = categoryName;
    notifyListeners();
  }

  void updateTagId({tagId}) {
    this.tagId = tagId;
    notifyListeners();
  }

  Future<void> saveProducts(Map<String, dynamic> data) async {
    final LocalStorage storage = LocalStorage("store");
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey["home"]!, data);
      }
    } catch (_) {}
  }

  Future<void> getProductsList({
    categoryId,
    minPrice,
    maxPrice,
    orderBy,
    order,
    String? tagId,
    lang,
    sort,
    page,
    featured,
    onSale,
    attribute,
    attributeTerm,
  }) async {
    try {
      if (categoryId != null) {
        this.categoryId = categoryId;
      }
      if (tagId != null && tagId.isNotEmpty) {
        this.tagId = int.parse(tagId);
      }
      isFetching = true;
      isEnd = false;
      notifyListeners();

      final products = await _service.fetchProductsByCategory(
        categoryId: categoryId,
        tagId: tagId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        orderBy: orderBy,
        order: order,
        lang: lang,
        sort:sort,
        page: page,
        featured: featured,
        onSale: onSale,
        attribute: attribute,
        attributeTerm: attributeTerm,
      );
      isEnd = products.isEmpty || page > 20;

      ///Removed because isEnd always returns true if user click on category button on Category screen.
      ///Issue: https://github.com/instasoft/support/issues/3158#issuecomment-643657380
//      bool isExisted = productsList.indexWhere(
//              (o) => products.isNotEmpty && o.id == products[0].id) >
//          -1;
//      print(
//          '${products[0].id} ${productsList.indexWhere((o) => products.isNotEmpty && o.id == products[0].id)}');
//      if (!isExisted) {
//        if (page == 0 || page == 1) {
//          productsList = products;
//        } else {
//          productsList = [...productsList, ...products];
//        }
//      } else {
//        isEnd = true;
//      }

      if (page == 0 || page == 1) {
        productsList = products;
      } 
      // else {
      //   productsList = [...productsList, ...products];
      // }

      isFetching = false;
      errMsg = null;
      notifyListeners();
    } catch (err, _) {
      errMsg =
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString();
      isFetching = false;
      notifyListeners();
    }
  }

  void setProductsList(products) {
    productsList = products;
    isFetching = false;
    isEnd = false;
    notifyListeners();
  }

  Future<void> createProduct(
      List galleryImages,
      List<File> fileImages,
      String cookie,
      String nameProduct,
      String type,
      String idCategory,
      double salePrice,
      double regularPrice,
      String description) async {
    Future uploadImage() async {
      try {
        if (fileImages.isNotEmpty) {
          for (var i = 0; i < fileImages.length; i++) {
            printLog("path ${path.basename(fileImages[i].path)}");
            await _service.uploadImage({
              "title": {"rendered": path.basename(fileImages[i].path)},
              "media_attachment": base64.encode(fileImages[i].readAsBytesSync())
            })?.then((photoId) {
              galleryImages.add("$photoId");
            });
          }
        } else {
          return;
        }
      } catch (e) {
        rethrow;
      }
    }

    await uploadImage().then((_) async {
      await _service.createProduct(cookie, {
        "title": nameProduct,
        "product_type": type,
        "content": description,
        "regular_price": regularPrice,
        "sale_price": salePrice,
        "image_ids": galleryImages,
        "categories": [
          {"id": idCategory}
        ],
        "status": kNewProductStatus
      });
    });
  }

  /// Show the product list
  static showList({
    cateId,
    cateName,
    String? tag,
    required BuildContext context,
    List<Product>? products,
    config,
    bool showCountdown = false,
    Duration countdownDuration = Duration.zero,
  }) {
    try {
      var categoryId = cateId ?? config['category']?.toString();
      var categoryName = cateName ?? config['name'];
      final bool? onSale = config != null ? config['onSale'] : null;
      final bool? configCountdown = config != null
          ? config['showCountDown'] ?? false
          : kSaleOffProduct["ShowCountDown"] as bool?;

      String? tagId = tag ?? (config ?? {})['tag']?.toString();
      final product = Provider.of<DealsModel>(context, listen: false);

      if (kIsWeb || isDisplayDesktop(context)) {
        eventBus.fire(const EventCloseCustomDrawer());
      } else {
        eventBus.fire(const EventCloseNativeDrawer());
      }
      // for caching current products list
      if (products != null && products.isNotEmpty) {
        product.setProductsList(products);
        return Navigator.of(
          context,
          rootNavigator: !(Config().isBuilder),
        ).push(MaterialPageRoute(
          builder: (context) => ProductsPage(
            products: products,
            categoryId: categoryId,
            tagId: tagId,
            onSale: onSale,
            title: (onSale ?? false) && showCountdown ? categoryName : null,
            showCountdown:
                configCountdown! && (onSale ?? false) && showCountdown,
            countdownDuration: countdownDuration,
          ),
        ));
      }
      product.updateTagId(tagId: config != null ? config['tag'] : null);

      // for fetching beforehand
      if (categoryId != null) {
        product.fetchProductsByCategory(
            categoryId: categoryId, categoryName: categoryName);
      }

      product.setProductsList(<Product>[]); //clear old products
      product.getProductsList(
        tagId: tagId,
        categoryId: categoryId,
        page: 1,
        onSale: onSale,
        lang: Provider.of<AppModel>(context, listen: false).langCode,
      );

      Navigator.of(
        context,
        rootNavigator: !(Config().isBuilder),
      ).push(MaterialPageRoute(
        builder: (context) => ProductsPage(
          products: products ?? [],
          categoryId: categoryId,
          tagId: tagId,
          onSale: onSale,
          title: (onSale ?? false) && showCountdown ? categoryName : null,
          showCountdown: configCountdown! && (onSale ?? false) && showCountdown,
          countdownDuration: countdownDuration,
        ),
      ));
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
    }
  }
}
