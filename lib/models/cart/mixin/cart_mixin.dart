import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../../common/tools.dart';
import '../../entities/payment_method.dart';
import '../../entities/product.dart';
import '../../entities/product_variation.dart';
import '../../entities/user.dart';
import '../../index.dart';

mixin CartMixin {
  User? user;
  Address? address;
  double taxesTotal = 0;
  double rewardTotal = 0;

  PaymentMethod? paymentMethod;

  String? notes;
  String? currency;
  Map<String, dynamic>? currencyRates;

  final Map<String?, Product> item = {};

  final Map<String, ProductVariation?> productVariationInCart = {};

  // The IDs and quantities of products currently in the cart.
  final Map<String?, int> productsInCart = {};

  // The IDs and meta_data of products currently in the cart for woo commerce
  final Map<String, dynamic> productsMetaDataInCart = {};

  final Map<String, dynamic> outOfStockItems = {};


  ///cartId as fetched from database
  int? cartId;

  int get totalCartQuantity => productsInCart.values.fold(0, (v, e,) => v + e);

  bool refreshing = false;

  final Map<String, bool> loadingProducts = {};



  bool _hasProductVariation(String? id) =>
      productVariationInCart[id] != null &&
      productVariationInCart[id]!.price != null &&
      productVariationInCart[id]!.price!.isNotEmpty;

  double getProductPrice(id) {
    if (_hasProductVariation(id)) {
      return double.parse(productVariationInCart[id]!.onSale==true?productVariationInCart[id]!.salePrice!:productVariationInCart[id]!.price!) * productsInCart[id]!;
    } else {
      String productId = Product.cleanProductID(id);

      String price = Tools.getPriceProductValue(item[productId], currency, onSale: true)!;
      if (price.isNotEmpty) {
        return double.parse(price) * productsInCart[id]!;
      }
      return 0.0;
    }
  }

  double getSubTotal() {
    return productsInCart.keys.fold(0.0, (sum, id) {
      return sum + getProductPrice(id);
    });
  }

  void setPaymentMethod(data) {
    paymentMethod = data;
  }

  // Returns the Product instance matching the provided id.
  Product getProductById(String id) {
    return item[id]!;
  }

  // Returns the Product instance matching the provided id.
  ProductVariation getProductVariationById(String? key) {
    var product =  productVariationInCart[key];
    return product ?? ProductVariation();
  }

  String getCheckoutId() {
    return '';
  }

  void setUser(data) {
    user = data;
  }
}
