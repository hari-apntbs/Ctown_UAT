
import 'package:flutter/foundation.dart';

class SuggestedProductProvider extends ChangeNotifier {
  List selectedReplacementProductsData = [];

  setSelectedReplacementProducts(products) {
    selectedReplacementProductsData = products;
    notifyListeners();
  }

  removeAtIndex(index) {
    selectedReplacementProductsData.removeAt(index);
    notifyListeners();
  }

  selectReplacementItem(parentIndex, index) {
    selectedReplacementProductsData[parentIndex]["replacement_products"]
        .forEach((element) {
      element["isSelected"] = false;
    });
    selectedReplacementProductsData[parentIndex]["replacement_products"][index]
        ["isSelected"] = true;
    print(selectedReplacementProductsData[parentIndex]["replacement_products"]
        [index]);
    notifyListeners();
  }

  addselectReplacementItemQuantity(parentIndex, index) {
    selectedReplacementProductsData[parentIndex]["replacement_products"][index]
            ["item"]
        .selectedQtty++;
    notifyListeners();
  }

  reduceselectReplacementItemQuantity(parentIndex, index) {
    print(selectedReplacementProductsData[parentIndex]["replacement_products"]
            [index]["item"]
        .runtimeType);
    selectedReplacementProductsData[parentIndex]["replacement_products"][index]
            ["item"]
        .selectedQtty--;
    notifyListeners();
  }
  // addReplacementProductForSpecificItem(item, index) {
  //   // Map data = {
  //   //   "outofstock_product": selectedReplacementProductsData[index]
  //   //       ["outofstock_product"],
  //   //   "replacement_product": item
  //   // };
  //   selectedReplacementProductsData[index]["replacement_product"] = item;
  //   notifyListeners();
  // }

  // getSelecteditem(index, data) {
  //   if (selectedReplacementProductsData[index]["replacement_product"]
  //           .productId ==
  //       data.productId) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }
}
