import 'package:flutter/material.dart';

import '../models/cart/cart_model.dart';
import '../services/index.dart';
import 'entities/tax.dart';

class TaxModel extends ChangeNotifier {
  final Services _service = Services();
  List<Tax>? taxes = [];
  double taxesTotal = 0;

  Future<void> getTaxes(CartModel cartModel, onSuccess) async {
    try {
      Map<String, dynamic>? res = await _service.getTaxes(cartModel);
      taxes = res!["items"];
      taxesTotal = double.parse(res["total"]);
      onSuccess(taxesTotal);
    } catch (err) {
      notifyListeners();
    }
  }
}
