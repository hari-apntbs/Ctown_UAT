import 'package:flutter/material.dart';

import '../entities/product.dart';
import '../entities/product_variation.dart';
import 'mixin/address_mixin.dart';
import 'mixin/cart_mixin.dart';
import 'mixin/coupon_mixin.dart';
import 'mixin/currency_mixin.dart';
import 'mixin/local_mixin.dart';
import 'mixin/magento_mixin.dart';
import 'mixin/opencart_mixin.dart';
import 'mixin/shopify_mixin.dart';
import 'mixin/vendor_mixin.dart';

abstract class CartModel
    with
        CartMixin,
        AddressMixin,
        LocalMixin,
        CouponMixin,
        CurrencyMixin,
        MagentoMixin,
        ShopifyMixin,
        OpencartMixin,
        VendorMixin,
        ChangeNotifier {
  double getSubTotal();

  double getItemTotal(
      {ProductVariation? productVariation, Product? product, int quantity = 1});

  double getTotal();

  Future updateQuantity(Product product, String? key, int quantity, {context});

  removeItemFromCart(String? key, BuildContext context);

  Product getProductById(String id);

  ProductVariation getProductVariationById(String? key);

  void clearCart();

  void setOrderNotes(String note);

  void initData();

  void addOutOfStock(String? id);

  void refreshCart(bool val);

  String addProductToCart({
    context,
    Product? product,
    int? quantity = 1,
    ProductVariation? variation,
    Function? notify,
    isSaveLocal = false,
    Map<String, dynamic>? options,
  });

  String addProductToCartNew({
    context,
    Product? product,
    int quantity = 1,
    ProductVariation? variation,
    Function? notify,
    isSaveLocal = false,
    Map<String, dynamic>? options,
  });
  void setRewardTotal(double total);

  void removeOutofStockItem(String? id);

  bool isLoadingProduct(String? productId);

  void setLoadingProduct(String? productId, bool isLoading);
}
