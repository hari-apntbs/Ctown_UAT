import 'dart:convert';

import 'package:ctown/common/constants/general.dart';
import 'package:ctown/common/constants/route_list.dart';
import 'package:ctown/frameworks/magento/services/magento.dart';
import 'package:ctown/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app.dart';
import '../../cache_manager_file.dart';
import '../../common/config/languages.dart';
import '../../common/constants/loading.dart';
import '../../generated/l10n.dart';
import '../../models/app_model.dart';
import '../../models/cart/cart_base.dart';
import '../../models/index.dart';
import '../../services/index.dart';
import 'deals.dart';

class Language extends StatefulWidget {
  @override
  _LanguageState createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  final GlobalKey<ScaffoldState> _scaffordKey = GlobalKey<ScaffoldState>();
  List<Widget> list = [];
  List<Map<String, dynamic>> languages = [
    {
      "name": "English",
      "icon": ImageCountry.GB,
      "code": "en",
      "text": "English",
      "storeViewCode": ""
    },
    {
      "name": "عربى",
      "icon": ImageCountry.AR,
      "code": "ar",
      "text": "عربى",
      "storeViewCode": "ar"
    },
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _showLoading(String language) {
    final snackBar = SnackBar(
      content: Text(
        S.of((App.navigatorKey.currentState?.context)!).languageSuccess,
        style: const TextStyle(
          fontSize: 15,
        ),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: Theme.of((App.navigatorKey.currentState?.context)!).primaryColor,
      action: SnackBarAction(
        label: language,
        onPressed: () {},
      ),
    );
    // ignore: deprecated_member_use
    ScaffoldMessenger.of((App.navigatorKey.currentState?.context)!).showSnackBar(snackBar);
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
    String? id = lang == "en"
        ? store1["store_en"]["id"]
        : store1["store_ar"]["id"] ?? "";
    String quote = await MagentoApi().getQuoteId(
        token: token,
        lang: Provider.of<AppModel>((App.navigatorKey.currentState?.context)!, listen: false).langCode);
    String url = "https://up.ctown.jo/api/customer_store_quote_id_change.php";
    Map body = {"quote_id": "$quote", "store_id": "$id"};
    printLog("second body" + jsonEncode(body));
    var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    printLog(response.body);
    printLog(response.statusCode);
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      return responseBody;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).language,
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
      body: ListView.separated(
        itemCount: languages.length,
        itemBuilder: (context, i) {
          return languages[i]["code"] != Provider.of<AppModel>(context, listen: false).langCode ? Card(
            elevation: 0,
            margin: const EdgeInsets.all(0),
            child: ListTile(
              tileColor: Theme.of(context).scaffoldBackgroundColor,
              // leading: Image.asset(
              //   languages[i]["icon"],
              //   width: 30,
              //   height: 20,
              //   fit: BoxFit.cover,
              // ),
              title: Text(languages[i]["name"],
              style: TextStyle(
                color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white : Colors.black
              ),),
                onTap: () async {
                  try {
                    showDialog(context: context, builder: kLoadingWidget);
                    await Provider.of<AppModel>(context, listen: false)
                        .changeLanguage(languages[i]["code"], context);
                    _showLoading(languages[i]["text"]);
                    if (Provider.of<UserModel>(context, listen: false).loggedIn) {
                      await storecartchange(
                          Provider.of<AppModel>(context, listen: false).langCode);
                    }
                  }
                  catch(e) {
                    printLog(e.toString());
                  }
                  finally {
                    Provider.of<AppModel>(context, listen: false).setLangChange(true);
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    Navigator.of(context).pop();
                    // Navigator.of(context, rootNavigator: true).pop('dialog');
                    // Navigator.of(context, rootNavigator: true)
                    //     .pushReplacementNamed(RouteList.dashboard).then((_) {
                    //   CustomCacheManager.instance.emptyCache(); // Clear cache
                    // });
                  }
                }
            ),
          ) : const SizedBox.shrink();
        }, separatorBuilder: (BuildContext context, int index) {
          return const Divider(
            color: Colors.black12,
            height: 1.0,
            indent: 75,
            //endIndent: 20,
          );
      },
      ),
    );
  }
}
