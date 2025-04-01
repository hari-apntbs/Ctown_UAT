import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:localstorage/localstorage.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../common/index.dart';
import '../common/styles.dart';
import '../services/index.dart';
import 'cart/cart_model.dart';
import 'category_model.dart';

class AppModel with ChangeNotifier {
  Map<String, dynamic>? appConfig;
  bool isLoading = true;
  String? message;
  bool darkTheme = kDefaultDarkTheme;
  String? _langCode = kAdvanceConfig['DefaultLanguage'] as String?;
  List<String>? categories;
  String? productListLayout;
  double? ratioProductImage;
  String? currency; //USD, VND
  String? currencyCode;
  int? smallestUnitRate;
  Map<String, dynamic> currencyRate = Map<String, dynamic>();
  bool showDemo = false;
  String? username;
  bool isInit = false;
  late Map<String, dynamic> drawer;
  Map? deeplink;
  VendorType? vendorType;
  bool offerTab = false;

  String? get langCode => _langCode;
  bool messageServed = false;
  bool isCartPressed = false;
  bool langChanged = false;

  AppModel() {
    getConfig();
    vendorType = kstoreMV.contains(serverConfig['type'])
        ? VendorType.multi
        : VendorType.single;
  }
  Future<bool> getConfig() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var defaultCurrency = kAdvanceConfig['DefaultCurrency'] as Map;

      _langCode =
          prefs.getString("language") ?? kAdvanceConfig['DefaultLanguage'] as String?;
      darkTheme = prefs.getBool("darkTheme") ?? false;
      currency = prefs.getString("currency") ?? defaultCurrency['currency'];
      currencyCode =
          prefs.getString("currencyCode") ?? defaultCurrency['currencyCode'];
      smallestUnitRate = defaultCurrency['smallestUnitRate'];
      isInit = true;

      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> changeLanguage(String? country, BuildContext context) async {
    try {
      if (country == null || country.isEmpty) {
        printLog("Invalid country value");
        return false;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      _langCode = country;
      printLog("Language set to: $_langCode");

      await prefs.setString("language", _langCode!);

      printLog("Loading app configuration...");
      await loadAppConfig(isSwitched: true);

      printLog("Loading currency...");
      await loadCurrency();

      printLog("Firing EventChangeLanguage...");
      eventBus.fire(const EventChangeLanguage());

      printLog("Fetching categories...");
      await Provider.of<CategoryModel>(context, listen: false)
          .getCategories(lang: country, sortingList: categories);

      printLog("Language change completed successfully");
      return true;
    } catch (err) {
      return false;
    }
  }

  void setPushMessageState(bool val) {
    messageServed = val;
  }

  void setLangChange(bool val) {
    langChanged = val;
  }

  Future<void> changeCurrency(String? item, BuildContext context) async {
    try {
      Provider.of<CartModel>(context, listen: false).changeCurrency(item);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      currency = item;
      await prefs.setString("currency", currency!);
      notifyListeners();
    } catch (error) {
      printLog('[_getFacebookLink] error: ${error.toString()}');
    }
  }

  Future<void> updateTheme(bool theme) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      darkTheme = theme;
      await prefs.setBool("darkTheme", theme);
      notifyListeners();
    } catch (error) {
      printLog('[_getFacebookLink] error: ${error.toString()}');
    }
  }

  void updateShowDemo(bool value) {
    showDemo = value;
    notifyListeners();
  }

  void updateUsername(String user) {
    username = user;
    notifyListeners();
  }

  void loadStreamConfig(config) {
    appConfig = config;
    productListLayout = appConfig!['Setting']['ProductListLayout'];
    isLoading = false;
    notifyListeners();
  }

  getSavedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore') ?? "";
    return jsonDecode(result);
  }

  Future<Map?> loadAppConfig({isSwitched = false}) async {
    try {
      if (!isInit) {
        await getConfig();
      }
      final LocalStorage storage = LocalStorage('builder.json');
      var config = await storage.getItem('config');
      if (config != null) {
        appConfig = config;
      } else {
        /// we only apply the http config if isUpdated = false, not using switching language
        // ignore: prefer_contains
        if (kAppConfig.indexOf('http') != -1) {
          // load on cloud config and update on air
          String path = kAppConfig;

          var store;
          String? storeId = "";
          try {
            store = await getSavedStore();

            storeId = langCode == "en"
                ? store["store_en"]["id"]
                : store["store_ar"]["id"];
            // storeId = "58";
          } catch (e) {
            printLog(e);
            storeId = "";
          }

          if (path.contains('.php')) {
            path = path.substring(0, path.lastIndexOf('/'));
            path += '/mobilebannersection$langCode.php?store_id=$storeId';
          }
          printLog(Uri.encodeFull(path));
          final appJson = await http.get(Uri.parse(Uri.encodeFull(path)),
              headers: {"Accept": "application/json"});
          appConfig =
              convert.jsonDecode(convert.utf8.decode(appJson.bodyBytes));

          printLog("0000000000000000000000");
          printLog("app config added");
          printLog(appConfig.toString().contains("promotionImage"));
        } else {
          // load local config
          String path = "lib/config/config_$langCode.json";
          try {
            final appJson = await rootBundle.loadString(path);
            appConfig = convert.jsonDecode(appJson);
          } catch (e) {
            final appJson = await rootBundle.loadString(kAppConfig);
            appConfig = convert.jsonDecode(appJson);
          }
        }
      }

      /// Load Product ratio from config file
      productListLayout = appConfig!['Setting']['ProductListLayout'];
      ratioProductImage = appConfig!['Setting']['ratioProductImage'] ??
          kAdvanceConfig['RatioProductImage'] as double?;

      drawer = appConfig!['Drawer'] != null
          ? Map<String, dynamic>.from(appConfig!['Drawer'])
          : kDefaultDrawer;

      /// Load categories config for the Tabbar menu
      /// User to sort the category Setting
      var categoryTab = appConfig!['TabBar']
          .firstWhere((e) => e['layout'] == 'category', orElse: () => {});
      if (categoryTab['categories'] != null) {
        categories = List<String>.from(categoryTab['categories']);
      }

      /// apply App Caching if isCaching is enable
      if (!kIsWeb) {
        await Services().widget?.onLoadedAppConfig(langCode!, (configCache) {
          appConfig = configCache;
        });
      }
      isLoading = false;

      printLog('[Debug] Finish Load AppConfig');

      notifyListeners();

      return appConfig;
    } catch (err, trace) {
      printLog(trace);
      isLoading = false;
      message = err.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> loadCurrency() async {
    /// Load the Rate for Product Currency
    final rates = await Services().getCurrencyRate();
    if (rates != null) {
      currencyRate = rates;
    }
  }

  void updateProductListLayout(layout) {
    productListLayout = layout;
    notifyListeners();
  }

  void cartPressed(bool val) {
    isCartPressed = val;
    notifyListeners();
  }

  void updateTab(val) {
    offerTab = val;
    notifyListeners();
  }
}
