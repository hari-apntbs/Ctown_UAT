import 'dart:convert';
import 'dart:io';

import 'package:ctown/models/app_model.dart';
import 'package:ctown/screens/settings/list_items.dart';
import 'package:provider/provider.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';
import '../../common/constants.dart';
import '../../models/index.dart' show UserModel;
import '../../generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ShoppingList extends StatefulWidget {
  @override
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  List<String> shoppingListData = [];
  TextEditingController shoppingListController =
      TextEditingController(text: "");
  TextEditingController renameController = TextEditingController(text: "");
  late UserModel userModel;
  final ScrollController _scrollController = ScrollController();

  late Size screenSize;

  onGoBack(dynamic value) {
    // refreshData();
    setState(() {});
  }

  void navigateSecondPage({data}) {
    Route route = MaterialPageRoute(
        builder: (context) => ShoppingListItems(
              data: data,
            ));
    Navigator.push(context, route).then(onGoBack);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // title: Text("My title"),
        content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            Provider.of<AppModel>(context, listen: false).langCode == "en" ? "Enter Shopping List Name" : "ادخل اسم قائمة التسوق",
            style: const TextStyle(fontSize: 17.5),
          ),
          Container(
            width: screenSize.width * 0.8,
            child: TextField(
              // obscureText: true,
              controller: shoppingListController,
              decoration: InputDecoration(),
              onSubmitted: (e) {
                // if (shoppingListController.text.isNotEmpty)
                print(e);
              },
              style: TextStyle(
                fontFamily: 'NotoSans', // Font that supports both English and Arabic
                fontSize: 16.0,         // Adjust font size as needed
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () async {
                  if (shoppingListController.text.isEmpty) {
                    SnackBar snackBar = SnackBar(
                      content: Text(Provider.of<AppModel>(context, listen: false).langCode == "en" ? "Please enter the name" : "الرجاء إدخال الاسم"),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    return;
                  }

                  await addCollections(
                      collectionName: shoppingListController.text);
                  setState(() {
                    shoppingListData.add(shoppingListController.text);
                  });
                  shoppingListController.clear();
                  // Navigator.pop(context);
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                },
                child: Container(
                  width: 100,
                  height: 40,
                  child: Center(child: Text(Provider.of<AppModel>(context, listen: false).langCode=='en'?"Save":'حفظ',style: TextStyle(color: Colors.white),)),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10)),
                ),
              )
            ],
          ),
          SizedBox(
            height: 15,
          )
        ],
      ),
    ));

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

//
  addCollections({required String collectionName}) async {
    String url = "https://up.ctown.jo/api/addshopping.php";
    Map body = {"title": collectionName, "customer_id": userModel.user!.id};
    var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    Map<dynamic, dynamic>? responseBody = {};
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      print(responseBody);
      return responseBody;
    }
    return responseBody;
  }
//

  deleteCollections({required String? id}) async {
    String url = "https://up.ctown.jo/api/deleteshopping.php";
    Map body = {"id": id};
    var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    Map<dynamic, dynamic>? responseBody = {};
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      print(responseBody);
      return responseBody;
    }
    return responseBody;
  }

  renameCollections(
      {required String collectionName, required String? id}) async {
    String url = "https://up.ctown.jo/api/addshopping.php";
    Map body = {
      "title": collectionName,
      "customer_id": userModel.user!.id,
      "id": id
    };
    var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    Map<dynamic, dynamic>? responseBody = {};
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      print(responseBody);
      return responseBody;
    }
    return responseBody;
  }

// getcollections
  getCollections() async {
    String url = "https://up.ctown.jo/api/shoppinglist.php";
    Map body = {"customer_id": userModel.user!.id};
    print(body);

    var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    Map<dynamic, dynamic>? responseBody = {};
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      print(responseBody);
      return responseBody!["data"];
    }
    return responseBody;
  }

  Future<String> getListItemLength({String? id}) async {
    String url = "https://up.ctown.jo/api/viewshoppinglist.php";
    Map body = {"id": id};
    printLog(body);

    var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    Map<dynamic, dynamic>? responseBody = {};
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      if (responseBody!["success"] == "0" && responseBody["data"] == "") {
        return "no items";
      }
      List<Map<String, dynamic>> data = [];
      responseBody["data"].forEach((e) {
        data.add({"name": e["name"]});
      });

      return data.length.toString() + " " + "item(s)";
    }
    return "";
  }

  Future<void> _onScrollsToTop(ScrollsToTopEvent event) async {
    _scrollController.animateTo(0, duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
  }

//
  @override
  Widget build(BuildContext context) {
    userModel = Provider.of<UserModel>(context, listen: false);
    screenSize = MediaQuery.of(context).size;
    return Platform.isIOS ? ScrollsToTop(
      onScrollsToTop: _onScrollsToTop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            S.of(context).myShoppingList,
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
              onTap: () async {
                // print(Provider.of<SettingsProvider>(context, listen: false)
                //     .shoppingListItems
                //     .length);
                Navigator.pop(context);
                // print(userModel.user.id);
                // await getCollections();
                // delete(id: 2);
              }
              //
              ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          // backgroundColor: Colors.white24,
          onPressed: () {
            showAlertDialog(context);
            // showModalBottomSheet(
            //     context: context,
            //     builder: (context) {
            //       return Padding(
            //         padding: EdgeInsets.only(left: 20, top: 20, right: 20),
            //         child: SingleChildScrollView(
            //           child: Column(
            //             mainAxisSize: MainAxisSize.max,
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: <Widget>[
            //               Text(
            //                 "Enter Shopping List Name",
            //                 style: TextStyle(fontSize: 17.5),
            //               ),
            //               Container(
            //                 width: screenSize.width * 0.8,
            //                 child: TextField(
            //                   // obscureText: true,
            //                   controller: shoppingListController,
            //                   decoration: InputDecoration(),
            //                   onSubmitted: (e) {
            //                     // if (shoppingListController.text.isNotEmpty)
            //                     print(e);
            //                   },
            //                 ),
            //               ),
            //               SizedBox(
            //                 height: 20,
            //               ),
            //               Row(
            //                 mainAxisAlignment: MainAxisAlignment.end,
            //                 children: [
            //                   InkWell(
            //                     onTap: () async {
            //                       if (shoppingListController.text.isEmpty) {
            //                         SnackBar snackBar = SnackBar(
            //                           content: Text("please enter the name"),
            //                         );
            //                         Scaffold.of(context).showSnackBar(snackBar);
            //                         return;
            //                       }

            //                       await addCollections(
            //                           collectionName:
            //                               shoppingListController.text);
            //                       setState(() {
            //                         shoppingListData
            //                             .add(shoppingListController.text);
            //                       });
            //                       shoppingListController.clear();
            //                       Navigator.pop(context);
            //                     },
            //                     child: Container(
            //                       width: 100,
            //                       height: 40,
            //                       child: Center(child: Text("Save")),
            //                       decoration: BoxDecoration(
            //                           color: Theme.of(context).primaryColor,
            //                           borderRadius: BorderRadius.circular(10)),
            //                     ),
            //                   )
            //                 ],
            //               ),
            //               SizedBox(
            //                 height: screenSize.height * 0.15,
            //               )
            //             ],
            //           ),
            //         ),
            //       );
            //     });
          },
          child: Icon(Icons.add,color: Theme.of(context).colorScheme.surface),
        ),
        body: Container(
            child: FutureBuilder(
                future: getCollections(),
                // query(),
                builder: (context, AsyncSnapshot snapshot) {
                  final langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
                  if (snapshot.data != null) {
                    if (snapshot.data.isEmpty) {
                      return Center(child: Text(langCode == "en" ? "Create your shopping list" : "إنشاء قائمة التسوق الخاصة بك"));
                    }
                    return ListView.builder(
                        controller: _scrollController,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              onTap: () {
                                // Navigator.of(context).push(MaterialPageRoute(
                                //     builder: (context) => ShoppingListItems(
                                //           data: snapshot.data[index],
                                //         )));
                                print(snapshot.data[index]);
                                navigateSecondPage(
                                  data: snapshot.data[index],
                                );
                              },
                              title: Text(snapshot.data[index]["title"],
                                  style: TextStyle(
                                    fontFamily: 'NotoSans'      // Adjust font size as needed
                                  )),
                              // subtitle: Text(
                              // snapshot.data[index]["data"].length.toString() +
                              // "6" + " " + "item(s)"),
                              subtitle: FutureBuilder(
                                future: getListItemLength(
                                    id: snapshot.data[index]["id"]),
                                builder: (context, AsyncSnapshot snap) {
                                  if (snap.data != null) {
                                    return Text(snap.data,
                                        style: TextStyle(
                                            fontFamily: 'NotoSans'      // Adjust font size as needed
                                        ));
                                  }
                                  return Text("");
                                },
                              ),
                              trailing: PopupMenuButton<String>(
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'Rename',
                                    child: Text('Rename'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'Delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                                onSelected: (String value) async {
                                  if (value == "Delete") {
                                    // print("deleted");
                                    // showAlertDialog(context);
                                    // delete(id: snapshot.data[index]["_id"]);
                                    var result = await deleteCollections(
                                        id: snapshot.data[index]["id"]);

                                    setState(() {});
                                    if (result["success"] == "1") {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content:
                                              Text('Item deleted successfully')));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content:
                                              Text('Could not delete item')));
                                    }
                                  } else if (value == "Rename") {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                                left: 20, top: 20, right: 20),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    "Enter the New List Name",
                                                    style:
                                                        TextStyle(fontSize: 17.5),
                                                  ),
                                                  Container(
                                                    width: screenSize.width * 0.8,
                                                    child: TextField(
                                                      // obscureText: true,
                                                      controller:
                                                          renameController,
                                                      decoration:
                                                          InputDecoration(),
                                                      style: TextStyle(
                                                        fontFamily: 'NotoSans', // Font that supports both English and Arabic
                                                        fontSize: 16.0,         // Adjust font size as needed
                                                      ),
                                                      onSubmitted: (e) {
                                                        // if (shoppingListController.text.isNotEmpty)
                                                        print(e);
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      InkWell(
                                                        onTap: () async {
                                                          if (renameController
                                                              .text.isEmpty) {
                                                            SnackBar snackBar =
                                                                SnackBar(
                                                              content: Text(
                                                                  "please enter the new name"),
                                                            );
                                                            ScaffoldMessenger.of(context)
                                                                .showSnackBar(
                                                                    snackBar);
                                                            return;
                                                          }
                                                          var result =
                                                              await renameCollections(
                                                                  collectionName:
                                                                      renameController
                                                                          .text,
                                                                  id: snapshot.data[
                                                                          index]
                                                                      ["id"]);
                                                          setState(() {});
                                                          if (result["success"] ==
                                                              "1") {
                                                            ScaffoldMessenger.of(context)
                                                                .showSnackBar(SnackBar(
                                                                    content: Text(
                                                                        result[
                                                                            "message"])));
                                                          } else {
                                                            ScaffoldMessenger.of(context)
                                                                .showSnackBar(SnackBar(
                                                                    content: Text(
                                                                        'Could not rename item')));
                                                          }
                                                          renameController
                                                              .clear();
                                                          Navigator.pop(context);
                                                        },
                                                        child: Container(
                                                          width: 100,
                                                          height: 40,
                                                          child: Center(
                                                              child:
                                                                  Text("Rename")),
                                                          decoration: BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        screenSize.height * 0.15,
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  }
                                },
                              ),
                            ),
                          );
                        });
                  }
                  return Center(child: CircularProgressIndicator());
                })),
      ),
    ) : Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).myShoppingList,
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
            onTap: () async {
              // print(Provider.of<SettingsProvider>(context, listen: false)
              //     .shoppingListItems
              //     .length);
              Navigator.pop(context);
              // print(userModel.user.id);
              // await getCollections();
              // delete(id: 2);
            }
          //
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        // backgroundColor: Colors.white24,
        onPressed: () {
          showAlertDialog(context);
       },
        child: Icon(Icons.add,color: Theme.of(context).colorScheme.surface),
      ),
      body: Container(
          child: FutureBuilder(
              future: getCollections(),
              // query(),
              builder: (context, AsyncSnapshot snapshot) {
                final langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
                if (snapshot.data != null) {
                  if (snapshot.data.isEmpty) {
                    return Center(child: Text(langCode == "en" ? "Create your shopping list" : "إنشاء قائمة التسوق الخاصة بك"));
                  }
                  return ListView.builder(
                    controller: _scrollController,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            onTap: () {
                              // Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (context) => ShoppingListItems(
                              //           data: snapshot.data[index],
                              //         )));
                              print(snapshot.data[index]);
                              navigateSecondPage(
                                data: snapshot.data[index],
                              );
                            },
                            title: Text(snapshot.data[index]["title"]),
                            // subtitle: Text(
                            // snapshot.data[index]["data"].length.toString() +
                            // "6" + " " + "item(s)"),
                            subtitle: FutureBuilder(
                              future: getListItemLength(
                                  id: snapshot.data[index]["id"]),
                              builder: (context, AsyncSnapshot snap) {
                                if (snap.data != null) {
                                  return Text(snap.data);
                                }
                                return Text("");
                              },
                            ),
                            trailing: PopupMenuButton<String>(
                              itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'Rename',
                                  child: Text('Rename'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'Delete',
                                  child: Text('Delete'),
                                ),
                              ],
                              onSelected: (String value) async {
                                if (value == "Delete") {
                                  // print("deleted");
                                  // showAlertDialog(context);
                                  // delete(id: snapshot.data[index]["_id"]);
                                  var result = await deleteCollections(
                                      id: snapshot.data[index]["id"]);

                                  setState(() {});
                                  if (result["success"] == "1") {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content:
                                        Text('Item deleted successfully')));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content:
                                        Text('Could not delete item')));
                                  }
                                } else if (value == "Rename") {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              left: 20, top: 20, right: 20),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  "Enter the New List Name",
                                                  style:
                                                  TextStyle(fontSize: 17.5),
                                                ),
                                                Container(
                                                  width: screenSize.width * 0.8,
                                                  child: TextField(
                                                    // obscureText: true,
                                                    controller:
                                                    renameController,
                                                    decoration:
                                                    InputDecoration(),
                                                    style: TextStyle(
                                                      fontFamily: 'NotoSans', // Font that supports both English and Arabic
                                                      fontSize: 16.0,         // Adjust font size as needed
                                                    ),
                                                    onSubmitted: (e) {
                                                      // if (shoppingListController.text.isNotEmpty)
                                                      print(e);
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                                  children: [
                                                    InkWell(
                                                      onTap: () async {
                                                        if (renameController
                                                            .text.isEmpty) {
                                                          SnackBar snackBar =
                                                          SnackBar(
                                                            content: Text(
                                                                "please enter the new name"),
                                                          );
                                                          ScaffoldMessenger.of(context)
                                                              .showSnackBar(
                                                              snackBar);
                                                          return;
                                                        }
                                                        var result =
                                                        await renameCollections(
                                                            collectionName:
                                                            renameController
                                                                .text,
                                                            id: snapshot.data[
                                                            index]
                                                            ["id"]);
                                                        setState(() {});
                                                        if (result["success"] ==
                                                            "1") {
                                                          ScaffoldMessenger.of(context)
                                                              .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  result[
                                                                  "message"])));
                                                        } else {
                                                          ScaffoldMessenger.of(context)
                                                              .showSnackBar(SnackBar(
                                                              content: Text(
                                                                  'Could not rename item')));
                                                        }
                                                        renameController
                                                            .clear();
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        width: 100,
                                                        height: 40,
                                                        child: Center(
                                                            child:
                                                            Text("Rename")),
                                                        decoration: BoxDecoration(
                                                            color: Theme.of(
                                                                context)
                                                                .primaryColor,
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                10)),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height:
                                                  screenSize.height * 0.15,
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                }
                              },
                            ),
                          ),
                        );
                      });
                }
                return Center(child: CircularProgressIndicator());
              })),
    );
  }
}

/*

// Local Saved Data

import 'dart:convert';

import 'package:ctown/screens/settings/db_crud.dart';
import 'package:ctown/screens/settings/list_items.dart';

import '../../generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:ctown/screens/settings/settings_provider.dart';
import 'package:provider/provider.dart';

class ShoppingList extends StatefulWidget {
  @override
  _ShoppingListState createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  List shoppingListData = [];
  TextEditingController shoppingListController =
      TextEditingController(text: "");
  TextEditingController renameController = TextEditingController(text: "");
  Size screenSize;
  //

//
  // showAlertDialog(BuildContext context) {
  //   // set up the buttons
  //   Widget cancelButton = TextButton(
  //     child: Text("Cancel"),
  //     onPressed: () {
  //       Navigator.of(context).pop(false);
  //     },
  //   );
  //   Widget continueButton = TextButton(
  //     child: Text("Continue"),
  //     onPressed: () {
  //       Navigator.of(context).pop();
  //     },
  //   );

  //   // set up the AlertDialog
  //   AlertDialog alert = AlertDialog(
  //     title: Text("AlertDialog"),
  //     content: Text("Do you want to delete this shopping list?"),
  //     actions: [
  //       cancelButton,
  //       continueButton,
  //     ],
  //   );

  //   // show the dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }

  Future onGoBack(dynamic value) {
    // refreshData();
    setState(() {});
  }

  void navigateSecondPage({data}) {
    Route route = MaterialPageRoute(
        builder: (context) => ShoppingListItems(
              data: data,
            ));
    Navigator.push(context, route).then(onGoBack);
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () => Navigator.pop(context, true),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("My title"),
      content: Text("This is my message."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

//
  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          S.of(context).myShoppingList,
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
            onTap: () async {
              // print(Provider.of<SettingsProvider>(context, listen: false)
              //     .shoppingListItems
              //     .length);
              Navigator.pop(context);
              // delete(id: 2);
            }
            //
            ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        // backgroundColor: Colors.white24,
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.only(left: 20, top: 20, right: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Enter Shopping List Name",
                          style: TextStyle(fontSize: 17.5),
                        ),
                        Container(
                          width: screenSize.width * 0.8,
                          child: TextField(
                            // obscureText: true,
                            controller: shoppingListController,
                            decoration: InputDecoration(),
                            onSubmitted: (e) {
                              // if (shoppingListController.text.isNotEmpty)
                              print(e);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                if (shoppingListController.text.isEmpty) {
                                  SnackBar snackBar = SnackBar(
                                    content: Text("please enter the name"),
                                  );
                                  Scaffold.of(context).showSnackBar(snackBar);
                                  return;
                                }
                                insert(
                                  name: shoppingListController.text,
                                  items: "[]",
                                  // jsonEncode(["Potato", "Tomato"])
                                  // .toString()
                                );
                                setState(() {
                                  shoppingListData
                                      .add(shoppingListController.text);
                                });
                                shoppingListController.clear();
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 100,
                                height: 40,
                                child: Center(child: Text("Save")),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: screenSize.height * 0.15,
                        )
                      ],
                    ),
                  ),
                );
              });
        },
        child: Icon(Icons.add),
      ),
      body: Container(
          child: FutureBuilder(
              future: query(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  if (snapshot.data.isEmpty) {
                    return Center(child: Text("Create your shopping list"));
                  }
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            onTap: () {
                              // Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (context) => ShoppingListItems(
                              //           data: snapshot.data[index],
                              //         )));
                              navigateSecondPage(
                                data: snapshot.data[index],
                              );
                            },
                            title: Text(snapshot.data[index]["name"]),
                            subtitle: Text(
                                jsonDecode(snapshot.data[index]["items"])
                                        .length
                                        .toString() +
                                    " " +
                                    "item(s)"),
                            trailing: PopupMenuButton<String>(
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'Rename',
                                  child: Text('Rename'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'Delete',
                                  child: Text('Delete'),
                                ),
                              ],
                              onSelected: (String value) {
                                if (value == "Delete") {
                                  // print("deleted");
                                  // showAlertDialog(context);
                                  delete(id: snapshot.data[index]["_id"]);
                                  setState(() {});
                                } else if (value == "Rename") {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              left: 20, top: 20, right: 20),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  "Enter the New List Name",
                                                  style:
                                                      TextStyle(fontSize: 17.5),
                                                ),
                                                Container(
                                                  width: screenSize.width * 0.8,
                                                  child: TextField(
                                                    // obscureText: true,
                                                    controller:
                                                        renameController,
                                                    decoration:
                                                        InputDecoration(),
                                                    onSubmitted: (e) {
                                                      // if (shoppingListController.text.isNotEmpty)
                                                      print(e);
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        if (renameController
                                                            .text.isEmpty) {
                                                          SnackBar snackBar =
                                                              SnackBar(
                                                            content: Text(
                                                                "please enter the new name"),
                                                          );
                                                          Scaffold.of(context)
                                                              .showSnackBar(
                                                                  snackBar);
                                                          return;
                                                        }
                                                        update(
                                                            id: snapshot
                                                                    .data[index]
                                                                ["_id"],
                                                            name:
                                                                renameController
                                                                    .text,
                                                            items: snapshot
                                                                    .data[index]
                                                                ["items"]);
                                                        setState(() {});
                                                        renameController
                                                            .clear();
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        width: 100,
                                                        height: 40,
                                                        child: Center(
                                                            child:
                                                                Text("Rename")),
                                                        decoration: BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height:
                                                      screenSize.height * 0.15,
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                }
                              },
                            ),
                          ),
                        );
                      });
                }
                return Center(child: CircularProgressIndicator());
              })),
    );
  }
}
*/
