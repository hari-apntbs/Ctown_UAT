import 'dart:convert' as convert;
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:quiver/strings.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:transparent_image/transparent_image.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validated/validated.dart' as validate;

import '../common/constants.dart';
import '../models/index.dart' show Product, ProductModel;
import '../screens/index.dart' show ProductDetailScreen;
import '../services/index.dart';
import '../tabbar.dart';
// import '../widgets/blog/banner/blog_list_view.dart';
// import '../widgets/blog/banner/blog_view.dart';
import '../widgets/common/skeleton.dart';
import '../widgets/common/webview.dart';
import 'config.dart';
import 'constants.dart';

enum kSize { small, medium, large }

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor != null
        ? hexColor.toUpperCase().replaceAll("#", "")
        : 'FFFFFF';
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class Tools {
  static double? formatDouble(dynamic value) => value * 1.0;

  static formatDateString(String date) {
    DateTime timeFormat = DateTime.parse(date);
    final timeDif = DateTime.now().difference(timeFormat);
    return timeago.format(DateTime.now().subtract(timeDif), locale: 'en');
  }

  static prestashopImage(String url, [kSize? size = kSize.medium]) {
    switch (size) {
      case kSize.large:
        return '$url/large_default';
      case kSize.small:
        return '$url/small_default';
      default: // kSize.medium
        return '$url/medium_default';
    }
  }

  static String formatImage(String url, [kSize? size = kSize.medium]) {
    if (serverConfig['type'] == 'presta') {
      return prestashopImage(url, size);
    }

    if (Config().isCacheImage ?? kAdvanceConfig['kIsResizeImage'] as bool) {
      String pathWithoutExt = p.withoutExtension(url);
      String ext = p.extension(url);
      String imageURL = url;

      if (ext == ".jpeg") {
        imageURL = url;
      } else {
        switch (size) {
          case kSize.large:
            imageURL = '$pathWithoutExt-large$ext';
            break;
          case kSize.small:
            imageURL = '$pathWithoutExt-small$ext';
            break;
          default: // kSize.medium:e
            imageURL = '$pathWithoutExt-medium$ext';
            break;
        }
      }

      return imageURL;
    } else {
      return url;
    }
  }

  static NetworkImage networkImage(String url, [kSize size = kSize.medium]) {
    return NetworkImage(formatImage(url, size));
  }

  /// Smart image function to load image cache and check empty URL to return empty box
  /// Only apply for the product image resize with (small, medium, large)
  static Widget image({
    String? url,
    kSize? size,
    double? width,
    double? height,
    BoxFit? fit,
    String? tag,
    double offset = 0.0,
    bool isResize = false,
    isVideo = false,
    hidePlaceHolder = false,
  }) {
    if (height == null && width == null) {
      width = 200;
    }

    if (url == null || url == '') {
      return Skeleton(
        width: width,
        height: height ?? width! * 1.2,
      );
    }

    if (isVideo) {
      return Stack(
        children: <Widget>[
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(color: Colors.black12.withOpacity(1)),
            child: ExtendedImage.network(
              isResize ? formatImage(url, size) : url,
              width: width,
              height: height ?? width! * 1.2,
              fit: fit,
              cache: true,
              enableLoadState: false,
              alignment: Alignment(
                  (offset >= -1 && offset <= 1)
                      ? offset
                      : (offset > 0)
                          ? 1.0
                          : -1.0,
                  0.0),
            ),
          ),
          Positioned.fill(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white70.withOpacity(0.5),
              size: width == null ? 30 : width / 1.7,
            ),
          ),
        ],
      );
    }

    if (kIsWeb) {
      return FadeInImage.memoryNetwork(
        image: isResize ? formatImage(url, size) : url,
        fit: fit,
        width: width,
        height: height,
        placeholder: kTransparentImage,
      );
    }

    return ExtendedImage.network(
      isResize ? formatImage(url, size) : url,
      width: width,
      height: height,
      fit: fit,
      cache: true,
      enableLoadState: false,
      alignment: Alignment(
        (offset >= -1 && offset <= 1)
            ? offset
            : (offset > 0)
                ? 1.0
                : -1.0,
        0.0,
      ),
      loadStateChanged: (ExtendedImageState state) {
        Widget? widget;
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            widget = hidePlaceHolder
                ? const SizedBox()
                : Skeleton(
                    width: width ?? 100,
                    height: height ?? 140,
                  );
            break;
          case LoadState.completed:
            widget = ExtendedRawImage(
              image: state.extendedImageInfo?.image,
              width: width,
              height: height,
              fit: fit,
            );
            break;
          case LoadState.failed:
            widget = Container(
              width: width,
              height: height ?? width! * 1.2,
              color: const Color(kEmptyColor),
            );
            break;
        }
        return widget;
      },
    );
  }

  static String? getVariantPriceProductValue(
    product,
    Map<String, dynamic> rates,
    String currency, {
    bool? onSale,
  }) {
    String? price = onSale == true
        ? (isNotBlank(product.salePrice) ? product.salePrice : product.price)
        : product.price;
    return getCurrencyFormatted(price, rates, currency: currency);
  }

  static String? getPriceProductValue(product, String currency, {bool? onSale}) {
    try {
      String? price = onSale == true
          ? (isNotBlank(product.salePrice)
              ? product.salePrice ?? '0'
              : product.price)
          : (isNotBlank(product.regularPrice)
              ? product.regularPrice ?? '0'
              : product.price);
      return price;
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
      return '';
    }
  }

  static String? getPriceProduct(
      product, Map<String, dynamic> rates, String currency,
      {bool? onSale}) {
    String? price = getPriceProductValue(product, currency, onSale: onSale);
    return getCurrencyFormatted(price, rates, currency: currency);
  }

  static String? getCurrencyFormatted(price, Map<String, dynamic> rates,
      {currency}) {
    Map<String, dynamic>? defaultCurrency = kAdvanceConfig['DefaultCurrency'] as Map<String, dynamic>?;
    List currencies = kAdvanceConfig["Currencies"] as List<dynamic>? ?? [];
    if (currency != null && currencies.isNotEmpty) {
      currencies.forEach((item) {
        if ((item as Map)["currency"] == currency) {
          defaultCurrency = item as Map<String, dynamic>?;
        }
      });
    }

    if (rates != null && rates[defaultCurrency!["currency"]] != null) {
      price =
          getPriceValueByCurrency(price, defaultCurrency!["currency"], rates);
    }

    final formatCurrency = NumberFormat.currency(
        symbol: "", decimalDigits: defaultCurrency!['decimalDigits']);
    try {
      String number = "";
      if (price is String) {
        number =
            formatCurrency.format(price.isNotEmpty ? double.parse(price) : 0);
      } else {
        number = formatCurrency.format(price);
      }
      return defaultCurrency!['symbolBeforeTheNumber']
          ? defaultCurrency!['symbol'] + number
          : number + defaultCurrency!['symbol'];
    } catch (err) {
      printLog('getCurrencyFormatted $err');
      return defaultCurrency!['symbolBeforeTheNumber']
          ? defaultCurrency!['symbol'] + formatCurrency.format(0)
          : formatCurrency.format(0) + defaultCurrency!['symbol'];
    }
  }

  static double getPriceValueByCurrency(
      price, String? currency, Map<String, dynamic> rates) {
    double? rate = rates[currency] != null ? rates[currency] : 1.0;

    if (price == '' || price == null) {
      return 0;
    }
    return double.parse(price.toString()) * rate!;
  }

  /// check tablet screen
  static bool isTablet(MediaQueryData query) {
    if (Config().isBuilder) {
      return false;
    }

    if (kIsWeb) {
      return true;
    }

    if (UniversalPlatform.isWindows || UniversalPlatform.isMacOS) {
      return false;
    }

    var size = query.size;
    var diagonal =
        sqrt((size.width * size.width) + (size.height * size.height));
    var isTablet = diagonal > 1100.0;
    return isTablet;
  }

  /// cache avatar for the chat
  static getCachedAvatar(String avatarUrl) {
    return CachedNetworkImage(
      imageUrl: avatarUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }

  static Future<List<dynamic>> loadStatesByCountry(String country) async {
    try {
      // load local config
      String path = "lib/config/states/state_${country.toLowerCase()}.json";
      final appJson = await rootBundle.loadString(path);
      return List<dynamic>.from(convert.jsonDecode(appJson));
    } catch (e) {
      return [];
    }
  }

  ///------------ store LISTING SECTION ------------///
  static getValueByKey(Map<String, dynamic> json, String key) {
    if (key == null) return null;
    try {
      List keys = key.split(".");
      Map<String, dynamic>? data = Map<String, dynamic>.from(json);
      if (keys[0] == '_links') {
        var links = json['listing_data']['_links'] ?? [];
        for (var item in links) {
          if (item['network'] == keys[keys.length - 1]) return item['url'];
        }
      }
      for (int i = 0; i < keys.length - 1; i++) {
        if (data![keys[i]] is Map) {
          data = data[keys[i]];
        } else {
          return null;
        }
      }
      if (data![keys[keys.length - 1]].toString().isEmpty) return null;
      return data[keys[keys.length - 1]];
    } catch (e) {
      printLog(e.toString());
      return 'Error when mapping $key';
    }
  }

  ///------------ store LISTING SECTION ------------///
}

class Validator {
  static String? validateEmail(String value) {
    try {
      validate.isEmail(value);
    } catch (e) {
      return 'The E-mail Address must be a valid email address.';
    }

    return null;
  }
}

class Videos {
  static String? getVideoLink(String content) {
    if (_getYoutubeLink(content) != null) {
      return _getYoutubeLink(content);
    } else if (_getFacebookLink(content) != null) {
      return _getFacebookLink(content);
    } else {
      return _getVimeoLink(content);
    }
  }

  static String? _getYoutubeLink(String content) {
    final regExp = RegExp(
        "https://www.youtube.com/((v|embed))\/?[a-zA-Z0-9_-]+",
        multiLine: true,
        caseSensitive: false);

    String? youtubeUrl;

    try {
      if (content.isNotEmpty) {
        Iterable<RegExpMatch> matches = regExp.allMatches(content);
        if (matches.isNotEmpty) {
          youtubeUrl = matches.first.group(0) ?? '';
        }
      }
    } catch (error) {
//      printLog('[_getYoutubeLink] ${error.toString()}');
    }
    return youtubeUrl;
  }

  static String? _getFacebookLink(String content) {
    final regExp = RegExp(
        "https://www.facebook.com\/[a-zA-Z0-9\.]+\/videos\/(?:[a-zA-Z0-9\.]+\/)?([0-9]+)",
        multiLine: true,
        caseSensitive: false);

    String? facebookVideoId;
    String? facebookUrl;
    try {
      if (content.isNotEmpty) {
        Iterable<RegExpMatch> matches = regExp.allMatches(content);
        if (matches.isNotEmpty) {
          facebookVideoId = matches.first.group(1);
          if (facebookVideoId != null) {
            facebookUrl =
                'https://www.facebook.com/video/embed?video_id=$facebookVideoId';
          }
        }
      }
    } catch (error) {
      printLog(error);
    }
    return facebookUrl;
  }

  static String? _getVimeoLink(String content) {
    final regExp = RegExp("https://player.vimeo.com/((v|video))\/?[0-9]+",
        multiLine: true, caseSensitive: false);

    String? vimeoUrl;

    try {
      if (content.isNotEmpty) {
        Iterable<RegExpMatch> matches = regExp.allMatches(content);
        if (matches.isNotEmpty) {
          vimeoUrl = matches.first.group(0);
        }
      }
    } catch (error) {
      printLog(error);
    }
    return vimeoUrl;
  }
}

class Utils {
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static bool isListingTheme() {
    if (serverConfig['type'] == 'listeo' ||
        serverConfig['type'] == 'listpro' ||
        serverConfig['type'] == 'mylisting') {
      return true;
    }
    return false;
  }

  // static void setStatusBarWhiteForeground(bool active) {
  //   if (!UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
  //     return;
  //   }
  //
  //   FlutterStatusbarcolor.setStatusBarWhiteForeground(active);
  // }

  static Future<dynamic> parseJsonFromAssets(String assetsPath) async {
    return rootBundle.loadString(assetsPath).then(convert.jsonDecode);
  }

  static Function getLanguagesList = getLanguages;

  static onTapNavigateOptions(
      {BuildContext? context, required Map config, List<Product>? products}) async {
    /// support to show the product detail
    if (config["product"] != null) {
      /// for pre-load the product detail
      final Services _service = Services();
      Product? product = await _service.getProduct(config["product"]);

      return Navigator.push(
          context!,
          MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                ProductDetailScreen(product: product),
            fullscreenDialog: true,
          ));
    }
    if (config["tab"] != null) {
      return MainTabControlDelegate.getInstance().changeTab(config["tab"]);
    }
    if (config["screen"] != null) {
      return Navigator.of(context!).pushNamed(config["screen"]);
    }

    /// Launch the URL from external
    if (config['url_launch'] != null) {
      await launch(config["url_launch"]);
    }

    // /// support to show blog detail
    // if (config['blog'] != null) {
    //   return Navigator.push(
    //     context,
    //     MaterialPageRoute<void>(
    //       builder: (BuildContext context) =>
    //           BlogView(id: config['blog'].toString()),
    //       fullscreenDialog: true,
    //     ),
    //   );
    // }

    // /// support to show blog category
    // if (config['blog_category'] != null) {
    //   return Navigator.push(
    //     context,
    //     MaterialPageRoute<void>(
    //       builder: (BuildContext context) =>
    //           BlogListView(id: config['blog_category'].toString()),
    //       fullscreenDialog: true,
    //     ),
    //   );
    // }

    /// support to show the post detail
    if (config["url"] != null) {
      await Navigator.push(
        context!,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).primaryColorLight,
              leading: GestureDetector(
                child: const Icon(Icons.arrow_back_ios),
                onTap: () => Navigator.pop(context),
              ),
            ),
            body: InAppWebView(
              appBarRequire: false,
              url: config["url"],
            ),
          ),
        ),
      );
    } else {
      /// For static image
      if (config['category'] == null &&
          config['tag'] == null &&
          products == null) {
        return;
      }

      /// Default navigate to show the list products
      ProductModel.showList(
          context: context!, config: config, products: products);
    }
  }
}
