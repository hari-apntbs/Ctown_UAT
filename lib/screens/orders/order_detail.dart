// import 'package:ctown/models/entities/order.dart';
// import 'package:ctown/screens/orders/suggested_product_model.dart';
// import 'package:ctown/screens/orders/suggested_product_provider.dart';
// import 'package:ctown/screens/orders/suggested_products.dart';
// import 'package:country_pickers/country_pickers.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:provider/provider.dart';
// import 'package:share/share.dart';
// import 'dart:io';

// import 'package:webview_flutter/webview_flutter.dart' as web;

// import '../../common/config.dart';
// import '../../common/constants.dart';
// import '../../common/tools.dart';
// import '../../generated/l10n.dart';
// import '../../models/index.dart'
//     show
//         AppModel,
//         Order,
//         OrderModel,
//         OrderNote,
//         PaymentMethodModel,
//         Product,
//         UserModel;
// import '../../services/index.dart';
// import 'package:flutter/foundation.dart';

// import "package:path_provider/path_provider.dart";
// import 'package:permission_handler/permission_handler.dart';

// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:http/http.dart' as http;
// import 'package:printing/printing.dart';
// import 'dart:convert';
// import 'package:ctown/frameworks/magento/services/magento.dart';

// class OrderDetail extends StatefulWidget {
//   final Order order;
//   String productType;
//   final List<ProductItem> lineItem;
//   final String fromWhere;
//   final VoidCallback onRefresh;

//   OrderDetail(
//       {this.order,
//       this.onRefresh,
//       this.productType,
//       this.lineItem,
//       this.fromWhere});

//   @override
//   _OrderDetailState createState() => _OrderDetailState();
// }

// class _OrderDetailState extends State<OrderDetail> {
//   final services = Services();
//   String tracking;
//   var widgets;
//   Order order;
//   Product product;
//   TextEditingController cancelQuantity = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   String cancelQty = "";

//   get decoration => null;

//   @override
//   void initState() {
//     super.initState();
//     ordersubsteatus();

//     order = widget.order;
//   }

//   noteFunction(id) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String note = await prefs.getString("note_$id");

//     return note;
//   }

//   showAlertDialog(BuildContext context) {
//     // set up the buttons
//     Widget cancelButton = TextButton(
//       child: Text("Cancel"),
//       onPressed: () {
//         Navigator.of(context).pop(false);
//       },
//     );
//     Widget continueButton = TextButton(
//       child: Text("Continue"),
//       onPressed: () {},
//     );

//     // set up the AlertDialog
//     AlertDialog alert = AlertDialog(
//       title: Text("AlertDialog"),
//       content: Text(
//           "Would you like to continue learning how to use Flutter alerts?"),
//       actions: [
//         cancelButton,
//         continueButton,
//       ],
//     );

//     // show the dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }

//   applyReplacement(
//       {String ofsProductId,
//       String ofsProductPrice,
//       String ofsProductBarcode,
//       String orderId,
//       String productType,
//       String replacementId,
//       String replacementBarcode,
//       String startPicking,
//       String replacementPrice,
//       int qty}) async {
//     String url =
//         "https://up.ctown.jo/api/outofstock_customer_choose_product_replacement.php";
//     Map body = {
//       "order_id": orderId,
//       "outofstock_product_id": ofsProductId,
//       "outofstock_barcode": ofsProductBarcode,
//       "outofstock_price": ofsProductPrice,
//       "choose_replacement_price": replacementPrice,
//       "startpicking": startPicking,
//       "choose_replacement_product_id": replacementId,
//       "choose_replacement_barcode": replacementBarcode,
//       "product_type": productType,
//       "outofstock_qty": qty
//     };
//     print(url);
//     print(jsonEncode(body));

//     var response = await http.post(url, body: jsonEncode(body));
//     var responseBody = {};
//     if (response.statusCode == 200) {
//       responseBody = jsonDecode(response.body);
//       print(responseBody);
//       return responseBody;
//     }
//     return responseBody;
//   }

//   deleteReplacement(
//       {String ofsProductId,
//       String ofsProductPrice,
//       String ofsProductBarcode,
//       String orderId,
//       String productType,
//       int ofsQty}) async {
//     String url =
//         "https://up.ctown.jo/api/outofstock_replacement_product_customer_delete.php";
//     Map body = {
//       "order_id": orderId,
//       "outofstock_product_id": ofsProductId,
//       "outofstock_price": ofsProductPrice,
//       "outofstock_barcode": ofsProductBarcode,
//       "product_type": productType,
//       "outofstock_qty": ofsQty
//     };
//     print(url);
//     print(jsonEncode(body));

//     var response = await http.post(url, body: jsonEncode(body));
//     var responseBody = {};
//     if (response.statusCode == 200) {
//       responseBody = jsonDecode(response.body);
//       print(responseBody);
//       return responseBody;
//     }
//     return responseBody;
//   }

//   Future<List<SuggestedProduct>> getReplacement() async {
//     String url =
//         "https://up.ctown.jo/api/outofstock_product_replacement_customer.php";
//     Map body = {"order_id": widget.order.id};
//     print("dddi");
//     print(url);
//     print(jsonEncode(body));
//     var response = await http.post(url, body: jsonEncode(body));
//     if (response.statusCode == 200) {
//       var responseBody = jsonDecode(response.body);
//       // print(responseBody["data"].length);
//       // print("bef");
//       // print(responseBody["data"].runtimeType);
//       /*responseBody["data"].forEach((e) {
//         String a = e["outofstock_product_details"][0]["product_type"];
//         String b = widget.productType;
//         print("a $a");
//         print("b $b");
//         print("if ${a == b}");
//         if ((a == b) == false) {
//           print("threat ${e["outofstock_product_details"][0]["product_type"]}");
//           try {
//             print("rempoving");
//             responseBody["data"].remove(e);
//             print("removed");
//           } catch (e) {
//             print("catch $e");
//           }
//         }
//       });*/
//       // print("aft");
//       // print(responseBody["data"].length);
//       Provider.of<SuggestedProductProvider>(context, listen: false)
//           .selectedReplacementProductsData
//           .clear();
//       print("responseBody $responseBody");
//       List<SuggestedProduct> list =
//           suggestedProductFromJson(jsonEncode(responseBody["data"]));
//       list = list
//           .where((i) =>
//               i.outofstockProductDetails[0].productType == widget.productType)
//           .toList();

//       List providerData = [];

//       list.forEach((e) {
//         List replacementDetails = [];

//         e.replacementProductDetails.forEach((element) {
//           replacementDetails.add({"isSelected": false, "item": element});
//         });
//         providerData.add({
//           "outofstock_product": e.outofstockProductDetails[0],
//           "replacement_products": replacementDetails,
//           "outofstock_qty": e.outofstockQty
//         });
//       });

//       Provider.of<SuggestedProductProvider>(context, listen: false)
//           .setSelectedReplacementProducts(providerData);

//       print("provider setted");
//       print(Provider.of<SuggestedProductProvider>(context, listen: false)
//           .selectedReplacementProductsData);
//       print(list);
//       return list;
//     }
//   }

//   Future getInvoice({orderId}) async {
//     String apiUrl = "https://up.ctown.jo/api/mobileinvoice.php";
//     Map body = {"order_id": orderId};
//     print(jsonEncode(body));
//     var response = await http.post(apiUrl, body: jsonEncode(body));
//     var responseBody;
//     print(response.statusCode);
//     if (response.statusCode == 200) {
//       responseBody = jsonDecode(response.body);
//       print(responseBody);
//       return responseBody;
//     } else {
//       responseBody = {};
//     }
//     return responseBody;
//   }

//   // List produid=[];
//   String status;
//   var produid;
//   Future configproduct(orderid, sku, delivery_from) async {
//     String apiUrl = "https://up.ctown.jo/api/particularitem_status_check.php";

//     Map body = {
//       "order_id": orderid,
//       "sku": sku,
//       "delivery_from": delivery_from
//     };

//     print(jsonEncode(body));
//     var response = await http.post(apiUrl, body: jsonEncode(body));
//     var responseBody;
//     print(response.statusCode);

//     if (response.statusCode == 200) {
//       responseBody = jsonDecode(response.body);
//       produid = responseBody["data"][0]["product_id"];
//       status = responseBody["data"][0]["sub_status"];
//       print(responseBody);

//       return responseBody;
//     } else {
//       responseBody = {};
//     }
//     return responseBody;
//   }

//   particularitemcancel({orderId, productId, ProductItem product, qty}) async {
//     String apiUrl =
//         "https://up.ctown.jo/api/particularitemcancelqtycheckmobile.php";
//     Map body = {"order_id": orderId, "product_id": productId};
//     print(jsonEncode(body));
//     var response = await http.post(apiUrl, body: jsonEncode(body));
//     var responseBody;
//     print(response.statusCode);
//     if (response.statusCode == 200) {
//       responseBody = jsonDecode(response.body);
//       // setState(() {
//       // product.qty_canceled= int.parse(responseBody["canceled_qty"].toString());
//       // });
//       print(responseBody);
//       return responseBody["data"];
//     } else {
//       responseBody = {};
//     }
//     return responseBody;
//   }

//   Future configproductname(sku, orderid) async {
//     print(json.encode({"sku": sku, "order_id": orderid}));
//     Uri uri =
//         Uri.parse('https://up.ctown.jo/api/configurable_label_weight_check.php');

//     try {
//       final client = http.Client();
//       final response = await client.post(
//         uri,
//         headers: {HttpHeaders.contentTypeHeader: 'application/json'},
//         body: json.encode({"sku": sku, "order_id": orderid}),
//       );
//       if (response.statusCode == 200) {
//         var body = jsonDecode(response.body);

//         print(body);

//         return body;
//       }
//     } catch (e) {
//       return 'Could not update data';
//     }
//   }

//   String text;
//   ordersubsteatus() async {
//     var mainStatus = widget.order.status;
//     var elements = [];
//     for (var i in widget.lineItem) {
//       print("${widget.order.increment_id}$elements${i.product_type}");
//       if (i.product_type == 'simple') {
//         if (i.delivery_from == 'Grocery' ||
//             i.delivery_from == 'Supplier' ||
//             i.delivery_from == 'Warehouse') {
//           widget.lineItem.forEach((element) {
//             if (element.product_type == "simple") {
//               elements.add(element.sub_status == 'Order Placed' &&
//                       mainStatus == 'processing'
//                   ? 'processing'
//                   : element.sub_status);
//             }
//           });
//         }

//         var map = Map();
//         elements.forEach((element) {
//           if (!map.containsKey(element)) {
//             map[element] = 1;
//           } else {
//             map[element] += 1;
//           }
//         });

//         print(widget.order.status);
//         print("array");

//         print(map);

//         String stCheck = '';
//         var arrCount = map.length;
//         if ((mainStatus == 'pending')) {
//           stCheck = mainStatus;
//         } else {
//           if (arrCount > 1) {
//             map.keys.forEach((k) {
//               if (k != "canceled") {
//                 stCheck = k;
//               }
//             });
//           } else {
//             var entryList = map.entries.toList();
//             stCheck = entryList[0].key;
//           }
//         }
//         text = stCheck;
//         print(mainStatus);

//         return stCheck;
//       }
//     }
//   }

//   Future downloadFile({String url, String fileName, String dir}) async {
//     HttpClient httpClient = new HttpClient();
//     File file;
//     String filePath = '';
//     String myUrl = "";

//     try {
//       myUrl = url;
//       // + fileName;
//       print(myUrl);
//       var request = await httpClient.getUrl(Uri.parse(myUrl));
//       print(request);
//       var response = await request.close();
//       print(response);
//       print(response.statusCode);
//       if (response.statusCode == 200) {
//         var bytes = await consolidateHttpClientResponseBytes(response);
//         Map<PermissionGroup, PermissionStatus> permissions =
//             await PermissionHandler()
//                 .requestPermissions([PermissionGroup.storage]);
//         PermissionStatus permission = await PermissionHandler()
//             .checkPermissionStatus(PermissionGroup.storage);
//         // if (!status.isGranted) {
//         //   await Permission.storage.request();
//         // }
//         print(permissions);
//         print("fdsegdgdrfg");
//         print(permission);
//         filePath = '$dir/$fileName.pdf';
//         file = File(filePath);
//         await file.writeAsBytes(bytes);
//         print("write file complete");
//       } else {
//         filePath = 'Error code: ' + response.statusCode.toString();
//         return "error code";
//       }
//     } catch (ex) {
//       print(ex);
//       filePath = 'Can not fetch url';
//       return "file system exception";
//     }
//     print(filePath);
//     return filePath;
//   }

//   Future<File> viewFile({String url, String fileName, String dir}) async {
//     HttpClient httpClient = HttpClient();
//     File file;
//     var request = await httpClient.getUrl(Uri.parse(url));
//     print(request);
//     var response = await request.close();
//     print(response);
//     print(response.statusCode);
//     var bytes;
//     if (response.statusCode == 200) {
//       bytes = await consolidateHttpClientResponseBytes(response);
//       final output = await getTemporaryDirectory();
//       print("output");
//       final file = File("${output.path}/$fileName.pdf");
//       print("file write starts");
//       var invoice = await file.writeAsBytes(bytes);
//       print("file write ends");
//       return invoice;
//     } else {
//       return Future.error('error');
//     }
//     // return file;
//   }

//   void getTracking() {
//     services.getAllTracking().then((onValue) {
//       if (onValue != null && onValue.trackings != null) {
//         for (var track in onValue.trackings) {
//           if (track.orderId == order.number) {
//             setState(() {
//               tracking = track.trackingNumber;
//             });
//           }
//         }
//       }
//     });
//   }

//   subtotal(List<ProductItem> lineItem) {
//     double price = 0.0;
//     lineItem.forEach((element) {
//       print(element.quantity);
//       price += element.price * double.parse(element.quantity.toString());
//     });
//     return price;
//   }

//   total(List<ProductItem> lineItem) {
//     double price = 0.0;
//     lineItem.forEach((element) {
//       print(element.quantity);
//       price += element.price * double.parse(element.quantity.toString());
//     });
//     return price;
//   }

//   void cancelOrder() {
//     Services().widget.cancelOrder(context, order).then((onValue) {
//       setState(() {
//         order = onValue;
//       });
//     });
//   }

//   void createRefund() {
//     if (order.status == 'refunded') return;
//     services.updateOrder(order.id, status: 'refunded').then((onValue) {
//       setState(() {
//         order = onValue;
//       });
//       Provider.of<OrderModel>(context, listen: false).getMyOrder(
//           userModel: Provider.of<UserModel>(context, listen: false));
//     });
//   }

//   GlobalKey<ScaffoldState> _orderKey = GlobalKey<ScaffoldState>();
//   // GlobalKey<ScaffoldState> _porderKey = GlobalKey<ScaffoldState>();
//   var elements = [];
//   @override
//   Widget build(BuildContext context) {
//     final userModel = Provider.of<UserModel>(context);
//     final currencyRate = Provider.of<AppModel>(context).currencyRate;

//     return Scaffold(
//       key: _orderKey,
//       backgroundColor: Theme.of(context).backgroundColor,
//       appBar: AppBar(
//         title: Text(
//           S.of(context).orderNo + " #${order.increment_id}",
//           style: const TextStyle(
//             fontSize: 16.0,
//             color: Colors.white,
//           ),
//         ),
//         leading: GestureDetector(
//           child: const Icon(
//             Icons.arrow_back_ios,
//             color: Colors.white,
//           ),
//           onTap: () => Navigator.pop(context),
//         ),
//       ),
//       // appBar: AppBar(
//       //   leading: IconButton(
//       //       icon: Icon(
//       //         Icons.arrow_back_ios,
//       //         size: 20,
//       //         color: Theme.of(context).accentColor,
//       //       ),
//       //       onPressed: () {
//       //         Navigator.of(context).pop();
//       //       }),
//       //   title: Text(
//       //     S.of(context).orderNo + " #${order.number}",
//       //     style: TextStyle(color: Theme.of(context).accentColor),
//       //   ),
//       //   backgroundColor: Theme.of(context).backgroundColor,
//       //   elevation: 0.0,
//       // ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 15.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             for (var i in widget.lineItem)
//               if (i.total != '0')
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   child: Column(
//                     children: [
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: <Widget>[
//                           Expanded(child: Text(i.name)),
//                           const SizedBox(
//                             width: 15,
//                           ),
//                           InkWell(
//                             child: Text("x${i.quantity}"),
//                             onTap: () {
//                               print(i.delivery_from);
//                               print(widget.order.id);
//                               print(i.productId);
//                               print(Provider.of<SuggestedProductProvider>(
//                                       context,
//                                       listen: false)
//                                   .selectedReplacementProductsData);
//                             },
//                           ),
//                           const SizedBox(width: 20),
//                           Text(
//                             Tools.getCurrencyFormatted(i.total, currencyRate),
//                             style: TextStyle(
//                                 color: Theme.of(context).accentColor,
//                                 fontWeight: FontWeight.w600),
//                           ),
//                           const SizedBox(
//                             width: 10.0,
//                           ),
//                           if (!kPaymentConfig['EnableShipping'] ||
//                               !kPaymentConfig['EnableAddress'])
//                             DownloadButton(i.productId)
//                         ],
//                       ),
//                       FutureBuilder(
//                           future: configproductname(i.sku, order.id),
//                           builder: (context, snapshot) {
//                             if (snapshot.data != null) {
//                               if (snapshot.data["success"] == 1) {
//                                 return Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     InkWell(
//                                       onTap: () {
//                                         print(i.qty_canceled);
//                                       },
//                                       child: Text(
//                                         snapshot.data["data"]["attributes_info"]
//                                                         [0]["label"]
//                                                     .toString() !=
//                                                 null
//                                             ? snapshot.data["data"]
//                                                     ["attributes_info"][0]
//                                                     ["label"]
//                                                 .toString()
//                                             : '',
//                                         style: TextStyle(
//                                             color:
//                                                 Theme.of(context).accentColor),
//                                       ),
//                                     ),
//                                     //  Text(
//                                     //         // "x" + i.qty_canceled.toString() ?? "x")

//                                     Container(
//                                         padding:
//                                             const EdgeInsets.only(right: 10),
//                                         child: Text(
//                                           snapshot.data["data"]
//                                                           ["attributes_info"][0]
//                                                       ["value"] !=
//                                                   null
//                                               ? snapshot.data["data"]
//                                                       ["attributes_info"][0]
//                                                   ["value"]
//                                               : '',
//                                           style: TextStyle(
//                                               color:
//                                                   Theme.of(context).accentColor,
//                                               fontWeight: FontWeight.w600),
//                                         ))
//                                   ],
//                                 );

//                                 // Text(
//                                 //     "${snapshot.data["data"]["attributes_info"][0]["label"].toString() != null ? snapshot.data["data"]["attributes_info"][0]["label"].toString() : ''}:${snapshot.data["data"]["attributes_info"][0]["value"] != null ? snapshot.data["data"]["attributes_info"][0]["value"] : ''}",style: TextStyle(
//                                 //     color: Theme.of(context).accentColor,
//                                 //     fontWeight: FontWeight.w600),);
//                               }
//                               return Container();
//                             }
//                             return Container();
//                           }),

//                       Padding(
//                         padding: const EdgeInsets.only(top: 7.0, right: 9.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               S.of(context).delivery,
//                               style: TextStyle(
//                                   color: Theme.of(context).accentColor),
//                             ),
//                             Text("${i.delivery_date}")
//                           ],
//                         ),
//                       ),

//                       // text=="Order Placed"||text=="processing"

//                       //       ?
//                       FutureBuilder(
//                           future: configproduct(
//                               order.id,
//                               i.sku,
//                               i.delivery_from == null
//                                   ? 'Grocery'
//                                   : i.delivery_from),
//                           builder: (context, snapshot) {
//                             return Column(
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                       top: 7.0, right: 9.0),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       InkWell(
//                                         onTap: () {
//                                           print(i.qty_canceled);
//                                         },
//                                         child: Text(
//                                           S.of(context).cancelled_qty,
//                                           style: TextStyle(
//                                               color: Theme.of(context)
//                                                   .accentColor),
//                                         ),
//                                       ),
//                                       //  Text(
//                                       //         // "x" + i.qty_canceled.toString() ?? "x")
//                                       snapshot.data != null
//                                           ? FutureBuilder(
//                                               future: particularitemcancel(
//                                                   orderId: order.id,
//                                                   productId:
//                                                       i.product_type == 'simple'
//                                                           ? i.product_id
//                                                           : produid,
//                                                   product: i),
//                                               builder: (context, snapshot) {
//                                                 if (snapshot.hasData) {
//                                                   return Text(
//                                                       "x${snapshot.data["canceled_qty"]}");
//                                                 }
//                                                 return Text("x" +
//                                                         i.qty_canceled
//                                                             .toString() ??
//                                                     "x");
//                                               },
//                                             )
//                                           : Container()
//                                     ],
//                                   ),
//                                 ),
//                                 text != 'canceled' ||
//                                         text != 'delivered' ||
//                                         text.toLowerCase() != "start picking" ||
//                                         text.toLowerCase() != "end picking"
//                                     ? Padding(
//                                         child: i.qty_canceled < i.quantity
//                                             ? RaisedButton(
//                                                 onPressed: () async {
//                                                   await configproduct(order.id,
//                                                       i.sku, i.delivery_from);
//                                                   print(produid);
//                                                   await showDialog(
//                                                       context: context,
//                                                       builder:
//                                                           (context) =>
//                                                               AlertDialog(
//                                                                 title: Text(Provider.of<AppModel>(context,
//                                                                                 listen: false)
//                                                                             .langCode ==
//                                                                         'en'
//                                                                     ? "Are You Sure"
//                                                                     : 'هل أنت واثق'),
//                                                                 content: Row(
//                                                                   children: <
//                                                                       Widget>[
//                                                                     // Column(children: [
//                                                                     //   Text("Do you want to cancel the order"),
//                                                                     // ],),
//                                                                     Expanded(
//                                                                       child:
//                                                                           Form(
//                                                                         key:
//                                                                             _formKey,
//                                                                         child:
//                                                                             TextFormField(
//                                                                           autofocus:
//                                                                               true,
//                                                                           keyboardType:
//                                                                               TextInputType.number,
//                                                                           controller:
//                                                                               cancelQuantity,
//                                                                           decoration:
//                                                                               InputDecoration(
//                                                                             // labelText:
//                                                                             //     "Do you want to cancel the order",

//                                                                             hintText:
//                                                                                 "Enter the quantity",
//                                                                           ),
//                                                                           validator:
//                                                                               (value) {
//                                                                             if (int.parse(value) >
//                                                                                 i.quantity) {
//                                                                               return "Enter a valid quantity";
//                                                                             } else {
//                                                                               return null;
//                                                                             }
//                                                                           },
//                                                                         ),
//                                                                       ),
//                                                                     )
//                                                                   ],
//                                                                 ),
//                                                                 // content: Text(
//                                                                 //     "Do you want to cancel the order"),

//                                                                 actions: <
//                                                                     Widget>[
//                                                                   FlatButton(
//                                                                     onPressed:
//                                                                         () {
//                                                                       print(i
//                                                                           .order_status_id);
//                                                                       cancelQuantity
//                                                                           .clear();
//                                                                       Navigator.of(
//                                                                               context)
//                                                                           .pop(
//                                                                               false);
//                                                                     },
//                                                                     child: Text(S
//                                                                         .of(context)
//                                                                         .no),
//                                                                   ),
//                                                                   FlatButton(
//                                                                     onPressed:
//                                                                         () async {
//                                                                       if (_formKey
//                                                                           .currentState
//                                                                           .validate()) {
//                                                                         showDialog(
//                                                                           context:
//                                                                               context,
//                                                                           barrierDismissible:
//                                                                               true,
//                                                                           builder:
//                                                                               kLoadingWidget,
//                                                                         );

//                                                                         String
//                                                                             url =
//                                                                             "https://up.ctown.jo/api/particularitemcancelmobile.php";
//                                                                         Map body =
//                                                                             {
//                                                                           "order_id":
//                                                                               order.id,
//                                                                           "product_id": i.product_type == 'simple'
//                                                                               ? i.product_id
//                                                                               : produid,
//                                                                           "canceledQty":
//                                                                               cancelQuantity.text
//                                                                         };

//                                                                         // print(i.productId);
//                                                                         print(i.product_type ==
//                                                                                 'simple'
//                                                                             ? i.product_id
//                                                                             : produid);
//                                                                         print(order
//                                                                             .id);
//                                                                         print(cancelQuantity
//                                                                             .text);

//                                                                         final res = await http.post(
//                                                                             url,
//                                                                             body:
//                                                                                 json.encode(body));
//                                                                         print(
//                                                                             "PARTICULAR ITEM RESPONSE");
//                                                                         print(res
//                                                                             .body);
//                                                                         print(res
//                                                                             .statusCode);
//                                                                         if (res.statusCode ==
//                                                                             200) {
//                                                                           var responseBody =
//                                                                               json.decode(res.body);
//                                                                           if (responseBody["success"] ==
//                                                                               1) {
//                                                                             setState(() {
//                                                                               i.qty_canceled += int.parse(cancelQuantity.text);
//                                                                             });
//                                                                             cancelQuantity.clear();
//                                                                             // setState(() {
//                                                                             //   // widget.lineItem.clear();
//                                                                             // });
//                                                                           }

//                                                                           SnackBar
//                                                                               snackbar =
//                                                                               SnackBar(content: Text(responseBody['message']));
//                                                                           _orderKey
//                                                                               .currentState
//                                                                               .showSnackBar(snackbar);
//                                                                           //Navigator.pop(context1);
//                                                                         } else {
//                                                                           SnackBar
//                                                                               snackbar =
//                                                                               SnackBar(content: Text("Something went wrong.Try again"));
//                                                                           _orderKey
//                                                                               .currentState
//                                                                               .showSnackBar(snackbar);
//                                                                         }

//                                                                         // Navigator.of(context1).push(MaterialPageRoute(builder:(context1)=>

//                                                                         // Navigator
//                                                                         //     .push(
//                                                                         //   context,
//                                                                         //   MaterialPageRoute(
//                                                                         //       builder:
//                                                                         //           (context) =>
//                                                                         //               OrderDetail(
//                                                                         //                 lineItem:
//                                                                         //                     widget.lineItem,
//                                                                         //                 fromWhere:
//                                                                         //                     widget.fromWhere,
//                                                                         //                 order:
//                                                                         //                     widget.order,
//                                                                         //                 productType:
//                                                                         //                     widget.productType,
//                                                                         //                 onRefresh:
//                                                                         //                     widget.onRefresh,
//                                                                         //               )),
//                                                                         // );
//                                                                         Navigator.of(context,
//                                                                                 rootNavigator: true)
//                                                                             .pop();
//                                                                         Navigator.of(context)
//                                                                             .pop(true);
//                                                                       }
//                                                                     },
//                                                                     child: Text(S
//                                                                         .of(context)
//                                                                         .yes),
//                                                                   ),
//                                                                 ],
//                                                               ));
//                                                 },
//                                                 color: Theme.of(context)
//                                                     .primaryColor,
//                                                 shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         new BorderRadius
//                                                             .circular(20.0)),
//                                                 child: Text(
//                                                   Provider.of<AppModel>(context,
//                                                                   listen: false)
//                                                               .langCode ==
//                                                           "ar"
//                                                       ? "إلغاء المنتج"
//                                                       : 'Cancel Product',
//                                                   style: TextStyle(
//                                                       color: Colors.white),
//                                                 ),
//                                               )
//                                             : Text("Already Cancelled"),
//                                         padding: EdgeInsets.only(bottom: 10))
//                                     : Container()
//                               ],
//                             );
//                           })
//                       // : Container()
//                     ],
//                   ),
//                 ),

//             // Container(
//             //      height:20,

//             //      width:20,color:Colors.yellow),
//             // FlatBtton(color: Theme.of(context).primaryColor,),,;

//             const SizedBox(height: 10),
//             (order.customerNote != null && kPaymentConfig['EnableCustomerNote'])
//                 ? Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: <Widget>[
//                       Text(
//                         S.of(context).yourNote,
//                         style: TextStyle(color: Theme.of(context).accentColor),
//                       ),
//                       Text(
//                         order.customerNote,
//                         style: TextStyle(
//                           color: Theme.of(context).accentColor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       )
//                     ],
//                   )
//                 : Container(),

//             Container(
//               decoration:
//                   BoxDecoration(color: Theme.of(context).primaryColorLight),
//               padding: const EdgeInsets.all(15),
//               margin: const EdgeInsets.symmetric(vertical: 10),
//               child: Column(
//                 children: <Widget>[
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: <Widget>[
//                       Text(
//                         S.of(context).subtotal,
//                         style: TextStyle(color: Theme.of(context).accentColor),
//                       ),
//                       Text(
//                         Tools.getCurrencyFormatted(
//                             // subtotal(widget.lineItem).toString(),
//                             order.subtotal,
//                             // widget.lineItem.price,
//                             currencyRate),
//                         style: TextStyle(
//                             color: Theme.of(context).accentColor,
//                             fontWeight: FontWeight.w600),
//                       )
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   (order.shippingMethodTitle != null &&
//                           kPaymentConfig['EnableShipping'])
//                       ? Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: <Widget>[
//                             Text(
//                               S.of(context).shippingMethod,
//                               style: TextStyle(
//                                   color: Theme.of(context).accentColor),
//                             ),
//                             Text(
//                               order.shippingMethodTitle,
//                               style: TextStyle(
//                                 color: Theme.of(context).accentColor,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             )
//                           ],
//                         )
//                       : Container(),
//                   // const SizedBox(height: 10),
//                   // Row(
//                   //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   //   children: <Widget>[
//                   //     Text(
//                   //       S.of(context).totalTax,
//                   //       style: TextStyle(color: Theme.of(context).accentColor),
//                   //     ),
//                   //     Text(
//                   //       Tools.getCurrencyFormatted(
//                   //           order.totalTax, currencyRate),
//                   //       style: TextStyle(
//                   //         color: Theme.of(context).accentColor,
//                   //         fontWeight: FontWeight.w600,
//                   //       ),
//                   //     )
//                   //   ],
//                   // ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: <Widget>[
//                       Text(
//                         S.of(context).total1,
//                         style: TextStyle(color: Theme.of(context).accentColor),
//                       ),
//                       Text(
//                         Tools.getCurrencyFormatted(
//                             // widget.lineItem.price
//                             // total(widget.lineItem).toString(),
//                             order.total,
//                             currencyRate),
//                         style: TextStyle(
//                           color: Theme.of(context).accentColor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             tracking != null ? const SizedBox(height: 20) : Container(),
//             tracking != null
//                 ? GestureDetector(
//                     child: Align(
//                       alignment: Alignment.topLeft,
//                       child: Row(
//                         children: <Widget>[
//                           Text("${S.of(context).trackingNumberIs} "),
//                           Text(
//                             tracking,
//                             style: TextStyle(
//                                 color: Theme.of(context).primaryColor),
//                           )
//                         ],
//                       ),
//                     ),
//                     onTap: () {
//                       return Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => WebviewScaffold(
//                             url: "${afterShip['tracking_url']}/$tracking",
//                             appBar: AppBar(
//                               leading: GestureDetector(
//                                 child: const Icon(Icons.arrow_back_ios),
//                                 onTap: () {
//                                   Navigator.of(context).pop();
//                                 },
//                               ),
//                               title: Text(S.of(context).trackingPage),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   )
//                 : Container(),
//             Services().widget.renderOrderTimelineTracking(context, order),
//             const SizedBox(height: 20),

//             /// Render the Cancel and Refund
//             if (kPaymentConfig['EnableRefundCancel'])
//               Services().widget.renderButtons(order, cancelOrder, createRefund),

//             const SizedBox(height: 20),

// //
// //
//             FutureBuilder(
//                 future: getInvoice(orderId: widget.order.id),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasData) {
//                     return Column(
//                       children: [
//                         Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: <Widget>[
//                               Text(
//                                   Provider.of<AppModel>(context, listen: false)
//                                               .langCode ==
//                                           "ar"
//                                       ? "فاتورة"
//                                       : "Invoice",
//                                   style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold)),
//                             ]),
//                         const SizedBox(height: 10),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 10, horizontal: 10),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: <Widget>[
//                               if (snapshot.data["success"] == 1)
//                                 Container(
//                                   width: 145,
//                                   // color: Colors.red,
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       //
//                                       Column(children: [
//                                         InkWell(
//                                           onTap: () async {
//                                             await showModalBottomSheet(
//                                               isScrollControlled: true,
//                                               shape:
//                                                   const RoundedRectangleBorder(
//                                                       borderRadius:
//                                                           BorderRadius.vertical(
//                                                               top: Radius
//                                                                   .circular(
//                                                                       12))),
//                                               context: context,
//                                               builder: (context) {
//                                                 return FutureBuilder(
//                                                     future: viewFile(
//                                                         url: snapshot
//                                                             .data["data"],
//                                                         fileName:
//                                                             "Invoice_${widget.order.id}",
//                                                         dir:
//                                                             "/storage/emulated/0/Download"),
//                                                     builder:
//                                                         (context, snapshot) {
//                                                       // if (snapshot
//                                                       //     .hasError) {
//                                                       //   return Container(
//                                                       //       height: MediaQuery.of(context).size.height * 0.9,
//                                                       //       child: Center(child: Text('Could not generate invoice at this time')));
//                                                       // }
//                                                       if (snapshot.data ==
//                                                           null) {
//                                                         return Center(
//                                                             child:
//                                                                 CircularProgressIndicator());
//                                                       }
//                                                       return Container(
//                                                         height: MediaQuery.of(
//                                                                     context)
//                                                                 .size
//                                                                 .height *
//                                                             0.9,
//                                                         decoration: BoxDecoration(
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         40)),
//                                                         child: PdfPreview(
//                                                           build: (format) =>
//                                                               snapshot.data
//                                                                   .readAsBytes(),
//                                                         ),
//                                                       );
//                                                     });
//                                               },
//                                             );
//                                           },
//                                           child: Icon(Icons.print_rounded),
//                                         ),
//                                         Text(Provider.of<AppModel>(context,
//                                                         listen: false)
//                                                     .langCode ==
//                                                 "ar"
//                                             ? "رأي"
//                                             : "View")
//                                       ]),
//                                       Column(children: [
//                                         InkWell(
//                                           onTap: () async {
// //

//                                             showDialog(
//                                               context: context,
//                                               barrierDismissible: false,
//                                               builder: kLoadingWidget,
//                                             );

//                                             String result = await downloadFile(
//                                                 url: snapshot.data["data"],
//                                                 fileName:
//                                                     "Invoice_${widget.order.id}",
//                                                 dir:
//                                                     "/storage/emulated/0/Download");
//                                             Navigator.of(context,
//                                                     rootNavigator: true)
//                                                 .pop();
//                                             if (result.contains(
//                                                 "/storage/emulated/0/")) {
//                                               SnackBar snackbar = SnackBar(
//                                                 content: Text(
//                                                     "Invoice is saved successfully in this location $result"),
//                                               );
//                                               _orderKey.currentState
//                                                   .showSnackBar(snackbar);
//                                             } else {
//                                               SnackBar snackbar = SnackBar(
//                                                 content: Text(
//                                                     "Something went wrong..please try again"),
//                                               );
//                                               _orderKey.currentState
//                                                   .showSnackBar(snackbar);
//                                             }

// //
//                                           },
//                                           child: Icon(Icons.download_outlined),
//                                         ),
//                                         Text(Provider.of<AppModel>(context,
//                                                         listen: false)
//                                                     .langCode ==
//                                                 "ar"
//                                             ? "تحميل"
//                                             : "Download")
//                                       ])
//                                     ],
//                                   ),
//                                 ),
//                               if (snapshot.data["success"] == 0) Container()
//                             ],
//                           ),
//                         )
//                       ],
//                     );
//                   }
//                   return Container();
//                 }),

// //

//             FutureBuilder<List<SuggestedProduct>>(
//                 future: getReplacement(),
//                 builder: (context, snapshot) {
//                   if (snapshot.data != null) {
//                     // return Text(snapshot.data.toString());

//                     return Column(children: [
//                       if (Provider.of<SuggestedProductProvider>(context)
//                           .selectedReplacementProductsData
//                           .isNotEmpty)
//                         Text(Provider.of<AppModel>(context, listen: false)
//                                     .langCode ==
//                                 "ar"
//                             ? "يرجى ملاحظة أن المنتج (المنتجات) التالية غير متوفر بالمخزون وأن بعض المنتجات البديلة المشابهة لهذا المنتج مدرجة .. يمكنك اختيار بديل أو إزالة العنصر غير الموجود في المخزون من هذا الطلب"
//                             : "Please note that the following product(s) are out of stock and some of the replacement products which are similar to this product are listed..You can choose a replacement or remove the out of stock item from this order" +
//                                 " "),
//                       Column(
//                           children: List.generate(
//                               // snapshot.data.length,
//                               Provider.of<SuggestedProductProvider>(context)
//                                   .selectedReplacementProductsData
//                                   .length,
//                               (index) => Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       OutOfStockProductItem(
//                                           widgetKey: _orderKey,
//                                           orderId: widget.order.id,
//                                           parentIndex: index,
//                                           outOfStockproductId:
//                                               Provider.of<SuggestedProductProvider>(context)
//                                                   .selectedReplacementProductsData[index]
//                                                       ["outofstock_product"]
//                                                   .productId,
//                                           outOfStockproductPrice:
//                                               Provider.of<SuggestedProductProvider>(context)
//                                                   .selectedReplacementProductsData[index]
//                                                       ["outofstock_product"]
//                                                   .productPrice,
//                                           outOfStockBarcode:
//                                               Provider.of<SuggestedProductProvider>(context)
//                                                   .selectedReplacementProductsData[index]
//                                                       ["outofstock_product"]
//                                                   .barcode,
//                                           productType:
//                                               Provider.of<SuggestedProductProvider>(context)
//                                                   .selectedReplacementProductsData[index]
//                                                       ["outofstock_product"]
//                                                   .productType,
//                                           ondelete: deleteReplacement,
//                                           outOfStockQty:
//                                               Provider.of<SuggestedProductProvider>(context)
//                                                       .selectedReplacementProductsData[index]
//                                                   ["outofstock_qty"],
//                                           index: index,
//                                           data: Provider.of<SuggestedProductProvider>(context)
//                                                   .selectedReplacementProductsData[index]
//                                               ["outofstock_product"]
//                                           // snapshot.data[index]
//                                           //     .outofstockProductDetails[0],
//                                           ),
//                                       Text("Replacements : "),
//                                       Column(
//                                         children: List.generate(
//                                           // snapshot
//                                           //     .data[index]
//                                           //     .replacementProductDetails
//                                           //     .length,
//                                           Provider.of<SuggestedProductProvider>(
//                                                   context)
//                                               .selectedReplacementProductsData[
//                                                   index]["replacement_products"]
//                                               .length,
//                                           (i) =>
//                                               //  Text("$i")
//                                               SuggestedReplacementProductItem(
//                                                   parentIndex: index,
//                                                   orderId: widget.order.id,
//                                                   outOfStockproductId: Provider.of<SuggestedProductProvider>(context)
//                                                       .selectedReplacementProductsData[index]
//                                                           ["outofstock_product"]
//                                                       .productId,
//                                                   outOfStockPrice: Provider.of<SuggestedProductProvider>(context)
//                                                       .selectedReplacementProductsData[index]
//                                                           ["outofstock_product"]
//                                                       .productPrice,
//                                                   startPicking: Provider.of<SuggestedProductProvider>(context)
//                                                               .selectedReplacementProductsData
//                                                               .length <=
//                                                           1
//                                                       ? "startpicking"
//                                                       : "",
//                                                   outOfStockBarcode: Provider.of<SuggestedProductProvider>(context)
//                                                       .selectedReplacementProductsData[index]
//                                                           ["outofstock_product"]
//                                                       .barcode,
//                                                   productType: Provider.of<SuggestedProductProvider>(context)
//                                                       .selectedReplacementProductsData[index]
//                                                           ["outofstock_product"]
//                                                       .productType,
//                                                   onPressed: applyReplacement,
//                                                   index: i,
//                                                   outOfStockQty: Provider.of<SuggestedProductProvider>(context)
//                                                           .selectedReplacementProductsData[index]
//                                                       ["outofstock_qty"],
//                                                   // "2",
//                                                   // snapshot
//                                                   //     .data[index].outofstockQty,
//                                                   data: Provider.of<SuggestedProductProvider>(context)
//                                                           .selectedReplacementProductsData[index]
//                                                       ["replacement_products"][i]["item"]),
//                                           /* SuggestedReplacementProductItem(
//                                             parentIndex: index,
//                                             orderId: widget.order.id,
//                                             outOfStockproductId: snapshot
//                                                 .data[index]
//                                                 .outofstockProductDetails[0]
//                                                 .productId,
//                                             outOfStockBarcode: snapshot
//                                                 .data[index]
//                                                 .outofstockProductDetails[0]
//                                                 .barcode,
//                                             productType: snapshot
//                                                 .data[index]
//                                                 .outofstockProductDetails[0]
//                                                 .productType,
//                                             onPressed: applyReplacement,
//                                             index: i,
//                                             outOfStockQty: snapshot
//                                                 .data[index].outofstockQty,
//                                             data: snapshot.data[index]
//                                                 .replacementProductDetails[i],
//                                           ),*/
//                                         ),
//                                       )
//                                     ],
//                                   )))
//                     ]);
// //    return ListView.builder(
// //      physics: NeverScrollableScrollPhysics(),
// //      itemCount: snapshot.data.length,
// //      itemBuilder: (context,index){
// //      return Column(children: [
// // Text(snapshot.data[index].outofstockProductDetails[index].productName)
// //      ],);
// //    });
//                   }
//                   return Container();
//                   //  Center(child: CircularProgressIndicator());
//                 }),
// //
//             SizedBox(
//               height: 10,
//             ),
//             order.status == "pending"
//                 ? FutureBuilder(
//                     future: noteFunction(order.id),
//                     builder: (context, snapshot) {
//                       if (snapshot.hasData) {
//                         return Padding(
//                             padding: EdgeInsets.only(left: 1, right: 10),
//                             child: Text(snapshot.data));
//                       }
//                       // return Center(child: CircularProgressIndicator());
//                       return Container();
//                     })
//                 : Container(),

//             widget.order.status == "pending"
//                 ? Padding(
//                     padding: const EdgeInsets.only(bottom: 10, top: 10),
//                     child: Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: <Widget>[
//                           RaisedButton(
//                               onPressed: () async {
//                                 String apiUrl =
//                                     "https://up.ctown.jo/api/timeduration.php";
//                                 Map body = {"order_id": widget.order.id};

//                                 var response = await http.post(apiUrl,
//                                     body: json.encode(body));

//                                 var responseBody = json.decode(response.body);

//                                 if (response.statusCode == 200) {
//                                   SharedPreferences prefs =
//                                       await SharedPreferences.getInstance();

//                                   await prefs.setString(
//                                       "note_${widget.order.id}",
//                                       "Note : You have to finish the payment of the order within ${responseBody['data'][0]["minutes"]} minutes orelse the order will be cancelled");

//                                   widget.order.notes =
//                                       "Note : You have to finish the payment of the order within ${responseBody['data'][0]["minutes"]} minutes orelse the order will be cancelled";
//                                   setState(() {});
//                                   await showModalBottomSheet(
//                                     context: context,
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.vertical(
//                                       top: Radius.circular(40),
//                                       //bottom: Radius.circular(80),
//                                     )),
//                                     builder: (context) => Container(
//                                         height: 150,
//                                         child: Column(
//                                           children: [
//                                             SizedBox(
//                                               height: 12,
//                                             ),
//                                             ListTile(
//                                               leading:
//                                                   Icon(Icons.wysiwyg_rounded),
//                                               title: Text("Cash on Delivery"),
//                                               onTap: () async {
//                                                 print("cash on delivery");
//                                                 String response =
//                                                     await MagentoApi()
//                                                         .updatePaymentMethod(
//                                                             widget.order.id);
//                                                 print(response);
//                                                 print("widget fromwhere");
//                                                 print(widget.fromWhere);
//                                                 if (widget.fromWhere ==
//                                                     "success") {
//                                                   Navigator.pop(context);
//                                                   widget.onRefresh();
//                                                 } else {
//                                                   SnackBar snackbar = SnackBar(
//                                                     content: Text(response),
//                                                   );
//                                                   _orderKey.currentState
//                                                       .showSnackBar(snackbar);

//                                                   Navigator.pop(context);

//                                                   print("refresh starts");
//                                                   widget.onRefresh();
//                                                   print("refresh ends");
//                                                 }
//                                                 // Navigator.pop(context);
//                                                 // Navigator.pushNamed(context, "/orders");
//                                                 // Navigator.pushReplacement(
//                                                 //     context,
//                                                 //     MaterialPageRoute(
//                                                 //         builder:
//                                                 //             (BuildContext context) =>
//                                                 //                 super.widget));
//                                                 print("function ends");
//                                               },
//                                             ),
//                                             ListTile(
//                                               leading:
//                                                   Icon(Icons.wysiwyg_rounded),
//                                               title: Text("Credit card"),
//                                               onTap: () async {
//                                                 print(widget.order.id);
//                                                 await cardPay(
//                                                     context, widget.order);
//                                               },
//                                             ),
//                                           ],
//                                         )),
//                                   );
//                                 } else {
//                                   SnackBar snackBar = SnackBar(
//                                       content: Text('Error during updating'));
//                                   _orderKey.currentState.showSnackBar(snackBar);
//                                 }
//                               },
//                               color: Theme.of(context).primaryColor,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius:
//                                       new BorderRadius.circular(20.0)),
//                               child: Text(
//                                 'Re-initiate Payment',
//                                 style: TextStyle(color: Colors.white),
//                               ))
//                         ]))
//                 : Container(),

//             //
//             text != 'canceled'
//                 ? text != 'delivered'
//                     ? text != "start picking"
//                         ? text != "end picking"

//                             // widget.lineItem[2].sub_status == 'Order Placed' &&
//                             //          widget.order.status == 'processing'||widget.lineItem[0].sub_status=='Order Placed'

//                             ? Padding(
//                                 child: RaisedButton(
//                                     onPressed: () async {
//                                       showDialog(
//                                           context: context,
//                                           builder: (context) => AlertDialog(
//                                                 title: Text(
//                                                     Provider.of<AppModel>(
//                                                                     context,
//                                                                     listen:
//                                                                         false)
//                                                                 .langCode ==
//                                                             'en'
//                                                         ? "Are You Sure"
//                                                         : 'هل أنت واثق'),
//                                                 content: Text(Provider.of<
//                                                                     AppModel>(
//                                                                 context,
//                                                                 listen: false)
//                                                             .langCode ==
//                                                         'en'
//                                                     ? "Do you want to cancel the order"
//                                                     : "هل تريد إلغاء الطلب"),
//                                                 actions: <Widget>[
//                                                   FlatButton(
//                                                     onPressed: () =>
//                                                         Navigator.of(context)
//                                                             .pop(false),
//                                                     child:
//                                                         Text(S.of(context).no),
//                                                   ),
//                                                   FlatButton(
//                                                     onPressed: () async {
//                                                       showDialog(
//                                                         context: context,
//                                                         barrierDismissible:
//                                                             true,
//                                                         builder: kLoadingWidget,
//                                                       );

//                                                       String url =
//                                                           "https://up.ctown.jo/api/ordercancelmobile.php";
//                                                       Map body = {
//                                                         "order_id": order.id
//                                                       };

//                                                       print(order.id);

//                                                       final res =
//                                                           await http.post(url,
//                                                               body: json.encode(
//                                                                   body));
//                                                       print(res.body);
//                                                       if (res.statusCode ==
//                                                           200) {
//                                                         var responseBody = json
//                                                             .decode(res.body);
//                                                         SnackBar snackbar = SnackBar(
//                                                             content: Text(
//                                                                 responseBody[
//                                                                     'message']));
//                                                         _orderKey.currentState
//                                                             .showSnackBar(
//                                                                 snackbar);
//                                                         // Navigator.pop(context);
//                                                       } else {
//                                                         SnackBar snackbar =
//                                                             SnackBar(
//                                                                 content: Text(
//                                                                     "Something went wrong.Try again"));
//                                                         _orderKey.currentState
//                                                             .showSnackBar(
//                                                                 snackbar);
//                                                       }
//                                                       setState(() {
//                                                         text = "canceled";
//                                                         // order.status = "canceled";
//                                                         // widget.lineItem[0].order_status_id =
//                                                         //     '7';
//                                                       });
//                                                       Navigator.of(context,
//                                                               rootNavigator:
//                                                                   true)
//                                                           .pop();
//                                                       Navigator.of(context)
//                                                           .pop(true);
//                                                     },
//                                                     child:
//                                                         Text(S.of(context).yes),
//                                                   ),
//                                                 ],
//                                               ));

//                                       /*
//                               showDialog(
//                                 context: context,
//                                 barrierDismissible: true,
//                                 builder: kLoadingWidget,
//                               );

//                               String url =
//                                   "https://online.ajmanmarkets.ae/api/ordercancelmobile.php";
//                               Map body = {"order_id": order.id};
//                               print(order.id);
//                               final res =
//                                   await http.post(url, body: json.encode(body));
//                               print(res.body);
//                               if (res.statusCode == 200) {
//                                 var responseBody = json.decode(res.body);
//                                 SnackBar snackbar = SnackBar(
//                                     content: Text(responseBody['message']));
//                                 _orderKey.currentState.showSnackBar(snackbar);
//                                 // Navigator.pop(context);
//                               } else {
//                                 SnackBar snackbar = SnackBar(
//                                     content:
//                                         Text("Something went wrong.Try again"));
//                                 _orderKey.currentState.showSnackBar(snackbar);
//                               }
//                               setState(() {
//                                 order.status = "canceled";
//                               });
//                               Navigator.of(context, rootNavigator: true).pop();*/
//                                     },
//                                     color: Theme.of(context).primaryColor,
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius:
//                                             new BorderRadius.circular(20.0)),
//                                     child: Text(
//                                       Provider.of<AppModel>(context,
//                                                       listen: false)
//                                                   .langCode ==
//                                               "ar"
//                                           ? "الغاء الطلب"
//                                           : 'Cancel Order',
//                                       style: TextStyle(color: Colors.white),
//                                     )),
//                                 padding: EdgeInsets.only(bottom: 10))
//                             : Container()
//                         : Container()
//                     : Container()
//                 : Container(),

// //
//             if (order.billing != null) ...[
//               Text(S.of(context).shippingAddress,
//                   style: const TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),
//               Text(
//                 ((order.billing.apartment?.isEmpty ?? true)
//                         ? ''
//                         : '${order.billing.apartment} ') +
//                     ((order.billing.block?.isEmpty ?? true)
//                         ? ''
//                         : '${(order.billing.apartment?.isEmpty ?? true) ? '' : '- '} ${order.billing.block}, ') +
//                     order.billing.street +
//                     ", " +
//                     order.billing.city +
//                     ", " +
//                     getCountryName(order.billing.country),
//                 style:
//                     const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
//               ),
//             ],
// //

//             //
//             if (order.status == "processing" &&
//                 kPaymentConfig['EnableRefundCancel'])
//               Column(
//                 children: <Widget>[
//                   const SizedBox(height: 30),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ButtonTheme(
//                           height: 45,
//                           child: RaisedButton(
//                               textColor: Colors.white,
//                               color: HexColor("#056C99"),
//                               onPressed: refundOrder,
//                               child: Text(
//                                   S.of(context).refundRequest.toUpperCase(),
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.w700))),
//                         ),
//                       )
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             const SizedBox(
//               height: 20,
//             ),
//             FutureBuilder<List<OrderNote>>(
//               future: services.getOrderNote(
//                   userModel: userModel, orderId: order.id),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) return Container();
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Text(
//                       S.of(context).orderNotes,
//                       style: const TextStyle(
//                           fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 10),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: List.generate(
//                         snapshot.data.length,
//                         (index) {
//                           return Padding(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: <Widget>[
//                                 CustomPaint(
//                                   painter: BoxComment(
//                                       color: Theme.of(context).primaryColor),
//                                   child: Container(
//                                     width: MediaQuery.of(context).size.width,
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(
//                                           left: 10,
//                                           right: 10,
//                                           top: 15,
//                                           bottom: 25),
//                                       child: HtmlWidget(
//                                         snapshot.data[index].note,
//                                         textStyle: const TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 13,
//                                             height: 1.2),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Text(
//                                   formatTime(DateTime.parse(
//                                       snapshot.data[index].dateCreated)),
//                                   style: const TextStyle(fontSize: 13),
//                                 )
//                               ],
//                             ),
//                             padding: const EdgeInsets.only(bottom: 15),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),

//             const SizedBox(height: 50)
//           ],
//         ),
//       ),
//     );
//   }

//   //

//   cardPay(context, order) async {
//     String apiUrl = "https://up.ctown.jo/api/repay.php";
//     Map body;
//     var response = await http.post(apiUrl,
//         // headers: {
//         //   'Authorization': 'Bearer ' + accessToken,
//         //   "content-type": "application/json"
//         // },
//         body: jsonEncode({'order_id': order.id}));
//     if (response.statusCode == 200) {
//       body = jsonDecode(response.body);
//       print(body);
//     }

//     Map urlMap = {
//       "paymentUrl": body['data']['_links']['payment']['href'],
//       "redirectUrl": body['data']['merchantAttributes']['redirectUrl'],
//       "cancelUrl": body['data']['merchantAttributes']['cancelUrl']
//     };

//     try {
//       var cardDetails =
//           Provider.of<PaymentMethodModel>(context, listen: false).cardDetails;
//       print("card details $cardDetails");

//       await Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => WillPopScope(
//             onWillPop: () async {
//               // widget.onLoading(false);
//               // isPaying = false;
//               return true;
//             },
//             child: web.WebView(
//               initialUrl: urlMap['paymentUrl'],
//               javascriptMode: web.JavascriptMode.unrestricted,
//               navigationDelegate: (web.NavigationRequest request) async {
//                 if (request.url.contains(urlMap['redirectUrl'])) {
//                   final uri = Uri.parse(request.url);
//                   final payerID = uri.queryParameters['ref'];
//                   if (payerID != null) {
//                     var status = await MagentoApi().getPaymentStatus(payerID);
//                     // if (status == 'CAPTURED') {
//                     //
//                     //
//                     if (status == 'AUTHORISED') {
//                       if (order != null) {
//                         await MagentoApi().submitPaymentSuccess(order.id);
//                         // widget.onFinish(newOrder);
//                         // widget.onLoading(false);
//                         // isPaying = false;
//                         // newOrder = null;
//                       }
//                       // await createOrder(paid: true).then((value) {
//                       //   widget.onLoading(false);
//                       //   isPaying = false;
//                       // });
//                     } else {
//                       /// handle payment failure
//                       // widget.onLoading(false);
//                       // isPaying = false;
//                       await showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return AlertDialog(
//                             title: Text(S.of(context).orderStatusFailed),
//                             // content: Text("${err?.message ?? err}"),
//                             content:
//                                 const Text("Your payment was not successful!!"),
//                             actions: <Widget>[
//                               FlatButton(
//                                 child: Text(
//                                   S.of(context).ok,
//                                   style: TextStyle(
//                                       color: Theme.of(context).primaryColor),
//                                 ),
//                                 onPressed: () {
//                                   Navigator.of(context).pop();
//                                 },
//                               )
//                             ],
//                           );
//                         },
//                       );
//                     }
//                   } else {
//                     // widget.onLoading(false);
//                     // isPaying = false;
//                     Navigator.of(context).pop();
//                   }
//                   // Navigator.of(context).pop();
//                 }
//                 if (request.url.contains(urlMap['cancelUrl'])) {
//                   // widget.onLoading(false);
//                   // isPaying = false;
//                   Navigator.of(context).pop();
//                 }
//                 return web.NavigationDecision.navigate;
//               },
//             ),
//           ),
//         ),
//       );
//     } catch (e) {
//       // widget.onLoading(false);
//       // isPaying = false;
//       print("exception $e");
//       print("starting delete cart");

//       return Tools.showSnackBar(
//           Scaffold.of(context), 'Unable to process the request');
//     }

//     // finally {
//     //   // await Services().deleteItemFromCart(
//     //   //     cartModel.productsInCart.keys.toList(),
//     //   //     cookie != null ? cookie : null);
//     //   cartModel.clearCart();
//     //   print("successfully emptied cart item");
//     //   Navigator.pop(context);
//     // }

//     //delete cart items
//     //

//     // Navigator.of(context, rootNavigator: true).pop();
//   }
//   //

//   String getCountryName(country) {
//     try {
//       return CountryPickerUtils.getCountryByIsoCode(country).name;
//     } catch (err) {
//       return country;
//     }
//   }

//   Future<void> refundOrder() async {
//     _showLoading();
//     try {
//       await services.updateOrder(order.id, status: "refunded");
//       _hideLoading();
//       widget.onRefresh();
//       Navigator.of(context).pop();
//     } catch (err) {
//       _hideLoading();

//       Tools.showSnackBar(Scaffold.of(context), err.toString());
//     }
//   }

//   void _showLoading() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Center(
//           child: Container(
//             decoration: BoxDecoration(
//                 color: Colors.white30,
//                 borderRadius: BorderRadius.circular(5.0)),
//             padding: const EdgeInsets.all(50.0),
//             child: kLoadingWidget(context),
//           ),
//         );
//       },
//     );
//   }

//   void _hideLoading() {
//     Navigator.of(context).pop();
//   }

//   String formatTime(DateTime time) {
//     return "${time.day}/${time.month}/${time.year}";
//   }
// }

// class BoxComment extends CustomPainter {
//   final Color color;

//   BoxComment({this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint();

//     paint.color = color;
//     var path = Path();
//     path.lineTo(size.width, 0);
//     path.lineTo(size.width, size.height - 10);
//     path.lineTo(30, size.height - 10);
//     path.lineTo(20, size.height);
//     path.lineTo(20, size.height - 10);
//     path.lineTo(0, size.height - 10);
//     path.close();
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }

// class DownloadButton extends StatefulWidget {
//   final String id;

//   DownloadButton(this.id);

//   @override
//   _DownloadButtonState createState() => _DownloadButtonState();
// }

// class _DownloadButtonState extends State<DownloadButton> {
//   bool isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     final services = Services();
//     return InkWell(
//       onTap: () async {
//         setState(() {
//           isLoading = true;
//         });

import 'dart:convert';
import 'dart:io';

import 'package:country_pickers/country_pickers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import "package:path_provider/path_provider.dart";
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart' as web;

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../frameworks/magento/services/magento.dart';
import '../../generated/l10n.dart';
//         Product product = await services.getProduct(widget.id);
//         setState(() {
//           isLoading = false;
//         });
//         await Share.share(product.files[0]);
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 8,
//           vertical: 4,
//         ),
//         decoration: BoxDecoration(
//           color: Theme.of(context).primaryColor.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(3),
//         ),
//         child: Row(
//           children: <Widget>[
//             isLoading
//                 ? Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Container(
//                       width: 15.0,
//                       height: 15.0,
//                       child: Center(
//                         child: kLoadingWidget(context),
//                       ),
//                     ),
//                   )
//                 : Icon(
//                     Icons.file_download,
//                     color: Theme.of(context).primaryColor,
//                   ),
//             Text(
//               S.of(context).download,
//               style: TextStyle(
//                 color: Theme.of(context).primaryColor,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import '../../models/entities/order.dart';
import '../../models/index.dart' show AppModel, Order, OrderModel, OrderNote, PaymentMethodModel, Product, UserModel;
import '../../services/index.dart';
import 'suggested_product_model.dart';
import 'suggested_product_provider.dart';
import 'suggested_products.dart';

class OrderDetail extends StatefulWidget {
  final Order? order;
  String? productType;
  final List<ProductItem>? lineItem;
  final String? fromWhere;
  final VoidCallback? onRefresh;

  OrderDetail({this.order, this.onRefresh, this.productType, this.lineItem, this.fromWhere});

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  final services = Services();
  String? tracking;
  var widgets;
  Order? order;
  Product? product;
  TextEditingController cancelQuantity = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String cancelQty = "";

  get decoration => null;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ordersubsteatus();

    order = widget.order;
  }

  noteFunction(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? note = await prefs.getString("note_$id");

    return note;
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop(false);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("AlertDialog"),
      content: Text("Would you like to continue learning how to use Flutter alerts?"),
      actions: [
        cancelButton,
        continueButton,
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

  applyReplacement(
      {String? ofsProductId,
      String? ofsProductPrice,
      String? ofsProductBarcode,
      String? orderId,
      String? productType,
      String? replacementId,
      String? replacementBarcode,
      String? startPicking,
      String? replacementPrice,
      int? qty}) async {
    String url = "https://up.ctown.jo/api/outofstock_customer_choose_product_replacement.php";
    Map body = {
      "order_id": orderId,
      "outofstock_product_id": ofsProductId,
      "outofstock_barcode": ofsProductBarcode,
      "outofstock_price": ofsProductPrice,
      "choose_replacement_price": replacementPrice,
      "startpicking": startPicking,
      "choose_replacement_product_id": replacementId,
      "choose_replacement_barcode": replacementBarcode,
      "product_type": productType,
      "outofstock_qty": qty
    };
    print(url);
    print(jsonEncode(body));

    var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    Map<dynamic, dynamic>? responseBody = {};
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      print(responseBody);
      return responseBody;
    }
    return responseBody;
  }

  deleteReplacement(
      {String? ofsProductId, String? ofsProductPrice, String? ofsProductBarcode, String? orderId, String? productType, int? ofsQty}) async {
    String url = "https://up.ctown.jo/api/outofstock_replacement_product_customer_delete.php";
    Map body = {
      "order_id": orderId,
      "outofstock_product_id": ofsProductId,
      "outofstock_price": ofsProductPrice,
      "outofstock_barcode": ofsProductBarcode,
      "product_type": productType,
      "outofstock_qty": ofsQty
    };
    print(url);
    print(jsonEncode(body));

    var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    Map<dynamic, dynamic>? responseBody = {};
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      print(responseBody);
      return responseBody;
    }
    return responseBody;
  }

  Future<List<SuggestedProduct>> getReplacement() async {
    List<SuggestedProduct> list = [];
    String url = "https://up.ctown.jo/api/outofstock_product_replacement_customer.php";
    Map body = {"order_id": widget.order!.id, "proType": widget.productType};
    print(widget.productType);
    print("dddi");
    print(url);
    print(jsonEncode(body));
    var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      // print(responseBody["data"].length);
      // print("bef");
      // print(responseBody["data"].runtimeType);
      /*responseBody["data"].forEach((e) {
        String a = e["outofstock_product_details"][0]["product_type"];
        String b = widget.productType;
        print("a $a");
        print("b $b");
        print("if ${a == b}");
        if ((a == b) == false) {
          print("threat ${e["outofstock_product_details"][0]["product_type"]}");
          try {
            print("rempoving");
            responseBody["data"].remove(e);
            print("removed");
          } catch (e) {
            print("catch $e");
          }
        }
      });*/
      // print("aft");
      // print(responseBody["data"].length);
      Provider.of<SuggestedProductProvider>(context, listen: false).selectedReplacementProductsData.clear();
      print("responseBody $responseBody");
      list = suggestedProductFromJson(jsonEncode(responseBody["data"]));
      list = list.where((i) => i.outofstockProductDetails![0].productType == widget.productType).toList();

      List providerData = [];

      list.forEach((e) {
        List replacementDetails = [];

        e.replacementProductDetails!.forEach((element) {
          replacementDetails.add({"isSelected": false, "item": element});
        });
        providerData.add(
            {"outofstock_product": e.outofstockProductDetails![0], "replacement_products": replacementDetails, "outofstock_qty": e.outofstockQty});
      });

      Provider.of<SuggestedProductProvider>(context, listen: false).setSelectedReplacementProducts(providerData);

      print("provider setted");
      print(Provider.of<SuggestedProductProvider>(context, listen: false).selectedReplacementProductsData);
      print(list);
    }
    return list;
  }

  Future getInvoice({orderId}) async {
    String apiUrl = "https://up.ctown.jo/api/mobileinvoice.php";
    Map body = {"order_id": orderId};
    print(jsonEncode(body));
    var response = await http.post(Uri.parse(apiUrl), body: jsonEncode(body));
    var responseBody;
    print(response.statusCode);
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      print(responseBody);
      return responseBody;
    } else {
      responseBody = {};
    }
    return responseBody;
  }

  // List produid=[];
  String? status;
  var produid;
  Future configproduct(orderid, sku, delivery_from) async {
    String apiUrl = "https://up.ctown.jo/api/particularitem_status_check.php";

    Map body = {"order_id": orderid, "sku": sku, "delivery_from": delivery_from};

    print(jsonEncode(body));
    var response = await http.post(Uri.parse(apiUrl), body: jsonEncode(body));
    var responseBody;
    print(response.statusCode);

    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      produid = responseBody["data"][0]["product_id"];
      status = responseBody["data"][0]["sub_status"];
      print(responseBody);

      return responseBody;
    } else {
      responseBody = {};
    }
    return responseBody;
  }

  Future configproductname(sku, orderid) async {
    print(json.encode({"sku": sku, "order_id": orderid}));
    Uri uri = Uri.parse('https://up.ctown.jo/api/configurable_label_weight_check.php');

    try {
      final client = http.Client();
      final response = await client.post(
        uri,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: json.encode({"sku": sku, "order_id": orderid}),
      );
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);

        print(body);

        return body;
      }
    } catch (e) {
      return 'Could not update data';
    }
  }

  particularitemcancel({orderId, productId, ProductItem? product, qty}) async {
    String apiUrl = "https://up.ctown.jo/api/particularitemcancelqtycheckmobile.php";
    Map body = {"order_id": orderId, "product_id": productId};
    print(jsonEncode(body));
    var response = await http.post(Uri.parse(apiUrl), body: jsonEncode(body));
    var responseBody;
    print(response.statusCode);
    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      // setState(() {
      // product.qty_canceled= int.parse(responseBody["canceled_qty"].toString());
      // });
      print(responseBody);
      return responseBody["data"];
    } else {
      responseBody = {};
    }
    return responseBody;
  }

  String? text;
  ordersubsteatus() async {
    var mainStatus = widget.order!.status;
    var elements = [];
    for (var i in widget.lineItem!) {
      print("${widget.order!.increment_id}$elements${i.product_type}");
      if (i.product_type == 'simple') {
        if (i.delivery_from == 'Grocery' || i.delivery_from == 'Supplier' || i.delivery_from == 'Warehouse') {
          widget.lineItem!.forEach((element) {
            if (element.product_type == "simple") {
              elements.add(element.sub_status == 'Order Placed' && mainStatus == 'processing' ? 'processing' : element.sub_status);
            }
          });
        }

        var map = Map();
        elements.forEach((element) {
          if (!map.containsKey(element)) {
            map[element] = 1;
          } else {
            map[element] += 1;
          }
        });

        print(widget.order!.status);
        print("array");

        print(map);

        String? stCheck = '';
        var arrCount = map.length;
        if ((mainStatus == 'pending') || (mainStatus == 'canceled')) {
          stCheck = mainStatus;
        } else {
          if (arrCount > 1) {
            map.keys.forEach((k) {
              if (k != "canceled") {
                stCheck = k;
              }
            });
          } else {
            var entryList = map.entries.toList();
            stCheck = entryList[0].key;
          }
        }
        text = stCheck;
        print(mainStatus);

        return stCheck;
      }
    }
  }

  Future downloadFile({String? url, String? fileName, String? dir}) async {
    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = '';
    String? myUrl = "";

    try {
      myUrl = url;
      // + fileName;
      print(myUrl);
      var request = await httpClient.getUrl(Uri.parse(myUrl!));
      print(request);
      var response = await request.close();
      print(response);
      print(response.statusCode);
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        // Map<PermissionGroup, PermissionStatus> permissions =
        //     await PermissionHandler()
        //         .requestPermissions([PermissionGroup.storage]);
        // PermissionStatus permission = await PermissionHandler()
        //     .checkPermissionStatus(PermissionGroup.storage);
        // if (!status.isGranted) {
        //   await Permission.storage.request();
        // }
        if (Platform.isAndroid) {
          var deviceInfo = await DeviceInfoPlugin().androidInfo;
          printLog(deviceInfo);
          if (deviceInfo.version.sdkInt < 29) {
            var status = await Permission.storage.status;
            if (!status.isGranted) {
              await Permission.manageExternalStorage.request();
            }
          }
        }
        filePath = '$dir/$fileName.pdf';
        file = File(filePath);
        await file.writeAsBytes(bytes);
        print("write file complete");
      } else {
        filePath = 'Error code: ' + response.statusCode.toString();
        return "error code";
      }
    } catch (ex) {
      print(ex);
      filePath = 'Can not fetch url';
      return "file system exception";
    }
    print(filePath);
    return filePath;
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

  void getTracking() {
    services.getAllTracking().then((onValue) {
      if (onValue != null && onValue.trackings != null) {
        for (var track in onValue.trackings) {
          if (track.orderId == order!.number) {
            setState(() {
              tracking = track.trackingNumber;
            });
          }
        }
      }
    });
  }

  subtotal(List<ProductItem> lineItem) {
    double price = 0.0;
    lineItem.forEach((element) {
      print(element.quantity);
      price += element.price! * double.parse(element.quantity.toString());
    });
    return price;
  }

  total(List<ProductItem> lineItem) {
    double price = 0.0;
    lineItem.forEach((element) {
      print(element.quantity);
      price += element.price! * double.parse(element.quantity.toString());
    });
    return price;
  }

  void cancelOrder() {
    Services().widget?.cancelOrder(context, order).then((onValue) {
      setState(() {
        order = onValue;
      });
    });
  }

  void createRefund() {
    if (order?.status == 'refunded') return;
    final langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
    services.updateOrder(order?.id, langCode, status: 'refunded').then((onValue) {
      setState(() {
        order = onValue;
      });
      Provider.of<OrderModel>(context, listen: false).getMyOrder(
          userModel: Provider.of<UserModel>(context, listen: false), lang: Provider.of<AppModel>(context, listen: false).langCode ?? "en");
    });
  }

  GlobalKey<ScaffoldState> _orderKey = GlobalKey<ScaffoldState>();
  // GlobalKey<ScaffoldState> _porderKey = GlobalKey<ScaffoldState>();
  var elements = [];

  Future<void> _onScrollsToTop(ScrollsToTopEvent event) async {
    _scrollController.animateTo(0, duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";

    return ScrollsToTop(
      onScrollsToTop: _onScrollsToTop,
      child: Scaffold(
        key: _orderKey,
        appBar: AppBar(
          title: Text(
            S.of(context).orderNo + " #${order?.increment_id}",
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
        // appBar: AppBar(
        //   leading: IconButton(
        //       icon: Icon(
        //         Icons.arrow_back_ios,
        //         size: 20,
        //         color: Theme.of(context).accentColor,
        //       ),
        //       onPressed: () {
        //         Navigator.of(context).pop();
        //       }),
        //   title: Text(
        //     S.of(context).orderNo + " #${order.number}",
        //     style: TextStyle(color: Theme.of(context).accentColor),
        //   ),
        //   backgroundColor: Theme.of(context).backgroundColor,
        //   elevation: 0.0,
        // ),
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (var i in widget.lineItem!)
                if (i.total != '0')
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(child: Text(i.name!)),
                            const SizedBox(
                              width: 15,
                            ),
                            InkWell(
                              child: Text("x${i.quantity}"),
                              onTap: () {
                                print(i.delivery_from);
                                print(widget.order!.id);
                                print(i.productId);
                                print(Provider.of<SuggestedProductProvider>(context, listen: false).selectedReplacementProductsData);
                              },
                            ),
                            const SizedBox(width: 20),
                            Text(
                              Tools.getCurrencyFormatted(i.total, currencyRate)!,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            if (!(kPaymentConfig['EnableShipping'] as bool) || !(kPaymentConfig['EnableAddress'] as bool)) DownloadButton(i.productId)
                          ],
                        ),
                        FutureBuilder(
                            future: configproductname(i.sku, order!.id),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.data != null) {
                                if (snapshot.data["success"] == 1) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          print(i.qty_canceled);
                                        },
                                        child: Text(
                                          snapshot.data["data"]["attributes_info"][0]["label"].toString() != ""
                                              ? snapshot.data["data"]["attributes_info"][0]["label"].toString()
                                              : '',
                                        ),
                                      ),
                                      //  Text(
                                      //         // "x" + i.qty_canceled.toString() ?? "x")

                                      Container(
                                          padding: const EdgeInsets.only(right: 10),
                                          child: Text(
                                            snapshot.data["data"]["attributes_info"][0]["value"] != null
                                                ? snapshot.data["data"]["attributes_info"][0]["value"]
                                                : '',
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ))
                                    ],
                                  );

                                  // Text(
                                  //     "${snapshot.data["data"]["attributes_info"][0]["label"].toString() != null ? snapshot.data["data"]["attributes_info"][0]["label"].toString() : ''}:${snapshot.data["data"]["attributes_info"][0]["value"] != null ? snapshot.data["data"]["attributes_info"][0]["value"] : ''}",style: TextStyle(
                                  //     color: Theme.of(context).accentColor,
                                  //     fontWeight: FontWeight.w600),);
                                }
                                return Container();
                              }
                              return Container();
                            }),

                        Padding(
                          padding: const EdgeInsets.only(top: 7.0, right: 9.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                S.of(context).delivery,
                              ),
                              Text("${i.delivery_date}")
                            ],
                          ),
                        ),

                        // text=="Order Placed"||text=="processing"

                        //       ?
                        FutureBuilder(
                            future: configproduct(order!.id, i.sku, i.delivery_from),
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 7.0, right: 9.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              print(i.qty_canceled);
                                            },
                                            child: Text(
                                              S.of(context).cancelled_qty,
                                            ),
                                          ),
                                          //  Text(
                                          //         // "x" + i.qty_canceled.toString() ?? "x")
                                          FutureBuilder(
                                            future: particularitemcancel(
                                                orderId: order!.id, productId: i.product_type == 'simple' ? i.product_id : produid, product: i),
                                            builder: (context, AsyncSnapshot snapshot) {
                                              if (snapshot.hasData) {
                                                return Text("x${snapshot.data["canceled_qty"]}");
                                              }
                                              return Text("x" + i.qty_canceled.toString());
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                    text == 'order_placed' || text == 'processing'
                                        ? Padding(
                                            padding: EdgeInsets.only(bottom: 10),
                                            child: i.qty_canceled! < i.quantity!
                                                ? ElevatedButton(
                                                    onPressed: () async {
                                                      await configproduct(order!.id, i.sku, i.delivery_from);
                                                      print(produid);
                                                      await showDialog(
                                                          context: context,
                                                          builder: (context) => AlertDialog(
                                                                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                                                title: Text(Provider.of<AppModel>(context, listen: false).langCode == 'en'
                                                                    ? "Are You Sure"
                                                                    : 'هل أنت واثق'),
                                                                content: Row(
                                                                  children: <Widget>[
                                                                    // Column(children: [
                                                                    //   Text("Do you want to cancel the order"),
                                                                    // ],),
                                                                    Expanded(
                                                                      child: Form(
                                                                        key: _formKey,
                                                                        child: TextFormField(
                                                                          autofocus: true,
                                                                          keyboardType: TextInputType.number,
                                                                          controller: cancelQuantity,
                                                                          decoration: InputDecoration(
                                                                            // labelText:
                                                                            //     "Do you want to cancel the order",

                                                                            hintText: "Enter the quantity",
                                                                          ),
                                                                          validator: (value) {
                                                                            if (int.parse(value!) > i.quantity!) {
                                                                              return "Enter a valid quantity";
                                                                            } else {
                                                                              return null;
                                                                            }
                                                                          },
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                // content: Text(
                                                                //     "Do you want to cancel the order"),

                                                                actions: <Widget>[
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      print(i.order_status_id);
                                                                      cancelQuantity.clear();
                                                                      Navigator.of(context).pop(false);
                                                                    },
                                                                    child: Text(S.of(context).no),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () async {
                                                                      if (_formKey.currentState!.validate()) {
                                                                        showDialog(
                                                                          context: context,
                                                                          barrierDismissible: true,
                                                                          builder: kLoadingWidget,
                                                                        );

                                                                        String url = "https://up.ctown.jo/api/particularitemcancelmobile.php";
                                                                        Map body = {
                                                                          "order_id": order!.id,
                                                                          "product_id": i.product_type == 'simple' ? i.product_id : produid,
                                                                          "canceledQty": cancelQuantity.text
                                                                        };

                                                                        // print(i.productId);
                                                                        print(i.product_type == 'simple' ? i.product_id : produid);
                                                                        print(order!.id);
                                                                        print(cancelQuantity.text);

                                                                        final res = await http.post(Uri.parse(url), body: json.encode(body));
                                                                        print("PARTICULAR ITEM RESPONSE");
                                                                        print(res.body);
                                                                        print(res.statusCode);
                                                                        if (res.statusCode == 200) {
                                                                          var responseBody = json.decode(res.body);
                                                                          if (responseBody["success"] == 1) {
                                                                            setState(() {
                                                                              i.qty_canceled = (i.qty_canceled)! + int.parse(cancelQuantity.text);
                                                                            });
                                                                            cancelQuantity.clear();
                                                                            // setState(() {
                                                                            //   // widget.lineItem.clear();
                                                                            // });
                                                                          }

                                                                          SnackBar snackbar = SnackBar(content: Text(responseBody['message']));
                                                                          ScaffoldMessenger.of(context).showSnackBar(snackbar);
                                                                          //Navigator.pop(context1);
                                                                        } else {
                                                                          SnackBar snackbar =
                                                                              SnackBar(content: Text("Something went wrong.Try again"));
                                                                          ScaffoldMessenger.of(context).showSnackBar(snackbar);
                                                                        }

                                                                        // Navigator.of(context1).push(MaterialPageRoute(builder:(context1)=>

                                                                        // Navigator
                                                                        //     .push(
                                                                        //   context,
                                                                        //   MaterialPageRoute(
                                                                        //       builder:
                                                                        //           (context) =>
                                                                        //               OrderDetail(
                                                                        //                 lineItem:
                                                                        //                     widget.lineItem,
                                                                        //                 fromWhere:
                                                                        //                     widget.fromWhere,
                                                                        //                 order:
                                                                        //                     widget.order,
                                                                        //                 productType:
                                                                        //                     widget.productType,
                                                                        //                 onRefresh:
                                                                        //                     widget.onRefresh,
                                                                        //               )),
                                                                        // );
                                                                        Navigator.of(context, rootNavigator: true).pop();
                                                                        Navigator.of(context).pop(true);
                                                                      }
                                                                    },
                                                                    child: Text(S.of(context).yes),
                                                                  ),
                                                                ],
                                                              ));
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: Theme.of(context).primaryColor,
                                                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                                                    ),
                                                    child: Text(
                                                      Provider.of<AppModel>(context, listen: false).langCode == "ar"
                                                          ? "إلغاء المنتج"
                                                          : 'Cancel Product',
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  )
                                                : Text("Already Cancelled"))
                                        : Container()
                                  ],
                                );
                              }
                              return Container();
                            })
                        // : Container()
                      ],
                    ),
                  ),

              // Container(
              //      height:20,

              //      width:20,color:Colors.yellow),
              // FlatBtton(color: Theme.of(context).primaryColor,),,;

              const SizedBox(height: 10),
              (order!.customerNote != null && kPaymentConfig['EnableCustomerNote'] as bool)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          S.of(context).yourNote,
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                        Text(
                          order!.customerNote!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    )
                  : Container(),

              Container(
                decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          S.of(context).subtotal,
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                        Text(
                          Tools.getCurrencyFormatted(
                              // subtotal(widget.lineItem).toString(),
                              order!.subtotal,
                              // widget.lineItem.price,
                              currencyRate)!,
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    (order!.shippingMethodTitle != null && kPaymentConfig['EnableShipping'] as bool)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                S.of(context).shippingMethod,
                                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                              ),
                              Text(
                                order!.shippingMethodTitle!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          )
                        : Container(),
                    // const SizedBox(height: 10),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: <Widget>[
                    //     Text(
                    //       S.of(context).totalTax,
                    //       style: TextStyle(color: Theme.of(context).accentColor),
                    //     ),
                    //     Text(
                    //       Tools.getCurrencyFormatted(
                    //           order.totalTax, currencyRate),
                    //       style: TextStyle(
                    //         color: Theme.of(context).accentColor,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     )
                    //   ],
                    // ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          S.of(context).total1,
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                        Text(
                          Tools.getCurrencyFormatted(
                              // widget.lineItem.price
                              // total(widget.lineItem).toString(),
                              order!.total,
                              currencyRate)!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              tracking != null ? const SizedBox(height: 20) : Container(),
              tracking != null
                  ? GestureDetector(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          children: <Widget>[
                            Text("${S.of(context).trackingNumberIs} "),
                            Text(
                              tracking!,
                              style: TextStyle(color: Theme.of(context).primaryColor),
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrackingWebView(
                              url: "${afterShip['tracking_url']}/$tracking",
                            ),
                          ),
                        );
                      },
                    )
                  : Container(),
              Services().widget?.renderOrderTimelineTracking(context, order) ?? const SizedBox.shrink(),
              const SizedBox(height: 20),

              /// Render the Cancel and Refund
              if (kPaymentConfig['EnableRefundCancel'] as bool)
                Services().widget?.renderButtons(order, cancelOrder, createRefund) ?? const SizedBox.shrink(),

              const SizedBox(height: 20),

//
//
              FutureBuilder(
                  future: getInvoice(orderId: widget.order!.id),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                            Text(Provider.of<AppModel>(context, listen: false).langCode == "ar" ? "فاتورة" : "Invoice",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                if (snapshot.data["success"] == 1)
                                  Container(
                                    width: 145,
                                    // color: Colors.red,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        //
                                        Column(children: [
                                          InkWell(
                                            onTap: () async {
                                              String invoiceUrl = "";
                                              try {
                                                EasyLoading.instance
                                                  ..loadingStyle = EasyLoadingStyle.custom
                                                  ..backgroundColor = Colors.transparent
                                                  ..indicatorColor = Colors.transparent
                                                  ..dismissOnTap = false
                                                  ..textColor = Colors.transparent
                                                  ..boxShadow = []
                                                  ..userInteractions = false;
                                                await EasyLoading.show(
                                                    indicator: SpinKitCubeGrid(color: Theme.of(context).primaryColor, size: 30.0),
                                                    maskType: EasyLoadingMaskType.black);
                                                var invoice = await getInvoice(orderId: widget.order?.id);
                                                if (invoice != null) {
                                                  invoiceUrl = invoice["data"];
                                                }
                                              } catch (e) {
                                                printLog(e.toString());
                                              } finally {
                                                EasyLoading.dismiss();
                                              }
                                              await showModalBottomSheet(
                                                isScrollControlled: true,
                                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
                                                context: context,
                                                builder: (context) {
                                                  return FutureBuilder(
                                                      future: viewFile(url: invoiceUrl, fileName: "Invoice_${widget.order!.id}"),
                                                      builder: (context, AsyncSnapshot snapshot) {
                                                        // if (snapshot
                                                        //     .hasError) {
                                                        //   return Container(
                                                        //       height: MediaQuery.of(context).size.height * 0.9,
                                                        //       child: Center(child: Text('Could not generate invoice at this time')));
                                                        // }
                                                        if (snapshot.data == null) {
                                                          return Center(child: CircularProgressIndicator());
                                                        }
                                                        return Container(
                                                          height: MediaQuery.of(context).size.height * 0.9,
                                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(40)),
                                                          child: PdfPreview(
                                                            build: (format) => snapshot.data.readAsBytes(),
                                                          ),
                                                        );
                                                      });
                                                },
                                              );
                                            },
                                            child: Icon(Icons.print_rounded),
                                          ),
                                          Text(Provider.of<AppModel>(context, listen: false).langCode == "ar" ? "رأي" : "View")
                                        ]),
                                        Column(children: [
                                          InkWell(
                                            onTap: () async {
                                              if (Platform.isAndroid) {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: kLoadingWidget,
                                                );
                                                String invoiceUrl = "";
                                                var invoice = await getInvoice(orderId: widget.order?.id);
                                                if (invoice != null) {
                                                  invoiceUrl = invoice["data"];
                                                }
                                                String result = await downloadFile(
                                                    url: invoiceUrl, fileName: "Invoice_${widget.order!.id}", dir: "/storage/emulated/0/Download");
                                                Navigator.of(context, rootNavigator: true).pop();
                                                if (result.contains("/storage/emulated/0/")) {
                                                  SnackBar snackbar = SnackBar(
                                                    content: Text("Invoice is saved successfully in this location $result"),
                                                  );
                                                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                                                } else {
                                                  SnackBar snackbar = SnackBar(
                                                    content: Text("Something went wrong..please try again"),
                                                  );
                                                  ScaffoldMessenger.of(context).showSnackBar(snackbar);
                                                }
                                              } else if (Platform.isIOS) {
                                                try {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: kLoadingWidget,
                                                  );
                                                  String invoiceUrl = "";
                                                  var invoice = await getInvoice(orderId: widget.order?.id);
                                                  if (invoice != null) {
                                                    invoiceUrl = invoice["data"];
                                                  }
                                                  var downloadDir = await getApplicationDocumentsDirectory();
                                                  HttpClient httpClient = HttpClient();
                                                  var time = DateTime.now().microsecondsSinceEpoch;
                                                  File file;
                                                  String filePath = '${downloadDir.path}/invoice_${widget.order?.id}.pdf';
                                                  String myUrl = invoiceUrl;
                                                  var request = await httpClient.getUrl(Uri.parse(myUrl));

                                                  var response = await request.close();
                                                  if (response.statusCode == 200) {
                                                    var bytes = await consolidateHttpClientResponseBytes(response);
                                                    file = File(filePath);
                                                    await file.writeAsBytes(bytes);
                                                    SnackBar snackbar = SnackBar(
                                                      content: Text("Invoice is saved to Files/Ctown"),
                                                    );
                                                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                                                  }
                                                } catch (e) {
                                                  printLog(e.toString());
                                                } finally {
                                                  Navigator.of(context, rootNavigator: true).pop();
                                                }
                                              }
                                            },
                                            child: Icon(Icons.download_outlined),
                                          ),
                                          Text(Provider.of<AppModel>(context, listen: false).langCode == "ar" ? "تحميل" : "Download")
                                        ])
                                      ],
                                    ),
                                  ),
                                if (snapshot.data["success"] == 0) Container()
                              ],
                            ),
                          )
                        ],
                      );
                    }
                    return Container();
                  }),

//

              FutureBuilder<List<SuggestedProduct>>(
                  future: getReplacement(),
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      // return Text(snapshot.data.toString());

                      return Column(children: [
                        if (Provider.of<SuggestedProductProvider>(context).selectedReplacementProductsData.isNotEmpty)
                          Text(Provider.of<AppModel>(context, listen: false).langCode == "ar"
                              ? "يرجى ملاحظة أن المنتج (المنتجات) التالية غير متوفر بالمخزون وأن بعض المنتجات البديلة المشابهة لهذا المنتج مدرجة .. يمكنك اختيار بديل أو إزالة العنصر غير الموجود في المخزون من هذا الطلب"
                              : "Please note that the following product(s) are out of stock and some of the replacement products which are similar to this product are listed..You can choose a replacement or remove the out of stock item from this order" +
                                  " "),
                        Column(
                            children: List.generate(
                                // snapshot.data.length,
                                Provider.of<SuggestedProductProvider>(context).selectedReplacementProductsData.length,
                                (index) => Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        OutOfStockProductItem(
                                            widgetKey: _orderKey,
                                            orderId: widget.order!.id,
                                            parentIndex: index,
                                            outOfStockproductId: Provider.of<SuggestedProductProvider>(context)
                                                .selectedReplacementProductsData[index]["outofstock_product"]
                                                .productId,
                                            outOfStockproductPrice: Provider.of<SuggestedProductProvider>(context)
                                                .selectedReplacementProductsData[index]["outofstock_product"]
                                                .productPrice,
                                            outOfStockBarcode: Provider.of<SuggestedProductProvider>(context)
                                                .selectedReplacementProductsData[index]["outofstock_product"]
                                                .barcode,
                                            productType: Provider.of<SuggestedProductProvider>(context)
                                                .selectedReplacementProductsData[index]["outofstock_product"]
                                                .productType,
                                            ondelete: deleteReplacement,
                                            outOfStockQty: Provider.of<SuggestedProductProvider>(context).selectedReplacementProductsData[index]
                                                ["outofstock_qty"],
                                            index: index,
                                            data: Provider.of<SuggestedProductProvider>(context).selectedReplacementProductsData[index]
                                                ["outofstock_product"]
                                            // snapshot.data[index]
                                            //     .outofstockProductDetails[0],
                                            ),
                                        Text("Replacements : "),
                                        Column(
                                          children: List.generate(
                                            // snapshot
                                            //     .data[index]
                                            //     .replacementProductDetails
                                            //     .length,
                                            Provider.of<SuggestedProductProvider>(context)
                                                .selectedReplacementProductsData[index]["replacement_products"]
                                                .length,
                                            (i) =>
                                                //  Text("$i")
                                                SuggestedReplacementProductItem(
                                                    parentIndex: index,
                                                    orderId: widget.order!.id,
                                                    outOfStockproductId: Provider.of<SuggestedProductProvider>(context)
                                                        .selectedReplacementProductsData[index]["outofstock_product"]
                                                        .productId,
                                                    outOfStockPrice: Provider.of<SuggestedProductProvider>(context)
                                                        .selectedReplacementProductsData[index]["outofstock_product"]
                                                        .productPrice,
                                                    startPicking:
                                                        Provider.of<SuggestedProductProvider>(context).selectedReplacementProductsData.length <= 1
                                                            ? "startpicking"
                                                            : "",
                                                    outOfStockBarcode: Provider.of<SuggestedProductProvider>(context)
                                                        .selectedReplacementProductsData[index]["outofstock_product"]
                                                        .barcode,
                                                    productType: Provider.of<SuggestedProductProvider>(context)
                                                        .selectedReplacementProductsData[index]["outofstock_product"]
                                                        .productType,
                                                    onPressed: applyReplacement,
                                                    index: i,
                                                    outOfStockQty: Provider.of<SuggestedProductProvider>(context)
                                                        .selectedReplacementProductsData[index]["outofstock_qty"],
                                                    // "2",
                                                    // snapshot
                                                    //     .data[index].outofstockQty,
                                                    data: Provider.of<SuggestedProductProvider>(context).selectedReplacementProductsData[index]
                                                        ["replacement_products"][i]["item"]),
                                            /* SuggestedReplacementProductItem(
                                              parentIndex: index,
                                              orderId: widget.order.id,
                                              outOfStockproductId: snapshot
                                                  .data[index]
                                                  .outofstockProductDetails[0]
                                                  .productId,
                                              outOfStockBarcode: snapshot
                                                  .data[index]
                                                  .outofstockProductDetails[0]
                                                  .barcode,
                                              productType: snapshot
                                                  .data[index]
                                                  .outofstockProductDetails[0]
                                                  .productType,
                                              onPressed: applyReplacement,
                                              index: i,
                                              outOfStockQty: snapshot
                                                  .data[index].outofstockQty,
                                              data: snapshot.data[index]
                                                  .replacementProductDetails[i],
                                            ),*/
                                          ),
                                        )
                                      ],
                                    )))
                      ]);
//    return ListView.builder(
//      physics: NeverScrollableScrollPhysics(),
//      itemCount: snapshot.data.length,
//      itemBuilder: (context,index){
//      return Column(children: [
// Text(snapshot.data[index].outofstockProductDetails[index].productName)
//      ],);
//    });
                    }
                    return Container();
                    //  Center(child: CircularProgressIndicator());
                  }),
//
              SizedBox(
                height: 10,
              ),
              order!.status == "pending"
                  ? FutureBuilder(
                      future: noteFunction(order!.id),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          return Padding(padding: EdgeInsets.only(left: 1, right: 10), child: Text(snapshot.data));
                        }
                        // return Center(child: CircularProgressIndicator());
                        return Container();
                      })
                  : Container(),

              widget.order!.status == "pending"
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 10),
                      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                        ElevatedButton(
                            onPressed: () async {
                              String apiUrl = "https://up.ctown.jo/api/timeduration.php";
                              Map body = {"order_id": widget.order!.id};

                              var response = await http.post(Uri.parse(apiUrl), body: json.encode(body));

                              var responseBody = json.decode(response.body);

                              if (response.statusCode == 200) {
                                String payment_text = "";
                                if (langCode == "en") {
                                  payment_text =
                                      "Note : You have to finish the payment of the order within ${responseBody['data'][0]["minutes"]} minutes orelse the order will be cancelled";
                                } else {
                                  payment_text = "ملاحظة: يجب عليك إتمام عملية الدفع خلال 15 دقيقة وإلا سيتم إلغاء الطلب.";
                                }
                                SharedPreferences prefs = await SharedPreferences.getInstance();

                                await prefs.setString("note_${widget.order!.id}", payment_text);

                                widget.order!.notes = payment_text;
                                setState(() {});
                                await showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(40),
                                    //bottom: Radius.circular(80),
                                  )),
                                  builder: (context) => Container(
                                      height: 150,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 12,
                                          ),
                                          ListTile(
                                            leading: Icon(Icons.wysiwyg_rounded),
                                            title: Text("Cash on Delivery"),
                                            onTap: () async {
                                              print("cash on delivery");
                                              String? response = await MagentoApi().updatePaymentMethod(widget.order!.id);
                                              print(response);
                                              print("widget fromwhere");
                                              print(widget.fromWhere);
                                              if (widget.fromWhere == "success") {
                                                Navigator.pop(context);
                                                widget.onRefresh!();
                                              } else {
                                                SnackBar snackbar = SnackBar(
                                                  content: Text(response!),
                                                );
                                                ScaffoldMessenger.of(context).showSnackBar(snackbar);

                                                Navigator.pop(context);

                                                print("refresh starts");
                                                widget.onRefresh!();
                                                print("refresh ends");
                                              }
                                              // Navigator.pop(context);
                                              // Navigator.pushNamed(context, "/orders");
                                              // Navigator.pushReplacement(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //         builder:
                                              //             (BuildContext context) =>
                                              //                 super.widget));
                                              print("function ends");
                                            },
                                          ),
                                          ListTile(
                                            leading: Icon(Icons.wysiwyg_rounded),
                                            title: Text("Credit card"),
                                            onTap: () async {
                                              print(widget.order!.id);
                                              await cardPay(context, widget.order);
                                            },
                                          ),
                                        ],
                                      )),
                                );
                              } else {
                                SnackBar snackBar = SnackBar(content: Text('Error during updating'));
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                            ),
                            child: Text(
                              Provider.of<AppModel>(context, listen: false).langCode == "en" ? 'Re-initiate Payment' : "اعادة طريقة الدفع",
                              style: TextStyle(color: Colors.white),
                            ))
                      ]))
                  : Container(),

              //
              text == 'order_placed' || text == 'processing'
                  // widget.lineItem[2].sub_status == 'Order Placed' &&
                  //          widget.order.status == 'processing'||widget.lineItem[0].sub_status=='Order Placed'

                  ? Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                          onPressed: () async {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                      title: Text(Provider.of<AppModel>(context, listen: false).langCode == 'en' ? "Are You Sure" : 'هل أنت واثق'),
                                      content: Text(Provider.of<AppModel>(context, listen: false).langCode == 'en'
                                          ? "Do you want to cancel the order"
                                          : "هل تريد إلغاء الطلب"),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: Text(S.of(context).no),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              builder: kLoadingWidget,
                                            );

                                            String url = "https://up.ctown.jo/api/ordercancelmobile.php";
                                            Map body = {"order_id": order!.id};

                                            print(order!.id);

                                            final res = await http.post(Uri.parse(url), body: json.encode(body));
                                            print(res.body);
                                            if (res.statusCode == 200) {
                                              var responseBody = json.decode(res.body);
                                              SnackBar snackbar = SnackBar(content: Text(responseBody['message']));
                                              ScaffoldMessenger.of(context).showSnackBar(snackbar);
                                              // Navigator.pop(context);
                                            } else {
                                              SnackBar snackbar = SnackBar(content: Text("Something went wrong.Try again"));
                                              ScaffoldMessenger.of(context).showSnackBar(snackbar);
                                            }
                                            setState(() {
                                              text = "canceled";
                                              // widget.lineItem[0].order_status_id =
                                              //     '7';
                                            });
                                            Navigator.of(context, rootNavigator: true).pop();
                                            Navigator.of(context).pop(true);
                                          },
                                          child: Text(S.of(context).yes),
                                        ),
                                      ],
                                    ));

                            /*
                                showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: kLoadingWidget,
                                );

                                String url =
                                    "https://online.ajmanmarkets.ae/api/ordercancelmobile.php";
                                Map body = {"order_id": order.id};
                                print(order.id);
                                final res =
                                    await http.post(url, body: json.encode(body));
                                print(res.body);
                                if (res.statusCode == 200) {
                                  var responseBody = json.decode(res.body);
                                  SnackBar snackbar = SnackBar(
                                      content: Text(responseBody['message']));
                                  _orderKey.currentState.showSnackBar(snackbar);
                                  // Navigator.pop(context);
                                } else {
                                  SnackBar snackbar = SnackBar(
                                      content:
                                          Text("Something went wrong.Try again"));
                                  _orderKey.currentState.showSnackBar(snackbar);
                                }
                                setState(() {
                                  order.status = "canceled";
                                });
                                Navigator.of(context, rootNavigator: true).pop();*/
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                          ),
                          child: Text(
                            Provider.of<AppModel>(context, listen: false).langCode == "ar" ? "الغاء الطلب" : 'Cancel Order',
                            style: TextStyle(color: Colors.white),
                          )))
                  : Container(),

//
              if (order!.billing != null) ...[
                Text(S.of(context).shippingAddress, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  ((order!.billing!.apartment?.isEmpty ?? true) ? '' : '${order!.billing!.apartment} ') +
                      ((order!.billing!.block?.isEmpty ?? true)
                          ? ''
                          : '${(order!.billing!.apartment?.isEmpty ?? true) ? '' : '- '} ${order!.billing!.block}, ') +
                      order!.billing!.street! +
                      ", " +
                      order!.billing!.city! +
                      ", " +
                      getCountryName(order!.billing!.country),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ],
//

              //
              if (order!.status == "processing" && kPaymentConfig['EnableRefundCancel'] as bool)
                Column(
                  children: <Widget>[
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ButtonTheme(
                            height: 45,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: HexColor("#056C99"),
                                ),
                                onPressed: refundOrder,
                                child: Text(S.of(context).refundRequest.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700))),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              const SizedBox(
                height: 20,
              ),
              FutureBuilder<List<OrderNote>?>(
                future: services.getOrderNote(userModel: userModel, orderId: order!.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Container();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        S.of(context).orderNotes,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          snapshot.data!.length,
                          (index) {
                            return Padding(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  CustomPaint(
                                    painter: BoxComment(color: Theme.of(context).primaryColor),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 25),
                                        child: HtmlWidget(
                                          snapshot.data![index].note!,
                                          textStyle: const TextStyle(color: Colors.white, fontSize: 13, height: 1.2),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    formatTime(DateTime.parse(snapshot.data![index].dateCreated!)),
                                    style: const TextStyle(fontSize: 13),
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.only(bottom: 15),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 50)
            ],
          ),
        ),
      ),
    );
  }

  //

  cardPay(context, order) async {
    String apiUrl = "https://up.ctown.jo/api/repay.php";
    Map? body;
    var response = await http.post(Uri.parse(apiUrl),
        // headers: {
        //   'Authorization': 'Bearer ' + accessToken,
        //   "content-type": "application/json"
        // },
        body: jsonEncode({'order_id': order.id}));
    if (response.statusCode == 200) {
      body = jsonDecode(response.body);
      print(body);
    }

    Map urlMap = {
      "paymentUrl": body!['data']['_links']['payment']['href'],
      "redirectUrl": body['data']['merchantAttributes']['redirectUrl'],
      "cancelUrl": body['data']['merchantAttributes']['cancelUrl']
    };

    try {
      var cardDetails = Provider.of<PaymentMethodModel>(context, listen: false).cardDetails;
      print("card details $cardDetails");

      web.WebViewController controller = web.WebViewController();
      controller
        ..setJavaScriptMode(web.JavaScriptMode.unrestricted)
        ..setNavigationDelegate(web.NavigationDelegate(onNavigationRequest: (web.NavigationRequest request) async {
          if (request.url.contains(urlMap['redirectUrl'])) {
            final uri = Uri.parse(request.url);
            final payerID = uri.queryParameters['ref'];
            if (payerID != null) {
              var status = await MagentoApi().getPaymentStatus(payerID);
              // if (status == 'CAPTURED') {
              //
              //
              if (status == 'AUTHORISED') {
                if (order != null) {
                  await MagentoApi().submitPaymentSuccess(order.id);
                  // widget.onFinish(newOrder);
                  // widget.onLoading(false);
                  // isPaying = false;
                  // newOrder = null;
                }
                // await createOrder(paid: true).then((value) {
                //   widget.onLoading(false);
                //   isPaying = false;
                // });
              } else {
                /// handle payment failure
                // widget.onLoading(false);
                // isPaying = false;
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      title: Text(S.of(context).orderStatusFailed),
                      // content: Text("${err?.message ?? err}"),
                      content: const Text("Your payment was not successful!!"),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            S.of(context).ok,
                            style: TextStyle(color: Theme.of(context).primaryColor),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    );
                  },
                );
              }
            } else {
              // widget.onLoading(false);
              // isPaying = false;
              Navigator.of(context).pop();
            }
            // Navigator.of(context).pop();
          }
          if (request.url.contains(urlMap['cancelUrl'])) {
            // widget.onLoading(false);
            // isPaying = false;
            Navigator.of(context).pop();
          }
          return web.NavigationDecision.navigate;
        }))
        ..loadRequest(Uri.parse(urlMap['paymentUrl']));
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WillPopScope(
              onWillPop: () async {
                // widget.onLoading(false);
                // isPaying = false;
                return true;
              },
              child: web.WebViewWidget(controller: controller)),
        ),
      );
    } catch (e) {
      // widget.onLoading(false);
      // isPaying = false;
      print("exception $e");
      print("starting delete cart");

      return Tools.showSnackBar(ScaffoldMessenger.of(context), 'Unable to process the request');
    }

    // finally {
    //   // await Services().deleteItemFromCart(
    //   //     cartModel.productsInCart.keys.toList(),
    //   //     cookie != null ? cookie : null);
    //   cartModel.clearCart();
    //   print("successfully emptied cart item");
    //   Navigator.pop(context);
    // }

    //delete cart items
    //

    // Navigator.of(context, rootNavigator: true).pop();
  }
  //

  String getCountryName(country) {
    try {
      return CountryPickerUtils.getCountryByIsoCode(country).name;
    } catch (err) {
      return country;
    }
  }

  Future<void> refundOrder() async {
    _showLoading();
    try {
      String lang = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
      await services.updateOrder(order!.id, lang, status: "refunded");
      _hideLoading();
      widget.onRefresh!();
      Navigator.of(context).pop();
    } catch (err) {
      _hideLoading();

      Tools.showSnackBar(ScaffoldMessenger.of(context), err.toString());
    }
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(5.0)),
            padding: const EdgeInsets.all(50.0),
            child: kLoadingWidget(context),
          ),
        );
      },
    );
  }

  void _hideLoading() {
    Navigator.of(context).pop();
  }

  String formatTime(DateTime time) {
    return "${time.day}/${time.month}/${time.year}";
  }
}

class BoxComment extends CustomPainter {
  final Color? color;

  BoxComment({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.color = color!;
    var path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 10);
    path.lineTo(30, size.height - 10);
    path.lineTo(20, size.height);
    path.lineTo(20, size.height - 10);
    path.lineTo(0, size.height - 10);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DownloadButton extends StatefulWidget {
  final String? id;

  DownloadButton(this.id);

  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final services = Services();
    return InkWell(
      onTap: () async {
        setState(() {
          isLoading = true;
        });

        Product? product = await services.getProduct(widget.id);
        setState(() {
          isLoading = false;
        });
        await Share.share(product?.files![0] ?? "");
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: <Widget>[
            isLoading
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 15.0,
                      height: 15.0,
                      child: Center(
                        child: kLoadingWidget(context),
                      ),
                    ),
                  )
                : Icon(
                    Icons.file_download,
                    color: Theme.of(context).primaryColor,
                  ),
            Text(
              S.of(context).download,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrackingWebView extends StatelessWidget {
  final String url;

  const TrackingWebView({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          child: const Icon(Icons.arrow_back_ios),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Tracking Page'), // Replace with `S.of(context).trackingPage` if using localization
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          cacheEnabled: true,
        ),
        onWebViewCreated: (controller) {
          // Handle WebView created event if needed
        },
        onLoadStart: (controller, url) {
          // Handle URL changes during navigation if needed
        },
        onLoadStop: (controller, url) async {
          // Handle logic when the page finishes loading
        },
      ),
    );
  }
}
