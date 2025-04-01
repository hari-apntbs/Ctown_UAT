import 'package:ctown/models/entities/address.dart';
import 'package:flutter/cupertino.dart';
import '../../common/constants.dart';
import '../../frameworks/magento/services/magento_helper.dart';
import '../serializers/user.dart';

class User {
  String? id;
  bool? loggedIn;
  String? name;
  String? firstName;
  String? lastName;
  String? username;
  String? email;
  String? nicename;
  String? userUrl;
  String? picture;
  String? mobile_no;
  String? cookie;
  Address? shipping;
  Address? billing;
  String? jwtToken;
  bool? isVender;
  bool? isSocial = false;

  String? role;
  // from WooCommerce Json
  User.fromWooJson(Map<String, dynamic> json) {
    try {
      var user = json['user'];
      isSocial = true;
      loggedIn = true;
      id = json['wp_user_id'].toString();
      name = user['displayname'];
      cookie = json['cookie'];
      username = user['username'];
      nicename = user['nicename'];
      firstName = user['firstname'];
      mobile_no = user['mobile_no'];
      lastName = user['lastname'];
      email = user['email'] ?? id;
      isSocial = true;
      userUrl = user['avatar'];
    } catch (e) {
      printLog(e.toString());
    }
  }

  // from Magento Json
  User.fromMagentoJson(Map<String, dynamic> json, token) {
    try {
      loggedIn = true;
      id = json['id'].toString();
      name = json['firstname'] + " " + json["lastname"];
      username = "";
      cookie = token;
      firstName = json["firstname"];
      lastName = json["lastname"];
      email = json["email"];
      for (var address in json['addresses']) {
        if (address.containsKey('default_shipping') &&
            address['default_shipping']) {
          shipping = Address.fromMagentoJson(address);
        }
        if (address.containsKey('default_billing') &&
            address['default_billing']) {
          billing = Address.fromMagentoJson(address);
        }
        if (shipping != null && billing != null) break;
      }
      //mobile_no = json["mobile_no"];
      mobile_no = MagentoHelper.getCustomAttribute(
          json["custom_attributes"], "phone_number");
      printLog(mobile_no);
      picture = "";
    } catch (e) {
      printLog(e.toString());
    }
  }

  // from Opencart Json
  User.fromOpencartJson(Map<String, dynamic> json, token) {
    try {
      loggedIn = true;
      id = (json['customer_id'] != null ? int.parse(json['customer_id']) : 0)
          .toString();
      name = json['firstname'] + " " + json["lastname"];
      username = "";
      cookie = token;
      firstName = json["firstname"];
      mobile_no = json['mobile_no'];
      lastName = json["lastname"];
      email = json["email"];
      picture = "";
    } catch (e) {
      printLog(e.toString());
    }
  }

  // from Shopify json
  User.fromShopifyJson(Map<String, dynamic> json, token) {
    try {
      printLog("fromShopifyJson user $json");

      loggedIn = true;
      id = json['id'].toString();
      name = json['displayName'];
      username = "";
      cookie = token;
      firstName = json["firstName"];
      mobile_no = json['mobile_no'];
      lastName = json["firstName"];
      email = json["email"];
      picture = "";
    } catch (e) {
      printLog(e.toString());
    }
  }

  User.fromPrestaJson(Map<String, dynamic> json) {
    try {
      printLog("fromPresta user $json");

      loggedIn = true;
      id = json['id'].toString();
      name = json['firstname'] + ' ' + json['lastname'];
      username = json["email"];
      cookie = json['secure_key'];
      firstName = json["firstname"];
      mobile_no = json['mobile_no'];
      lastName = json["lastname"];
      email = json["email"];
    } catch (e) {
      printLog(e.toString());
    }
  }

  User.fromStrapi(Map<String, dynamic> parsedJson) {
    debugPrint('User.fromStrapi $parsedJson');
    loggedIn = true;

    SerializerUser model = SerializerUser.fromJson(parsedJson);
    id = model.user!.id.toString();
    jwtToken = model.jwt;
    email = model.user!.email;
    username = model.user!.username;
    nicename = model.user!.displayName;
  }

  // from WooCommerce Json
  User.fromWoJson(Map<String, dynamic> json) {
    try {
      var user = json['user'];
      loggedIn = true;
      id = json['wp_user_id'].toString();
      name = json['user_login'];
      cookie = json['cookie'];
      username = user['username'];
      firstName = json['user_login'];
      mobile_no = json['mobile_no'];
      lastName = '';
      email = user['email'] ?? username;
      isSocial = true;
      var roles = user['role'] as List;
      var role = roles.firstWhere(
          (item) => ((item == 'seller') || (item == 'wcfm_vendor')),
          orElse: () => null);
      if (role != null) {
        isVender = true;
      } else {
        isVender = false;
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  // User.fromListingJson(Map<String, dynamic> json) {
  //   try {
  //     id = json['id'].toString();
  //     name = json['displayname'] ?? '';
  //     username = json['username'] ?? '';
  //     firstName = json['firstname'] ?? '';
  //     mobile_no = json['mobile_no'] ?? '';
  //     lastName = json['lastname'] ?? '';
  //     cookie = json['cookie'] ?? '';
  //     email = json['email'] ?? '';
  //     role = json['role'][0] ?? '';
  //     shipping = Shipping.fromJson(json['shipping']);
  //     billing = Billing.fromJson(json['billing']);
  //     loggedIn = true;
  //   } catch (e) {
  //     printLog(e.toString());
  //   }
  // }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "loggedIn": loggedIn,
      "name": name,
      "firstName": firstName,
      "lastName": lastName,
      "username": username,
      "email": email,
      "picture": picture,
      "cookie": cookie,
      "nicename": nicename,
      "mobile_no": mobile_no,
      "url": userUrl,
      "isSocial": isSocial,
      "isVender": isVender
    };
  }

  User.fromLocalJson(Map<String, dynamic> json) {
    try {
      loggedIn = json['loggedIn'];
      id = json['id'].toString();
      name = json['name'];
      cookie = json['cookie'];
      username = json['username'];
      firstName = json['firstName'];
      lastName = json['lastName'];
      email = json['email'];
      picture = json['picture'];
      mobile_no = json['mobile_no'];
      nicename = json['nicename'];
      userUrl = json['url'];
      isSocial = json['isSocial'];
      isVender = json['isVender'];
    } catch (e) {
      printLog(e.toString());
    }
  }

  // from Create User
  User.fromAuthUser(Map<String, dynamic> json, String _cookie) {
    try {
      cookie = _cookie;
      id = json['id'].toString();
      name = json['displayname'];
      username = json['username'];
      firstName = json['firstname'];
      lastName = json['lastname'];
      mobile_no = json['mobile_no'];
      email = json['email'];
      picture = json['avatar'];
      nicename = json['nicename'];
      userUrl = json['url'];
      loggedIn = true;
      var roles = json['role'] as List;
      if (roles.isNotEmpty) {
        var role = roles.firstWhere(
            (item) => ((item == 'seller') || (item == 'wcfm_vendor')),
            orElse: () => null);
        if (role != null) {
          isVender = true;
        } else {
          isVender = false;
        }
      } else {
        isVender = (json['capabilities']['wcfm_vendor'] as bool?) ?? false;
      }
      // if (json['shipping'] != null) {
      //   shipping = Shipping.fromJson(json['shipping']);
      // }
      // if (json['billing'] != null) {
      //   billing = Billing.fromJson(json['billing']);
      // }
    } catch (e) {
      printLog(e.toString());
    }
  }

  @override
  String toString() => 'User { username: $id $name $email}';
}

class UserPoints {
  int? points;
  List<UserEvent> events = [];

  UserPoints.fromJson(Map<String, dynamic> json) {
    points = json['points_balance'];

    if (json['events'] != null) {
      for (var event in json['events']) {
        events.add(UserEvent.fromJson(event));
      }
    }
  }
}

class UserEvent {
  String? id;
  String? userId;
  String? orderId;
  String? date;
  String? description;
  String? points;

  UserEvent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderId = json['order_id'];
    date = json['date_display_human'];
    description = json['description'];
    points = json['points'];
  }
}
