import 'package:ctown/screens/settings/return_product_model.dart';
import 'package:flutter/cupertino.dart';

class SettingsProvider with ChangeNotifier {
  Set<String?> selectedProductsForReturn = {};
  List<ReturnProductModel> returnProducts = [];
  List<Map<String, dynamic>> shoppingListItems = [];

  setShoppingListItems(listData) {
    shoppingListItems = listData;
    // shoppingListItems.toSet().toList();
    notifyListeners();
  }

  removeShoppingItem(index) {
    shoppingListItems.removeAt(index);
    notifyListeners();
  }

  listItemStatusChanger(index, val) {
    shoppingListItems[index]["isSelected"] = val;
    notifyListeners();
  }

  //
  String version = "";
  setAppVersion(value) {
    version = value;
    notifyListeners();
  }

  void setReturnProducts(list) {
    returnProducts = list;
    notifyListeners();
  }

  void selectedProductAddQty(int index, int value) {
    returnProducts[index].qty = (returnProducts[index].qty)! + value;
    notifyListeners();
  }

  void selectedProductRemoveQty(int index, int value) {
    returnProducts[index].qty = (returnProducts[index].qty)! - value;
    notifyListeners();
  }

  void selectedProduct(index, value) {
    returnProducts[index].selected = value;
    notifyListeners();
  }

  void addSelectedProductsForReturn(value) {
    selectedProductsForReturn.add(value);
    notifyListeners();
  }

  void removeSelectedProductsForReturn(value) {
    selectedProductsForReturn.remove(value);
    notifyListeners();
  }
}
