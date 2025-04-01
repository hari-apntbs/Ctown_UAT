import 'package:flutter/cupertino.dart';

class CartProvider extends ChangeNotifier {
  double magentoPromotionsDiscount = 0.0;
  double cartGrandTotal = 0.0;
  double baseSubTotal = 0.0;

  // double d;
  // double c;
  // double s;
  // getDiscountsIfAny({String cookie}) async {
  //   final LocalStorage storage = LocalStorage('store');
  //   final userJson = storage.getItem(kLocalKey["userInfo"]);
  //   String url = "https://up.ctown.jo/rest/V1/carts/mine/payment-information";

  //   // print(userJson["cookie"]);
  //   var response = await http.post(url, headers: {
  //     'Authorization': 'Bearer ' + userJson["cookie"],
  //   });

  //   if (response.statusCode == 200) {
  //     // print(response.body);
  //     var data = jsonDecode(response.body);

  //     c = double.parse(data["totals"]["grand_total"].toString());
  //     d = double.parse(data["totals"]["discount_amount"].toString());
  //   }
  //   print({"grandTotal": c, "discount": d});
  //   return {"grandTotal": c, "discount": d};
  //   // model.getTotal({data["totals"]["discount_amount"]});
  // }

  setCartGrandTotal(value) {
    cartGrandTotal = value;
    notifyListeners();
  }

  setBaseSubTotal(value) {
    baseSubTotal = value;
    notifyListeners();
  }

  setMagentoDiscount(value) {
    magentoPromotionsDiscount = value;
    notifyListeners();
  }

  List avail_qty = [];
  setAvailQty(data) {
    avail_qty = data;
    notifyListeners();
  }

  removeAvailQty(value) {
    avail_qty.remove(value);
    notifyListeners();
  }
}
