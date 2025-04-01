import 'package:flutter/foundation.dart';

class StoreProvider extends ChangeNotifier {
  List<Map<String, dynamic>> countries = [];

  List<Map<String, dynamic>> stores = [];

  //

  addStores(value) {
    stores = value;
    notifyListeners();
  }

  selectStore(index) {
    stores.forEach((element) {
      element["isSelected"] = false;
    });
    stores[index]["isSelected"] = true;
    notifyListeners();
  }

  //
  addCountry(value) {
    countries = value;
    notifyListeners();
  }

  selectCountry(index) {
    countries.forEach((element) {
      element["isSelected"] = false;
    });
    countries[index]["isSelected"] = true;
    notifyListeners();
  }
}
