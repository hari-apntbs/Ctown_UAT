import 'dart:convert';

import 'package:ctown/common/constants/general.dart';
import 'package:ctown/common/constants/route_list.dart';
import 'package:ctown/frameworks/magento/services/magento.dart';
import 'package:ctown/models/app_model.dart';
import 'package:ctown/models/user_model.dart';
import 'package:ctown/screens/settings/not_deliverable.dart';
import 'package:ctown/screens/settings/selected_store_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app.dart';
import '../../cache_manager_file.dart';
import '../../common/constants/loading.dart';
import '../../models/cart/cart_base.dart';
import '../../services/index.dart';
import 'store_model.dart';

class UserManualStoreSelectionScreen extends StatefulWidget {
  final bool fromHome;

  const UserManualStoreSelectionScreen({super.key, required this.fromHome});
  @override
  _UserManualStoreSelectionScreenState createState() => _UserManualStoreSelectionScreenState();
}

class _UserManualStoreSelectionScreenState extends State<UserManualStoreSelectionScreen> {
  setSavedStore(map) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('savedStore', jsonEncode(map));
      printLog("savvved");
      return true;
    } catch (e) {
      printLog(e);
      return false;
    }
  }

  setSavedStore1(map) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('savedStore1', jsonEncode(map));
      printLog("savvved");
      return true;
    } catch (e) {
      printLog(e);
      return false;
    }
  }

  setSavedStoregroupid(name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('setSavedStoregroupid', jsonEncode(name));
      printLog("savvved finished");
      return true;
    } catch (e) {
      printLog(e);
      return false;
    }
  }

  getStoresForUserSelectedCountry({String? countryCode}) async {
    printLog("function starts");
    String url = "https://up.ctown.jo/api/storelistmobile1.php";
    var body = {"country": countryCode};
    printLog("second body" + jsonEncode(body));
    var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    printLog(response.body);
    printLog(response.statusCode);
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      printLog(responseBody["data"]);
      List<SelectedStoreModel> stores = selectedStoreModelFromJson(jsonEncode(responseBody["data"]));

      return stores;
    }
  }

  getSavedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore')!;

    return jsonDecode(result);
  }

  storecartchange(lang) async {
    final LocalStorage storage = LocalStorage('store');
    final userJson = await storage.getItem(kLocalKey["userInfo"]!);
    String token = userJson["cookie"];
    var store1 = await getSavedStore();
    String id = lang == "en" ? store1["store_en"]["id"] : store1["store_ar"]["id"] ?? "";
    String qoute = await MagentoApi().getQuoteId(token: token, lang: Provider.of<AppModel>(context, listen: false).langCode);
    String url = "https://up.ctown.jo/api/customer_store_quote_id_change.php";
    Map body = {"quote_id": "$qoute", "store_id": "$id"};
    printLog("second body" + jsonEncode(body));
    var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    printLog(response.body);
    printLog(response.statusCode);
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      return responseBody;
    }
  }

  String? selectedStore;

  Future<List<MyStoreModel>> getListOfStores() async {
    List<MyStoreModel> store = [];
    String url = "https://up.ctown.jo/api/countrycode1.php";
    var response = await http.get(Uri.parse(url));
    printLog(response.body);
    printLog(response.statusCode);
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      store = myStoreModelFromJson(jsonEncode(responseBody["data"]));
    }
    return store;
  }

  @override
  Widget build(BuildContext context) {
    CartModel cartModel = Provider.of<CartModel>(context);
    var cookie = Provider.of<UserModel>(context, listen: false).user != null ? Provider.of<UserModel>(context, listen: false).user!.cookie : null;
    AppModel appModel = Provider.of<AppModel>(context);

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            FutureBuilder<List<MyStoreModel>>(
              future: getListOfStores(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.data != null) {
                  return Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Column(children: [
                      const Text(
                        "Select a store Manually",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Column(
                        children: List.generate(
                          snapshot.data!.length,
                          (index) {
                            return ExpansionTile(
                              title: Text(snapshot.data![index].countryName ?? "", style: Theme.of(context).textTheme.bodyMedium,),
                              iconColor: Theme.of(context).textTheme.bodyMedium?.color,
                              collapsedIconColor: Theme.of(context).textTheme.bodyMedium?.color,
                              children: [
                                FutureBuilder(
                                  future: getStoresForUserSelectedCountry(countryCode: snapshot.data![index].countryName ?? ""),
                                  builder: (context, AsyncSnapshot snapshot) {
                                    if (snapshot.data != null) {
                                      return Padding(
                                          padding: const EdgeInsets.only(left: 10, right: 10),
                                          child: Column(
                                            children: List.generate(
                                              snapshot.data!.length,
                                              (index) => ListTile(
                                                onTap: () async {
                                                  bool result = false;
                                                  try {
                                                    showDialog(context: context, builder: kLoadingWidget);
                                                    var store = snapshot.data[index];
                                                    Map map = {
                                                      "store_en": {
                                                        "id": store.defaultStoreIdEn,
                                                        "currency": store.currencyEn,
                                                        "code": store.defaultStoreCodeEn,
                                                      },
                                                      "store_ar": {
                                                        "id": store.defaultStoreIdAr,
                                                        "currency": store.currencyAr,
                                                        "code": store.defaultStoreCodeAr,
                                                      },
                                                    };

                                                    printLog("map $map");
                                                    String name = store.name;
                                                    String groupid = store.groupId;
                                                    await setSavedStore1(name);
                                                    await setSavedStoregroupid(groupid);
                                                    result = await setSavedStore(map);
                                                    // await MagentoApi().getAllAttributes();
                                                    if (Provider.of<UserModel>(context, listen: false).loggedIn) {
                                                      await storecartchange(Provider.of<AppModel>(context, listen: false).langCode);
                                                      Future.delayed(const Duration(milliseconds: 4000), () {
                                                        printLog("Test Date2:" + DateTime.now().toIso8601String());
                                                        Services().widget?.syncCartFromWebsite(cookie, cartModel, context, appModel.langCode ?? "en");
                                                      });
                                                    }
                                                  } catch (e) {
                                                    printLog(e.toString());
                                                  } finally {
                                                    Navigator.of(context).pop();
                                                  }
                                                  if (result) {
                                                    Navigator.of(context, rootNavigator: true)
                                                        .pushNamedAndRemoveUntil(RouteList.dashboard, (route)=> false).then((_) {
                                                      CustomCacheManager.instance.emptyCache(); // Clear cache
                                                    });
                                                  }
                                                },
                                                title: Text(snapshot.data[index].name, style: Theme.of(context).textTheme.bodyMedium,),
                                              ),
                                            ),
                                          ));
                                    }
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ]),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class CheckIfDeliverable extends StatefulWidget {
  final bool? isSkip;

  const CheckIfDeliverable({Key? key, this.isSkip}) : super(key: key);

  @override
  _CheckIfDeliverableState createState() => _CheckIfDeliverableState();
}

class _CheckIfDeliverableState extends State<CheckIfDeliverable> {
  Position? location;
  bool serviceEnabled = false;
  LocationPermission? hasPermission;
  var result = {"permission": false, "success": 0, "message": "Store not set"};

  setSavedStore(map) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('savedStore', jsonEncode(map));
      printLog("savvved");
      return true;
    } catch (e) {
      printLog(e);
      return false;
    }
  }

  setSavedStoregroupid(name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('setSavedStoregroupid', jsonEncode(name));
      printLog("savvved finished");
      return true;
    } catch (e) {
      printLog(e);
      return false;
    }
  }

  setSavedStore1(map) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('savedStore1', jsonEncode(map));
      printLog("savvved");
      return true;
    } catch (e) {
      printLog(e);
      return false;
    }
  }

  getStoresForSelectedCountry({countryCode, storeId}) async {
    String url = "https://up.ctown.jo/api/storelistmobile1.php";
    var body = {"country": countryCode};
    printLog(jsonEncode(body));
    var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    printLog(response.body);
    printLog(response.statusCode);
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      printLog(responseBody["data"]);
      List<SelectedStoreModel> store = selectedStoreModelFromJson(jsonEncode(responseBody["data"]));
      printLog(store.length);
      SelectedStoreModel resultStore = store.where((i) => i.defaultStoreIdEn == storeId).toList()[0];
      return resultStore;
    }
  }

  getNearbyStore({LatLng? latLng, bool withBody = true}) async {
    String url = "https://up.ctown.jo/api/getlocationmobile.php";
    String lang = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
    var body;

    if (widget.isSkip == false) {
      printLog("Success Test 1");
      body = {
        "latitude": latLng!.latitude.toString(),
        "longitude": latLng.longitude.toString(),
        "user_id": Provider.of<UserModel>(context, listen: false).user?.id
      };
    } else {
      printLog("Success Test 2");
      body = {"latitude": latLng!.latitude.toString(), "longitude": latLng.longitude.toString()};
    }
    printLog(jsonEncode(body));
    var response;
    if (withBody) {
      response = await http.post(Uri.parse(url), body: jsonEncode(body));
    } else {
      response = await http.post(Uri.parse(url));
    }
    var responseBody;
    if (response.statusCode == 200) {
      printLog(response.body);
      responseBody = jsonDecode(response.body);
      if (responseBody["success"] == 0) {
        printLog("returning failure");
        return {"success": 0, "message": "Store not set"};
      } else {
        SelectedStoreModel store =
            await getStoresForSelectedCountry(countryCode: responseBody["data"][0]["country_code"], storeId: responseBody["data"][0]["store_id"]);
        if (store != null) {
          Map map = {
            "store_en": {
              "id": store.defaultStoreIdEn,
              "currency": store.currencyEn,
              "code": store.defaultStoreCodeEn,
            },
            "store_ar": {
              "id": store.defaultStoreIdAr,
              "currency": store.currencyAr,
              "code": store.defaultStoreCodeAr,
            },
          };

          printLog("map $map");
          String? name = store.name;
          String? groupid = store.groupId;

          bool success = await setSavedStore(map);
          await setSavedStore1(name);
          await setSavedStoregroupid(groupid);
          await MagentoApi().getAllAttributes(lang);
          if (success) {
            return {"success": 1, "message": "Store set successfully"};
          } else {
            return {"success": 0, "message": "Store not set"};
          }
        } else {
          return {"success": 0, "message": "Store not set"};
        }
      }
    } else {
      return {"success": 0, "message": "Store not set"};
    }
  }

  checkIfDeliverableLocationFound() async {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    hasPermission = await Geolocator.checkPermission();
    if (hasPermission == LocationPermission.denied) {
      hasPermission = await Geolocator.requestPermission();
    }
    printLog("Service Enabled $serviceEnabled");
    printLog("Has Permission $hasPermission");
    if (serviceEnabled && (hasPermission != LocationPermission.denied || hasPermission != LocationPermission.deniedForever)) {
      try {
        location = await Geolocator.getCurrentPosition();
        result = await getNearbyStore(latLng: LatLng(location?.latitude ?? 0.0, location?.longitude ?? 0.0));
      } catch (e) {
        printLog(e.toString());
      }
    }
    printLog(location);
    printLog("Result: $result");
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: checkIfDeliverableLocationFound(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data != null) {
            if (snapshot.data["success"] == 0 && snapshot.data["permission"] == false) {
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => UserManualStoreSelectionScreen(fromHome: false)));
              });
            } else {
              if (snapshot.data["success"] == 0 && snapshot.data["permission"] == null) {
                Future.delayed(const Duration(seconds: 1), () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => NotDeliverable(isSkip: widget.isSkip)));
                });
              } else {
                Future.delayed(const Duration(seconds: 1), () {
                  Navigator.of(context, rootNavigator: true).pushReplacementNamed(RouteList.dashboard);
                });
              }
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
