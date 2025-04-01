// ignore: prefer_relative_imports
import 'dart:convert';

import 'package:ctown/models/entities/address.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants/general.dart';
import '../services/index.dart';
import 'user_model.dart';

class AddressModel extends ChangeNotifier {
  List<Address> listAddress = [];
  bool isLoading = true;
  String? errMsg;
  // int page = 1;
  // bool endPage = false;
   getSavedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore')!;

    return jsonDecode(result);
  }
 

  Future<void> getMyAddress({required UserModel userModel,String? lang}) async {
    try {
       var store = await getSavedStore();

      String? id = lang == "en"
          ? store["store_en"]["id"]
          : store["store_ar"]["id"] ?? "";
      isLoading = true;
      listAddress = [];
      notifyListeners();
      final result = await Services()
          .getCustomerInfo(userModel.user!.id, userModel.user!.cookie, lang);
      if (result != null && result['addresses'] != null) {
        for (var address in result['addresses']) {
          printLog("id$id");
          printLog("storeid${address["store_id"]}");
          if(address["store_id"].toString()==id){
          final add = Address.fromMagentoJson(Map.from(address));
          if (add.email?.isEmpty ?? true) {
            add.email = result["email"];
          }
          if (!listAddress.contains(add)) {
            listAddress.add(add);
          }
          }
        }
      }
      printLog("my test");
      printLog(listAddress);
      printLog(listAddress.length);
      errMsg = null;
      isLoading = false;
      notifyListeners();
    } catch (err) {
      errMsg =
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> loadMore({UserModel userModel}) async {
  //   try {
  //     isLoading = true;
  //     page = page + 1;
  //     notifyListeners();
  //     var orders =
  //         await Services().getMyOrders(userModel: userModel, page: page);

  //     endPage = orders.isEmpty || orders.length < ApiPageSize;
  //     bool isExisted = myOrders
  //             .indexWhere((o) => orders.isNotEmpty && o.id == orders[0].id) >
  //         -1;
  //     if (!isExisted) {
  //       if (page == 0 || page == 1) {
  //         myOrders = orders;
  //       } else {
  //         myOrders = [...myOrders, ...orders];
  //       }
  //     } else {
  //       endPage = true;
  //     }

  //     errMsg = null;
  //     isLoading = false;
  //     notifyListeners();
  //   } catch (err) {
  //     errMsg =
  //         "There is an issue with the app during request the data, please contact admin for fixing the issues " +
  //             err.toString();
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }
}
