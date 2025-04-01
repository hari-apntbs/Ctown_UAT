import 'dart:convert';
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../common/tools.dart';
import '../screens/products/home_product.dart';
import '../services/index.dart';
import '../widgets/layout/adaptive.dart';
import 'app_model.dart';
import 'entities/product.dart';
import 'entities/product_variation.dart';

class HomeProductModel with ChangeNotifier {
  final Services _service = Services();
  List<List<Product>>? products;
  String? message;
  bool allLoaded = false;

  List<bool> completedList = [];
  int catIdListLen = -1;

  /// current select product id/name
  String? categoryId;
  String? categoryName;
  int? tagId;

  bool isFetching = false;
  List<Product>? productsList;
  String? errMsg;
  bool? isEnd;

  bool isProductVariationLoading = true;
  ProductVariation? productVariation;
  List<Product>? lstGroupedProduct;
  String? cardPriceRange;
  String detailPriceRange = '';
  List<Map<String, dynamic>> productVarList = [];
  List<Product>? outOfStockProducts = [];
  bool productAvailable = true;
  String currentSubCat = "";

  void setProductVariationLoading(bool value) {
    isProductVariationLoading = value;
    notifyListeners();
  }

  void setProductAvail(bool value) {
    productAvailable = value;
    notifyListeners();
  }

  void saveProductVariations(Product product , List<ProductVariation> variations) {
    Map<String, dynamic> proVar = {};
    proVar[product.sku ?? ""] = variations;
    productVarList.add(proVar);
  }

  List<ProductVariation> getProVariations(Product product) {
    List<ProductVariation> productVariationList = [];
    // productVarList.forEach((element) {
    //   if(element.containsKey(product.sku)) {
    //     productVariationList = element[product.sku];
    //   }
    // });
    return productVariationList;
  }

  changeProductVariation(ProductVariation? variation) {
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

  void changeDetailPriceRange(String? currency, Map<String, dynamic> rates) {
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

  void checkAllLoaded() {
    printLog('completedList: $completedList');
    if (completedList.length == catIdListLen &&
        !completedList.any((e) => e == false)) {
      printLog('All are loaded');
      allLoaded = true;
    } else {
      printLog('All are not loaded');
      allLoaded = false;
    }
    notifyListeners();
    return;
  }

  void setCatIdListLen(int newLen) {
    allLoaded = false;
    completedList = [];
    catIdListLen = newLen;
    notifyListeners();
  }

  Future<void> getProductsList({
    categoryId,
    minPrice,
    maxPrice,
    orderBy,
    order,
    String? tagId,
    lang,
    page,
    featured,
    sort,
    onSale,
    attribute,
    attributeTerm,
    isFromSearch,
    products, loadMore
  }) async {
    bool fromSearch = isFromSearch ?? false;
    if(products != null && products.length !=0 && products.length < 5) {
      productsList?.addAll(products);
    }
    try {
      if (categoryId != null) {
        this.categoryId = categoryId;
      }
      if (tagId != null && tagId.isNotEmpty) {
        this.tagId = int.parse(tagId);
      }
      if(loadMore == null) {
        isFetching = true;
      }
      isEnd = false;
      notifyListeners();

      final productsTemp = await _service.fetchProductsByCategory(
        categoryId: categoryId,
        tagId: tagId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        orderBy: orderBy,
        order: order,
        lang: lang,
        page: page,
        featured: featured,
        onSale: onSale,
        sort: sort,
        attribute: attribute,
        attributeTerm: attributeTerm,
      );
      completedList.add(true);
      checkAllLoaded();

      printLog('categoryId: $categoryId, noOfProducts: $productsTemp');
      printLog('noOfProducts: ${productsTemp.length}');
      isEnd = productsTemp.isEmpty;
      if(productsTemp.isEmpty) {
        setProductAvail(false);
      }

      if ((page == 0 || page == 1) && !fromSearch ) {
        printLog("runnnninnnnnfffffggggg");
        if(products != null && products.length !=0) {
          productsList = [...productsList!, ...productsTemp];
        }
        else {
          productsList = productsTemp;
        }
      } else {
        printLog(page);
        printLog("runnnninnnnnfffffggggg");
        productsList = [...productsList!, ...productsTemp];
      }

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

  Future<void> getMoreProducts({
    categoryId,
    minPrice,
    maxPrice,
    orderBy,
    order,
    String? tagId,
    lang,
    page,
    featured,
    sort,
    onSale,
    attribute,
    attributeTerm,
    isFromSearch,
    products, loadMore, currentCat
  }) async {
    bool fromSearch = isFromSearch ?? false;
    if(products != null && products.length !=0 && products.length < 5) {
      productsList?.addAll(products);
    }
    try {
      if (categoryId != null) {
        this.categoryId = categoryId;
      }
      if (tagId != null && tagId.isNotEmpty) {
        this.tagId = int.parse(tagId);
      }
      isEnd = false;
      notifyListeners();

      final productsTemp = await _service.fetchProductsByCategory(
        categoryId: categoryId,
        tagId: tagId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        orderBy: orderBy,
        order: order,
        lang: lang,
        page: page,
        featured: featured,
        onSale: onSale,
        sort: sort,
        attribute: attribute,
        attributeTerm: attributeTerm,
      );
      completedList.add(true);
      checkAllLoaded();

      printLog('categoryId: $categoryId, noOfProducts: $productsTemp');
      printLog('noOfProducts: ${productsTemp.length}');
      isEnd = productsTemp.isEmpty;
      if(productsTemp.isEmpty) {
        setProductAvail(false);
      }

      if((productsList?.isNotEmpty)! && !isFetching && currentCat == currentSubCat) {
        productsList = [...productsList!, ...productsTemp];
        // Set<String?> apiCategoryIds = productsTemp.map((p) => p.categoryId).toSet();
        // bool? allCategoryIdsMatch = productsList?.every((p) => apiCategoryIds.contains(p.categoryId));
        // if(allCategoryIdsMatch != null && allCategoryIdsMatch) {
        //
        // }
      }

      errMsg = null;
      notifyListeners();
    } catch (err, _) {
      errMsg =
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString();
      notifyListeners();
    }
  }



  Future<void> getProductsBySearchValue(String searchValue, String langCode, int page,{bool loadMore = false}) async {
    try {
      final _service = Services();
      if(loadMore == false) {
        isFetching = true;
      }
      isEnd = false;
      notifyListeners();
      var productData = await _service.searchProducts(
          name: searchValue,
          categoryId: null,
          tag: "",
          attribute: "",
          attributeId: "",
          page: page,
          lang: langCode,
          isBarcode: false);
      isEnd = productData.isEmpty;
      if(productData.length > 0) {
        if (page == 0 || page == 1) {
          printLog("runnnninnnnnfffffggggg");
          productsList = productData;
        } else {
          printLog(page);
          printLog("runnnninnnnnfffffggggg");
          productsList = [...productsList!, ...productData];
        }
      }
      isFetching = false;
      errMsg = null;
      notifyListeners();
    }
    catch(err, _) {
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
  void setCurrentCat(String categoryId) {
    currentSubCat = categoryId;
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

  static showList({
    String? sort,
    cateId,
    cateName,
    String? tag,
    required BuildContext context,
    List<Product?>? products,
    config,
    bool showCountdown = false,
    Duration countdownDuration = Duration.zero,
    String searchValue = "",
    bool isAppBarRequired = true,
    bool isFromSearch = false,
  }) async {
    try {
      var categoryId = cateId ?? config['category']?.toString();
      var categoryName = cateName ?? config['name'];
      final bool? onSale = config != null ? config['onSale'] : null;
      final bool? configCountdown = config != null
          ? config['showCountDown'] ?? false
          : kSaleOffProduct["ShowCountDown"] as bool?;

      String? tagId = tag ?? (config ?? {})['tag']?.toString();
      final product = Provider.of<HomeProductModel>(context, listen: false);

      if (kIsWeb || isDisplayDesktop(context)) {
        eventBus.fire(const EventCloseCustomDrawer());
      } else {
        eventBus.fire(const EventCloseNativeDrawer());
      }

      if (products != null && products.isNotEmpty) {
        product.setProductsList(products);
        return Navigator.of(
          context,
        ).push(MaterialPageRoute(
          builder: (context) => HomeProductsPage(
            products: products,
            categoryId: categoryId,
            tagId: tagId,
            onSale: onSale,
            title: (onSale ?? false) && showCountdown ? categoryName : null,
            showCountdown:
            configCountdown! && (onSale ?? false) && showCountdown,
            countdownDuration: countdownDuration,
            searchValue: searchValue,
            appBarRequired: isAppBarRequired,

          ),
        ));
      }
      product.updateTagId(tagId: config != null ? config['tag'] : null);
      product.setCurrentCat(categoryId);

      if (categoryId != null) {
        product.fetchProductsByCategory(
            categoryId: categoryId, categoryName: categoryName);
      }

      product.setProductsList(<Product>[]);
      product.getProductsList(
        tagId: tagId,
        sort: sort,
        categoryId: categoryId,
        page: 1,
        onSale: onSale,
        lang: Provider.of<AppModel>(context, listen: false).langCode,
      );

      Navigator.of(
        context,
      ).push(MaterialPageRoute(
        builder: (context) => HomeProductsPage(
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
