import 'package:ctown/widgets/home/clickandcollect_provider.dart';
import 'package:flutter/material.dart';

import '../models/cart/cart_model.dart';
import '../services/index.dart';
import 'entities/shipping_method.dart';

class ShippingMethodModel extends ChangeNotifier {
  final Services _service = Services();
  List<ShippingMethod>? shippingMethods;
  bool isLoading = true;
  String? message;

  Future<void> getShippingMethods(
      {CartModel? cartModel, String? token, String? checkoutId, ClickNCollectProvider? clickNCollectProvider}) async {
    try {
      isLoading = true;
      notifyListeners();
      shippingMethods = await _service.getShippingMethods(
          cartModel: cartModel, token: token, checkoutId: checkoutId,clickNCollectProvider:clickNCollectProvider);
      isLoading = false;
      message = null;
      notifyListeners();
    } catch (err) {
      isLoading = false;
      message = "⚠️ " + err.toString();
      notifyListeners();
    }
  }
}
