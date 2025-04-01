import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_platform/universal_platform.dart';

/// enable network proxy
const debugNetworkProxy = false;

/// some constants Local Key
const kLocalKey = {
  "userInfo": "userInfo",
  "shippingAddress": "shippingAddress",
  "recentSearches": "recentSearches",
  "wishlist": "wishlist",
  "home": "home",
  "cart": "cart",
  "countries": "countries",
  "shopify": "shopify" // only handle for shopify
};

/// Logging config
const kLOG_TAG = "[Ctown Jordan]";
const kLOG_ENABLE = true;

void printLog(dynamic data) {
  if (kLOG_ENABLE) {
    /// "y-m-d h:min:sec.msZ"
    final String now = DateTime.now().toUtc().toString().split(' ').last;
    debugPrint("[$now]$kLOG_TAG${data.toString()}");
  }
}

/// check if the environment is web
final bool kIsWeb = UniversalPlatform.isWeb;
final bool isIos = UniversalPlatform.isIOS;
final bool isAndroid = UniversalPlatform.isAndroid;
final bool isMacOS = UniversalPlatform.isMacOS;
final bool isWindow = UniversalPlatform.isWindows;
final bool isFuchsia = UniversalPlatform.isFuchsia;
final bool isMobile = UniversalPlatform.isIOS || UniversalPlatform.isAndroid;

final EventBus eventBus = EventBus();

/// constant for Magento payment
const kMagentoPayments = [
  "HyperPay_Amex",
  "HyperPay_ApplePay",
  "HyperPay_Mada",
  "HyperPay_Master",
  "HyperPay_PayPal",
  "HyperPay_SadadNcb",
  "HyperPay_Visa",
  "HyperPay_SadadPayware"
];

const ApiPageSize = 20;

///-----A&H Market LISTING-----///
enum BookStatus { booked, unavailable, waiting, confirmed, cancelled, error }
