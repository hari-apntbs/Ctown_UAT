import 'dart:convert' as convert;
import 'dart:io';

import 'package:ctown/common/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:new_version_plus/new_version_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateApp extends StatefulWidget {
  final Widget? child;

  const UpdateApp({super.key, this.child});

  @override
  _UpdateAppState createState() => _UpdateAppState();
}

class _UpdateAppState extends State<UpdateApp> {
  @override
  void initState() {
    super.initState();
    printLog("fjgjhjsdfxncvasdfaks");
  }

  getMaintainanceReport() async {
    await checkLatestVersion(context);
    String uri = "https://up.ctown.jo/api/servicemaintenance.php";
    var response = await http.get(Uri.parse(uri));
    print(response.body);
    print(response.body);
    print(uri);

    var responseBody = convert.jsonDecode(response.body);
    return responseBody;
  }

  checkLatestVersion(context) async {
    printLog("cvndsfzxvcfgadg");
    final newVersion = NewVersionPlus(
      iOSId: 'jo.ctown.ecom',
      androidId: 'jo.ctown.ecom',
      androidHtmlReleaseNotes: true,
    );
    printLog("bcghdghdsdgfgh");
    final status = await newVersion.getVersionStatus();
    printLog("fgdfghghjghgjsd");
    printLog(status);
    printLog("fhgdfghsghjgkdgdfgh");
    printLog(status?.canUpdate); // (true)
    printLog(status?.localVersion); // (1.2.1)
    printLog(status?.storeVersion); // (1.2.3)
    printLog(status?.appStoreLink);
    status != null && status.canUpdate
        ? await showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              String title = "App Update Available";
              String btnLabel = "Update Now";
              return Platform.isIOS
                  ? PopScope(
                      canPop: false,
                      child: CupertinoAlertDialog(
                        title: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                          Center(
                            child: Image.asset(
                              "assets/images/ctown.jpg",
                              height: 45,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Text("New version of this app is available.Please update to continue",
                              textAlign: TextAlign.center, style: TextStyle(fontSize: 16.5)),
                          const SizedBox(
                            height: 8,
                          ),
                          const Text("Changelog",
                              textAlign: TextAlign.start, style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold)),
                          HtmlWidget('''${status.releaseNotes}''', textStyle: const TextStyle(fontSize: 16.5)),
                          const SizedBox(
                            height: 8,
                          ),
                          Center(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
                                ),
                                child: Text(btnLabel, style: const TextStyle(color: Colors.white)),
                                onPressed: () async {
                                  String? url = status.appStoreLink;
                                  await canLaunchUrl(Uri.parse(url)) ? await launchUrl(Uri.parse(url)) : throw 'Could not launch $url';
                                }
                                // _onUpdateNowClicked(urlString),
                                ),
                          ),
                        ]),
                      ),
                    )
                  : PopScope(
                      canPop: false,
                      child: AlertDialog(
                        title: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Center(
                            child: Image.asset(
                              "assets/images/ctown.jpg",
                              height: 45,
                            ),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Text("New version of this app is available.Please update to continue",
                              textAlign: TextAlign.center, style: TextStyle(fontSize: 16.5)),
                          const SizedBox(
                            height: 8,
                          ),
                          const Text("Changelog",
                              textAlign: TextAlign.start, style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold)),
                          HtmlWidget('''${status.releaseNotes}''', textStyle: const TextStyle(fontSize: 16.5)),
                          const SizedBox(
                            height: 8,
                          ),
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                String? url = status.appStoreLink;
                                await canLaunchUrl(Uri.parse(url)) ? await launchUrl(Uri.parse(url)) : throw 'Could not launch $url';
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
                              ),
                              child: Text(btnLabel, style: const TextStyle(color: Colors.white)),
                            ),
                          ),
                        ]),
                      ),
                    );
            })
        : Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: getMaintainanceReport(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data["success"] == 1) {
                return Center(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/maintain.png',
                      height: 120,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      snapshot.data["data"][0]["description"].toString(),
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 25),
                    const Text("Please try after some time"),
                  ],
                ));
              } else {
                return widget.child!;
              }
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
