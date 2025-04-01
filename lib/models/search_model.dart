import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app.dart';
import '../common/constants.dart';
import '../services/index.dart';
import 'app_model.dart';
import 'entities/product.dart';

class SearchModel extends ChangeNotifier {
  // final String langCode;

  SearchModel() {
    getKeywords();
    _subLanguageChange = eventBus.on<EventChangeLanguage>().listen((event) {
      String? oldName = _currentName;
      _currentName = '';
      loadProduct(name: oldName);
    });
  }

  @override
  dispose() {
    _subLanguageChange?.cancel();
    super.dispose();
  }

  String? get langCode => Provider.of<AppModel>(App.navigatorKey.currentContext!, listen: false).langCode;

  List<String> keywords = [];
  List<Product>? _products = [];
  int _page = 1;
  bool _isEnd = false;
  String? _currentName = '';
  late CancelableOperation _cancelLoadProduct;
  bool? _isBarcode = false;

//  bool _isLoading = false;

  var category = '';
  var tag = '';
  var attribute = '';
  var attribute_term = '';

  bool isLoading = false;
  String? errMsg;

  bool get isEnd => _isEnd;

  StreamSubscription? _subLanguageChange;

  List<Product>? get products => _products;

  Future<void> loadProduct({String? name, bool hasFilter = false, bool? isBarcode = false}) async {
    if (name != _currentName || hasFilter) {
      _currentName = name;
      _page = 1;
      _products = null;
      _isEnd = false;
      _isBarcode = isBarcode;
    } else {
      _page++;
    }

    if (!hasFilter) {
      if (_isEnd) return;

      // if (isLoading) return;
    }

    // Cancel a previous product search request when a new request is created
    if (isLoading) {
      await _cancelLoadProduct.cancel();
    }

    isLoading = true;
    notifyListeners();

    List<Product> newProducts;

    _cancelLoadProduct = CancelableOperation.fromFuture(_searchProducts(
      name: name,
      page: _page,
      isBarcode: _isBarcode,
    ));

    newProducts = await _cancelLoadProduct.value;

    if (newProducts == null || newProducts.isEmpty) {
      if (products?.isEmpty ?? true) {
        _products = <Product>[];
      }
      isLoading = false;
      _isEnd = true;
      notifyListeners();
      return;
    }

    if (products == null) _products = <Product>[];

    products!.addAll(newProducts);

    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _page = 1;
    _products = <Product>[];
    await loadProduct();
  }

  void refreshProduct(List<Product> product) {
    _products = product;
    notifyListeners();
  }

  void searchByFilter(
    Map<String, List<dynamic>> searchFilterResult,
    String searchText,
  ) {
    if (searchFilterResult.isEmpty) clearFilter();

    searchFilterResult.forEach((key, value) {
      switch (key) {
        case 'categories':
          category = value.isNotEmpty ? '${value.first.id}' : '';
          break;
        case 'tags':
          tag = value.isNotEmpty ? '${value.first.id}' : '';
          break;
        default:
          attribute = key;
          attribute_term = value.isNotEmpty ? '${value.first.id}' : '';
      }
    });

    loadProduct(
      name: searchText.isEmpty ? '' : searchText,
      hasFilter: true,
    );
  }

  void clearFilter() {
    category = '';
    tag = '';
    attribute = '';
    attribute_term = '';
  }

  Future<List<Product>> _searchProducts({String? name, int? page, bool? isBarcode}) async {
    try {
      final data = await Services().searchProducts(
        name: name,
        categoryId: category.isNotEmpty ? category : null,
        tag: tag,
        attribute: attribute,
        attributeId: attribute_term,
        page: page,
        lang: langCode,
        isBarcode: isBarcode,
      );

      if (data.isNotEmpty && page == 1 && name!.isNotEmpty) {
        int index = keywords.indexOf(name);
        if (index > -1) {
          keywords.removeAt(index);
        }
        keywords.insert(0, name);
        await saveKeywords(keywords);
      }
      errMsg = null;
      return data;
    } catch (err) {
      isLoading = false;
      errMsg = "⚠️ " + err.toString();
      notifyListeners();
      return <Product>[];
    }
  }

  void clearKeywords() {
    keywords = [];
    saveKeywords(keywords);
    notifyListeners();
  }

  Future<void> saveKeywords(List<String> keywords) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(kLocalKey["recentSearches"]!, keywords);
    } catch (_) {
      printLog(_.toString());
    }
  }

  Future<void> getKeywords() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String>? list = prefs.getStringList(kLocalKey["recentSearches"]!);
      if (list != null && list.isNotEmpty) {
        keywords = list;
        notifyListeners();
      }
    } catch (_) {}
  }

  // searchListingProducts({String name, page, bool isBarcode}) async {
  //   _products.clear();
  //   try {
  //     isLoading = true;
  //     notifyListeners();
  //     _products = await Services().searchProducts(name: name, page: page, isBarcode: isBarcode);

  //     isLoading = false;
  //     errMsg = null;
  //     notifyListeners();
  //   } catch (err) {
  //     isLoading = false;
  //     errMsg =
  //         "There is an issue with the app during request the data, please contact admin for fixing the issues " +
  //             err.toString();
  //     notifyListeners();
  //   }
  //   return _products;
  // }
}
