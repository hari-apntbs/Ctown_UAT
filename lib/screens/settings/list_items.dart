import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:ctown/screens/settings/settings_provider.dart';

import 'package:ctown/widgets/home/search/search_results.dart';
import 'package:flutter/material.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, UserModel;

import 'package:http/http.dart' as http;

class ShoppingListItems extends StatefulWidget {
  final data;
  ShoppingListItems({this.data});
  @override
  _ShoppingListItemsState createState() => _ShoppingListItemsState();
}

class _ShoppingListItemsState extends State<ShoppingListItems> {
  //
  String langCode = "";

  List<Map<String, dynamic>>? listItems;

  void initState() {
    // List<Map<String, dynamic>> data = [];

    // widget.data["data"].forEach((e) {
    //   data.add({"name": e["name"], "isSelected": false, "id": e["id"]});
    // });
    langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
    Provider.of<SettingsProvider>(context, listen: false).shoppingListItems =
        [];
    // listItems =
    //     Provider.of<SettingsProvider>(context, listen: false).shoppingListItems;

    super.initState();
  }

  late UserModel userModel;
  //
  List<Map<String, dynamic>>? items;
  TextEditingController listItemController = TextEditingController(text: "");
  //
  late Size screenSize;
  final ScrollController _scrollController = ScrollController();

//

  addCollectionItems({
    required String name,
  }) async {
    String url = "https://up.ctown.jo/api/addshoppinglist.php";
    Map body = {
      "name": name,
      "shopping_id": widget.data["id"],
      "id": userModel.user!.id
    };
    var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    Map<dynamic, dynamic>? responseBody = {};
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      // print(responseBody);
      // var newListData = [
      //   ...Provider.of<SettingsProvider>(context, listen: false)
      //       .shoppingListItems,
      //   {"name": name, "isSelected": false}
      // ];
      // Provider.of<SettingsProvider>(context, listen: false)
      //     .setShoppingListItems(newListData);
      return responseBody;
    }
    return responseBody;
  }

  getListItems() async {
    String url = "https://up.ctown.jo/api/viewshoppinglist.php";
    Map body = {"id": widget.data["id"]};
    print(body);

    var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    Map<dynamic, dynamic>? responseBody = {};
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      if (responseBody!["data"] == "") {
        return [];
      }
      List<Map<String, dynamic>> data = [];
      responseBody["data"].forEach((e) {
        data.add({"name": e["name"], "isSelected": false, "id": e["id"]});
      });
      print("data $data");
      Provider.of<SettingsProvider>(context, listen: false).shoppingListItems =
          data;
      // listItems =
      //     Provider.of<SettingsProvider>(context, listen: false).shoppingListItems;
      listItems = data;
      print(responseBody);
      return responseBody["data"];
    }
    return responseBody;
  }

//
  getNames() {
    List allSearchTexts =
        Provider.of<SettingsProvider>(context, listen: false).shoppingListItems;
    List searchTexts = [];
    allSearchTexts.forEach((element) {
      if (!element["isSelected"]) {
        searchTexts.add(element);
      }
    });
    print("searchtexts  $searchTexts");
    String text = "";

    for (int i = 0; i < searchTexts.length; i++) {
      text = text + searchTexts[i]["name"];
      if (i < searchTexts.length - 1) {
        text = text + ",";
      }
    }
    print(text);

    return text;
  }

//

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
              Provider.of<AppModel>(context, listen: false).langCode == "en" ? "Enter the list item" : "أدخل عنصر القائمة",
              style: TextStyle(fontSize: 17.5),
            ),
            Container(
              width: screenSize.width * 0.8,
              child: TextField(
                maxLines: 5,
                // obscureText: true,
                controller: listItemController,
                decoration: InputDecoration(),
                onSubmitted: (e) {
                  // if (listItemController.text.isNotEmpty)
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
                  onTap: () async {
                    if (listItemController.text.isEmpty) {
                      SnackBar snackBar = SnackBar(
                        content: Text(Provider.of<AppModel>(context, listen: false).langCode == "en" ? "Please enter item name" : "الرجاء إدخال اسم العنصر"),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      return;
                    }
                    printLog(listItemController.text);
                    // update(
                    //     id: widget.data["_id"],
                    //     name: widget.data["name"],
                    //     items:
                    //         getItems(listItemController.text));
                    var result =
                        await addCollectionItems(name: listItemController.text);
                    setState(() {
                      // shoppingListData.add(listItemController.text);
                    });

                    // jsonEncode(["Potato", "Tomato"])
                    //     .toString());

                    listItemController.clear();
                    // Navigator.pop(context);
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    if (result["success"] == "1") {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(Provider.of<AppModel>(context, listen: false).langCode == "en" ? "Item added successfully" : "تمت إضافة العنصر بنجاح")));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(Provider.of<AppModel>(context, listen: false).langCode == "en" ? "Could not add item" : "لا يمكن إضافة العنصر")));
                    }
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
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

//
  onGoBack(dynamic value) {
    // refreshData();
    setState(() {});
  }

  void navigateSecondPage({data}) {
    Route route = MaterialPageRoute(
        builder: (context) => SearchResults(
              name: data,
              isBarcode: false,
            ));
    Navigator.push(context, route).then(onGoBack);
  }

  deleteListItem({required String? id, int? index}) async {
    String url = "https://up.ctown.jo/api/deleteshoppinglist.php";
    Map body = {"id": id};
    var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    print(response.body);
    Map<dynamic, dynamic>? responseBody = {};
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      print(responseBody);
      Provider.of<SettingsProvider>(context, listen: false)
          .removeShoppingItem(index);
      return responseBody;
    }
    return responseBody;
  }


  Future<void> _onScrollsToTop(ScrollsToTopEvent event) async {
    _scrollController.animateTo(0, duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
  }

  @override
  void dispose(){
    _scrollController.dispose();
    super.dispose();
  }

//
  @override
  Widget build(BuildContext context) {
    userModel = Provider.of<UserModel>(context, listen: false);

    screenSize = MediaQuery.of(context).size;
    return ScrollsToTop(
      onScrollsToTop: _onScrollsToTop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.data["title"],
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
                //     .shoppingListItems);
                Navigator.pop(context);
              }),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                showAlertDialog(context);
                /*
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
                                "Enter the List Item",
                                style: TextStyle(fontSize: 17.5),
                              ),
                              Container(
                                width: screenSize.width * 0.8,
                                child: TextField(
                                  // obscureText: true,
                                  controller: listItemController,
                                  decoration: InputDecoration(),
                                  onSubmitted: (e) {
                                    // if (listItemController.text.isNotEmpty)
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
                                    onTap: () async {
                                      if (listItemController.text.isEmpty) {
                                        SnackBar snackBar = SnackBar(
                                          content: Text("please enter item name"),
                                        );
                                        Scaffold.of(context)
                                            .showSnackBar(snackBar);
                                        return;
                                      }
                                      print(listItemController.text);
                                      // update(
                                      //     id: widget.data["_id"],
                                      //     name: widget.data["name"],
                                      //     items:
                                      //         getItems(listItemController.text));
                                      var result = await addCollectionItems(
                                          name: listItemController.text);
                                      setState(() {
                                        // shoppingListData.add(listItemController.text);
                                      });

                                      // jsonEncode(["Potato", "Tomato"])
                                      //     .toString());

                                      listItemController.clear();
                                      Navigator.pop(context);
                                      if (result["success"] == "1") {
                                        Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Item added successfully')));
                                      } else {
                                        Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text('Could not add item')));
                                      }
                                    },
                                    child: Container(
                                      width: 100,
                                      height: 40,
                                      child: Center(child: Text("Save")),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(10)),
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
                    });*/
              },
            ),
            const SizedBox(width: 20)
          ],
        ),
        //

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (Provider.of<SettingsProvider>(context, listen: false)
                .shoppingListItems
                .isEmpty) {
              // print("Empty");
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(langCode == "en" ? "Please add some items to search" : "الرجاء إضافة بعض العناصر للبحث")));

              return;
            }
            navigateSecondPage(data: getNames());
          },
          isExtended: true,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          icon: const Icon(Icons.search, size: 20),
          label: Text(
            S.of(context).search.toUpperCase(),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        //
        body: Container(
            // padding: EdgeInsets.only(top:10),
            child:
                // listItems.isEmpty?Center(child: Text("Add some items"),):

                FutureBuilder(
                    future: getListItems(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.data != null) {
                        if (snapshot.data.isEmpty) {
                          return Center(
                            child: Text(langCode == "en" ? "Add some items" : "أضف بعض العناصر"),
                          );
                        }
                        return ListView.builder(
                          controller: _scrollController,
                            itemCount: Provider.of<SettingsProvider>(context,
                                    listen: false)
                                .shoppingListItems
                                .length,
                            // snapshot.data.length,
                            itemBuilder: (context, index) {
                              // return Text(snapshot.data[index]["name"]);
                              return Dismissible(
                                key: UniqueKey(),
                                onDismissed: (direction) async {
                                  var result = await deleteListItem(
                                      id: Provider.of<SettingsProvider>(context,
                                              listen: false)
                                          .shoppingListItems[index]["id"],
                                      index: index);
                                  setState(() {});

                                  // Then show a snackbar.
                                  if (result["success"] == "1") {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content:
                                            Text(langCode == "en" ? 'Item deleted successfully' : "تم حذف العنصر بنجاح")));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text(langCode == "en" ? "Could not delete item" : "لا يمكن حذف العنصر")));
                                  }
                                },
                                // Show a red background as the item is swiped away.
                                background: Container(color: Colors.red),
                                child: ListCard(
                                  index: index,
                                  title: Provider.of<SettingsProvider>(context,
                                          listen: false)
                                      .shoppingListItems[index]["name"],
                                ),
                              );
                            });
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    })),
      ),
    );
  }
}

class ListCard extends StatefulWidget {
  final title;
  final index;
  ListCard({this.title, this.index});
  @override
  _ListCardState createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (widget.index == 0)
        SizedBox(
          height: 5,
        ),
      Card(
          child: Container(
        height: 30,
        padding: EdgeInsets.only(left: 10.0, right: 10),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            widget.title,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: 0.5,
            color: Colors.black),
          ),
          RoundCheckBox(
            size: 23,
            checkedColor: Theme.of(context).primaryColor,
            isChecked: Provider.of<SettingsProvider>(context)
                .shoppingListItems[widget.index]["isSelected"],
            onTap: (val) {
              // print(val);
              Provider.of<SettingsProvider>(context, listen: false)
                  .listItemStatusChanger(widget.index, val);
            },
          ),
          // ClipRRect(
          //   clipBehavior: Clip.hardEdge,
          //   borderRadius: BorderRadius.all(Radius.circular(6)),
          //   child: SizedBox(
          //     width: Checkbox.width,
          //     height: Checkbox.width,
          //     child: Container(
          //       decoration: new BoxDecoration(
          //         border: Border.all(
          //           width: 1,
          //         ),
          //         borderRadius: new BorderRadius.circular(5),
          //       ),
          //       child: Theme(
          //         data: ThemeData(
          //           unselectedWidgetColor: Colors.transparent,
          //         ),
          //         child: Checkbox(
          //           value: Provider.of<SettingsProvider>(context)
          //               .shoppingListItems[widget.index]["isSelected"],
          //           onChanged: (val) {
          //             Provider.of<SettingsProvider>(context, listen: false)
          //                 .listItemStatusChanger(widget.index, val);
          //           },
          //           activeColor: Theme.of(context).primaryColor,
          //           // checkColor: CommonColors.checkBoxColor,
          //           materialTapTargetSize: MaterialTapTargetSize.padded,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ]),

        // CheckboxListTile(
        //     activeColor: Theme.of(context).primaryColor,
        //     dense: true,
        //     //font change
        //     title: new Text(
        //       widget.title,
        //       style: TextStyle(
        //           fontSize: 14,
        //           fontWeight: FontWeight.w600,
        //           letterSpacing: 0.5),
        //     ),
        //     value: Provider.of<SettingsProvider>(context)
        //         .shoppingListItems[widget.index]["isSelected"],
        //     // secondary: Container(
        //     //   height: 50,
        //     //   width: 50,
        //     //   child: Image.asset(
        //     //     checkBoxListTileModel[index].img,
        //     //     fit: BoxFit.cover,
        //     //   ),
        //     // ),
        //     onChanged: (bool val) {
        //       print(val);
        //       // print(Provider.of<SettingsProvider>(context, listen: false)
        //       //     .shoppingListItems[widget.index]["isSelected"]);
        //       // Provider.of<SettingsProvider>(context, listen: false)
        //       //         .shoppingListItems[widget.index]["isSelected"] =
        //       //     !Provider.of<SettingsProvider>(context, listen: false)
        //       //         .shoppingListItems[widget.index]["isSelected"];

        //       Provider.of<SettingsProvider>(context, listen: false)
        //           .listItemStatusChanger(widget.index, val);
        //       // itemChange(val, index);
        //     })
      ))
    ]);
  }
}
/*

// Locally Saved Data
import 'dart:convert';

import 'package:ctown/app.dart';
import 'package:ctown/screens/settings/settings_provider.dart';
import 'package:ctown/widgets/home/search/search_results.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'db_crud.dart';

class ShoppingListItems extends StatefulWidget {
  final data;
  ShoppingListItems({this.data});
  @override
  _ShoppingListItemsState createState() => _ShoppingListItemsState();
}

class _ShoppingListItemsState extends State<ShoppingListItems> {
  List<Map<String, dynamic>> items;
  TextEditingController listItemController = TextEditingController(text: "");
  //
  Size screenSize;
  //
  Future queryItem() async {
    items = [];
    var result = await singleRecordQuery(id: widget.data["_id"]);
    jsonDecode(result[0]["items"]).forEach((e) {
      items.add({"name": e.toString(), "isSelected": false});
    });
    Provider.of<SettingsProvider>(context, listen: false)
        .setShoppingListItems(items);
    print("result $result");
    return result;
  }

  bool getValue(String name) {
    items.forEach((element) {
      if (element["name"] == name) {
        print(element["name"] + "+    " + name);
        // return element["isSelected"];
      }
    });
    return false;
  }

//

  String getItems(item) {
    List itemdata = [];
    Provider.of<SettingsProvider>(context, listen: false)
        .shoppingListItems
        .forEach((element) {
      itemdata.add(element["name"]);
    });
    itemdata.add(item);
    print(itemdata);
    print(jsonEncode(itemdata).toString());
    return jsonEncode(itemdata).toString();
  }

//
  getNames() {
    List allSearchTexts =
        Provider.of<SettingsProvider>(context, listen: false).shoppingListItems;
    List searchTexts = [];
    allSearchTexts.forEach((element) {
      if (!element["isSelected"]) {
        searchTexts.add(element);
      }
    });
    print("searchtexts  $searchTexts");
    String text = "";

    for (int i = 0; i < searchTexts.length; i++) {
      text = text + searchTexts[i]["name"];
      if (i < searchTexts.length - 1) {
        text = text + ",";
      }
    }
    print(text);
    // searchTexts.forEach((element) {
    //   text = text + element + ",";
    // });
    return text;
    // Provider.of<SettingsProvider>(context, listen: false)
    //     .shoppingListItems
    //     .forEach((element) {
    //   itemdata.add(element["name"]);
    // });
  }

  //
  // deleteItemFromProvider({String name}) {
  //   List previousData =
  //       Provider.of<SettingsProvider>(context, listen: false).shoppingListItems;
  //   previousData.forEach((element) {
  //     if (element["name"] == name) {
  //       print("removed element $element");
  //       previousData.remove(element);
  //     }
  //   });
  //   List latestData = previousData;
  //   Provider.of<SettingsProvider>(context, listen: false)
  //       .setShoppingListItems(latestData);
  // }

//
  getItemsAfterDelete({String name}) {
    List dataToString = [];
    List previousData =
        Provider.of<SettingsProvider>(context, listen: false).shoppingListItems;
    var foundElement;
    previousData.forEach((element) {
      if (element["name"] == name) {
        foundElement = element;
        print("removed element $element");
      }
    });
    print("ddd");
    print(previousData);
    print(foundElement);
    previousData.remove(foundElement);
    Provider.of<SettingsProvider>(context, listen: false)
        .shoppingListItems
        .remove(foundElement);
    print(previousData);
    previousData.forEach((element) {
      dataToString.add(element["name"]);
    });

    return jsonEncode(dataToString).toString();
  }

//
  Future onGoBack(dynamic value) {
    // refreshData();
    setState(() {});
  }

  void navigateSecondPage({data}) {
    Route route = MaterialPageRoute(
        builder: (context) => SearchResults(
              name: data,
              isBarcode: false,
            ));
    Navigator.push(context, route).then(onGoBack);
  }

//
  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.data["name"],
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
              // var result = await singleRecordQuery(id: widget.data["_id"]);
              // print(jsonDecode(result[0]["items"]));
              // print(jsonDecode(result[0]["items"]).runtimeType);
              // print(jsonDecode(result[0]["items"])[0]);
              Navigator.pop(context);
              // print(Provider.of<SettingsProvider>(context, listen: false)
              //     .shoppingListItems);
            }),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
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
                              "Enter the List Item",
                              style: TextStyle(fontSize: 17.5),
                            ),
                            Container(
                              width: screenSize.width * 0.8,
                              child: TextField(
                                // obscureText: true,
                                controller: listItemController,
                                decoration: InputDecoration(),
                                onSubmitted: (e) {
                                  // if (listItemController.text.isNotEmpty)
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
                                    if (listItemController.text.isEmpty) {
                                      SnackBar snackBar = SnackBar(
                                        content: Text("please enter item name"),
                                      );
                                      Scaffold.of(context)
                                          .showSnackBar(snackBar);
                                      return;
                                    }
                                    print(listItemController.text);
                                    update(
                                        id: widget.data["_id"],
                                        name: widget.data["name"],
                                        items:
                                            getItems(listItemController.text));

                                    // jsonEncode(["Potato", "Tomato"])
                                    //     .toString());
                                    setState(() {
                                      // shoppingListData.add(listItemController.text);
                                    });
                                    listItemController.clear();
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 40,
                                    child: Center(child: Text("Save")),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(10)),
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
          ),
          SizedBox(width: 20)
        ],
      ),
      //

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if(  Provider.of<SettingsProvider>(context, listen: false)
        .shoppingListItems.isEmpty){
          // print("Empty");
           Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('Please add some items to search')));
          
          return;
        }
          navigateSecondPage(data: getNames());
        },
        isExtended: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        icon: const Icon(Icons.search, size: 20),
        label: Text(
          "search".toUpperCase(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      //
      body: Container(
        // padding: EdgeInsets.only(top:10),
        child: FutureBuilder(
            future: queryItem(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                List listData = jsonDecode(snapshot.data[0]["items"]);
                if (listData.isEmpty) {
                  return Center(child: Text("Add some items"));
                }
                return ListView.builder(
                    itemCount:
                        Provider.of<SettingsProvider>(context, listen: false)
                            .shoppingListItems
                            .length,
                    itemBuilder: (context, index) {
                      
                      return Dismissible(
                        // Each Dismissible must contain a Key. Keys allow Flutter to
                        // uniquely identify widgets.
                        key: UniqueKey(),
                        // Provide a function that tells the app
                        // what to do after an item has been swiped away.
                        onDismissed: (direction) async {
                          // Remove the item from the data source.
                          // deleteItemFromProvider(
                          //     name: Provider.of<SettingsProvider>(context,
                          //             listen: false)
                          //         .shoppingListItems[index]["name"]);

                          await update(
                              id: widget.data["_id"],
                              name: widget.data["name"],
                              items: getItemsAfterDelete(
                                  name: Provider.of<SettingsProvider>(context,
                                          listen: false)
                                      .shoppingListItems[index]["name"]));
                          setState(() {});

                          // Then show a snackbar.
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('item deleted successfully')));
                        },
                        // Show a red background as the item is swiped away.
                        background: Container(color: Colors.red),
                        child: ListCard(
                          index: index,
                          title: Provider.of<SettingsProvider>(context,
                                  listen: false)
                              .shoppingListItems[index]["name"],
                        ),
                      );

                      // return Text(listData[index].toString());
                    });
              }
              return Center(
                child: Text("No data"),
              );
            }),
      ),
    );
  }
}

class ListCard extends StatefulWidget {
  final title;
  final index;
  ListCard({this.title, this.index});
  @override
  _ListCardState createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
  @override
  Widget build(BuildContext context) {
    return Column(children:[
        if(widget.index==0)SizedBox(height: 5,),Card(
      child: 
        Container(
        height: 30,
        padding: EdgeInsets.only(left:10.0,right:10),
        child:

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
   Text(
                  widget.title,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5),),
  RoundCheckBox(
    size: 23,
    checkedColor: Theme.of(context).primaryColor,
              onTap: (val) {
                

                          // print(Provider.of<SettingsProvider>(context, listen: false)
                  //     .shoppingListItems[widget.index]["isSelected"]);
                  // Provider.of<SettingsProvider>(context, listen: false)
                  //         .shoppingListItems[widget.index]["isSelected"] =
                  //     !Provider.of<SettingsProvider>(context, listen: false)
                  //         .shoppingListItems[widget.index]["isSelected"];

                  Provider.of<SettingsProvider>(context, listen: false)
                      .listItemStatusChanger(widget.index, val);
              
              },
            ),
]),


            // CheckboxListTile(
            //     activeColor: Theme.of(context).primaryColor,
            //     dense: true,
            //     //font change
            //     title: new Text(
            //       widget.title,
            //       style: TextStyle(
            //           fontSize: 14,
            //           fontWeight: FontWeight.w600,
            //           letterSpacing: 0.5),
            //     ),
            //     value: Provider.of<SettingsProvider>(context)
            //         .shoppingListItems[widget.index]["isSelected"],
            //     // secondary: Container(
            //     //   height: 50,
            //     //   width: 50,
            //     //   child: Image.asset(
            //     //     checkBoxListTileModel[index].img,
            //     //     fit: BoxFit.cover,
            //     //   ),
            //     // ),
            //     onChanged: (bool val) {
            //       print(val);
            //       // print(Provider.of<SettingsProvider>(context, listen: false)
            //       //     .shoppingListItems[widget.index]["isSelected"]);
            //       // Provider.of<SettingsProvider>(context, listen: false)
            //       //         .shoppingListItems[widget.index]["isSelected"] =
            //       //     !Provider.of<SettingsProvider>(context, listen: false)
            //       //         .shoppingListItems[widget.index]["isSelected"];

            //       Provider.of<SettingsProvider>(context, listen: false)
            //           .listItemStatusChanger(widget.index, val);
            //       // itemChange(val, index);
            //     })
          
      
      )
    )]);
  }
}
*/
