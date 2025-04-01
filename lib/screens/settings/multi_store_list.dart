import 'dart:convert';

import 'package:ctown/models/index.dart';
import 'package:ctown/screens/settings/store_provider.dart';
import 'package:ctown/screens/settings/selected_country_stores.dart';

import 'package:provider/provider.dart';
import 'store_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MultiStoresList extends StatefulWidget {
  @override
  _MultiStoresListState createState() => _MultiStoresListState();
}

class _MultiStoresListState extends State<MultiStoresList> {
  getListOfStores() async {
    String url = "https://up.ctown.jo/api/countrycode1.php";
    var response = await http.get(Uri.parse(url));
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) { 
      var responseBody = jsonDecode(response.body);
      // return responseBody["data"];
      List<MyStoreModel> store =
          myStoreModelFromJson(jsonEncode(responseBody["data"]));
      List<Map<String, dynamic>> tempList = [];
      print(store.length);
      print("list get");
      store.forEach((element) {
        tempList.add({"isSelected": false, "store": element});
      });
      print("tempList $tempList");
      try {
        Provider.of<StoreProvider>(context, listen: false).addCountry(tempList);
      } catch (e) {
        print(e);
      }
      print("list set");
      print(Provider.of<StoreProvider>(context, listen: false).countries);
      return store;
    }
  }

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 30, left: 15, right: 15),
        child: FutureBuilder(
            future: getListOfStores(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Text(
                      "Select Your Country",
                      style: TextStyle(fontSize: 18),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.60,
                      width: double.infinity,
                      child: ListView.builder(
                          itemCount:
                              Provider.of<StoreProvider>(context, listen: false)
                                  .countries
                                  .length,
                          //  snapshot.data.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                onTap: () {
                                  Provider.of<StoreProvider>(context,
                                          listen: false)
                                      .selectCountry(index);
                                },
                                title: Text(Provider.of<StoreProvider>(context,
                                        listen: false)
                                    .countries[index]["store"]
                                    .countryName),
                                trailing: Provider.of<StoreProvider>(
                                  context,
                                ).countries[index]["isSelected"]
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
                              onPressed: () {
                                print("done");
                                bool isSelected = false;
                                var v = Provider.of<StoreProvider>(context,
                                        listen: false)
                                    .countries
                                    .where((i) => i["isSelected"] == true);
                                print(v);
                                if (v.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content:
                                          Text("Please select a country")));
                                  return;
                                }
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SelectedCountryStores(
                                        countryCode:
                                            v.first["store"].countryName),
                                  ),
                                );
                                // Map map = {};

                                // setSavedStore(map);
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
