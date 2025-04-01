import 'dart:convert';

import 'package:ctown/common/config/general.dart';
import 'package:ctown/common/constants.dart';
import 'package:ctown/common/constants/general.dart';
import 'package:ctown/common/constants/route_list.dart';
import 'package:ctown/models/user_model.dart';
import 'package:ctown/screens/settings/selected_store_model.dart';
import 'package:ctown/widgets/common/place_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app.dart';
import '../../frameworks/magento/services/magento.dart';
import '../../models/app_model.dart';
import '../../models/cart/cart_base.dart';
import '../../services/index.dart';

class NotDeliverable extends StatefulWidget {
  final bool? isSkip;

  const NotDeliverable({Key? key, this.isSkip}) : super(key: key);

  @override
  _NotDeliverableState createState() => _NotDeliverableState();
}

class _NotDeliverableState extends State<NotDeliverable> {
  bool isLoading = false;
  late Size screenSize;
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  getNearbyStore({LatLng? latLng}) async {
    String lang = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
    String url = "https://up.ctown.jo/api/getlocationmobile.php";
    Map<String, dynamic> body;
    try {
      if (widget.isSkip == false) {
        body = {
          "latitude": latLng!.latitude.toString(),
          "longitude": latLng.longitude.toString(),
          "user_id": Provider.of<UserModel>(context, listen: false).user?.id
        };
      } else {
        body = {
          "latitude": latLng!.latitude.toString(),
          "longitude": latLng.longitude.toString()
        };
      }
      printLog(body);

      var response = await http.post(Uri.parse(url), body: jsonEncode(body));
      var responseBody;
      if (response.statusCode == 200) {
        responseBody = jsonDecode(response.body);
        printLog(responseBody);
        printLog("1 ran");
        // printLog(responseBody["data"][0]);
        // return responseBody["data"];
        if (responseBody["success"] == 0) {
          printLog("returning failure");
          return {"success": 0, "message": "Store not set"};
        } else {
          SelectedStoreModel store = await getStoresForSelectedCountry(
              countryCode: responseBody["data"][0]["country_code"],
              storeId: responseBody["data"][0]["store_id"]);

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
            String? groupid=store.groupId;

            printLog("map $map");

            await setSavedStore1(name);
            await setSavedStoregroupid(groupid);
            bool success = await setSavedStore(map);
            if (success) {
              await MagentoApi().getAllAttributes(lang);
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
    catch(e) {
      printLog(e);
      return null;
    }

  }

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

  setSavedStore1(name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('savedStore1', jsonEncode(name));
      printLog("savvved finished");
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
      List<SelectedStoreModel> store =
          selectedStoreModelFromJson(jsonEncode(responseBody["data"]));
      printLog(store.length);
      SelectedStoreModel resultStore =
          store.where((i) => i.defaultStoreIdEn == storeId).toList()[0];
      return resultStore;
    }
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _key,
      body: Stack(children: [
        Container(
          color: Colors.white,
          height: screenSize.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/del.jpg',
                height: 120,
              ),
              Text("Sorry, We don't deliver to your location yet."),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(20.0)),
                ),
                  onPressed: () async {
                    isLoading = false;
                    setState(() {});
                    LocationResult result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PlacePicker(
                          kIsWeb
                              ? kGoogleAPIKey['web']
                              : isIos
                              ? kGoogleAPIKey['ios']
                              : kGoogleAPIKey['android'],
                        ),
                      ),
                    ) ?? LocationResult();

                    if(result.latLng != null){
                      try {
                        showDialog(context: context, builder: kLoadingWidget);
                        var resp = await getNearbyStore(latLng: result.latLng);
                        Navigator.of(context).pop();
                        if (resp != null && resp["success"] == 1) {
                          printLog("resp $resp");
                          isLoading = false;
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(resp["message"]),
                          ));
                          Future.delayed(const Duration(seconds: 1), () {
                            Navigator.of(context, rootNavigator: true)
                                .pushReplacementNamed(RouteList.dashboard);
                          });
                        }
                        printLog("result $result");
                        printLog(result.latLng);
                      }
                      catch(e) {
                        printLog(e.toString());
                      }
                    }
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Store not set"),
                      ));
                    }
                  },
                  child: const Text(
                    "Fine tune your location",
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          ),
        ),
        if (isLoading)
          const Positioned.fill(
            child: Align(
                alignment: Alignment.centerRight,
                child: Center(child: CircularProgressIndicator())),
          ),
      ]),
    );
  }
}
