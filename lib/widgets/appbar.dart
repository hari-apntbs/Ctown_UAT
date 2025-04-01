import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:badges/badges.dart' as badge;
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../algolia/algolia_search.dart';
import '../algolia/credentials.dart';
import '../algolia/suggestion_repository.dart';
import '../common/constants.dart';
import '../generated/l10n.dart';
import '../models/app_model.dart';
import '../models/user_model.dart';
import '../screens/home/notification.dart';
import '../screens/index.dart';

class AppLocal extends StatefulWidget {
  String? scanBarcode;
  AppLocal({this.scanBarcode});

  @override
  _AppLocalState createState() => _AppLocalState();
}

class _AppLocalState extends State<AppLocal> {
  Future<void> onBarcodePressed(BuildContext context) async {
    var barcodeScanRes;
    try {
      barcodeScanRes = await BarcodeScanner.scan();
      printLog(barcodeScanRes);
      printLog(barcodeScanRes.type);
      printLog(barcodeScanRes.rawContent);
      if (barcodeScanRes.rawContent != '-1') {
        await getSavedStore();
        _presentAutoComplete(context, barcodeScanRes.rawContent);
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
  }

  StreamController? _userController;
  var responseBody;

  notificationcount(user_id) async {
    String apiUrl = "https://up.ctown.jo/api/mobileCustomerNotificationCount.php";
    Map body = {"user_id": "$user_id"};
    var response = await http.post(Uri.parse(apiUrl), body: jsonEncode(body));
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      printLog("Notification Count Test");
    } else {
      responseBody = {};
    }
    setState(() {});
  }

  Timer? timer;
  String currentStore = "";
  String searchIndex = "";

  @override
  void initState() {
    super.initState();

    _userController = StreamController();

    // Store necessary data in variables
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final user = Provider.of<UserModel>(context, listen: false).user;
        if (user != null) {
          Timer.periodic(const Duration(minutes: 3), (timer) {
            if (mounted) {
              notificationcount(user.id);
            } else {
              timer.cancel(); // Cancel the timer when the widget is no longer mounted
            }
          });
        }
      }
    });
  }

  void _presentAutoComplete(BuildContext context, String barcode) => Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => Provider<SuggestionRepository>(
            create: (_) => SuggestionRepository(initialIndexName: searchIndex),
            dispose: (_, value) => value.dispose(),
            child: AlgoliaSearch(
              barcode: barcode,
              indexName: searchIndex,
            )),
        fullscreenDialog: true,
      ));

  getSavedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore') ?? "";
    var jsonData = jsonDecode(result);
    if (jsonData.length > 0) {
      if (Provider.of<AppModel>(context, listen: false).langCode == "en") {
        currentStore = jsonData['store_en']['code'] ?? "";
      } else {
        currentStore = jsonData['store_ar']['code'] ?? "";
      }
      if (currentStore != "") {
        searchIndex = await Credentials.getSearchIndex(currentStore);
        printLog("==========search index $searchIndex");
      }
    }
    printLog(jsonData);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isRotate = screenSize.width > screenSize.height;
    var appModel = Provider.of<AppModel>(context);
    var isDarkTheme = appModel.darkTheme ?? false;

    return Container(
      width: screenSize.width,

      // color: Color(0xffda0c15),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: FittedBox(
        child: Container(
            width: screenSize.width / ((isRotate ? 1.25 : 2) / (screenSize.height / screenSize.width)),
            constraints: const BoxConstraints(
              minHeight: 40.0,
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 6, left: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () async {
                        // SharedPreferences prefs = await SharedPreferences.getInstance();
                        // String token = prefs.getString("inAppToken") ?? "";
                        // await Clipboard.setData(ClipboardData(text: "$token"));
                        // printLog("InApp Token $token");
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String token = prefs.getString("fcmToken") ?? "";
                        await Clipboard.setData(ClipboardData(text: token));
                        printLog(token);
                        if(Platform.isIOS) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to clipboard",), duration: Duration(milliseconds: 500),));
                        }
                        // copied successfully
                      },
                      child: Container(
                        padding: const EdgeInsets.only(right: 46, left: 5, top: 5),
                        height: 35.0,
                        width: 65,
                        decoration: BoxDecoration(
                          // color: Colors.red,
                          image: DecorationImage(
                              image: AssetImage(
                                !isDarkTheme ? "assets/images/logo.png" : "assets/images/CTOWN-LOGO.png",
                              ),
                              fit: BoxFit.fitWidth),
                        ),
                      ),
                    ),

                    // Image.asset("assets/images/logo.png",
                    //     height: 45, fit: BoxFit.cover),
                    // Container(
                    //   // width: 35,
                    //   // height: 35,
                    //   width: 75,
                    //   // color: Colors.red,
                    //   height: 35,
                    //   margin: const EdgeInsetsDirectional.only(end: 8.0),
                    //   child: Image.asset(
                    //     "assets/images/logo.png",
                    //     height: 35,
                    //     width: 75,
                    //     fit: BoxFit.fitWidth,
                    //   ),
                    // ),
                  ),
                  Expanded(
                    flex: 11,
                    child: Container(
                      // width: 280,
                      // width: MediaQuery.of(context).size.width - 120,
                      height: 35,
                      margin: const EdgeInsets.only(left: 2),

                      decoration: BoxDecoration(
                        // color: Colors.white,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        // boxShadow: [
                        //   Shadows.primaryShadow,
                        // ],
                        border: Border.all(
                            width: 0.7,
                            // color: Theme.of(context).primaryColor
                            color: Colors.grey),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Container(
                          //   width: 20,
                          //   height: 18,
                          //   margin: const EdgeInsetsDirectional.only(start: 5.0),
                          //   child: FlatButton(
                          //     onPressed: () {
                          //       Navigator.of(context)
                          //           .pushNamed(RouteList.homeSearch,arguments: '');
                          //     },
                          //     //onPressed: () => this.onLoupePressed(context),
                          //     color: const Color.fromARGB(0, 0, 0, 0),
                          //     shape: const RoundedRectangleBorder(
                          //       borderRadius:
                          //       BorderRadius.all(Radius.circular(0)),
                          //     ),
                          //     textColor: const Color.fromARGB(255, 0, 0, 0),
                          //     padding: const EdgeInsets.all(0),
                          //     child: Image.asset(
                          //       "assets/images/search.png",
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                await getSavedStore();
                                _presentAutoComplete(context, "");
                              },
                              // onTap: () => _presentAutoComplete(context),
                              // onTap: () {
                              //   Navigator.of(context).pushNamed(
                              //       RouteList.homeSearch,
                              //       arguments: '');
                              // },
                              child: Text(
                                // ' $scanBarcode',
                                S.of(context).search_placeholder,
                                //textAlign: TextAlign.left,
                                style: GoogleFonts.poppins(
                                    //fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                    // color: Colors.black,
                                    color: Theme.of(context).colorScheme.secondary),
                                // style: const TextStyle(
                                //   color: Colors.black,
                                //   fontFamily: "Poppins",
                                //   fontWeight: FontWeight.w400,
                                //   fontSize: 16,
                                // ),
                              ),
                            ),
                          ),
                          // const Spacer(),

                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(left: 10),
                              child: TextButton(
                                onPressed: () => onBarcodePressed(context),
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(0)),
                                  ),
                                  foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                                  padding: const EdgeInsets.all(0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Image.asset("assets/images/barcode.png",
                                        color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white : Colors.black),
                                    const SizedBox(
                                      width: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Provider.of<UserModel>(context, listen: false).loggedIn
                        ? responseBody != null
                            ? responseBody["success"] == 1
                                ? InkWell(
                                    onTap: () {
                                      if ((Provider.of<UserModel>(context, listen: false).loggedIn)) {
                                        // Navigator.push(context, MaterialPageRoute(builder: (context)=> Notification()));
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Notificationsceens()));
                                      } else {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                                      }
                                    },
                                    child: Container(
                                        width: 35,
                                        height: 35,
                                        margin: const EdgeInsetsDirectional.only(end: 8.0),
                                        child: badge.Badge(
                                          position: BadgePosition.topEnd(
                                            top: 5,
                                            end: 4,
                                          ),
                                          badgeContent: Text(
                                            '${responseBody["data"]["notificationCount"]}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                          child: IconButton(
                                            onPressed: () {},
                                            icon: const Icon(
                                              Icons.notifications,
                                              color: Colors.yellow,
                                              size: 25,
                                            ),
                                          ),
                                        )),
                                  )
                                : Container(
                                    width: 35,
                                    height: 35,
                                    margin: const EdgeInsetsDirectional.only(end: 8.0),
                                    child: IconButton(
                                      onPressed: () {
                                        if ((Provider.of<UserModel>(context, listen: false).loggedIn)) {
                                          // Navigator.push(context, MaterialPageRoute(builder: (context)=> Notification()));
                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => Notificationsceens()));
                                        } else {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.notifications,
                                        color: Colors.yellow,
                                        size: 25,
                                      ),
                                    ))
                            : Container(
                                width: 35,
                                height: 35,
                                margin: const EdgeInsetsDirectional.only(end: 8.0),
                                child: IconButton(
                                  onPressed: () {
                                    if ((Provider.of<UserModel>(context, listen: false).loggedIn)) {
                                      // Navigator.push(context, MaterialPageRoute(builder: (context)=> Notification()));
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => Notificationsceens()));
                                    } else {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.notifications,
                                    color: Colors.yellow,
                                    size: 25,
                                  ),
                                ))
                        : Container(
                            width: 35,
                            height: 35,
                            margin: const EdgeInsetsDirectional.only(end: 8.0),
                            child: IconButton(
                              onPressed: () {
                                if ((Provider.of<UserModel>(context, listen: false).loggedIn)) {
                                  // Navigator.push(context, MaterialPageRoute(builder: (context)=> Notification()));
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Notificationsceens()));
                                } else {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                                }
                              },
                              icon: const Icon(
                                Icons.notifications,
                                color: Colors.yellow,
                                size: 25,
                              ),
                            )),
                  )
                ],
              ),
            )),
      ),
    );
  }
}

class AppLocal2 extends StatefulWidget {
  String? scanBarcode;
  AppLocal2({this.scanBarcode});

  @override
  _AppLocal2State createState() => _AppLocal2State();
}

class _AppLocal2State extends State<AppLocal2> {
  Future<void> onBarcodePressed(BuildContext context) async {
    ScanResult barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await BarcodeScanner.scan();
      printLog(barcodeScanRes);
      printLog(barcodeScanRes.type);
      printLog(barcodeScanRes.rawContent);
      if (barcodeScanRes.rawContent != '-1') {
        await getSavedStore();
        _presentAutoComplete(context, barcodeScanRes.rawContent);
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  StreamController? _userController;
  var responseBody;

  notificationcount(user_id) async {
    String apiUrl = "https://up.ctown.jo/api/mobileCustomerNotificationCount.php";
    Map body = {"user_id": "$user_id"};
    var response = await http.post(Uri.parse(apiUrl), body: jsonEncode(body));
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      printLog("Notification Count Test");
    } else {
      responseBody = {};
    }
    setState(() {});
  }

  Timer? timer;
  String currentStore = "";
  String searchIndex = "";

  @override
  void initState() {
    // timer =
    //     Timer.periodic(const Duration(seconds: 5), (Timer t) => loadPosts());

    _userController = StreamController();
    Timer.periodic(const Duration(minutes: 3), (timer) {
      if (mounted) {
        if (Provider.of<UserModel>(context, listen: false).user != null) {
          notificationcount(Provider.of<UserModel>(context, listen: false).user!.id);
        }
      }
    });
    // feedback();

    super.initState();
  }

  void _presentAutoComplete(BuildContext context, String barcode) => Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => Provider<SuggestionRepository>(
            create: (_) => SuggestionRepository(initialIndexName: searchIndex),
            dispose: (_, value) => value.dispose(),
            child: AlgoliaSearch(
              barcode: barcode,
              indexName: searchIndex,
            )),
        fullscreenDialog: true,
      ));

  getSavedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore') ?? "";
    var jsonData = jsonDecode(result);
    if (jsonData.length > 0) {
      if (Provider.of<AppModel>(context, listen: false).langCode == "en") {
        currentStore = jsonData['store_en']['code'] ?? "";
      } else {
        currentStore = jsonData['store_ar']['code'] ?? "";
      }
      if (currentStore != "") {
        searchIndex = await Credentials.getSearchIndex(currentStore);
        printLog("==========search index $searchIndex");
      }
    }
    printLog(jsonData);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isRotate = screenSize.width > screenSize.height;
    var appModel = Provider.of<AppModel>(context);
    var isDarkTheme = appModel.darkTheme ?? false;

    return Container(
      width: screenSize.width,
      color: Theme.of(context).scaffoldBackgroundColor,
      // color: Color(0xffda0c15),
      child: FittedBox(
        // fit: BoxFit.cover,
        child: Container(
            width: screenSize.width / ((isRotate ? 1.25 : 2) / (screenSize.height / screenSize.width)),
            constraints: const BoxConstraints(
              minHeight: 40.0,
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              // padding: const EdgeInsets.only(right: 6,left: 5,top:5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () async {
                        // SharedPreferences prefs = await SharedPreferences.getInstance();
                        // String token = prefs.getString("inAppToken") ?? "";
                        // await Clipboard.setData(ClipboardData(text: "$token"));
                        // printLog("InApp Token $token");
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        String token = prefs.getString("fcmToken") ?? "";
                        await Clipboard.setData(ClipboardData(text: token));
                        printLog(token);
                        if (Platform.isIOS) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                              "Copied to clipboard",
                            ),
                            duration: Duration(milliseconds: 500),
                          ));
                        }
                      },
                      child: Container(
                        height: 45.0,
                        width: 75,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                !isDarkTheme ? "assets/images/logo.png" : "assets/images/CTOWN-LOGO.png",
                              ),
                              fit: BoxFit.fitWidth),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: Container(
                      // width: 280,
                      // width: MediaQuery.of(context).size.width - 120,
                      height: 35,
                      margin: const EdgeInsets.only(left: 0),

                      decoration: BoxDecoration(
                        // color: Colors.white,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        // boxShadow: [
                        //   Shadows.primaryShadow,
                        // ],
                        border: Border.all(
                            width: 0.7,
                            // color: Theme.of(context).primaryColor
                            color: Colors.grey),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                await getSavedStore();
                                _presentAutoComplete(context, "");
                              },
                              child: Text(
                                S.of(context).search_placeholder,
                                style: GoogleFonts.poppins(fontSize: 11, color: Theme.of(context).colorScheme.secondary),
                              ),
                            ),
                          ),
                          // const Spacer(),

                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(left: 10),
                              child: TextButton(
                                onPressed: () => onBarcodePressed(context),
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(0, 0, 0, 0),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(0)),
                                  ),
                                  foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                                  padding: const EdgeInsets.all(0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Image.asset("assets/images/barcode.png",
                                        color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white : Colors.black),
                                    const SizedBox(
                                      width: 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Provider.of<UserModel>(context, listen: false).loggedIn
                        ? responseBody != null
                            ? responseBody["success"] == 1
                                ? InkWell(
                                    onTap: () {
                                      if ((Provider.of<UserModel>(context, listen: false).loggedIn)) {
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => Notificationsceens()));
                                      } else {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                                      }
                                    },
                                    child: Container(
                                        width: 35,
                                        height: 35,
                                        margin: const EdgeInsetsDirectional.only(end: 8.0),
                                        child: badge.Badge(
                                          position: BadgePosition.topEnd(
                                            top: 5,
                                            end: 4,
                                          ),
                                          badgeContent: Text(
                                            '${responseBody["data"]["notificationCount"]}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                          ),
                                          child: IconButton(
                                            onPressed: () {},
                                            icon: const Icon(
                                              Icons.notifications,
                                              color: Colors.yellow,
                                              size: 25,
                                            ),
                                          ),
                                        )),
                                  )
                                : Container(
                                    width: 35,
                                    height: 35,
                                    margin: const EdgeInsetsDirectional.only(end: 8.0),
                                    child: IconButton(
                                      onPressed: () {
                                        if ((Provider.of<UserModel>(context, listen: false).loggedIn)) {
                                          // Navigator.push(context, MaterialPageRoute(builder: (context)=> Notification()));
                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => Notificationsceens()));
                                        } else {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.notifications,
                                        color: Colors.yellow,
                                        size: 25,
                                      ),
                                    ))
                            : Container(
                                width: 35,
                                height: 35,
                                margin: const EdgeInsetsDirectional.only(end: 8.0),
                                child: IconButton(
                                  onPressed: () {
                                    if ((Provider.of<UserModel>(context, listen: false).loggedIn)) {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Notificationsceens()));
                                    } else {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.notifications,
                                    color: Colors.yellow,
                                    size: 25,
                                  ),
                                ))
                        : Container(
                            width: 35,
                            height: 35,
                            margin: const EdgeInsetsDirectional.only(end: 8.0),
                            child: IconButton(
                              onPressed: () {
                                if ((Provider.of<UserModel>(context, listen: false).loggedIn)) {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Notificationsceens()));
                                } else {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                                }
                              },
                              icon: const Icon(
                                Icons.notifications,
                                color: Colors.yellow,
                                size: 25,
                              ),
                            )),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
