import 'package:flutter/foundation.dart';
import 'package:quiver/strings.dart';
import 'package:localstorage/localstorage.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../services/index.dart';
import '../../entities/address.dart';
import '../../entities/shipping_method.dart';
import '../../entities/user.dart';
import 'cart_mixin.dart';

mixin AddressMixin on CartMixin implements ChangeNotifier {
  Address? address;
  ShippingMethod? shippingMethod;

  Future<void> saveShippingAddress(Address? address) async {
    final LocalStorage storage = LocalStorage("store");
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey["shippingAddress"]!, address);
      }
      printLog("Address addred");
    } catch (e) {
      printLog(e);
    }
  }

  Future getShippingAddress(String? lang) async {
    final LocalStorage storage = LocalStorage("store");
    try {
      final ready = await storage.ready;
      if (ready) {
        final json = await storage.getItem(kLocalKey["shippingAddress"]!);
        if (json != null) {
          return Address.fromLocalJson(json);
        } else {
          final userJson = await storage.getItem(kLocalKey["userInfo"]!);
          if (userJson != null) {
            // User user = await Services().getUserInfo(userJson["cookie"]);
            if (user != null) {
              user!.isSocial = userJson["isSocial"] ?? false;
            } else {
              user = User.fromLocalJson(userJson);
            }

            if (user!.billing == null) {
              final info =
                  await Services().getCustomerInfo(user!.id, user!.cookie, lang);
              if (info!["billing"] != null) {
                // user.billing = Billing.fromJson(info["billing"]);
                user!.billing = Address.fromJson(info["billing"]);
              }
            }

            return Address(
              id: user!.billing != null && user!.billing!.id!.isNotEmpty
                    ? user!.billing!.id
                    : user!.shipping != null && user!.shipping!.id!.isNotEmpty ? user!.shipping!.id : "",
                firstName: user!.billing != null && user!.billing!.firstName!.isNotEmpty
                    ? user!.billing!.firstName
                    : user!.firstName,
                lastName: user!.billing != null && user!.billing!.lastName!.isNotEmpty
                    ? user!.billing!.lastName
                    : user!.lastName,
                email: user!.billing != null && user!.billing!.email != null && user!.billing!.email!.isNotEmpty
                    ? user!.billing!.email
                    : user!.email,
                // street: user.billing != null && user.billing.address1.isNotEmpty ? user.billing.address1 : "",
                street: user!.billing != null && user!.billing!.street!.isNotEmpty
                    ? user!.billing!.street
                    : "",
                country: user!.billing != null && isNotBlank(user!.billing!.country)
                    ? user!.billing!.country
                    : kPaymentConfig["DefaultCountryISOCode"] as String?,
                state: user!.billing != null && user!.billing!.state!.isNotEmpty
                    ? user!.billing!.state
                    : kPaymentConfig["DefaultStateISOCode"] as String?,
                phoneNumber: user!.billing != null &&
                        user!.billing!.phoneNumber != null &&
                        user!.billing!.phoneNumber!.isNotEmpty
                    ? user!.billing!.phoneNumber
                    : "",
                city: user!.billing != null && user!.billing!.city!.isNotEmpty
                    ? user!.billing!.city
                    : "",
                zipCode: user!.billing != null && user!.billing!.zipCode != null && user!.billing!.zipCode!.isNotEmpty
                    ? user!.billing!.zipCode
                    : "",

                ////
                apartment: user!.billing != null &&
                        user!.billing!.apartment != null &&
                        user!.billing!.apartment!.isNotEmpty
                    ? user!.billing!.apartment
                    : "",
                block: user!.billing != null && user!.billing!.block != null && user!.billing!.block!.isNotEmpty ? user!.billing!.block : "",
                landmark: user!.billing != null && user!.billing!.landmark != null && user!.billing!.landmark!.isNotEmpty ? user!.billing!.landmark : ""

                //
                );
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  setAddress(data) async {
    address = data;
    await saveShippingAddress(data);
    notifyListeners();
  }

  Future<Address?> getAddress(String? lang) async {
    address ??= await getShippingAddress(lang);
    return address;
  }

  double? getShippingCost() {
    if (shippingMethod != null && shippingMethod!.cost! > 0) {
      return shippingMethod!.cost;
    }
    if (shippingMethod != null && isNotBlank(shippingMethod!.classCost)) {
      List items = shippingMethod!.classCost!.split("*");
      String cost = items[0] != "[qty]" ? items[0] : items[1];
      double shippingCost = double.parse(cost) ?? 0.0;
      int count = 0;
      for (var key in productsInCart.keys) {
        printLog("this plus");
        count += productsInCart[key]!;
      }
      return shippingCost * count;
    }
    return 0.0;
  }

  void setShippingMethod(data) {
    shippingMethod = data;
  }
}
