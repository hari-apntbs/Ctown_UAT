import 'dart:convert';
import 'dart:io';

import 'package:ctown/common/constants.dart';
import 'package:ctown/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

import '../../../generated/l10n.dart';

class MyVouchersWidget extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> couponData = [];
  couponcode(String? user_id) async {
    var url = "https://up.ctown.jo/api/myvoucher.php?id=$user_id";
    printLog("Voucher Url: $url");

    var res = await http.get(Uri.parse(url));

    final response = jsonDecode(res.body);
    if (response["success"] == 1) {
      print("userid");
      print(response['data']);
      await checkCouponExpiry(user_id??"");
      return response['data'];
    } else if (response["success"] == 0) {
      print("failed");
      return null;

      // print(userModel.user.id);
    }
  }

  checkCouponExpiry(String userId) async {
    var url =
        "https://up.ctown.jo/api/loyalty_redeemption.php?id=$userId&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}";
    var res = await http.get(Uri.parse(url));
    final response = jsonDecode(res.body);
    if (response["success"] == 1) {
      print("userid");

      // print(userModel.user.id);
      print(response['data']);
      List jsonData = response['data'];
      if(jsonData.isNotEmpty) {
        jsonData.forEach((element) {
          couponData.add(element);
        });
      }
      return response['data'];
    } else {
      print("userid");
      // print(userModel.user.id);
    }
  }
  Future<void> _onScrollsToTop(ScrollsToTopEvent event) async {
    _scrollController.animateTo(0, duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
  }


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context, listen: false).user!;
    String? user_id = user.id;
    String url = "https://up.ctown.jo/api/";
    return Platform.isIOS ? ScrollsToTop(
      onScrollsToTop: _onScrollsToTop,
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              S.of(context).myvoucher,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
            leading: GestureDetector(
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onTap: () => Navigator.pop(context),
            ),
          ),
          body: Container(
            child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: FutureBuilder(
                    future: couponcode(user_id),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.data != null && snapshot.data.isNotEmpty) {
                        return ListView.builder(
                            controller: _scrollController,
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              bool expired = false;
                              if(couponData.isNotEmpty) {
                                couponData.forEach((element) {
                                  if(snapshot.data[index]["image"].contains(element["voucherBarcode"])) {
                                    if(DateTime.parse(element["expiryDate"]).isBefore(DateTime.now())) {
                                      expired = true;
                                    }
                                  }
                                });
                              }
                              return InkWell(
                                onTap: () {
                                  if(!expired) {
                                    printLog(url + snapshot.data[index]["image"]);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => VoucherView(
                                              image: url +
                                                  snapshot.data[index]["image"],
                                            )));
                                  }
                                },
                                child: Stack(children: [
                                  Center(
                                    child: Container(
                                      padding: EdgeInsets.all(10.0),
                                      width: 300,
                                      child: expired ?Image.asset("assets/images/couponbw.png")
                                          :Image.asset("assets/images/cupon.png"),
                                    ),
                                  ),
                                  Positioned(
                                      top: 22,
                                      right: 2,
                                      left: 3,
                                      child: Center(
                                        child: Container(
                                          // width: 300,
                                          // margin: EdgeInsets.only(right:10),
                                          child: Image.network(url +
                                              snapshot.data[index]["image"]),
                                        ),
                                      )),
                                  if(expired)
                                    Positioned(
                                        top: 0,
                                        right: 50,
                                        left: 50,
                                        bottom: 10,
                                        child: Center(
                                          child: Container(
                                            // width: 300,
                                            // margin: EdgeInsets.only(right:10),
                                            child: Image.asset("assets/images/expiry.png",
                                              height: 150, width: 180, fit: BoxFit.fill,),
                                          ),
                                        ))
                                ]),
                              );
                            });
                      } else if (snapshot.connectionState == ConnectionState.done && snapshot.data == null) {
                        return Center(
                          child: Text(S.of(context).No_vouchers),
                        );
                      }
                      else if(snapshot.connectionState == ConnectionState.done && snapshot.data.isEmpty) {
                        return Center(
                          child: Text(S.of(context).No_vouchers),
                        );
                      }
                      else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  // child:

                  //     Wrap(children: [

                  //     ],)
                )
              ],
            ),
          ))
          // Container(
          //   constraints: BoxConstraints.expand(),
          //   decoration: BoxDecoration(
          //     color: Color.fromARGB(255, 255, 255, 255),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.stretch,
          //     children: [
          //       Container(
          //         height: 154,
          //         margin: EdgeInsets.only(left: 13, top: 88, right: 13),
          //         child: Style(
          //           decoration: StyleDecoration(
          //             boxShadow: [
          //               BoxShadow(
          //                 color: Color.fromARGB(255, 0, 0, 0),
          //                 offset: Offset(2, 2),
          //                 blurRadius: 2,
          //               ),
          //             ],
          //           ),
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.stretch,
          //             children: [
          //               Container(
          //                 height: 65,
          //                 margin: EdgeInsets.only(left: 15, top: 16, right: 14),
          //                 child: Stack(
          //                   alignment: Alignment.center,
          //                   children: [
          //                     Positioned(
          //                       left: 0,
          //                       top: 0,
          //                       right: 0,
          //                       child: Image.asset(
          //                         "assets/images/voucher-1.png",
          //                         fit: BoxFit.cover,
          //                       ),
          //                     ),
          //                     Positioned(
          //                       top: 18,
          //                       child: Image.asset(
          //                         "assets/images/voucher-barcode.png",
          //                         fit: BoxFit.cover,
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //               Spacer(),
          //               Align(
          //                 alignment: Alignment.topLeft,
          //                 child: Container(
          //                   width: 321,
          //                   height: 23,
          //                   margin: EdgeInsets.only(left: 18, bottom: 8),
          //                   child: Row(
          //                     crossAxisAlignment: CrossAxisAlignment.stretch,
          //                     children: [
          //                       Align(
          //                         alignment: Alignment.bottomLeft,
          //                         child: Text(
          //                           "100 AED",
          //                           textAlign: TextAlign.left,
          //                           style: TextStyle(
          //                             color: AppColors.primaryText,
          //                             fontFamily: "Poppins",
          //                             fontWeight: FontWeight.w400,
          //                             fontSize: 15,
          //                           ),
          //                         ),
          //                       ),
          //                       Align(
          //                         alignment: Alignment.bottomLeft,
          //                         child: Container(
          //                           margin: EdgeInsets.only(left: 113),
          //                           child: Text(
          //                             "Expiry Date: 31 December 2020",
          //                             textAlign: TextAlign.center,
          //                             style: TextStyle(
          //                               color: AppColors.secondaryText,
          //                               fontFamily: "Poppins",
          //                               fontWeight: FontWeight.w400,
          //                               fontSize: 10,
          //                             ),
          //                           ),
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          ),
    ) : Scaffold(
        appBar: AppBar(
          title: Text(
            S.of(context).myvoucher,
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
          leading: GestureDetector(
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: Container(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    child: FutureBuilder(
                      future: couponcode(user_id),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.data != null && snapshot.data.isNotEmpty) {
                          return ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                bool expired = false;
                                if(couponData.isNotEmpty) {
                                  couponData.forEach((element) {
                                    if(snapshot.data[index]["image"].contains(element["voucherBarcode"])) {
                                      if(DateTime.parse(element["expiryDate"]).isBefore(DateTime.now())) {
                                        expired = true;
                                      }
                                    }
                                  });
                                }
                                return InkWell(
                                  onTap: () {
                                    if(!expired) {
                                      print(url + snapshot.data[index]["image"]);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => VoucherView(
                                                image: url +
                                                    snapshot.data[index]["image"],
                                              )));
                                    }
                                  },
                                  child: Stack(children: [
                                    Center(
                                      child: Container(
                                        padding: EdgeInsets.all(10.0),
                                        width: 300,
                                        child:expired ?Image.asset("assets/images/couponbw.png")
                                            :Image.asset("assets/images/cupon.png"),
                                      ),
                                    ),
                                    Positioned(
                                        top: 22,
                                        right: 2,
                                        left: 3,
                                        child: Center(
                                          child: Container(
                                            // width: 300,
                                            // margin: EdgeInsets.only(right:10),
                                            child: Image.network(url +
                                                snapshot.data[index]["image"]),
                                          ),
                                        )),
                                    if(expired)
                                      Positioned(
                                          top: 0,
                                          right: 50,
                                          left: 50,
                                          bottom: 10,
                                          child: Center(
                                            child: Container(
                                              // width: 300,
                                              // margin: EdgeInsets.only(right:10),
                                              child: Image.asset("assets/images/expiry.png",
                                                height: 150, width: 180, fit: BoxFit.fill,),
                                            ),
                                          ))
                                  ]),
                                );
                              });
                        } else if (snapshot.connectionState == ConnectionState.done && snapshot.data == null) {
                          return Center(
                            child: Text(S.of(context).No_vouchers),
                          );
                        }
                        else if(snapshot.connectionState == ConnectionState.done && snapshot.data.isEmpty) {
                          return Center(
                            child: Text(S.of(context).No_vouchers),
                          );
                        }
                        else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                    // child:

                    //     Wrap(children: [

                    //     ],)
                  )
                ],
              ),
            ))
    );
  }
}

class VoucherView extends StatefulWidget {
  final image;

  const VoucherView({Key? key, this.image}) : super(key: key);

  @override
  _VoucherViewState createState() => _VoucherViewState();
}

class _VoucherViewState extends State<VoucherView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).myvoucher,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Image.network(widget.image),
      ),
    );
  }
}
