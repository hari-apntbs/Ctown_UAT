import 'dart:convert';

import 'package:ctown/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../common/webview.dart';

class Promotionbanner extends StatefulWidget {
  // const Promotionbanner({ Key? key }) : super(key: key);

  @override
  _PromotionbannerState createState() => _PromotionbannerState();
}

class _PromotionbannerState extends State<Promotionbanner> {
  promotionbanner(lang) async {
    String apiUrl =
        "https://up.ctown.jo/api/mobile_promotion_banner_pdf_images.php";

    Map body = {"lang": lang};
    print(body);
    var response = await http.post(Uri.parse(apiUrl), body: jsonEncode(body));
    var responseBody;
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);

      print(responseBody);
      return responseBody;
    } else {
      responseBody = {};
    }
    return responseBody;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Provider.of<AppModel>(context, listen: false).langCode == 'en'
              ? "Promotion Banner"
              : "مجلة العروض",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        future: promotionbanner(
            Provider.of<AppModel>(context, listen: false).langCode == 'en'
                ? 'en'
                : 'ar'),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data != null) {
            return ListView.builder(
                itemCount: snapshot.data["data"].length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PromotionWidget(
                              url: snapshot.data["data"][index]
                                  ["pdf_page_url"])));
                    },
                    child: Container(
                      // color: Colors.red,
                      height: 130,
                      width: 600,
                      margin: const EdgeInsets.only(top: 10),
                      child: Image.network(
                        snapshot.data["data"][index]["pdf_image"],
                        fit: BoxFit.cover,
                        scale: 8,
                      ),
                    ),
                  );
                });
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class PromotionWidget extends StatelessWidget {
  final String? url;
  PromotionWidget({this.url});
  WebViewController? _controller;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Promotion Banner",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: InAppWebView(
            appBarRequire: false,
            url: url,
            javaScript: 'document.getElementById("header").style.display = "none"; document.getElementsByClassName("nav-breadcrumbs")[0].style.display = "none"; document.getElementsByClassName("page-footer")[0].style.display = "none";document.querySelector("#mobilePhonePopup").style.display = "none";document.querySelector(".page-wrapper").style.display = "";localStorage.setItem("useBrowser", "granted");',
            // onPageFinished: (e) {
            //   print("web view finsished");
            //   Future.delayed(Duration(seconds: 4), () {
            //     // _controller.evaluateJavascript('alert(hello from flutter)');
            //     _controller.evaluateJavascript(
            //         'document.getElementById("header").style.display = "none"; document.getElementsByClassName("nav-breadcrumbs")[0].style.display = "none"; document.getElementsByClassName("page-footer")[0].style.display = "none";');
            //     // _controller.evaluateJavascript(
            //     //     '\$("#header").hide(); \$(".header")[0].hide();\$(".page-footer")[0].hide();');
            //     // _controller.evaluateJavascript(
            //     //     'Jquery("#header").hide(); Jquery(".header")[0].hide();Jquery(".page-footer")[0].hide();');
            //   });
            // },
            // 'https://flutter.dev',
          ),
        ),
      ),
    );
  }
}
