import 'dart:convert';

import 'dart:io';
import 'package:ctown/models/app_model.dart';
import 'package:ctown/models/user_model.dart';
import 'package:ctown/screens/home/message_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import "package:path_provider/path_provider.dart";
import 'package:scrolls_to_top/scrolls_to_top.dart';

import '../../generated/l10n.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Notificationsceens extends StatefulWidget {
  final screen;

  const Notificationsceens({Key? key, this.screen}) : super(key: key);
  // const Notificationsceens({ Key? key }) : super(key: key);

  @override
  _NotificationsceensState createState() => _NotificationsceensState();
}

class _NotificationsceensState extends State<Notificationsceens> {
  bool notify = true;
  bool messsages = false;
  final ScrollController _scrollController = ScrollController();
  notificationmessage(userid) async {
    String apiUrl =
        "https://up.ctown.jo/api/mobileCustomerNotificationReadMessageSection.php";
    Map body = {"user_id": userid};
    var response = await http.post(Uri.parse(apiUrl), body: jsonEncode(body));
    var responseBody;
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      print("vengadesh");
      print(responseBody);
      return responseBody;
    } else {
      responseBody = {};
    }
    return responseBody;
  }

  notificationstatusmessage(
      current_notification_id, user_id, message_section) async {
    String apiUrl =
        "https://up.ctown.jo/api/mobileCustomerNotificationReadMsgStatusChange.php";
    Map body = {
      "current_notification_id": current_notification_id,
      "user_id": user_id,
      "message_section": message_section
    };
    var response = await http.post(Uri.parse(apiUrl), body: jsonEncode(body));
    var responseBody;
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      print("vengadesh");
      print(responseBody);
      return responseBody;
    } else {
      responseBody = {};
    }
    return responseBody;
  }

  Future<File> viewFile({required String url, String? fileName, String? dir}) async {
    HttpClient httpClient = HttpClient();
    File file;
    var request = await httpClient.getUrl(Uri.parse(url));
    print(request);
    var response = await request.close();
    print(response);
    print(response.statusCode);
    var bytes;
    if (response.statusCode == 200) {
      bytes = await consolidateHttpClientResponseBytes(response);
      final output = await getTemporaryDirectory();
      print("output");
      final file = File("${output.path}/$fileName.pdf");
      print("file write starts");
      var invoice = await file.writeAsBytes(bytes);
      print("file write ends");
      return invoice;
    } else {
      return Future.error('error');
    }
    // return file;
  }

  notificationread(userid) async {
    String apiUrl =
        "https://up.ctown.jo/api/mobileCustomerNotificationReadNotificationSection.php";
    Map body = {"user_id": userid};
    var response = await http.post(Uri.parse(apiUrl), body: jsonEncode(body));
    var responseBody;
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      print("vengadesh");
      print(responseBody);
      return responseBody;
    } else {
      responseBody = {};
    }
    return responseBody;
  }

  notificationdelete(userid) async {
    String apiUrl =
        "https://up.ctown.jo/api/mobileCustomerNotificationClear.php";
    Map body = {"user_id": userid};
    var response = await http.post(Uri.parse(apiUrl), body: jsonEncode(body));
    var responseBody;
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);

      print(responseBody);
      return SnackBar(
        content: Text(responseBody["message"]),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: "close",
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
    } else {
      responseBody = {};
    }
    return responseBody;
  }

  notificationparticulardelete(
      current_notification_id, user_id, message_section) async {
    String apiUrl =
        "https://up.ctown.jo/api/mobileCustomerNotificationParticularDelete.php";
    Map body = {
      "current_notification_id": current_notification_id,
      "user_id": user_id,
      "message_section": message_section
    };
    print("delete");
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
  void initState() {
    // TODO: implement initState
    if (widget.screen == 'message') {
      setState(() {
        messsages = true;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onScrollsToTop(ScrollsToTopEvent event) async {
    _scrollController.animateTo(0, duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context, listen: false).user;
    var appModel = Provider.of<AppModel>(context);
    var isDarkTheme = appModel.darkTheme;
    final langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
    return ScrollsToTop(
      onScrollsToTop: _onScrollsToTop,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xffda0c15),
            title: Text(
              S.of(context).listMessages,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
          ),
          body: notify == true && user != null
              ? Container(
                  height: MediaQuery.of(context).size.height * 1,
                  child: SingleChildScrollView(
                    child: Column(children: [
                      ListTile(
                        trailing: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                  title: Text(Provider.of<AppModel>(context,
                                                  listen: false)
                                              .langCode ==
                                          'en'
                                      ? "Are You Sure"
                                      : "هل أنت واثق"),
                                  content: Text(Provider.of<AppModel>(context,
                                                  listen: false)
                                              .langCode ==
                                          'en'
                                      ? "Do you want to clear Notifications"
                                      : "هل تريد مسح الاشعارات"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text(Provider.of<AppModel>(context,
                                                      listen: false)
                                                  .langCode ==
                                              'en'
                                          ? "no"
                                          : "لا"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        notificationdelete(user.id);
                                        setState(() {
                                          notify = false;
                                        });
                                        Navigator.of(context).pop(false);
                                      },
                                      child: Text(Provider.of<AppModel>(context,
                                                      listen: false)
                                                  .langCode ==
                                              'en'
                                          ? "yes"
                                          : "نعم"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(
                              Provider.of<AppModel>(context, listen: false)
                                          .langCode ==
                                      'en'
                                  ? "Clear All"
                                  : "امسح الكل",
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                            )),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                messsages = false;
                              });
                            },
                            child: Container(
                              color: messsages == false
                                  ? const Color(0xffda0c15)
                                  : Colors.grey,
                              height: 50,
                              width: MediaQuery.of(context).size.width * .500,
                              child: Center(
                                  child: Text(langCode == "en" ? "Notifications" : "الإشعارات",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ))),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                messsages = true;
                              });
                            },
                            child: Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width * .500,
                              color: messsages == true
                                  ? const Color(0xffda0c15)
                                  : Colors.grey,
                              child: Center(
                                  child: Text(langCode == "en" ?  "Messages" :"الرسائل",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ))),
                            ),
                          ),
                        ],
                      ),
                      if (messsages == false)
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height * .650,
                                child: FutureBuilder(
                                    future: notificationread(user.id),
                                    builder: (context, AsyncSnapshot snapshat) {
                                      if (snapshat.data != null) {
                                        if (snapshat.data["success"] == 1) {
                                          return ListView.builder(
                                              controller: _scrollController,
                                              shrinkWrap: true,
                                              itemCount:
                                                  snapshat.data['data'].length,
                                              itemBuilder: (context, index) {
                                                return Slidable(
                                                  child: snapshat.data["data"]
                                                              [index]["id"] !=
                                                          "0"
                                                      ? InkWell(
                                                          onTap: () {
                                                            print(
                                                                "snapshat.data['data'].length");
                                                            print(snapshat
                                                                .data['data']
                                                                .length);
                                                            notificationstatusmessage(
                                                                snapshat.data[
                                                                        "data"]
                                                                    [index]["id"],
                                                                user.id,
                                                                snapshat.data[
                                                                            "data"]
                                                                        [index][
                                                                    "message_section"]);
                                                            setState(() {
                                                              snapshat.data["data"]
                                                                          [index][
                                                                      "read_message"] =
                                                                  '0';
                                                            });
                                                            Navigator.pushNamed(
                                                                context,
                                                                "/orders");
                                                          },
                                                          child: Card(
                                                              color: snapshat.data["data"]
                                                                              [
                                                                              index]
                                                                          [
                                                                          "read_message"] ==
                                                                      '1'
                                                                   ? isDarkTheme?Colors.black:Color(
                                                                      0xffFFFFF0)
                                                                  : isDarkTheme?Colors.black12:Colors.white,
                                                              child: ListTile(
                                                                leading: Icon(
                                                                    Icons
                                                                        .notifications,
                                                                   ),
                                                                title: Text(
                                                                  snapshat.data[
                                                                              "data"]
                                                                          [index]
                                                                      ["title"],
                                                                  style: TextStyle(
                                                                      color: Color(0xffda0c15),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                subtitle: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      snapshat.data["data"]
                                                                              [
                                                                              index]
                                                                          [
                                                                          "body"],
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                      color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white70 : Colors.black),
                                                                    ),
                                                                    Text(
                                                                      snapshat.data["data"]
                                                                              [
                                                                              index]
                                                                          [
                                                                          "dateandtime"],
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .grey),
                                                                    )
                                                                  ],
                                                                ),
                                                              )),
                                                        )
                                                      : Card(),
                                                  startActionPane:
                                                  ActionPane(
                                                    motion: const ScrollMotion(),
                                                    children: [
                                                      SlidableAction(
                                                        onPressed: (BuildContext context) {
                                                          notificationparticulardelete(
                                                              snapshat.data["data"]
                                                              [index]["id"],
                                                              user.id,
                                                              snapshat.data["data"]
                                                              [index][
                                                              "message_section"]);
                                                          setState(() {
                                                            snapshat.data["data"]
                                                            [index]["id"] = "0";
                                                          });
                                                        },
                                                        label: "Delete",
                                                        icon: Icons.delete,
                                                        backgroundColor: Colors.red,
                                                        foregroundColor: Colors.white,
                                                      )
                                                    ],
                                                  ),
                                                  endActionPane:
                                                  ActionPane(
                                                      motion: const ScrollMotion(),
                                                      children: [
                                                        SlidableAction(
                                                          onPressed: (BuildContext context) {
                                                            notificationparticulardelete(
                                                                snapshat.data["data"]
                                                                [index]["id"],
                                                                user.id,
                                                                snapshat.data["data"]
                                                                [index][
                                                                "message_section"]);
                                                            setState(() {
                                                              snapshat.data["data"]
                                                              [index]["id"] = "0";
                                                            });
                                                          },
                                                          label: "Delete",
                                                          icon: Icons.delete,
                                                          backgroundColor: Colors.red,
                                                          foregroundColor: Colors.white,
                                                        )
                                                      ]
                                                  ),
                                                );
                                              });
                                        } else {
                                          return Center(
                                            child: Container(

                                                child: Text(
                                                    Provider.of<AppModel>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .langCode ==
                                                            'en'
                                                        ? "No Notification "
                                                        : "لا يوجد إشعارات")),
                                          );
                                        }
                                      }
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }),
                              ),
                            ],
                          ),
                        ),
                      if (messsages == true)
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                height: MediaQuery.of(context).size.height * .650,
                                child: FutureBuilder(
                                    future: notificationmessage(user.id),
                                    builder: (context, AsyncSnapshot snapshat) {
                                      if (snapshat.data != null) {
                                        if (snapshat.data["success"] == 1) {
                                          return ListView.builder(
                                            controller: _scrollController,
                                              // physics:
                                              //     const AlwaysScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount:
                                                  snapshat.data['data'].length,
                                              itemBuilder: (context, index) {
                                                return Slidable(
                                                  child: snapshat.data["data"]
                                                              [index]["id"] !=
                                                          "0"
                                                      ? InkWell(
                                                          onTap: () {
                                                            print(
                                                                "snapshat.data['data'].length");
                                                            print(snapshat
                                                                .data['data']
                                                                .length);
                                                            notificationstatusmessage(
                                                                snapshat.data[
                                                                        "data"]
                                                                    [index]["id"],
                                                                user.id,
                                                                snapshat.data[
                                                                            "data"]
                                                                        [index][
                                                                    "message_section"]);
                                                            setState(() {
                                                              snapshat.data["data"]
                                                                          [index][
                                                                      "read_message"] =
                                                                  '0';
                                                            });
                                                            Navigator.of(context).push(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            MessageViewer(
                                                                              message_files:
                                                                                  snapshat.data["data"][index]["message_files"],
                                                                              id: snapshat.data["data"][index]["id"],
                                                                              message_content:
                                                                                  snapshat.data["data"][index]["message_content"],
                                                                              title:
                                                                                  snapshat.data["data"][index]["title"],
                                                                              body:
                                                                                  snapshat.data["data"][index]["body"],
                                                                              url:
                                                                                  snapshat.data["data"][index]["url"],
                                                                            )));
                                                          },
                                                          child: Card(
                                                              color: snapshat.data["data"]
                                                                              [
                                                                              index]
                                                                          [
                                                                          "read_message"] ==
                                                                      '1'
                                                                  ? isDarkTheme?Colors.black:Color(
                                                                      0xffFFFFF0)
                                                                  : isDarkTheme?Colors.black12:Colors.white,
                                                              // color: Colors
                                                              //     .orangeAccent[50],
                                                              child: ListTile(
                                                                leading: Icon(
                                                                  Icons
                                                                      .notifications,
                                                                ),
                                                                title: Text(
                                                                  snapshat.data[
                                                                              "data"]
                                                                          [index]
                                                                      ["title"],
                                                                  style: TextStyle(
                                                                      color: Color(0xffda0c15),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                subtitle: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      snapshat.data["data"]
                                                                              [
                                                                              index]
                                                                          [
                                                                          "body"],
                                                                      style: const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    Text(
                                                                      snapshat.data["data"]
                                                                              [
                                                                              index]
                                                                          [
                                                                          "dateandtime"],
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .grey),
                                                                    )
                                                                  ],
                                                                ),
                                                              )),
                                                        )
                                                      : Card(),
                                                  startActionPane: ActionPane(
                                                      motion: const ScrollMotion(),
                                                      children: [
                                                        SlidableAction(
                                                          onPressed: (BuildContext context) {
                                                            notificationparticulardelete(
                                                                snapshat.data["data"]
                                                                [index]["id"],
                                                                user.id,
                                                                snapshat.data["data"]
                                                                [index][
                                                                "message_section"]);
                                                            setState(() {
                                                              snapshat.data["data"]
                                                              [index]["id"] = "0";
                                                            });
                                                          },
                                                          label: "Delete",
                                                          icon: Icons.delete,
                                                          backgroundColor: Colors.red,
                                                          foregroundColor: Colors.white,
                                                        )
                                                      ]
                                                  ),
                                                  endActionPane:
                                                  ActionPane(
                                                      motion: const ScrollMotion(),
                                                      children: [
                                                        SlidableAction(
                                                          onPressed: (BuildContext context) {
                                                            notificationparticulardelete(
                                                                snapshat.data["data"]
                                                                [index]["id"],
                                                                user.id,
                                                                snapshat.data["data"]
                                                                [index][
                                                                "message_section"]);
                                                            setState(() {
                                                              snapshat.data["data"]
                                                              [index]["id"] = "0";
                                                            });
                                                          },
                                                          label: "Delete",
                                                          icon: Icons.delete,
                                                          backgroundColor: Colors.red,
                                                          foregroundColor: Colors.white,
                                                        )
                                                      ]
                                                  ),
                                                );
                                              });
                                        } else {
                                          return Center(
                                            child: Container(

                                                child: Text(
                                                    Provider.of<AppModel>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .langCode ==
                                                            'en'
                                                        ? "No Notification "
                                                        : "لا يوجد إشعارات")),
                                          );
                                        }
                                      }
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }),
                              ),
                            ],
                          ),
                        )
                    ]),
                  ),
                )
              : Container(
                  // margin: EdgeInsets.only(top: 100),
                  child: Center(
                      child: Text(Provider.of<AppModel>(context, listen: false)
                                  .langCode ==
                              'en'
                          ? "No Notification "
                          : "لا يوجد إشعارات")))),
    );
  }
}
