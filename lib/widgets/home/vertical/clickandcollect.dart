import 'dart:async';
import 'dart:convert';

import 'package:ctown/models/entities/address.dart';
import 'package:ctown/widgets/home/clickandcollect_provider.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ClickAndCollect extends StatefulWidget {
  @override
  _ClickAndCollectState createState() => _ClickAndCollectState();
}

class _ClickAndCollectState extends State<ClickAndCollect> {
  double latitude = 25.4003;
  double longitude = 55.4319;

  ClickNCollectProvider? clickNCollectProvider;

  Completer<GoogleMapController> _controller = Completer();
  Future<void> _movecameraPosition(_kLake) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  getStoresList(context) async {
    String apiUrl = "https://up.ctown.jo/api/storelistmobile.php";
    var response = await http.get(Uri.parse(apiUrl));
    // print("responseBody ${response.body}");
    print(response.statusCode);
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body)["data"];

      print(responseBody[0]["lat"]);
      Provider.of<ClickNCollectProvider>(context, listen: false)
          .setInitialCameraPosition(double.parse(responseBody[0]["lat"]),
              double.parse(responseBody[0]["lng"]));

      return responseBody;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.only(top: 30),
          child: FutureBuilder(
              future: getStoresList(context),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.data != null) {
                  return Column(
                    children: [
                      Row(children: [
                        Container(
                            height: 70,
                            padding: EdgeInsets.only(top: 15, left: 10),
                            child: InkWell(
                              child: Text("Select your collection store",
                                  style: TextStyle(
                                    fontSize: 20,
                                  )),
                              onTap: () async {
                                String apiUrl =
                                    "https://up.ctown.jo/api/storelist.php";
                                var response = await http.post(Uri.parse(apiUrl),
                                    body: json.encode({"country": "JO"}));
                                var responseBody = jsonDecode(response.body);
                                print(responseBody["data"]);
                              },
                            ))
                      ]),
                      Container(
                        height: MediaQuery.of(context).size.height / 2.5,
                        width: MediaQuery.of(context).size.width,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(13.0827, 80.2707),
                            //     Provider.of<ClickNCollectProvider>(context)
                            //         .initialcameraposition,
                            // zoom: 15
                          ),
                          mapType: MapType.normal,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                          myLocationEnabled: true,
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 200,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                  onTap: () {
                                    Provider.of<ClickNCollectProvider>(context,
                                            listen: false)
                                        .setInitialCameraPosition(
                                            double.parse(
                                                snapshot.data[index]["lat"]),
                                            double.parse(
                                                snapshot.data[index]["lng"]));
                                    // print(snapshot.data[0]["lat"]);
                                    CameraPosition _kLake = CameraPosition(
                                        // bearing: 192.8334901395799,
                                        target:
                                            Provider.of<ClickNCollectProvider>(
                                                    context,
                                                    listen: false)
                                                .initialcameraposition,
                                        // LatLng(13.0827, 80.2707),
                                        zoom: 15
                                        // 19.151926040649414
                                        );
                                    _movecameraPosition(_kLake);
                                  },
                                  child: Row(children: [
                                    SizedBox(width: 10),
                                    Card(
                                        color: Colors.white,
                                        child: Container(
                                          height: 170,
                                          width: 240,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                    height: 120,
                                                    padding: EdgeInsets.only(
                                                        left: 10, right: 10),
                                                    // color: Colors.red,
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Text(
                                                            snapshot.data[index]
                                                                ["name"],
                                                            style: TextStyle(
                                                                fontSize: 16.5,
                                                                color:
                                                                    Colors.black

                                                                // Theme.of(
                                                                //         context)
                                                                //     .accentColor

                                                                ),
                                                          ),

                                                          // RichText(
                                                          //     text: snapshot.data[0]
                                                          //         ["address"])
                                                          Text(
                                                            snapshot.data[0]
                                                                    [
                                                                    "address"] +
                                                                " " +
                                                                snapshot.data[0]
                                                                    ["city"] +
                                                                " " +
                                                                snapshot.data[0]
                                                                    [
                                                                    "country"] +
                                                                " " +
                                                                snapshot.data[0]
                                                                    [
                                                                    "postcode"],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 13.0),
                                                          )
                                                        ])),
                                                Container(
                                                  width: 240,
                                                  height: 38,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                    onPressed: () async {
                                                      Provider.of<ClickNCollectProvider>(
                                                              context,
                                                              listen: false)
                                                          .setDeliveryTypeAndStoreId(
                                                              snapshot.data[
                                                                      index]
                                                                  ["group_id"],
                                                              "clickandcollect");
                                                      Address address = Address(
                                                          state: snapshot
                                                                  .data[index]
                                                              ["name"],
                                                          country: snapshot
                                                                  .data[index]
                                                              ["country"],
                                                          zipCode: snapshot
                                                                  .data[index]
                                                              ["postcode"],
                                                          landmark: snapshot
                                                                  .data[index]
                                                              ["address"],
                                                          city: snapshot
                                                                  .data[index]
                                                              ["city"]);

                                                      // Provider.of<CartModel>(
                                                      //         context,
                                                      //         listen: false)
                                                      //     .setAddress(address);
                                                      print(Provider.of<
                                                                  ClickNCollectProvider>(
                                                              context,
                                                              listen: false)
                                                          .storeId);
                                                      print(Provider.of<
                                                                  ClickNCollectProvider>(
                                                              context,
                                                              listen: false)
                                                          .deliveryType);
                                                      Navigator.pop(context);

                                                      ///////
                                                      // Provider.of<ClickNCollectProvider>(
                                                      //         context,
                                                      //         listen: false)
                                                      //     .setInitialCameraPosition(
                                                      //         37.4219983,
                                                      //         -122.084);
                                                      // print(Provider.of<
                                                      //             ClickNCollectProvider>(
                                                      //         context,
                                                      //         listen: false)
                                                      //     .initialcameraposition);

                                                      // moveCameraInMap(context);
                                                    },
                                                    child: Text(
                                                        "SELECT THIS STORE",
                                                        style: TextStyle(
                                                            fontSize: 13.0,
                                                            color:
                                                                Colors.white)),
                                                  ),
                                                )
                                              ]),
                                        )),
                                  ]));
                            }),
                      )
                    ],
                  );
                }
                return InkWell(
                  onTap: () {
                    print(snapshot.data);
                  },
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              })),
    );
  }
}
