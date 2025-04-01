import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:ctown/common/constants/route_list.dart';
import 'package:ctown/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/constants/general.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/user_model.dart';
import '../../screens/base.dart';
import '../../services/index.dart';

class UserUpdate extends StatefulWidget {
  @override
  _StateUserUpdate createState() => _StateUserUpdate();
}

class _StateUserUpdate extends BaseScreen<UserUpdate> {
  TextEditingController? userEmail;
  late TextEditingController userPassword;
  late TextEditingController userDisplayName;
  late TextEditingController userNiceName;
  late TextEditingController userUrl;
  TextEditingController? userPhone;
  TextEditingController? userPhonenumber;
  late TextEditingController currentPassword;
  TextEditingController? firstname;
  TextEditingController? secondname;

  String? avatar;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void afterFirstLayout(BuildContext context) {
    final user = Provider.of<UserModel>(context, listen: false).user!;
    printLog("current_user123");
    printLog(user.mobile_no);
    final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
    setState(() {
      userEmail = TextEditingController(text: user.email);
      firstname = TextEditingController(text: user.firstName);
      secondname = TextEditingController(text: user.lastName);
      userPassword = TextEditingController(text: "");
      currentPassword = TextEditingController(text: "");
      userDisplayName = TextEditingController(text: user.name);
      userNiceName = TextEditingController(text: user.nicename);
      userUrl = TextEditingController(text: user.userUrl);
      userPhonenumber = TextEditingController(text: user.mobile_no);
      if (user.firstName != null && alphanumeric.hasMatch(user.firstName!)) {
        userPhone = TextEditingController(text: user.firstName);
      }
      avatar = user.picture;
    });
  }

  void updateUserInfo() {
    final user = Provider.of<UserModel>(context, listen: false).user;
    setState(() {
      isLoading = true;
    });
    Services().widget?.updateUserInfo(
        loggedInUser: user,
        onError: (e) {
          // ignore: deprecated_member_use
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e)));
          setState(() {
            isLoading = false;
          });
        },
        onSuccess: (param) {
          Provider.of<UserModel>(context, listen: false).updateUser(param);
          setState(() {
            isLoading = false;
          });

          Navigator.pop(context);
        },
        currentPassword: currentPassword.text,
        userDisplayName: userDisplayName.text,
        userEmail: userEmail!.text,
        userNiceName: userNiceName.text,
        userUrl: userUrl.text,
        userPhonenumber: userPhonenumber!.text,
        userPassword: userPassword.text);
  }

  getSavedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore')!;

    return jsonDecode(result);
  }

  updateUserProfile() async {
    final user = Provider.of<UserModel>(context, listen: false).user!;
    String url = "https://up.ctown.jo/index.php/rest/V1/customers/${user.id}";
    String token = 'h1oe6s65wunppubhvxq8hrnki9raobt1';

    var store1 = await getSavedStore();
    var storeCode =
        Provider.of<AppModel>(context, listen: false).langCode == "en"
            ? store1["store_en"]["id"]
            : store1["store_ar"]["id"];
    print(json.encode({
      "customer": {
        "id": user.id,
        "email": userEmail!.text,
        "firstname": firstname!.text,
        "lastname": secondname!.text,
        "storeId": storeCode,
        "websiteId": 1
      }
    }));
    final client = new http.Client();
    final response = await client.put(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'Authorization': 'Bearer ' + token
      },
      body: json.encode({
        "customer": {
          "id": user.id,
          "email": userEmail!.text,
          "firstname": firstname!.text,
          "lastname": secondname!.text,
          "storeId": storeCode,
          "websiteId": 1
        }
      }),
    );
    // var res = await http.put(url,
    //     headers: token != null ? {'Authorization': 'Bearer ' + token} : {},
    //     body: json.encode({
    //       "customer": {
    //         "id": user.id,
    //         "email": userEmail.text,
    //         "firstname": firstname.text,
    //         "lastname": secondname.text,
    //         "storeId": storeCode,
    //         "websiteId": 1
    //       }
    //     }));

    print(response.body);

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      print(responseBody);
      return responseBody;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context).user!;
    final langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          S.of(context).UpdateProfile,
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
      body: GestureDetector(
        onTap: () {
          Utils.hideKeyboard(context);
        },
        child: Column(
          children: <Widget>[
            // Container(
            //   height: MediaQuery.of(context).size.height * 0.25,
            //   child: Stack(
            //     children: <Widget>[
            //       Container(
            //         height: MediaQuery.of(context).size.height * 0.20,
            //         width: MediaQuery.of(context).size.width,
            //         decoration: BoxDecoration(
            //             color: Theme.of(context).primaryColor,
            //             borderRadius: const BorderRadius.vertical(
            //               bottom: Radius.elliptical(100, 10),
            //             ),
            //             boxShadow: [
            //               const BoxShadow(
            //                   color: Colors.black12,
            //                   offset: Offset(0, 2),
            //                   blurRadius: 8)
            //             ]),
            //         child: avatar != null
            //             ? Image.network(
            //                 avatar,
            //                 fit: BoxFit.cover,
            //               )
            //             : Container(),
            //       ),
            //       Align(
            //         alignment: Alignment.bottomCenter,
            //         child: Container(
            //           decoration: BoxDecoration(
            //               borderRadius: BorderRadius.circular(150),
            //               color: Theme.of(context).primaryColorLight),
            //           child: avatar != null
            //               ? Image.network(
            //                   avatar,
            //                   width: 150,
            //                   height: 150,
            //                 )
            //               : const Icon(
            //                   Icons.person,
            //                   size: 120,
            //                 ),
            //         ),
            //       ),
            //      Align(
            //        alignment: Alignment.bottomCenter,
            //        child: GestureDetector(
            //          onTap: () => Navigator.push(
            //            context,
            //            MaterialPageRoute(
            //              builder: (context) => Scaffold(
            //                appBar: AppBar(),
            //                body: WebView(
            //                  javascriptMode: JavascriptMode.unrestricted,
            //                  initialUrl: 'https://en.gravatar.com/',
            //                ),
            //              ),
            //            ),
            //          ),
            //          child: Container(
            //            margin: EdgeInsets.only(left: 80),
            //            padding: const EdgeInsets.all(7),
            //            decoration: BoxDecoration(
            //                borderRadius: BorderRadius.circular(100),
            //                color: Colors.grey.withOpacity(0.4)),
            //            child: Icon(
            //              Icons.mode_edit,
            //              size: 20,
            //            ),
            //          ),
            //        ),
            //      ),
            //       SafeArea(
            //         child: GestureDetector(
            //           onTap: () => Navigator.pop(context),
            //           child: Container(
            //             padding: const EdgeInsets.all(10),
            //             margin: const EdgeInsets.only(left: 10),
            //             child: const Icon(
            //               Icons.arrow_back_ios,
            //               color: Colors.white,
            //             ),
            //           ),
            //         ),
            //       )
            //     ],
            //   ),
            // ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(
                            height: 10,
                          ),
                          Text(S.of(context).email,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                // fontFamily:'raleway',
                                color: Theme.of(context).colorScheme.secondary,
                              )),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              controller: userEmail,
                              enabled: !user.isSocial!,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(langCode == "en" ? "First Name" : "الأسم الاول",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                // fontFamily:'raleway',
                                color: Theme.of(context).colorScheme.secondary,
                              )),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).scaffoldBackgroundColor,
                                border: Border.all(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    width: 1.5)),
                            child: TextField(
                              decoration: const InputDecoration(
                                  border: InputBorder.none),
                              controller: firstname,
                            ),
                          ),

                          Text(langCode == "en" ? "Last Name" :"الاسم الاخير",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                // fontFamily:'raleway',
                                color: Theme.of(context).colorScheme.secondary,
                              )),

                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).scaffoldBackgroundColor,
                                border: Border.all(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    width: 1.5)),
                            child: TextField(
                              decoration: const InputDecoration(
                                  border: InputBorder.none),
                              controller: secondname,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(S.of(context).phone,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.secondary,
                              )),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border.all(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                width: 1.5,
                              ),
                            ),
                            child: TextField(
                              enabled: false,
                              decoration: const InputDecoration(
                                  border: InputBorder.none),
                              controller: userPhonenumber,
                            ),
                          ),
                          // const SizedBox(height: 20),
                          // Text(S.of(context).url,
                          //     style: TextStyle(
                          //       fontSize: 16,
                          //       fontWeight: FontWeight.w600,
                          //       color: Theme.of(context).accentColor,
                          //     )),
                          // const SizedBox(height: 5),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 10),
                          //   decoration: BoxDecoration(
                          //       color: Theme.of(context).primaryColorLight,
                          //       borderRadius: BorderRadius.circular(5),
                          //       border: Border.all(
                          //           color: Theme.of(context).primaryColorLight,
                          //           width: 1.5)),
                          //   child: TextField(
                          //     decoration: const InputDecoration(
                          //         border: InputBorder.none),
                          //     controller: userUrl,
                          //   ),
                          // ),
                          // const SizedBox(height: 15),
                          // Services()
                          //     .widget
                          //     .renderCurrentPassInputforEditProfile(
                          //         context: context,
                          //         currentPasswordController: currentPassword),
                          if (!user.isSocial!)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Text(S.of(context).newPassword,
                                //     style: TextStyle(
                                //       fontSize: 14,
                                //       fontWeight: FontWeight.w600,
                                //       // fontFamily:'raleway',
                                //       color: Theme.of(context).accentColor,
                                //     )),
                                // const SizedBox(
                                //   height: 5,
                                // ),
                                // Container(
                                //   padding: const EdgeInsets.symmetric(
                                //       horizontal: 10),
                                //   decoration: BoxDecoration(
                                //       borderRadius: BorderRadius.circular(5),
                                //       border: Border.all(
                                //           color: Theme.of(context)
                                //               .primaryColorLight,
                                //           width: 1.5)),
                                //   child: TextField(
                                //     obscureText: true,
                                //     decoration: const InputDecoration(
                                //         border: InputBorder.none),
                                //     controller: userPassword,
                                //   ),
                                // ),
                              ],
                            ),
                          const SizedBox(
                            height: 50,
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: () async {
                                await updateUserProfile();
                                setState(() {
                                  user.firstName = firstname!.text;
                                  user.lastName = secondname!.text;
                                });
                                // await updateUserInfo();
                                await Navigator.of(context, rootNavigator: true)
                                    .pushReplacementNamed(RouteList.dashboard);
                              },
                              child: Container(
                                // padding: const EdgeInsets.symmetric(
                                //     horizontal: 50, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Container(
                                  height: 50,
                                  width: 400,
                                  child: isLoading
                                      ? const SpinKitCircle(
                                          color: Colors.white,
                                          size: 20.0,
                                        )
                                      : Center(
                                          child: Text(
                                            S.of(context).update,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                // fontFamily:'raleway',
                                                color: Colors.white),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
