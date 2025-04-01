import 'package:flutter/material.dart';

import '../common/constants/general.dart';
import '../frameworks/magento/services/magento.dart';
import '../models/cart/cart_model.dart';
import '../services/index.dart';
import 'entities/card_details.dart';
import 'entities/payment_method.dart';
import 'entities/shipping_method.dart';

class PaymentMethodModel extends ChangeNotifier {
  final Services _service = Services();
  late List<PaymentMethod> paymentMethods;
  List<CardDetails>? cardDetails;
  bool isLoading = true;
  String? message;
  String? selectedMethod;
  double total = 0.0;
  /////
  ///
  setTotal(t) {
    total = t;
    notifyListeners();
  }

  setSelectedMethod(method) {
    selectedMethod = method;
    notifyListeners();
  }

/////
  Future<void> getPaymentMethods(
      {required CartModel cartModel,
      ShippingMethod? shippingMethod,
      String? token, required String lang}) async {
    try {
      paymentMethods = await _service.getPaymentMethods(
        cartModel: cartModel,
        shippingMethod: shippingMethod,
        token: token,
        lang: lang
      );
      paymentMethods.forEach((element) {
        printLog("payment methods ${element.title}");
      });
      cardDetails = await MagentoApi().getCardDetails(
        cartModel.user!.id,
      );
      isLoading = false;
      message = null;
      notifyListeners();
    } catch (err) {
      isLoading = false;
      message =
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString();
      notifyListeners();
    }
  }
}
