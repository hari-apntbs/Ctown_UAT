import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../common/constants.dart';
import '../frameworks/magento/services/magento.dart';
import 'app_model.dart';
import 'entities/product.dart';

class WishListModel extends ChangeNotifier {
  WishListModel() {
    getLocalWishlist();
    // products.forEach((element) {
    //   if (element.status == false) {
    //     showTextAndButtonInWishList = true;
    //   }
    // });
  }

  List<Product?> products = [];

  List<Product?> getWishList() => products;
  bool showTextAndButtonInWishList = false;
  void addToWishlist(Product? product) {
    bool? isExist;
    isExist = products.where((element) => element != null && element.id == product!.id).isNotEmpty;
    // final isExist = products.firstWhere((item) => item!.id == product!.id,
    //     orElse: () => null);
    if (isExist == false || isExist == null) {
      printLog(product!.status);
      printLog(product.name);
      products.add(product);
      saveWishlist(products);
      notifyListeners();
    }
  }

  void removeToWishlist(Product? product) {
    bool? isExist;
    isExist = products.where((element) => element != null && element.id == product!.id).isNotEmpty;
    if (isExist) {
      products = products.where((item) => item!.id != product!.id).toList();
      // products.forEach((element) {
      //   if (element.status == false) {
      //     showTextAndButtonInWishList = true;
      //   }
      // });
      saveWishlist(products);
      notifyListeners();
    }
  }

  Future<void> saveWishlist(List<Product?> products) async {
    final LocalStorage storage = LocalStorage("store");

    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey["wishlist"]!, products);
      }
    } catch (_) {}
  }

  Future<void> getLocalWishlist() async {
    final LocalStorage storage = LocalStorage("store");
    try {
      final ready = await storage.ready;
      if (ready) {
        final json = await await storage.getItem(kLocalKey["wishlist"]!);
        if (json != null) {
          List<Product?> list = [];
          for (var item in json) {
            list.add(Product.fromLocalJson(item));
          }
          if (list.isNotEmpty) {
            List<dynamic> skuList = list.map((item) => item?.sku).toList();
            if(skuList.isNotEmpty) {
              String skuString = skuList.join(',');
              await MagentoApi().getAllAttributes(
                  Provider.of<AppModel>(App.navigatorKey.currentState!.context, listen: false).langCode ?? "en"
              );;
              List<Product> allProducts = await MagentoApi().getWishlistProducts(skuString,
                  Provider.of<AppModel>(App.navigatorKey.currentState!.context, listen: false).langCode ?? "en");
              if(allProducts.isNotEmpty) {
                products = allProducts;
              }
            }

          }
          products.forEach((element) {
            printLog(element!.status);
          });
        }
      }
    } catch (_) {}
  }

  Future<void> clearWishList() async {
    products = [];
    await saveWishlist(products);
    notifyListeners();
  }
}
