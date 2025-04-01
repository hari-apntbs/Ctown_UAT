import 'dart:convert';

import 'package:ctown/common/constants/loading.dart';
import 'package:ctown/screens/settings/return_product_model.dart';
import 'package:ctown/screens/settings/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ReturnPolicy extends StatefulWidget {
  final orderId;
  ReturnPolicy({this.orderId});
  @override
  _ReturnPolicyState createState() => _ReturnPolicyState();
}

class _ReturnPolicyState extends State<ReturnPolicy> {
  Map<String?, String?> packageMap = {};
  Map<String?, String?> reasonMap = {};
  TextEditingController msgController = TextEditingController();
  FocusNode? msgNode;

  late Size screenSize;
  List responseList = [];
  List<String?> packageConditions = [];
  List<String?> reasons = [];
  String? _chosenPackageCondition;
  String? _chosenReason = "Android";
  late SettingsProvider settingsProvider;

  packageConditionGetter() async {
    String apiUrl = "https://up.ctown.jo/api/returnpackage.php";
    var response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      responseBody["data"].forEach((e) {
        packageConditions.add(e["pts_name"]);
        packageMap[e["pts_packagecondition_id"]] = e["pts_name"];
      });

      _chosenPackageCondition = packageConditions[0];

      setState(() {});
    }
  }

  reasonsGetter() async {
    String apiUrl = "https://up.ctown.jo/api/returnreason.php";
    var response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);

      responseBody["data"].forEach((e) {
        reasons.add(e["pts_name"]);
        reasonMap[e["pts_reason_id"]] = e["pts_name"];
      });
      _chosenReason = reasons[0];
      print(reasons);
      setState(() {});
    }
  }

  getProductsAndDetails() async {
    String apiUrl = "https://up.ctown.jo/api/returnproductlist.php";
    Map<String, dynamic> body = {"order_id": widget.orderId};
    var response = await http.post(Uri.parse(apiUrl), body: jsonEncode(body));
    if (response.statusCode == 200) {
      List? responseBody = jsonDecode(response.body)["data"];
      // print(responseBody);
      // List data = responseBody;
      List<ReturnProductModel> products = returnProductModelFromJson(
          jsonEncode(jsonDecode((response.body))["data"]).toString());

      if (settingsProvider.returnProducts.isEmpty ||
          settingsProvider.selectedProductsForReturn.isEmpty) {
        settingsProvider.setReturnProducts(products);
        responseBody!.forEach((e) {
          settingsProvider.addSelectedProductsForReturn(e["name"]);
        });
      }

      return responseBody;
    }
    return [];
  }

  submitDetails() async {
    String apiUrl = "https://up.ctown.jo/api/addreturn.php";
    String packageId = packageMap.keys.firstWhere(
        (k) => packageMap[k] == _chosenPackageCondition,
        orElse: () => null)!;
    String reasonId = reasonMap.keys
        .firstWhere((k) => reasonMap[k] == _chosenReason, orElse: () => null)!;

    List items = [];
    settingsProvider.returnProducts.forEach((product) {
      if (product.selected!) {
        items.add({"product_id": product.id, "qty": product.qty});
      }
    });
    Map body = {
      "order_id": widget.orderId,
      "package_id": int.parse(packageId),
      "reason_id": int.parse(reasonId),
      "message": msgController.text,
      "item": items
    };
    print(body);
    var response = await http.post(Uri.parse(apiUrl), body: jsonEncode(body));
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      print(responseBody);
      return responseBody;
    }
    return {};
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    packageConditionGetter();
    reasonsGetter();
    msgNode = FocusNode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    settingsProvider.selectedProductsForReturn.clear();
  }

  @override
  Widget build(BuildContext context) {
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    screenSize = MediaQuery.of(context).size;
    return Scaffold(
        // appBar: AppBar(),
        appBar: AppBar(
          title: Text(
            "Return Policy",
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
            msgNode!.unfocus();
          },
          child: Container(
            height: screenSize.height,
            padding: EdgeInsets.only(top: 15, left: 15, right: 15),
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      child: Text(
                        "Enter all the details",
                        style: TextStyle(fontSize: 17),
                      ),
                      onTap: () async {
                        // await packageConditionGetter();
                        // print(packageMap);
                        // print(reasonMap);

                        // await getProductsAndDetails();
                        // print(settingsProvider.selectedProductsForReturn);
                        // settingsProvider.returnProducts.forEach((element) {
                        //   print(element.selected);
                        // });
                        msgNode!.unfocus();
                      },
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    if (packageMap.keys.length != null)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Package Condition",
                              style: TextStyle(fontSize: 13.7),
                            ),
                            // SizedBox(heig)
                            SizedBox(
                              width: 130,
                              height: 50,
                              child: ButtonTheme(
                                alignedDropdown: true,
                                child: DropdownButton<String>(
                                  focusColor: Colors.white,
                                  value: _chosenPackageCondition,
                                  // packageMap.values.toList()[0],
                                  elevation: 5,
                                  style: TextStyle(color: Colors.white),
                                  iconEnabledColor: Colors.black,
                                  items:
                                      //  <String>[
                                      //   'Android',
                                      //   'IOS',
                                      //   'Flutter',
                                      //   'Node',
                                      //   'Java',
                                      //   'Python',
                                      //   'PHP',
                                      // ].

                                      packageConditions
                                          // packageMap.values
                                          //     .toList()
                                          .map<DropdownMenuItem<String>>(
                                              (String? value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value!,
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      _chosenPackageCondition = value;
                                    });
                                    print(_chosenPackageCondition);
                                  },
                                ),
                              ),
                            ),
                          ]),
                    SizedBox(height: 15),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Reason",
                            style: TextStyle(fontSize: 13.7),
                          ),
                          // SizedBox(heig)
                          SizedBox(
                            width: 150,
                            height: 50,
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<String>(
                                focusColor: Colors.white,
                                value: _chosenReason,
                                elevation: 5,
                                style: TextStyle(color: Colors.white),
                                iconEnabledColor: Colors.black,
                                items: reasons.map<DropdownMenuItem<String>>(
                                    (String? value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value!,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  setState(() {
                                    _chosenReason = value;
                                  });
                                  print(_chosenReason);
                                },
                              ),
                            ),
                          ),
                        ]),
                    SizedBox(height: 15),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Add Message"),
                          SizedBox(height: 5),
                          TextFormField(
                            // minLines: 2,
                            controller: msgController,
                            focusNode: msgNode,
                            maxLines: 7,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              hintText: 'Your message',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0)),
                              ),
                            ),
                            onChanged: (e) {},
                            onEditingComplete: () {
                              // print("printer");
                              msgNode!.unfocus();
                            },
                            onFieldSubmitted: (e) {
                              // print("printer");
                              msgNode!.unfocus();
                            },
                          ),
                        ]),
                    SizedBox(height: 15),
                    Container(
                        width: double.infinity,
                        // height: 160,
                        child: FutureBuilder(
                            future: getProductsAndDetails(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                // return Text(snapshot.data.toString());
                                // snapshot.data.forEach((e) {
                                //   settingsProvider
                                //       .addSelectedProductsForReturn(e["name"]);
                                // });

                                // return ListView.builder(
                                //   itemCount: snapshot.data.length,
                                //   itemBuilder: (context, index) {
                                //     return ProductRows(
                                //       productName: snapshot.data[index]["name"],
                                //     );
                                //   },
                                // );
                                return Column(
                                  children:
                                      // List.generate(
                                      //     snapshot.data.length,
                                      //     (index) => ProductRows(
                                      //           productName: snapshot.data[index]
                                      //               ["name"],
                                      //           productQty: int.parse(snapshot
                                      //               .data[index]["qty"]
                                      //               .toString()
                                      //               .split(".")[0]),
                                      //         )));
                                      List.generate(
                                    settingsProvider.returnProducts.length,
                                    (index) => ProductRows(
                                      productName: settingsProvider
                                          .returnProducts[index].name,
                                      // isSelected: settingsProvider
                                      //     .returnProducts[index].selected,
                                      index: index,
                                      productQty: settingsProvider
                                          .returnProducts[index].qty,
                                    ),
                                  ),
                                );
                              }
                              return Center(child: CircularProgressIndicator());
                            })),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        msgNode!.unfocus();
                      },
                      child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Text(
                              "Click here to indicate that you have read and agree to the terms presented in the Terms and Conditions agreement")),
                    ),
                    SizedBox(height: 15),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 10, top: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ElevatedButton(
                                  onPressed: () async {
                                    bool atleastOneSelected = false;
                                    settingsProvider.returnProducts
                                        .forEach((element) {
                                      if (element.selected!) {
                                        atleastOneSelected = true;
                                      }
                                    });
                                    if (atleastOneSelected) {
                                      showDialog(
                                          context: context,
                                          builder: kLoadingWidget,
                                          barrierDismissible: false);
                                      var result = await submitDetails();
                                      print(result);
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      if (result["success"] != null) {
                                        if (result["success"] == "1") {
                                          SnackBar snackbar = SnackBar(
                                              duration:
                                                  Duration(milliseconds: 1500),
                                              content: Text(result["message"]));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackbar);
                                          print("1");
                                          Future.delayed(Duration(seconds: 3),
                                              () {
                                            Navigator.pop(context);
                                          });
                                          return;
                                        }
                                        // else{
                                        //     print("2");
                                        print(
                                            "thtis success ${result["success"].runtimeType}");
                                        SnackBar snackbar = SnackBar(
                                            duration:
                                                Duration(milliseconds: 1500),
                                            content: Text(result["message"]));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackbar);
                                      }
                                      // }
                                    } else {
                                      SnackBar snackbar = SnackBar(
                                          content: Text(
                                              "Select atleast one product"));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackbar);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        new BorderRadius.circular(20.0)),
                                  ),
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ])),
                  ]),
            ),
          ),
        ));
  }
}

class ProductRows extends StatelessWidget {
  ProductRows(
      {this.productName,
      this.productPrice,
      this.isSelected,
      this.index,
      this.productQty});
  final productName;
  final productPrice;
  bool? isSelected;
  int? index;
  final int? productQty;
  late Size screenSize;
  // bool isSelected = true;

  late SettingsProvider settingsProvider;

  TextEditingController qtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    qtyController.text = productQty.toString();
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(children: [
        // Checkbox(
        //     value: isSelected,
        //     onChanged: (value) {
        //       if (value) {
        //         settingsProvider
        //             .addSelectedProductsForReturn(widget.productName);
        //       } else {
        //         settingsProvider
        //             .removeSelectedProductsForReturn(widget.productName);
        //       }
        //       setState(() {
        //         isSelected = value;
        //       });
        //     }),
        Checkbox(
            value: Provider.of<SettingsProvider>(context)
                .returnProducts[index!]
                .selected,
            onChanged: (value) {
              settingsProvider.selectedProduct(index, value);
            }),
        Container(
          width: screenSize.width * 0.8,
          // color: Colors.red,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                // textAlign: TextAlign.justify,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 13,
                ),
              ),

              // SizedBox(height: 10),
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                        text: 'Price :',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                        children: <TextSpan>[
                          TextSpan(
                            text: '1500',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ]),
                  ),
                  SizedBox(width: 50),
                  Row(children: [
                    Text(
                      'Qty :',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                    Row(children: [
                      IconButton(
                          icon: Icon(
                            Icons.remove,
                            size: 16,
                          ),
                          onPressed: () {
                            if (settingsProvider.returnProducts[index!]
                                .selected!) if (settingsProvider
                                    .returnProducts[index!].qty! >
                                1) {
                              settingsProvider.selectedProductRemoveQty(
                                  index!, 1);
                            }
                          }),
                      // Container(
                      //     height: 30,
                      //     width: 30,
                      //     // color: Colors.red,
                      //     padding: EdgeInsets.only(left: 5),
                      //     child: TextFormField(
                      //       onChanged: (e) {
                      //         print(e);
                      //       },
                      //       onFieldSubmitted: (e) {
                      //         print("Submitted");
                      //         settingsProvider.returnProducts[index].qty =
                      //             e.toString();
                      //       },
                      //       keyboardType: TextInputType.number,
                      //       decoration: InputDecoration(

                      //           // contentPadding: EdgeInsets.only(
                      //           //     left: 5, right: 5, bottom: 5)
                      //           ),
                      //       controller: qtyController,
                      //     )),

                      Container(
                        height: 30,
                        width: 18,
                        child: Center(
                            child: Text(Provider.of<SettingsProvider>(context)
                                .returnProducts[index!]
                                .qty
                                .toString())),
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.add,
                            size: 16,
                          ),
                          onPressed: () {
                            if (settingsProvider.returnProducts[index!]
                                .selected!) if (settingsProvider
                                    .returnProducts[index!].originalQty! >
                                settingsProvider.returnProducts[index!].qty!) {
                              settingsProvider.selectedProductAddQty(index!, 1);
                            }
                          }),
                    ])
                  ])
                ],
              ),
              // ),
            ],
          ),
        ),
        // SizedBox(
        //   width: 10,
        // ),
        // Text("1500"),
        // SizedBox(
        //   width: 10,
        // ),
        // Text("2")
      ]),
    );
  }
}

/*
class ProductRows extends StatefulWidget {
  final productName;
  final productPrice;
  bool isSelected;
  int index;
  final int productQty;
  ProductRows(
      {this.productName,
      this.index,
      this.isSelected,
      this.productPrice,
      this.productQty});
  @override
  _ProductRowsState createState() => _ProductRowsState();
}

class _ProductRowsState extends State<ProductRows> {
  Size screenSize;
  // bool isSelected = true;

  SettingsProvider settingsProvider;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // if (widget.productName != null)
    //   settingsProvider.addSelectedProductsForReturn(widget.productName);
  }

  TextEditingController qtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    qtyController.text = widget.productQty.toString();
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(children: [
        // Checkbox(
        //     value: isSelected,
        //     onChanged: (value) {
        //       if (value) {
        //         settingsProvider
        //             .addSelectedProductsForReturn(widget.productName);
        //       } else {
        //         settingsProvider
        //             .removeSelectedProductsForReturn(widget.productName);
        //       }
        //       setState(() {
        //         isSelected = value;
        //       });
        //     }),
        Checkbox(
            value: Provider.of<SettingsProvider>(context)
                .returnProducts[widget.index]
                .selected,
            onChanged: (value) {
              // setState(() {
              //   //   widget.isSelected = value;

              //   settingsProvider.returnProducts[widget.index].selected = value;
              // });

              Provider.of<SettingsProvider>(context, listen: false)
                  .selectedProduct(widget.index, value);
            }),
        Container(
          width: screenSize.width * 0.8,
          // color: Colors.red,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  print(settingsProvider.selectedProductsForReturn);
                },
                child: Text(
                  widget.productName,
                  // textAlign: TextAlign.justify,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                        text: 'Price :',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                        children: <TextSpan>[
                          TextSpan(
                            text: '1500',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ]),
                  ),
                  SizedBox(width: 50),
                  Row(children: [
                    Text(
                      'Qty :',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                    Container(
                        height: 30,
                        width: 30,
                        // color: Colors.red,
                        padding: EdgeInsets.only(left: 5),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(

                              // contentPadding: EdgeInsets.only(
                              //     left: 5, right: 5, bottom: 5)
                              ),
                          controller: qtyController,
                        ))
                  ])
                ],
              ),
              // ),
            ],
          ),
        ),
        // SizedBox(
        //   width: 10,
        // ),
        // Text("1500"),
        // SizedBox(
        //   width: 10,
        // ),
        // Text("2")
      ]),
    );
  }
}
*/
