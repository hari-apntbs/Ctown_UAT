import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:io';

import 'package:ctown/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/user_model.dart';
import '../../values/values.dart';

Future<Album> fetchAlbum() async {
  final response = await http.get(Uri.parse('https://up.ctown.jo/api/getloyalty.php'));
  printLog("xcvbdfgsdfvxcgf");
  printLog('https://up.ctown.jo/api/getloyalty.php');
  if (response.statusCode == 200) {
    final jsonresponse = json.decode(response.body);
    return Album.fromJson(jsonresponse);
  } else {
    throw Exception('Failed to load album');
  }
}

class Album {
  final int? userId;
  final String? loylatyCardNumber;
  final String? firstName;
  final String? programname;
  final availablePoints;
  // final String availableAmount;

  Album({
    this.userId,
    this.loylatyCardNumber,
    this.firstName,
    this.programname,
    this.availablePoints,
    //this.availableAmount
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      loylatyCardNumber: json['loylatyCardNumber'],
      firstName: json['firstName'],
      programname: json['programName'],
      availablePoints: json['availablePoints'],
      // availableAmount: json['availableAmount'],
    );
  }
}

class JamaeytiWidget extends StatefulWidget {
  JamaeytiWidget({Key? key}) : super(key: key);

  @override
  _JamaeytiWidgetState createState() => _JamaeytiWidgetState();
}

class _JamaeytiWidgetState extends State<JamaeytiWidget> {
  UserModel? userModel;
  DateTime? dateTime;
  final ScrollController _scrollController = ScrollController();

  couponcode(String? userid) async {
    var url =
        "https://up.ctown.jo/api/loyalty_redeemption.php?id=$userid&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}";
    printLog(url);
    var res = await http.get(Uri.parse(url));

    final response = jsonDecode(res.body);
    if (response["success"] == 1) {
      print("userid");

      // print(userModel.user.id);
      printLog(response['data']);
      return response['data'];
    } else {
      printLog("userid");
      // print(userModel.user.id);
    }
  }

  bool onSelect = true;
  Future<Album>? futureAlbum;
  int? _value = 3;
  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  Future getData(BuildContext context, String url, id) async {
    // print("user id $id");
    Map<String, dynamic> _queryParams = {};
    _queryParams['id'] = id;
    var uri =
        "$url?id=$id&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}";
    printLog("fgdfasdgsfhgfghsdf");
    printLog(uri);

    var res = await http.get(Uri.parse(uri));
    //res = res.replace(queryParameters: _queryParams);
    // var res=http.post(
    //   url,
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //   },
    //   body: jsonEncode(<String, String>{
    //     'id': '34',
    //   }),
    // );
    if (res.statusCode == 200) {
      return res.body;
    } else {
      final body = convert.jsonDecode(res.body);

      Tools.showSnackBar(
        ScaffoldMessenger.of(context),
        body["message"] != null
            ? body["message"]
            : 'Incorrect OTP. Retry with correct OTP',
      );
    }
  }

  Future getData1(BuildContext context, String url, id) async {
    Map<String, dynamic> _queryParams = {};
    _queryParams['user_id'] = id;
    var uri =
        "$url?id=$id&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}";
    print(uri);

    var res = await http.get(Uri.parse(uri));
    if (res.statusCode == 200) {
      return res.body;
    } else {
      final body = convert.jsonDecode(res.body);

      Tools.showSnackBar(
        ScaffoldMessenger.of(context),
        body["message"] != null
            ? body["message"]
            : 'Incorrect OTP. Retry with correct OTP',
      );
    }
  }

  Future<void> _onScrollsToTop(ScrollsToTopEvent event) async {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 1000), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context, listen: false).user!;
    String? user_id = user.id;
    return Platform.isIOS ? ScrollsToTop(
      onScrollsToTop: _onScrollsToTop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            S.of(context).jamaeyati,
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
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FutureBuilder(
                future: getData(
                    context, 'https://up.ctown.jo/api/getloyalty.php', user_id),
                builder: (context, AsyncSnapshot snap) {
                  if (!snap.hasData) {
                    return kLoadingWidget(context);
                  }
                  if (snap.data.isEmpty) {
                    return const Center(
                      child: Text("No data"),
                    );
                  }
                  Map map = jsonDecode(snap.data);
                  print("Smile map");
                  print(map);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Text('Smiles'),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          // width: 252,
                          // height: 155,
                          margin: const EdgeInsets.all(5.0),
                          child: Column(
                            children: [
                              Container(
                                // width: 400,
                                // height: 165,
                                child: Image.asset(
                                  Provider.of<AppModel>(context, listen: false)
                                              .langCode ==
                                          'en'
                                      ? "assets/images/membership2.jpg"
                                      : "assets/images/membership3.jpg",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 5.0, right: 5, top: 0, bottom: 0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 0.1,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                            color: Colors.white),
                        //width: MediaQuery.of(context).size.width,
                        // width: MediaQuery.of(context).size.width * 0.8,
                        child: Center(
                          child: map['programName'] == 'Gold'
                              ? Table(
                                  children: [
                                    // TableRow(
                                    //
                                    //     children: [
                                    //       Text('Member Name',
                                    //         style: TextStyle(height: 1.5,fontFamily: 'raleway'),),
                                    //       Text(map['firstName'].toString(),
                                    //         style: TextStyle(height: 1.5,fontFamily: 'raleway'),)
                                    //     ]
                                    // ),

                                    TableRow(children: [
                                      const Text(
                                        'Jamaeyati No.',
                                        style: TextStyle(
                                          height: 1.5,
                                          color: AppColors.primaryText,
                                          // fontFamily: 'raleway',
                                        ),
                                      ),
                                      Text(
                                        map['loylatyCardNumber'].toString(),
                                        style: const TextStyle(
                                          height: 1.5,
                                          color: AppColors.primaryText,
                                          // fontFamily: 'raleway',
                                        ),
                                      )
                                    ]),
                                    TableRow(children: [
                                      const Text(
                                        'Available Points',
                                        style: TextStyle(
                                          color: AppColors.primaryText,
                                          height: 1.5,
                                          // fontFamily: 'raleway',
                                        ),
                                      ),
                                      Text(
                                        map['availablePoints'].toString(),
                                        style: const TextStyle(
                                          height: 1.5,
                                          color: AppColors.primaryText,
                                          // fontFamily: 'raleway',
                                        ),
                                      )
                                    ]),
                                    // TableRow(children: [
                                    //   Text(
                                    //     'Member Tier',
                                    //     style: TextStyle(
                                    //       color: AppColors.primaryText,
                                    //       height: 1.5,
                                    //       // fontFamily: 'raleway',
                                    //     ),
                                    //   ),
                                    //   Text(
                                    //     map['programName'].toString(),
                                    //     style: TextStyle(
                                    //       height: 1.5,
                                    //       color: AppColors.primaryText,
                                    //       // fontFamily: 'raleway',
                                    //     ),
                                    //   ),
                                    // ]),
                                    TableRow(children: [
                                      const Text(
                                        'Share Holding',
                                        style: TextStyle(
                                          height: 1.5,
                                          color: AppColors.primaryText,
                                          // fontFamily: 'raleway',
                                        ),
                                      ),
                                      Text(
                                        map['shareholding'].toString(),
                                        style: const TextStyle(
                                          height: 1.5,
                                          color: AppColors.primaryText,
                                          // fontFamily: 'raleway',
                                        ),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      const Text(
                                        'Transaction Amount',
                                        style: TextStyle(
                                          height: 1.5,
                                          color: AppColors.primaryText,
                                          // fontFamily: 'raleway',
                                        ),
                                      ),
                                      Text(
                                        map['transactionAmount'].toString(),
                                        style: const TextStyle(
                                          height: 1.5,
                                          color: AppColors.primaryText,
                                          // fontFamily: 'raleway',
                                        ),
                                      ),
                                    ]),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Table(
                                      children: [
                                        // TableRow(
                                        //
                                        //     children: [
                                        //       Text('Member Name',
                                        //         style: TextStyle(height: 1.5,fontFamily: 'raleway'),),
                                        //       Text(map['firstName'].toString(),
                                        //         style: TextStyle(height: 1.5,fontFamily: 'raleway'),)
                                        //     ]
                                        // ),

                                        TableRow(children: [
                                          Text(
                                            S.of(context).jamaeyati_no,
                                            style: const TextStyle(
                                              height: 1.5,
                                              color: AppColors.primaryText,
                                              // fontFamily: 'raleway',
                                            ),
                                          ),
                                          Text(
                                            map['loylatyCardNumber'].toString(),
                                            style: const TextStyle(
                                              height: 1.5,
                                              color: AppColors.primaryText,
                                              // fontFamily: 'raleway',
                                            ),
                                          )
                                        ]),
                                        TableRow(children: [
                                          Text(
                                            S.of(context).available_points,
                                            style: const TextStyle(
                                              height: 1.5,
                                              color: AppColors.primaryText,
                                              // fontFamily: 'raleway',
                                            ),
                                          ),
                                          Text(
                                            map['availablePoints'].toString(),
                                            style: const TextStyle(
                                              height: 1.5,
                                              color: AppColors
                                                  .primaryText, // fontFamily: 'raleway',
                                            ),
                                          )
                                        ]),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Image.network(
                                        "https://up.ctown.jo/api/barcode/barcode.php?text=${map['loylatyCardNumber']}&print=false&size=30")
                                  ],
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              Container(
                margin:
                    const EdgeInsets.only(top: 5.0, bottom: 0, left: 5, right: 5),
                decoration: const BoxDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FutureBuilder(
                      future: getData1(context,
                          'https://up.ctown.jo/api/loyaltytransaction.php', user_id),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return Container();
                        }
                        if (snap.data.isEmpty) {
                          return Center(
                            child: Text(
                              // 'No data to display'
                              S.of(context).No_data_to_display,
                            ),
                          );
                        }
                        List? map = jsonDecode(snap.data);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        onSelect = true;
                                      });
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 180,
                                      color: onSelect == false
                                          ? Colors.white
                                          : Theme.of(context).primaryColor,
                                      child: Center(
                                        child: Text(
                                          S.of(context).transactions,
                                          // "Transactions",
                                          // textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: onSelect == true
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.w400,
                                            // fontFamily: 'raleway',
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // SizedBox(width:20),
                                  InkWell(
                                    onTap: () {
                                      printLog("sucess");
                                      // onSelect==true?false:true;
                                      setState(() {
                                        onSelect = false;
                                        printLog(onSelect);
                                      });
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 170,
                                      color: onSelect == false
                                          ? Theme.of(context).primaryColor
                                          : Colors.white,
                                      child: Center(
                                        child: Text(
                                          Provider.of<AppModel>(context)
                                                      .langCode ==
                                                  'en'
                                              ? "Active Voucher"
                                              : "قسيمة ياهلا ",
                                          // "Active Voucher",
                                          // "Transactions",
                                          // textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: onSelect == false
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.w400,
                                            // fontFamily: 'raleway',
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                            if (onSelect == false)
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                color: Theme.of(context).primaryColor,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      // color: Colors.red,
                                      height: 20,
                                      child: Text(
                                        Provider.of<AppModel>(context, listen: false).langCode ==
                                                'en'
                                            ? "Voucher No#"
                                            : "رقم القسيمة ",
                                        // "Voucher No#",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      //  color: Colors.red,
                                      height: 20,
                                      child: Text(
                                          Provider.of<AppModel>(context)
                                                      .langCode ==
                                                  'en'
                                              ? "Expiry Date"
                                              : "تاريخ الإنتهاء ",

                                          // "Expiry Date",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          )),
                                    ),
                                    Container(
                                      //  color: Colors.red,
                                      height: 20,
                                      child: Text(
                                          Provider.of<AppModel>(context)
                                                      .langCode ==
                                                  'en'
                                              ? "Redeemed Points"
                                              : "لنقاط المكتسبة ",
                                          // "Redeemed Points",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          )),
                                    ),
                                    Container(
                                      //  color: Colors.red,
                                      height: 20,
                                      child: Text(
                                          Provider.of<AppModel>(context)
                                                      .langCode ==
                                                  'en'
                                              ? "Loyalty Amount"
                                              : "قيمة القسيمة ",

                                          // "Loyalty Amount",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            if (onSelect == false)
                              Container(
                                margin: const EdgeInsets.only(bottom: 5),
                                height: 300,
                                child: FutureBuilder(
                                  future: couponcode(user_id),
                                  builder: (context, AsyncSnapshot snapshot) {
                                    if (snapshot.data != null) {
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 5),
                                        height: 500,
                                        child: ListView.builder(
                                          // scrollDirection: Axis.horizontal,
                                          itemCount: snapshot.data.length,
                                          itemBuilder: (context, index) {
                                            return snapshot.data[index] != null && snapshot.data[index]
                                            ["isActive"] == true
                                                ? Row(
                                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                                    children: [
                                                      Center(
                                                        child: Container(
                                                            width: 85,
                                                            child: Text(
                                                              snapshot.data[index]
                                                                      [
                                                                      'voucherBarcode']
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 11),
                                                            )),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Center(
                                                        child: Container(
                                                            width: 60,
                                                            child: Text(
                                                              snapshot.data[index]
                                                                      [
                                                                      'expiryDate']
                                                                  .toString()
                                                                  .substring(
                                                                      0, 10),
                                                              style: const TextStyle(
                                                                  fontSize: 11),
                                                            )),
                                                      ),
                                                      const SizedBox(
                                                        width: 50,
                                                      ),
                                                      Center(
                                                        child: Container(
                                                            width: 30,
                                                            child: Text(
                                                              snapshot.data[index]
                                                                      [
                                                                      'redeemedPoints']
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 12),
                                                            )),
                                                      ),
                                                      const SizedBox(
                                                        width: 60,
                                                      ),
                                                      Center(
                                                        child: Container(
                                                            width: 30,
                                                            child: Text(
                                                              snapshot.data[index]
                                                                      ['amount']
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  fontSize: 12),
                                                            )),
                                                      )
                                                    ],
                                                  )
                                                : Container();
                                          },
                                        ),
                                      );
                                    }
                                    return Container();
                                  },
                                ),
                              ),
                            if(onSelect == true)
                              const SizedBox(height: 10,),
                            if (onSelect == true)
                              Container(
                                alignment: Alignment.center,
                                child: DropdownButton<int>(
                                    hint: Text(
                                      // "Select Type"
                                      S.of(context).select_type,
                                    ),
                                    value: _value,
                                    items: [
                                      DropdownMenuItem(
                                        child: Text(
                                          // "Last 2 weeks transactions"
                                          S.of(context).Last_2_weeks_transactions,
                                        ),
                                        value: 1,
                                      ),
                                      DropdownMenuItem(
                                        child: Text(
                                          // "Last month transactions"
                                          S.of(context).Last_month_transactions,
                                        ),
                                        value: 2,
                                      ),
                                      DropdownMenuItem(
                                          child: Text(
                                            // "Last 6 months transactions"
                                            S
                                                .of(context)
                                                .Last_6_months_transactions,
                                          ),
                                          value: 3),
                                      DropdownMenuItem(
                                          child: Text(
                                            // "Last year transactions",
                                            S.of(context).Last_year_transactions,
                                          ),
                                          value: 4)
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _value = value;
                                      });
                                    }),
                              ),
                            if (onSelect == true)
                              Container(
                                margin: const EdgeInsets.only(top: 5.0),
                                padding: const EdgeInsets.only(top: 0.0),
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 0.5,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(3)),
                                    ),
                                    child: Table(
                                      border: const TableBorder.symmetric(
                                        inside: BorderSide(
                                            width: 0.12, color: Colors.black),
                                      ),
                                      columnWidths: {
                                        0: const FlexColumnWidth(6),
                                        1: const FlexColumnWidth(5),
                                        2: const FlexColumnWidth(6),
                                        3: const FlexColumnWidth(3),
                                      },
                                      children: _filteredTransactionList(
                                          _value, map)
                                        ..insert(
                                          0,
                                          TableRow(
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius: const BorderRadius
                                                        .horizontal(
                                                    left: Radius.circular(0.0),
                                                    right: Radius.circular(0.0))),
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0,
                                                    top: 6.0,
                                                    bottom: 6.0),
                                                child: Text(
                                                  S.of(context).receiptno,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0,
                                                    top: 6.0,
                                                    bottom: 6.0),
                                                child: Text(
                                                    S.of(context).jam_date,
                                                    style: const TextStyle(
                                                        color: Colors.white)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0,
                                                    top: 6.0,
                                                    bottom: 6.0),
                                                child: Text(
                                                    Provider.of<AppModel>(context)
                                                                .langCode ==
                                                            'en'
                                                        ? S.of(context).purchase
                                                        : "طريقة الشراء ",
                                                    // S.of(context).purchase,
                                                    style: const TextStyle(
                                                        color: Colors.white)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0,
                                                    top: 6.0,
                                                    bottom: 6.0),
                                                child: Text(S.of(context).points,
                                                    style: const TextStyle(
                                                        color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ) :Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).jamaeyati,
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FutureBuilder(
              future: getData(
                  context, 'https://up.ctown.jo/api/getloyalty.php', user_id),
              builder: (context, AsyncSnapshot snap) {
                if (!snap.hasData) {
                  return kLoadingWidget(context);
                }
                if (snap.data.isEmpty) {
                  return const Center(
                    child: Text("No data"),
                  );
                }
                Map map = jsonDecode(snap.data);
                print("Smile map");
                print(map);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text('Smiles'),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        // width: 252,
                        // height: 155,
                        margin: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              // width: 400,
                              // height: 165,
                              child: Image.asset(
                                Provider.of<AppModel>(context, listen: false)
                                    .langCode ==
                                    'en'
                                    ? "assets/images/membership2.jpg"
                                    : "assets/images/membership3.jpg",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          left: 5.0, right: 5, top: 0, bottom: 0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 0.1,
                          ),
                          borderRadius:
                          const BorderRadius.all(Radius.circular(5)),
                          color: Colors.white),
                      //width: MediaQuery.of(context).size.width,
                      // width: MediaQuery.of(context).size.width * 0.8,
                      child: Center(
                        child: map['programName'] == 'Gold'
                            ? Table(
                          children: [
                            // TableRow(
                            //
                            //     children: [
                            //       Text('Member Name',
                            //         style: TextStyle(height: 1.5,fontFamily: 'raleway'),),
                            //       Text(map['firstName'].toString(),
                            //         style: TextStyle(height: 1.5,fontFamily: 'raleway'),)
                            //     ]
                            // ),

                            TableRow(children: [
                              const  Text(
                                'Jamaeyati No.',
                                style: TextStyle(
                                  height: 1.5,
                                  color: AppColors.primaryText,
                                  // fontFamily: 'raleway',
                                ),
                              ),
                              Text(
                                map['loylatyCardNumber'].toString(),
                                style: const TextStyle(
                                  height: 1.5,
                                  color: AppColors.primaryText,
                                  // fontFamily: 'raleway',
                                ),
                              )
                            ]),
                            TableRow(children: [
                              const Text(
                                'Available Points',
                                style: TextStyle(
                                  color: AppColors.primaryText,
                                  height: 1.5,
                                  // fontFamily: 'raleway',
                                ),
                              ),
                              Text(
                                map['availablePoints'].toString(),
                                style: const TextStyle(
                                  height: 1.5,
                                  color: AppColors.primaryText,
                                  // fontFamily: 'raleway',
                                ),
                              )
                            ]),
                            // TableRow(children: [
                            //   Text(
                            //     'Member Tier',
                            //     style: TextStyle(
                            //       color: AppColors.primaryText,
                            //       height: 1.5,
                            //       // fontFamily: 'raleway',
                            //     ),
                            //   ),
                            //   Text(
                            //     map['programName'].toString(),
                            //     style: TextStyle(
                            //       height: 1.5,
                            //       color: AppColors.primaryText,
                            //       // fontFamily: 'raleway',
                            //     ),
                            //   ),
                            // ]),
                            TableRow(children: [
                              const Text(
                                'Share Holding',
                                style: TextStyle(
                                  height: 1.5,
                                  color: AppColors.primaryText,
                                  // fontFamily: 'raleway',
                                ),
                              ),
                              Text(
                                map['shareholding'].toString(),
                                style: const TextStyle(
                                  height: 1.5,
                                  color: AppColors.primaryText,
                                  // fontFamily: 'raleway',
                                ),
                              ),
                            ]),
                            TableRow(children: [
                              const Text(
                                'Transaction Amount',
                                style: TextStyle(
                                  height: 1.5,
                                  color: AppColors.primaryText,
                                  // fontFamily: 'raleway',
                                ),
                              ),
                              Text(
                                map['transactionAmount'].toString(),
                                style: const TextStyle(
                                  height: 1.5,
                                  color: AppColors.primaryText,
                                  // fontFamily: 'raleway',
                                ),
                              ),
                            ]),
                          ],
                        )
                            : Column(
                          children: [
                            Table(
                              children: [
                                // TableRow(
                                //
                                //     children: [
                                //       Text('Member Name',
                                //         style: TextStyle(height: 1.5,fontFamily: 'raleway'),),
                                //       Text(map['firstName'].toString(),
                                //         style: TextStyle(height: 1.5,fontFamily: 'raleway'),)
                                //     ]
                                // ),

                                TableRow(children: [
                                  Text(
                                    S.of(context).jamaeyati_no,
                                    style: const TextStyle(
                                      height: 1.5,
                                      color: AppColors.primaryText,
                                      // fontFamily: 'raleway',
                                    ),
                                  ),
                                  Text(
                                    map['loylatyCardNumber'].toString(),
                                    style: const TextStyle(
                                      height: 1.5,
                                      color: AppColors.primaryText,
                                      // fontFamily: 'raleway',
                                    ),
                                  )
                                ]),
                                TableRow(children: [
                                  Text(
                                    S.of(context).available_points,
                                    style: const TextStyle(
                                      height: 1.5,
                                      color: AppColors.primaryText,
                                      // fontFamily: 'raleway',
                                    ),
                                  ),
                                  Text(
                                    map['availablePoints'].toString(),
                                    style: const TextStyle(
                                      height: 1.5,
                                      color: AppColors
                                          .primaryText, // fontFamily: 'raleway',
                                    ),
                                  )
                                ]),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Image.network(
                                "https://up.ctown.jo/api/barcode/barcode.php?text=${map['loylatyCardNumber']}&print=false&size=30")
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            Container(
              margin:
              const EdgeInsets.only(top: 5.0, bottom: 0, left: 5, right: 5),
              decoration: const BoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FutureBuilder(
                    future: getData1(context,
                        'https://up.ctown.jo/api/loyaltytransaction.php', user_id),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return Container();
                      }
                      if (snap.data.isEmpty) {
                        return Center(
                          child: Text(
                            // 'No data to display'
                            S.of(context).No_data_to_display,
                          ),
                        );
                      }
                      List? map = jsonDecode(snap.data);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      onSelect = true;
                                    });
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 180,
                                    color: onSelect == false
                                        ? Colors.white
                                        : Theme.of(context).primaryColor,
                                    child: Center(
                                      child: Text(
                                        S.of(context).transactions,
                                        // "Transactions",
                                        // textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: onSelect == true
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w400,
                                          // fontFamily: 'raleway',
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // SizedBox(width:20),
                                InkWell(
                                  onTap: () {
                                    print("sucess");
                                    // onSelect==true?false:true;
                                    setState(() {
                                      onSelect = false;
                                      printLog(onSelect);
                                    });
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 170,
                                    color: onSelect == false
                                        ? Theme.of(context).primaryColor
                                        : Colors.white,
                                    child: Center(
                                      child: Text(
                                        Provider.of<AppModel>(context)
                                            .langCode ==
                                            'en'
                                            ? "Active Voucher"
                                            : "قسيمة ياهلا ",
                                        // "Active Voucher",
                                        // "Transactions",
                                        // textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: onSelect == false
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w400,
                                          // fontFamily: 'raleway',
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                          if (onSelect == false)
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              color: Theme.of(context).primaryColor,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    // color: Colors.red,
                                    height: 20,
                                    child: Text(
                                      Provider.of<AppModel>(context, listen: false).langCode ==
                                          'en'
                                          ? "Voucher No#"
                                          : "رقم القسيمة ",
                                      // "Voucher No#",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    //  color: Colors.red,
                                    height: 20,
                                    child: Text(
                                        Provider.of<AppModel>(context)
                                            .langCode ==
                                            'en'
                                            ? "Expiry Date"
                                            : "تاريخ الإنتهاء ",

                                        // "Expiry Date",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        )),
                                  ),
                                  Container(
                                    //  color: Colors.red,
                                    height: 20,
                                    child: Text(
                                        Provider.of<AppModel>(context)
                                            .langCode ==
                                            'en'
                                            ? "Redeemed Points"
                                            : "لنقاط المكتسبة ",
                                        // "Redeemed Points",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        )),
                                  ),
                                  Container(
                                    //  color: Colors.red,
                                    height: 20,
                                    child: Text(
                                        Provider.of<AppModel>(context)
                                            .langCode ==
                                            'en'
                                            ? "Loyalty Amount"
                                            : "قيمة القسيمة ",

                                        // "Loyalty Amount",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                          if (onSelect == false)
                            Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              height: 300,
                              child: FutureBuilder(
                                future: couponcode(user_id),
                                builder: (context, AsyncSnapshot snapshot) {
                                  if (snapshot.data != null) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 5),
                                      height: 500,
                                      child: ListView.builder(
                                        // scrollDirection: Axis.horizontal,
                                        itemCount: snapshot.data.length,
                                        itemBuilder: (context, index) {
                                          return snapshot.data[index] != null && snapshot.data[index]
                                          ["isActive"] ==
                                              true
                                              ? Row(
                                            // crossAxisAlignment: CrossAxisAlignment.start,
                                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                            children: [
                                              Center(
                                                child: Container(
                                                    width: 85,
                                                    child: Text(
                                                      snapshot.data[index]
                                                      [
                                                      'voucherBarcode']
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 11),
                                                    )),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Center(
                                                child: Container(
                                                    width: 60,
                                                    child: Text(
                                                      snapshot.data[index]
                                                      [
                                                      'expiryDate']
                                                          .toString()
                                                          .substring(
                                                          0, 10),
                                                      style: const TextStyle(
                                                          fontSize: 11),
                                                    )),
                                              ),
                                              const SizedBox(
                                                width: 50,
                                              ),
                                              Center(
                                                child: Container(
                                                    width: 30,
                                                    child: Text(
                                                      snapshot.data[index]
                                                      [
                                                      'redeemedPoints']
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    )),
                                              ),
                                              const SizedBox(
                                                width: 60,
                                              ),
                                              Center(
                                                child: Container(
                                                    width: 30,
                                                    child: Text(
                                                      snapshot.data[index]
                                                      ['amount']
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    )),
                                              )
                                            ],
                                          )
                                              : Container();
                                        },
                                      ),
                                    );
                                  }
                                  return Container();
                                },
                              ),
                            ),
                          if(onSelect == true)
                            const SizedBox(height: 10,),
                          if (onSelect == true)
                            Container(
                              alignment: Alignment.center,
                              child: DropdownButton<int>(
                                  hint: Text(
                                    // "Select Type"
                                    S.of(context).select_type,
                                  ),
                                  value: _value,
                                  items: [
                                    DropdownMenuItem(
                                      child: Text(
                                        // "Last 2 weeks transactions"
                                        S.of(context).Last_2_weeks_transactions,
                                      ),
                                      value: 1,
                                    ),
                                    DropdownMenuItem(
                                      child: Text(
                                        // "Last month transactions"
                                        S.of(context).Last_month_transactions,
                                      ),
                                      value: 2,
                                    ),
                                    DropdownMenuItem(
                                        child: Text(
                                          // "Last 6 months transactions"
                                          S
                                              .of(context)
                                              .Last_6_months_transactions,
                                        ),
                                        value: 3),
                                    DropdownMenuItem(
                                        child: Text(
                                          // "Last year transactions",
                                          S.of(context).Last_year_transactions,
                                        ),
                                        value: 4)
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _value = value;
                                    });
                                  }),
                            ),
                          if (onSelect == true)
                            Container(
                              margin: const EdgeInsets.only(top: 5.0),
                              padding: const EdgeInsets.only(top: 0.0),
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 0.5,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(3)),
                                  ),
                                  child: Table(
                                    border: TableBorder.symmetric(
                                      inside: const BorderSide(
                                          width: 0.12, color: Colors.black),
                                    ),
                                    columnWidths: {
                                      0: const FlexColumnWidth(6),
                                      1: const FlexColumnWidth(5),
                                      2: const FlexColumnWidth(6),
                                      3: const FlexColumnWidth(3),
                                    },
                                    children: _filteredTransactionList(
                                        _value, map)
                                      ..insert(
                                        0,
                                        TableRow(
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius: const BorderRadius
                                                  .horizontal(
                                                  left: Radius.circular(0.0),
                                                  right: Radius.circular(0.0))),
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                  top: 6.0,
                                                  bottom: 6.0),
                                              child: Text(
                                                S.of(context).receiptno,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                  top: 6.0,
                                                  bottom: 6.0),
                                              child: Text(
                                                  S.of(context).jam_date,
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                  top: 6.0,
                                                  bottom: 6.0),
                                              child: Text(
                                                  Provider.of<AppModel>(context)
                                                      .langCode ==
                                                      'en'
                                                      ? S.of(context).purchase
                                                      : "طريقة الشراء ",
                                                  // S.of(context).purchase,
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                  top: 6.0,
                                                  bottom: 6.0),
                                              child: Text(S.of(context).points,
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TableRow> _filteredTransactionList(
      int? selection, List<dynamic>? transactionList) {
    DateTime fromDate;
    DateTime todate;
    DateTime todayDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    switch (selection) {
      case 1: // Last Two Weeks
        todate = todayDate;
        fromDate = todayDate.subtract(const Duration(days: 14));
        break;
      case 2: // Last One Month
        todate = todayDate;
        fromDate = DateTime(todayDate.year, todayDate.month - 1, todayDate.day);
        break;
      case 3: // Last Six Months
        todate = todayDate;
        fromDate = DateTime(todayDate.year, todayDate.month - 6, todayDate.day);
        break;
      case 4: // Last One Year
      default:
        todate = todayDate;
        fromDate = DateTime(todayDate.year - 1, todayDate.month, todayDate.day);
        break;
    }

    List<TableRow> rows = [];

    transactionList!.forEach((e) {
      var tempDate = DateFormat("dd-MM-yyyy", "en").parse(e['purchaseDate']);
      if (tempDate.isAfter(fromDate.subtract(const Duration(seconds: 1))) &&
          tempDate.isBefore(todate.add(const Duration(seconds: 1)))) {
        rows.add(TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                e['receiptNo'].toString(),
                style: const TextStyle(
                  height: 1.5,
                  // fontFamily: 'raleway',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                e['purchaseDate'].toString().substring(0, 10),
                style: const TextStyle(
                  height: 1.5,
                  // fontFamily: 'raleway',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                e['terminal'].toString() == 'online' ? 'Online' : 'retail',
                style: const TextStyle(
                  height: 1.5,
                  // fontFamily: 'raleway',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 3),
              child: Text(e['loyaltyPoints'].toString(),
                  style: const TextStyle(
                    height: 1.5,
                    // fontFamily: 'raleway',
                  ),
                  textAlign: TextAlign.end),
            ),
          ],
        ));
       }
    });

    return rows;
  }
}
