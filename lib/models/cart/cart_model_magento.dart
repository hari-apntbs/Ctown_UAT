import 'package:ctown/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:localstorage/localstorage.dart';

import '../../common/config.dart';
import '../../common/constants/general.dart';
import '../../common/tools.dart';
import '../../frameworks/magento/services/magento.dart';
import '../../services/index.dart';
import '../entities/product.dart';
import '../entities/product_variation.dart';
import 'cart_base.dart';
import 'mixin/address_mixin.dart';
import 'mixin/cart_mixin.dart';
import 'mixin/coupon_mixin.dart';
import 'mixin/currency_mixin.dart';
import 'mixin/local_mixin.dart';
import 'mixin/magento_mixin.dart';
import 'mixin/opencart_mixin.dart';
import 'mixin/shopify_mixin.dart';
import 'mixin/vendor_mixin.dart';

class CartModelMagento
    with
        ChangeNotifier,
        CartMixin,
        CouponMixin,
        CurrencyMixin,
        AddressMixin,
        LocalMixin,
        ShopifyMixin,
        OpencartMixin,
        VendorMixin,
        MagentoMixin
    implements CartModel {
  static final CartModelMagento _instance = CartModelMagento._internal();

  factory CartModelMagento() => _instance;

  CartModelMagento._internal();

  Future<void> initData() async {
    await getShippingAddress("en");
    //await getCartInLocal();
    await getCurrency();
  }


  double getSubTotal() {
    return productsInCart.keys.fold(0.0, (sum, key) {
      if (productVariationInCart[key] != null &&
          productVariationInCart[key]!.price != null &&
          productVariationInCart[key]!.price!.isNotEmpty) {
        return sum +
            double.parse(productVariationInCart[key]!.onSale==true?productVariationInCart[key]!.salePrice!:productVariationInCart[key]!.price!) *
                productsInCart[key]!;
      } else {
        String productId = Product.cleanProductID(key);

        String price =
            Tools.getPriceProductValue(item[productId], currency, onSale: true)!;
        if (price.isNotEmpty) {
          return sum + double.parse(price) * productsInCart[key]!;
        }
        return sum;
      }
    });
  }

  /// Magento: get item total
  double getItemTotal({
    ProductVariation? productVariation,
    Product? product,
    int quantity = 1,
  }) {
    double subtotal = double.parse(product!.price!) * quantity;
    if (discountAmount > 0) {
      return subtotal - discountAmount;
    } else {
      if (couponObj != null) {
        if (couponObj!.discountType == "percent") {
          return subtotal - subtotal * couponObj!.amount! / 100;
        } else {
          return subtotal - (couponObj!.amount! * quantity);
        }
      } else {
        return subtotal;
      }
    }
  }

  /// Magento: get coupon
  String getCoupon() {
    if (discountAmount > 0) {
      return "-" +
          Tools.getCurrencyFormatted(discountAmount, currencyRates,
              currency: currency)!;
    } else {
      if (couponObj != null) {
        if (couponObj!.discountType == "percent") {
          return "-${couponObj!.amount}%";
        } else {
          return "-" +
              Tools.getCurrencyFormatted(
                  couponObj!.amount! * totalCartQuantity, currencyRates,
                  currency: currency)!;
        }
      } else {
        return "";
      }
    }
  }

  /// Magento: get total
  double getTotal() {
    double subtotal = getSubTotal();

    if (discountAmount > 0) {
      subtotal -= discountAmount;
    } else {
      if (couponObj != null) {
        if (couponObj!.discountType == "percent") {
          subtotal -= subtotal * couponObj!.amount! / 100;
        } else {
          subtotal -= (couponObj!.amount! * totalCartQuantity);
        }
      }
    }
    if (kPaymentConfig['EnableShipping'] as bool) {
      subtotal += getShippingCost()!;
    }
    return subtotal;
  }

  /// Magento: get coupon cost
  double getCouponCost() {
    if (discountAmount > 0) {
      return discountAmount;
    } else {
      double subtotal = getSubTotal();
      if (couponObj != null) {
        if (couponObj!.discountType == "percent") {
          return subtotal * couponObj!.amount! / 100;
        } else {
          return couponObj!.amount! * totalCartQuantity;
        }
      } else {
        return 0.0;
      }
    }
  }

  Future<String> updateQuantity(Product product, String? key, int quantity, {context}) async {
    String message = '';
    int total = quantity;
    ProductVariation? variation;

    if (key!.contains('-')) {
      variation = getProductVariationById(key);
    }
    int? stockQuantity =
        variation == null ? product.stockQuantity : variation.stockQuantity;

    if (product.manageStock == null || !product.manageStock!) {
      productsInCart[key] = total;
    } else if (total <= stockQuantity!) {
      if (product.minQuantity == null && product.maxQuantity == null) {
        productsInCart[key] = total;
      } else if (product.minQuantity != null && product.maxQuantity == null) {
        total < product.minQuantity!
            ? message = 'Minimum quantity is ${product.minQuantity}'
            : productsInCart[key] = total;
      } else if (product.minQuantity == null && product.maxQuantity != null) {
        total > product.maxQuantity!
            ? message =
                'You can only purchase ${product.maxQuantity} for this product'
            : productsInCart[key] = total;
      } else if (product.minQuantity != null && product.maxQuantity != null) {
        if (total >= product.minQuantity! && total <= product.maxQuantity!) {
          productsInCart[key] = total;
        } else {
          if (total < product.minQuantity!) {
            message = 'Minimum quantity is ${product.minQuantity}';
          }
          if (total > product.maxQuantity!) {
            message =
                'You can only purchase ${product.maxQuantity} for this product';
          }
        }
      }
    } else {
      message = 'Currently we only have $stockQuantity of this product';
    }
    if (message.isEmpty) {
      //updateQuantityCartLocal(key: key, quantity: quantity);
      //var cartModel = Provider
      final LocalStorage storage = LocalStorage('store');
      final userJson = await storage.getItem(kLocalKey["userInfo"]!);

      MagentoApi().addItemsToCart( Provider.of<AppModel>(context, listen: false).langCode,
          _instance, key, userJson["cookie"], product.sku, quantity);
      notifyListeners();
    }
    return message;
  }

  // Removes an item from the cart.
  void removeItemFromCart(String? key, BuildContext context) async {
    final LocalStorage storage = LocalStorage('store');
    final userJson = await storage.getItem(kLocalKey["userInfo"]!);
    final lang = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
    if (productsInCart.containsKey(key)) {
      //removeProductLocal(key);
      //Services().deleteItemFromCart(productSkuInCart[key], userJson["cookie"]);
      await Services().deleteItemFromCart([]..add(key), userJson["cookie"], lang);
      productsInCart.remove(key);
      productVariationInCart.remove(key);
      productSkuInCart.remove(key);
    }
    notifyListeners();
  }

  void removeOutofStockItem(String? keyVal) async {
    String removeKey = "";
    productsInCart.forEach((key, value) {
      if((key?.contains(keyVal!))!) {
        removeKey = key ?? "";
      }
    });
    if (productsInCart.containsKey(removeKey)) {
      productsInCart.remove(removeKey);
      productVariationInCart.remove(removeKey);
      productSkuInCart.remove(removeKey);
    }
    notifyListeners();
  }

  void refreshCart(bool value) {
    refreshing = value;
    notifyListeners();
  }
  // Removes everything from the cart.
  void clearCart() {
    //clearCartLocal();
    //final LocalStorage storage = LocalStorage('store');
    //final userJson = storage.getItem(kLocalKey["userInfo"]);

    // productsInCart.keys.forEach((key) {
    //   String productId = Product.cleanProductID(key);
    //   printLog("productId");
    //   printLog(productId);
    //   Services().deleteItemFromCart(key, userJson["cookie"]);
    // });
    //Services().deleteItemFromCart(productsInCart.keys.toList(), userJson["cookie"]);
    productsInCart.clear();
    item.clear();
    productVariationInCart.clear();
    productSkuInCart.clear();
    shippingMethod = null;
    paymentMethod = null;
    cartId = null;
    resetCoupon();
    notes = null;
    discountAmount = 0.0;
    notifyListeners();
  }

  void setOrderNotes(String note) {
    notes = note;
    notifyListeners();
  }

  Future getCurrency() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      currency = prefs.getString("currency") ??
          (kAdvanceConfig['DefaultCurrency'] as Map)['currency'];
    } catch (e) {
      currency = (kAdvanceConfig['DefaultCurrency'] as Map)['currency'];
    }
  }

  String addProductToCart({
    context,
    Product? product,
    int? quantity = 1,
    ProductVariation? variation,
    Function? notify,
    isSaveLocal = false,
    Map<String, dynamic>? options,
  }) {
    var key = "${product?.id}";
    if (variation != null) {
      if (variation.id != null) {
        key += "-${variation.id}";
      }
      if (options != null && options.keys != null) {
        for (var option in options.keys) {
          key += "-" + option + options[option];
        }
      }
    }

    // int total = !productsInCart.containsKey(key)
    //     ? quantity
    //     : (productsInCart[key] + quantity);
    if (quantity! <= 0) {
      removeItemFromCart(key, context);
      return "";
    }

    String message = super.addProductToCart(
      product: product!,
      quantity: quantity,
      variation: variation,
      isSaveLocal: isSaveLocal,
      notify: notifyListeners,
    );

    var key2 = "${product.id}";
    if (variation != null) {
      if (variation.id != null) {
        key2 += "-${variation.id}";
      }
      for (var attribute in variation.attributes) {
        if (attribute.id == null) {
          key2 += "-" + attribute.name! + attribute.option!;
        }
      }
    }
    productSkuInCart[key2] = variation != null ? variation.sku : product.sku;
    return message;
  }

  @override
  void setRewardTotal(double total) {
    rewardTotal = total;
    notifyListeners();
  }

  String addProductToCartNew({
    context,
    Product? product,
    int quantity = 1,
    ProductVariation? variation,
    Function? notify,
    isSaveLocal = false,
    Map<String, dynamic>? options,
  }) {
    // var key = "${product.id}";
    // if (variation != null) {
    //   if (variation.id != null) {
    //     key += "-${variation.id}";
    //   }
    //   if (options != null && options.keys != null) {
    //     for (var option in options.keys) {
    //       key += "-" + option + options[option];
    //     }
    //   }
    // }

    // // int total = !productsInCart.containsKey(key)
    // //     ? quantity
    // //     : (productsInCart[key] + quantity);
    // if (quantity <= 0) {
    //   removeItemFromCart(key);
    //   return "";
    // }

    String message = super.addProductToCart(
      product: product!,
      quantity: quantity,
      variation: variation,
      isSaveLocal: isSaveLocal,
      notify: notifyListeners,
    );

    var key2 = "${product.id}";
    if (variation != null) {
      if (variation.id != null) {
        key2 += "-${variation.id}";
      }
      for (var attribute in variation.attributes) {
        if (attribute.id == null) {
          key2 += "-" + attribute.name! + attribute.option!;
        }
      }
    }
    productSkuInCart[key2] = variation != null ? variation.sku : product.sku;
    return message;
  }

  void addOutOfStock(String? id) {
    outOfStockItems[id!] = "out of stock";
  }

  bool isLoadingProduct(String? productId) {
    return loadingProducts[productId] ?? false;
  }

  void setLoadingProduct(String? productId, bool isLoading) {
    if(productId != null) {
      loadingProducts[productId] = isLoading;
      notifyListeners();
    }
  }
}
