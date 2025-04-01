import 'dart:convert';

import 'package:ctown/models/app_model.dart';
import 'package:ctown/models/user_model.dart';
import 'package:ctown/screens/settings/selected_store_model.dart';
import 'package:ctown/screens/settings/store_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectedCountryStores extends StatefulWidget {
  final countryCode;
  SelectedCountryStores({this.countryCode});
  @override
  _SelectedCountryStoresState createState() => _SelectedCountryStoresState();
}

class _SelectedCountryStoresState extends State<SelectedCountryStores> {
  //
  setSavedStore(map) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('savedStore', jsonEncode(map));
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
   setSavedStoregroupid(name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('setSavedStoregroupid', jsonEncode(name));
      print("savvved finished");
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
  setSavedStore1(map) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await prefs.setString('savedStore1', jsonEncode(map));
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void _restartApp() async {
    Restart.restartApp();
  }

  //
  getStoresForSelectedCountry() async {
    String url = "https://up.ctown.jo/api/storelistmobile1.php";
    Map body = {"country": widget.countryCode,"user_id":Provider.of<UserModel>(context, listen: false).user!.id,};
    print(jsonEncode(body));
    var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
     
      print(responseBody["data"]);
      List<SelectedStoreModel> store =
          selectedStoreModelFromJson(jsonEncode(responseBody["data"]));
      List<Map<String, dynamic>> tempList = [];
      print(store);
      store.forEach((element) {
        tempList.add({"isSelected": false, "store": element});
      });
      print("get data");
      try {
        Provider.of<StoreProvider>(context, listen: false).addStores(tempList);
      } catch (e) {
        print(e);
      }
      print(Provider.of<StoreProvider>(context, listen: false).stores);
      return store;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 30, left: 15, right: 15),
        child: FutureBuilder(
            future: getStoresForSelectedCountry(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      "Select One of the Available Stores",
                      style: TextStyle(fontSize: 18),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.60,
                      width: double.infinity,
                      child: ListView.builder(
                          itemCount:
                              Provider.of<StoreProvider>(context, listen: false)
                                  .stores
                                  .length,
                          //  snapshot.data.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                onTap: () {
                                  Provider.of<StoreProvider>(context,
                                          listen: false)
                                      .selectStore(index);
                                },
                                title: Text(Provider.of<StoreProvider>(context,
                                        listen: false)
                                    .stores[index]["store"]
                                    .name),
                                trailing: Provider.of<StoreProvider>(
                                  context,
                                ).stores[index]["isSelected"]
                                    ? Icon(
                                        Icons.check,
                                        color: Theme.of(context).primaryColor,
                                      )
                                    : Container(
                                        height: 1,
                                        width: 1,
                                      ),
                              ),
                            );
                            // return Text(snapshot.data.toString());
                            // return Text(snapshot.data[index]["country_name"]);
                            /*      return Container(
                              height: 80,
                              color: Colors.grey,
                              child:
                               Row(
                                children: [
                                  Text(snapshot.data[index]["country_name"])
                                ],
                              ),
                            );*/
                          }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          child: ElevatedButton(
                              onPressed: () async {
                                /*    List<dynamic> data = [
                                  {"lat": 44.968046, "lng": -94.420307},
                                  {"lat": 44.33328, "lng": -89.132008},
                                  {"lat": 33.755787, "lng": -116.359998},
                                  {"lat": 33.844843, "lng": -116.54911},
                                  {"lat": 44.92057, "lng": -93.44786},
                                  {"lat": 44.240309, "lng": -91.493619},
                                  {"lat": 44.968041, "lng": -94.419696},
                                  {"lat": 44.333304, "lng": -89.132027},
                                  {"lat": 33.755783, "lng": -116.360066},
                                  {"lat": 33.844847, "lng": -116.549069},
                                ];

                                var location = Location();
                                location.getLocation().then((locationData) {
                                  LatLng target = LatLng(locationData.latitude,
                                      locationData.longitude);
                                  print(target);
                                });*/

                                bool isSelected = false;
                                var v = Provider.of<StoreProvider>(context,
                                        listen: false)
                                    .stores
                                    .where((i) => i["isSelected"] == true);
                                print(v);
                                if (v.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text("Please select a store")));
                                  return;
                                }

                                Map map = {
                                  "store_en": {
                                    "id": v.first["store"].defaultStoreIdEn,
                                    "currency": v.first["store"].currencyEn,
                                    "code": v.first["store"].defaultStoreCodeEn,
                                  },
                                  "store_ar": {
                                    "id": v.first["store"].defaultStoreIdAr,
                                    "currency": v.first["store"].currencyAr,
                                    "code": v.first["store"].defaultStoreCodeAr,
                                  },
                                };
                                String? name = v.first["store"].name;
                                String? groupid = v.first["store"].groupId;
                                

                                print("map $map");
                                
                           

                                bool result = await setSavedStore(map);
                                await setSavedStore1(name);
                                await setSavedStoregroupid(groupid);

                                if (result) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                          "App is Restarting to take effect")));
                                  Future.delayed(Duration(seconds: 1),
                                      () => {_restartApp()});
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    new BorderRadius.circular(20.0)),
                              ),
                              child: Text(
                                Provider.of<AppModel>(context, listen: false)
                                            .langCode ==
                                        "ar"
                                    ? "منتهي"
                                    : 'Done',
                                style: TextStyle(color: Colors.white),
                              )),
                          padding: EdgeInsets.only(bottom: 10),
                        )
                      ],
                    )
                  ],
                );
                // Text(snapshot.data.toString());
              }
              return Center(
                  child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor,
              ));
            }),
      ),
    );
  }
}
