import 'dart:convert';
import 'dart:io';

import 'package:ctown/frameworks/magento/services/magento.dart';
import 'package:ctown/models/cart/cart_model.dart';
import 'package:ctown/models/entities/order.dart';
import 'package:ctown/models/payment_method_model.dart';
import 'package:ctown/screens/settings/return_policy.dart';
import 'package:ctown/services/index.dart';
import 'package:ctown/tabbar.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import "package:path_provider/path_provider.dart";
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/string_extension.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, Order, OrderModel, UserModel;
import '../../screens/base.dart';
import '../../widgets/payment/payment_webview.dart';
import 'order_detail.dart';

class MyOrders extends StatefulWidget {
  final String fromWhere;
  MyOrders({this.fromWhere = "settings"});
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends BaseScreen<MyOrders> {
  final RefreshController _refreshController = RefreshController();

  // List<Order> groceryOrders = [];
  // List<Order> supplierOrders = [];
  // List<Order> warehouseOrders = [];
  List<Order> myGroceries = [];
  final ScrollController _scrollController = ScrollController();
  @override
  void afterFirstLayout(BuildContext context) {
    refreshMyOrders();
  }

  getWidgets(model) {
    List.generate(model.myOrders.length, (index) {
      model.myOrders[index].lineItems.forEach((element) {
        return element.delivery_from == "Warehouse" ? Text("33") : Text("dffd");
      });
    });
  }

  @override
  void dispose() {
    // groceryOrders.clear();
    // supplierOrders.clear();
    // warehouseOrders.clear();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onScrollsToTop(ScrollsToTopEvent event) async {
    _scrollController.animateTo(0, duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
  }

  Future<void> _onRefresh() async {
    await Provider.of<OrderModel>(context, listen: false)
        .getMyOrder(userModel: Provider.of<UserModel>(context, listen: false),
    lang: Provider.of<AppModel>(context, listen: false).langCode ?? "en");
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    await Provider.of<OrderModel>(context, listen: false)
        .loadMore(Provider.of<AppModel>(context, listen: false).langCode ?? "en", userModel: Provider.of<UserModel>(context, listen: false),);
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Provider.of<UserModel>(context).loggedIn;

    return Platform.isIOS ? ScrollsToTop(
      onScrollsToTop: _onScrollsToTop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            S.of(context).orderHistory,
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
        body: Builder(
          builder: (BuildContext context) {
            return ListenableProvider.value(
              value: Provider.of<OrderModel>(context),
              child: Consumer<OrderModel>(
                builder: (context, model, child) {
                  if (model.myOrders == null) {
                    return Center(
                      child: kLoadingWidget(context),
                    );
                  }
                  if (!isLoggedIn) {
                    final LocalStorage storage = LocalStorage('data_order');
                    var orders = storage.getItem('orders');
                    var listOrder = [];
                    // for (var i in orders) {
                    //   listOrder.add(Order.fromStrapiJson(i));
                    // }
                    for (var i in orders) {
                      listOrder.add(Order.fromJson(i));
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15),
                          child:
                              Text("${listOrder.length} ${S.of(context).items}"),
                        ),
                        Expanded(
                          child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              itemCount: listOrder.length,
                              itemBuilder: (context, index) {
                                return OrderItem(
                                  fromWhere: widget.fromWhere,
                                  order: listOrder[listOrder.length - index - 1],
                                  onRefresh: () {},
                                );
                              }),
                        ),
                      ],
                    );
                  }

                  if (model.myOrders != null && model.myOrders!.isEmpty) {
                    return Center(child: Text(S.of(context).noOrders));
                  }
                  // model.myOrders.forEach((order) {
                  //   order.lineItems.forEach((element) {
                  //     if (element.delivery_from == "Warehouse") {
                  //       bool isExists = false;
                  //       warehouseOrders.forEach((warehouse) {
                  //         if (warehouse.id == order.id) {
                  //           isExists = true;
                  //         }
                  //       });
                  //       if (!isExists) {
                  //         warehouseOrders.add(order);
                  //       }
                  //     } else if (element.delivery_from == "Grocery") {
                  //       bool isExists = false;
                  //       groceryOrders.forEach((grocery) {
                  //         if (grocery.id == order.id) {
                  //           isExists = true;
                  //         }
                  //       });
                  //       if (!isExists) {
                  //         groceryOrders.add(order);
                  //       }
                  //     } else {
                  //       bool isExists = false;
                  //       supplierOrders.forEach((supplier) {
                  //         if (supplier.id == order.id) {
                  //           isExists = true;
                  //         }
                  //       });
                  //       if (!isExists) {
                  //         supplierOrders.add(order);
                  //       }
                  //     }
                  //   });
                  // });

                  // supplierOrders.toSet().toList();
                  // warehouseOrders.toSet().toList();

                  return Stack(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            child: Text(
                                "${model.myOrders!.length} ${S.of(context).items}"),
                          ),
                          Expanded(
                            child: SmartRefresher(
                              enablePullDown: true,
                              enablePullUp: !model.endPage,
                              onRefresh: _onRefresh,
                              onLoading: _onLoading,
                              header: const WaterDropHeader(),
                              footer: kCustomFooter(context),
                              controller: _refreshController,
                              child:

                                  // ListView.builder(
                                  //     padding:
                                  //         const EdgeInsets.symmetric(horizontal: 15),
                                  //     itemCount: model.myOrders.length,
                                  //     itemBuilder: (context, index) {
                                  //       // return OrderItem(
                                  //       //   order: model.myOrders[index],
                                  //       //   onRefresh: refreshMyOrders,
                                  //       // );
                                  //       return Column(
                                  //           children: List.generate(
                                  //               model.myOrders[index].lineItems.length,
                                  //               (index) => OrderItem(
                                  //                     order: model.myOrders[index],
                                  //                     onRefresh: refreshMyOrders,
                                  //                   )));
                                  //     }),
//
//
//
//
                              ListView(children: [
                                Column(
                                  children: List.generate(
                                    model.myOrders!.length,
                                    (index) {
                                      List<ProductItem> groceryOrders = [];
                                      List<ProductItem> warehouseOrders = [];
                                      List<ProductItem> supplierOrders = [];

                                      groceryOrders = model
                                          .myOrders![index].lineItems
                                          .where((i) =>
                                              i.delivery_from == "Grocery" ||
                                              i.delivery_from == null)
                                          .toList();
                                      warehouseOrders = model
                                          .myOrders![index].lineItems
                                          .where((i) =>
                                              i.delivery_from == "Warehouse")
                                          .toList();
                                      supplierOrders = model
                                          .myOrders![index].lineItems
                                          .where((i) =>
                                              i.delivery_from == "Supplier")
                                          .toList();

                                      /*
                                  latest edit
                                      model.myOrders[index].lineItems
                                          .forEach((element) {
                                        if (model.myOrders[index].increment_id ==
                                            "57000000199") {
                                          print("-------------------");
                                          print(element.delivery_from);
                                          print(element.productId);
                                          print(element.name);
                                          print("-------------------");
                                        }
                                        if (element.delivery_from == "Grocery") {
                                          groceryOrders.add(element);
                                        } else if (element.delivery_from ==
                                            "Warehouse") {
                                          if (model
                                                  .myOrders[index].increment_id ==
                                              "57000000199") {
                                            print(
                                                "-----_____________________________--------");
                                            print(element.delivery_from);
                                            print(element.productId);
                                            print(element.name);
                                            print("-------------------");
                                          }
                                          warehouseOrders.add(element);
                                        } else if (element.delivery_from ==
                                            "Supplier") {
                                          supplierOrders.add(element);
                                        } else {
                                          groceryOrders.add(element);
                                        }
                                      });
                                      print("==================");
                                      print(warehouseOrders.length);
                                      print(supplierOrders.length);
                                      print(groceryOrders.length);
                                      print("==================");

                                      */

                                      /* return Column(children: [
                                        OrderItem(
                                          fromWhere: widget.fromWhere,
                                          order: model.myOrders[index],
                                          lineItem: groceryOrders,
                                          onRefresh: refreshMyOrders,
                                        ),
                                        Column(
                                            children: List.generate(
                                                warehouseOrders.length, (index) {
                                          return OrderItem(
                                            fromWhere: widget.fromWhere,
                                            order: model.myOrders[index],
                                            lineItem: [warehouseOrders[index]],
                                            onRefresh: refreshMyOrders,
                                          );
                                          // Text(warehouseOrders[index].name);
                                        })),
                                        Column(
                                            children: List.generate(
                                                supplierOrders.length, (index) {
                                          return OrderItem(
                                            fromWhere: widget.fromWhere,
                                            order: model.myOrders[index],
                                            lineItem: [supplierOrders[index]],
                                            onRefresh: refreshMyOrders,
                                          );
                                          // Text(warehouseOrders[index].name);
                                        }))
                                      ]);*/
                                      return Column(children: [
                                        OrderItem(
                                          productType: "Grocery",
                                          fromWhere: widget.fromWhere,
                                          order: model.myOrders![index],
                                          lineItem: groceryOrders,
                                          onRefresh: refreshMyOrders,
                                        ),
                                        Column(
                                            children: List.generate(
                                                warehouseOrders.length, (i) {
                                          return OrderItem(
                                            productType: "Warehouse",
                                            fromWhere: widget.fromWhere,
                                            order: model.myOrders![index],
                                            lineItem: [warehouseOrders[i]],
                                            onRefresh: refreshMyOrders,
                                          );
                                          // Text(warehouseOrders[index].name);
                                        })),
                                        Column(
                                            children: List.generate(
                                                supplierOrders.length, (i) {
                                          return OrderItem(
                                            productType: "Supplier",
                                            fromWhere: widget.fromWhere,
                                            order: model.myOrders![index],
                                            lineItem: [supplierOrders[i]],
                                            onRefresh: refreshMyOrders,
                                          );
                                          // Text(warehouseOrders[index].name);
                                        }))
                                      ]);
                                    },
                                  ),
                                ),
                              ],
                              controller: _scrollController),

                              //
                              //     ListView(
                              //   children: [
                              //     ExpansionTile(
                              //         title: Text('Supplier'),
                              //         onExpansionChanged: (e) {
                              //           print(groceryOrders.length);
                              //         },
                              //         children: List.generate(
                              //             supplierOrders.length,
                              //             (index) => OrderItem(
                              //                   order: model.myOrders[index],
                              //                   onRefresh: refreshMyOrders,
                              //                 ))),
                              //     ExpansionTile(
                              //       title: Text('Grocery'),
                              //       children: List.generate(
                              //           groceryOrders.length,
                              //           (index) => OrderItem(
                              //                 order: model.myOrders[index],
                              //                 onRefresh: refreshMyOrders,
                              //               )),
                              //     ),
                              //     ExpansionTile(
                              //         title: Text('Warehouse'),
                              //         children: List.generate(
                              //             warehouseOrders.length,
                              //             (index) => OrderItem(
                              //                   order: model.myOrders[index],
                              //                   onRefresh: refreshMyOrders,
                              //                 ))),
                              //   ],
                              // ),
                            ),
                          )
                        ],
                      ),
                      model.isLoading
                          ? Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              color: Colors.black.withOpacity(0.2),
                              child: Center(
                                child: kLoadingWidget(context),
                              ),
                            )
                          : Container()
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    ) : Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).orderHistory,
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
      body: Builder(
        builder: (BuildContext context) {
          return ListenableProvider.value(
            value: Provider.of<OrderModel>(context),
            child: Consumer<OrderModel>(
              builder: (context, model, child) {
                if (model.myOrders == null) {
                  return Center(
                    child: kLoadingWidget(context),
                  );
                }
                if (!isLoggedIn) {
                  final LocalStorage storage = LocalStorage('data_order');
                  var orders = storage.getItem('orders');
                  var listOrder = [];
                  // for (var i in orders) {
                  //   listOrder.add(Order.fromStrapiJson(i));
                  // }
                  for (var i in orders) {
                    listOrder.add(Order.fromJson(i));
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        child:
                        Text("${listOrder.length} ${S.of(context).items}"),
                      ),
                      Expanded(
                        child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            itemCount: listOrder.length,
                            itemBuilder: (context, index) {
                              return OrderItem(
                                fromWhere: widget.fromWhere,
                                order: listOrder[listOrder.length - index - 1],
                                onRefresh: () {},
                              );
                            }),
                      ),
                    ],
                  );
                }

                if (model.myOrders != null && model.myOrders!.isEmpty) {
                  return Center(child: Text(S.of(context).noOrders));
                }
                // model.myOrders.forEach((order) {
                //   order.lineItems.forEach((element) {
                //     if (element.delivery_from == "Warehouse") {
                //       bool isExists = false;
                //       warehouseOrders.forEach((warehouse) {
                //         if (warehouse.id == order.id) {
                //           isExists = true;
                //         }
                //       });
                //       if (!isExists) {
                //         warehouseOrders.add(order);
                //       }
                //     } else if (element.delivery_from == "Grocery") {
                //       bool isExists = false;
                //       groceryOrders.forEach((grocery) {
                //         if (grocery.id == order.id) {
                //           isExists = true;
                //         }
                //       });
                //       if (!isExists) {
                //         groceryOrders.add(order);
                //       }
                //     } else {
                //       bool isExists = false;
                //       supplierOrders.forEach((supplier) {
                //         if (supplier.id == order.id) {
                //           isExists = true;
                //         }
                //       });
                //       if (!isExists) {
                //         supplierOrders.add(order);
                //       }
                //     }
                //   });
                // });

                // supplierOrders.toSet().toList();
                // warehouseOrders.toSet().toList();

                return Stack(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15),
                          child: Text(
                              "${model.myOrders!.length} ${S.of(context).items}"),
                        ),
                        Expanded(
                          child: SmartRefresher(
                            enablePullDown: true,
                            enablePullUp: !model.endPage,
                            onRefresh: _onRefresh,
                            onLoading: _onLoading,
                            header: const WaterDropHeader(),
                            footer: kCustomFooter(context),
                            controller: _refreshController,
                            child:

                            // ListView.builder(
                            //     padding:
                            //         const EdgeInsets.symmetric(horizontal: 15),
                            //     itemCount: model.myOrders.length,
                            //     itemBuilder: (context, index) {
                            //       // return OrderItem(
                            //       //   order: model.myOrders[index],
                            //       //   onRefresh: refreshMyOrders,
                            //       // );
                            //       return Column(
                            //           children: List.generate(
                            //               model.myOrders[index].lineItems.length,
                            //               (index) => OrderItem(
                            //                     order: model.myOrders[index],
                            //                     onRefresh: refreshMyOrders,
                            //                   )));
                            //     }),
//
//
//
//
                            ListView(children: [
                              Column(
                                children: List.generate(
                                  model.myOrders!.length,
                                      (index) {
                                    List<ProductItem> groceryOrders = [];
                                    List<ProductItem> warehouseOrders = [];
                                    List<ProductItem> supplierOrders = [];

                                    groceryOrders = model
                                        .myOrders![index].lineItems
                                        .where((i) =>
                                    i.delivery_from == "Grocery" ||
                                        i.delivery_from == null)
                                        .toList();
                                    warehouseOrders = model
                                        .myOrders![index].lineItems
                                        .where((i) =>
                                    i.delivery_from == "Warehouse")
                                        .toList();
                                    supplierOrders = model
                                        .myOrders![index].lineItems
                                        .where((i) =>
                                    i.delivery_from == "Supplier")
                                        .toList();

                                    /*
                                  latest edit
                                      model.myOrders[index].lineItems
                                          .forEach((element) {
                                        if (model.myOrders[index].increment_id ==
                                            "57000000199") {
                                          print("-------------------");
                                          print(element.delivery_from);
                                          print(element.productId);
                                          print(element.name);
                                          print("-------------------");
                                        }
                                        if (element.delivery_from == "Grocery") {
                                          groceryOrders.add(element);
                                        } else if (element.delivery_from ==
                                            "Warehouse") {
                                          if (model
                                                  .myOrders[index].increment_id ==
                                              "57000000199") {
                                            print(
                                                "-----_____________________________--------");
                                            print(element.delivery_from);
                                            print(element.productId);
                                            print(element.name);
                                            print("-------------------");
                                          }
                                          warehouseOrders.add(element);
                                        } else if (element.delivery_from ==
                                            "Supplier") {
                                          supplierOrders.add(element);
                                        } else {
                                          groceryOrders.add(element);
                                        }
                                      });
                                      print("==================");
                                      print(warehouseOrders.length);
                                      print(supplierOrders.length);
                                      print(groceryOrders.length);
                                      print("==================");

                                      */

                                    /* return Column(children: [
                                        OrderItem(
                                          fromWhere: widget.fromWhere,
                                          order: model.myOrders[index],
                                          lineItem: groceryOrders,
                                          onRefresh: refreshMyOrders,
                                        ),
                                        Column(
                                            children: List.generate(
                                                warehouseOrders.length, (index) {
                                          return OrderItem(
                                            fromWhere: widget.fromWhere,
                                            order: model.myOrders[index],
                                            lineItem: [warehouseOrders[index]],
                                            onRefresh: refreshMyOrders,
                                          );
                                          // Text(warehouseOrders[index].name);
                                        })),
                                        Column(
                                            children: List.generate(
                                                supplierOrders.length, (index) {
                                          return OrderItem(
                                            fromWhere: widget.fromWhere,
                                            order: model.myOrders[index],
                                            lineItem: [supplierOrders[index]],
                                            onRefresh: refreshMyOrders,
                                          );
                                          // Text(warehouseOrders[index].name);
                                        }))
                                      ]);*/
                                    return Column(children: [
                                      OrderItem(
                                        productType: "Grocery",
                                        fromWhere: widget.fromWhere,
                                        order: model.myOrders![index],
                                        lineItem: groceryOrders,
                                        onRefresh: refreshMyOrders,
                                      ),
                                      Column(
                                          children: List.generate(
                                              warehouseOrders.length, (i) {
                                            return OrderItem(
                                              productType: "Warehouse",
                                              fromWhere: widget.fromWhere,
                                              order: model.myOrders![index],
                                              lineItem: [warehouseOrders[i]],
                                              onRefresh: refreshMyOrders,
                                            );
                                            // Text(warehouseOrders[index].name);
                                          })),
                                      Column(
                                          children: List.generate(
                                              supplierOrders.length, (i) {
                                            return OrderItem(
                                              productType: "Supplier",
                                              fromWhere: widget.fromWhere,
                                              order: model.myOrders![index],
                                              lineItem: [supplierOrders[i]],
                                              onRefresh: refreshMyOrders,
                                            );
                                            // Text(warehouseOrders[index].name);
                                          }))
                                    ]);
                                  },
                                ),
                              ),
                            ],
                                controller: _scrollController),

                            //
                            //     ListView(
                            //   children: [
                            //     ExpansionTile(
                            //         title: Text('Supplier'),
                            //         onExpansionChanged: (e) {
                            //           print(groceryOrders.length);
                            //         },
                            //         children: List.generate(
                            //             supplierOrders.length,
                            //             (index) => OrderItem(
                            //                   order: model.myOrders[index],
                            //                   onRefresh: refreshMyOrders,
                            //                 ))),
                            //     ExpansionTile(
                            //       title: Text('Grocery'),
                            //       children: List.generate(
                            //           groceryOrders.length,
                            //           (index) => OrderItem(
                            //                 order: model.myOrders[index],
                            //                 onRefresh: refreshMyOrders,
                            //               )),
                            //     ),
                            //     ExpansionTile(
                            //         title: Text('Warehouse'),
                            //         children: List.generate(
                            //             warehouseOrders.length,
                            //             (index) => OrderItem(
                            //                   order: model.myOrders[index],
                            //                   onRefresh: refreshMyOrders,
                            //                 ))),
                            //   ],
                            // ),
                          ),
                        )
                      ],
                    ),
                    model.isLoading
                        ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.black.withOpacity(0.2),
                      child: Center(
                        child: kLoadingWidget(context),
                      ),
                    )
                        : Container()
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  void refreshMyOrders() {
    Provider.of<OrderModel>(context, listen: false)
        .getMyOrder(userModel: Provider.of<UserModel>(context, listen: false),
        lang: Provider.of<AppModel>(context, listen: false).langCode ?? "en");
  }

  cardPay(context, order) async {
    print(order.status);
    print(order.id);
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
    print(urlMap);
    try {
      var cardDetails =
          Provider.of<PaymentMethodModel>(context, listen: false).cardDetails;
      print("card details $cardDetails");
      WebViewController webController = WebViewController();
      webController
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) async {
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
                          content:
                          const Text("Your payment was not successful!!"),
                          actions: <Widget>[
                            TextButton(
                              child: Text(
                                S.of(context).ok,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
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
                Navigator.of(context).pop();
              }
              if (request.url.contains(urlMap['cancelUrl'])) {
                // widget.onLoading(false);
                // isPaying = false;
                Navigator.of(context).pop();
              }
              return NavigationDecision.navigate;
            }
        ))
        ..loadRequest(Uri.parse(urlMap['paymentUrl']));
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WillPopScope(
              onWillPop: () async {
                // widget.onLoading(false);
                // isPaying = false;
                return true;
              },
              child: WebViewWidget(controller: webController)
          ),
        ),
      );
    } catch (e) {
      // widget.onLoading(false);
      // isPaying = false;
      print("exception $e");
      print("starting delete cart");

      return Tools.showSnackBar(
          ScaffoldMessenger.of(context), 'Unable to process the request');
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
}

class OrderItem extends StatefulWidget {
  final Order? order;
  final String? type;
  final String? productType;
  final String? fromWhere;
  final List<ProductItem>? lineItem;
  final VoidCallback? onRefresh;

  OrderItem(
      {this.order,
      this.productType,
      this.onRefresh,
      this.type,
      this.lineItem,
      this.fromWhere});

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool showReturn = false;
  noteFunction(id) async {
    final langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
    String apiUrl = "https://up.ctown.jo/api/timeduration.php";
    String payment_text = "";
    Map body = {"order_id": widget.order!.id};

    var response =
    await http.post(Uri.parse(apiUrl), body: json.encode(body));

    var responseBody = json.decode(response.body);
    if(response.statusCode == 200) {
      if(langCode == "en") {
        payment_text = "Note : You have to finish the payment of the order within ${responseBody['data'][0]["minutes"]} minutes orelse the order will be cancelled";
      }
      else {
        payment_text = "ملاحظة: يجب عليك إتمام عملية الدفع خلال 15 دقيقة وإلا سيتم إلغاء الطلب.";
      }
      SharedPreferences prefs =
      await SharedPreferences.getInstance();

      await prefs.setString("note_${widget.order!.id}", payment_text);

      widget.order!.notes = payment_text;
    }
    else {
      if(langCode == "en") {
        payment_text = "Note : You have to finish the payment of the order within 15 minutes orelse the order will be cancelled";
      }
      else {
        payment_text = "ملاحظة: يجب عليك إتمام عملية الدفع خلال 15 دقيقة وإلا سيتم إلغاء الطلب.";
      }
    }

    return payment_text;
  }

//

  getInvoice({orderId}) async {
    String apiUrl = "https://up.ctown.jo/api/mobileinvoice.php";
    Map body = {"order_id": orderId};
    print(jsonEncode(body));
    var response = await http.post(Uri.parse(apiUrl), body: jsonEncode(body));
    var responseBody;
    if (response.statusCode == 200) {
      print(response.body);
      responseBody = jsonDecode(response.body);
      return responseBody;
    } else {
      responseBody = null;
    }
    return responseBody;
  }

  ordersubstatus() async {
    var elements = [
      "a",
      "b",
      "c",
      "d",
      "e",
      "a",
      "b",
      "c",
      "f",
      "g",
      "h",
      "h",
      "h",
      "e"
    ];
    var map = Map();

    elements.forEach((x) => map[x] = !map.containsKey(x) ? (1) : (map[x] + 1));

    print(map);
  }

  String? text;
  ordersubsteatus() async {
    var mainStatus = widget.order!.status;
    var elements = [];
    for (var i in widget.lineItem!) {
      print("${widget.order!.increment_id}$elements${i.product_type}");
      if (i.product_type == 'simple') {
        if (i.delivery_from == 'Grocery' ||
            i.delivery_from == 'Supplier' ||
            i.delivery_from == 'Warehouse') {
          widget.lineItem!.forEach((element) {
            if (element.product_type == "simple") {
              elements.add(element.sub_status == 'Order Placed' &&
                      mainStatus == 'processing'
                  ? 'processing'
                  : element.sub_status);
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
        print(stCheck);

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

      var request = await httpClient.getUrl(Uri.parse(myUrl!));

      var response = await request.close();

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
        // Map<Permission, PermissionStatus> permission = await [
        //   Permission.storage,
        // ].request();
        // print(permission[Permission.storage]);
        // print(permission);
        if(Platform.isAndroid) {
          var deviceInfo = await DeviceInfoPlugin().androidInfo;
          printLog(deviceInfo);
          if(deviceInfo.version.sdkInt < 29) {
            var status = await Permission.storage.status;
            if (!status.isGranted) {
              await Permission.manageExternalStorage.request();
            }
          }
        }
        filePath = '$dir/$fileName.pdf';
        file = File(filePath);
        await file.writeAsBytes(bytes);
      } else {
        filePath = 'Error code: ' + response.statusCode.toString();
        return "error code";
      }
    } catch (ex) {
      filePath = 'Can not fetch url';
      return "file system exception";
    }

    return filePath;
  }

  Future<File> viewFile({required String url, String? fileName}) async {
    HttpClient httpClient = HttpClient();
    File file;
    var request = await httpClient.getUrl(Uri.parse(url));

    var response = await request.close();

    var bytes;
    if (response.statusCode == 200) {
      bytes = await consolidateHttpClientResponseBytes(response);
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/$fileName.pdf");
      var invoice = await file.writeAsBytes(bytes);

      return invoice;
    } else {
      return Future.error('error');
    }
    // return file;
  }

//

//

  checkIfReturn() async {
    String apiUrl = "https://up.ctown.jo/api/return_days_check.php";
    // Map body = {"order_id": widget.order.id};
    Map body = {"order_id": widget.order!.id, "order_type": widget.productType};
    var response = await http.post(Uri.parse(apiUrl), body: jsonEncode(body));
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      // print(responseBody);
      if (responseBody["success"] == "1") {
        return true;
      }
    }

    return false;
  }

  @override
  void initState() {
    // TODO: implement initState
    checkIfReturn();
    //  ordersubstatus();
    super.initState();
  }
  
  onfinish(order) {
    Provider.of<CartModel>(context, listen: false).clearCart();
  }

  @override
  Widget build(BuildContext context) {
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    double total = 0.0;
    final langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
    getTotal() {
      widget.lineItem!.forEach((element) {
        total += element.price! * double.parse(element.quantity.toString());
      });
    }

    getTotal();
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            if (widget.order!.statusUrl != null) {
              launch(widget.order!.statusUrl!);
            } else {
              widget.order!.lineItems.forEach((element) {});
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OrderDetail(
                          lineItem: widget.lineItem,
                          fromWhere: widget.fromWhere,
                          order: widget.order,
                          productType: widget.productType,
                          onRefresh: widget.onRefresh,
                        )),
              );
              // print(widget.order.status);
            }
          },
          child: Container(
            height: 40,
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(3)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("#${widget.order!.increment_id}",
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold)),
                const Icon(Icons.arrow_right),
              ],
            ),
          ),
        ),
        widget.lineItem!.length == 1
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(Provider.of<AppModel>(context, listen: false).langCode == "en" ? "Product : " :"الاصناف:"),
                    const SizedBox(
                      width: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: List.generate(
                          widget.lineItem!.length,
                          (index) => Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                widget.lineItem![index].total != '0'
                                    ? widget.lineItem![index].name!
                                    : '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              ))), // Expanded(
                      //     child: Text(
                      //   order.paymentMethodTitle,
                      //   style: const TextStyle(fontWeight: FontWeight.bold),
                      //   textAlign: TextAlign.right,
                      // ))
                    ),
                  ],
                ),
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(Provider.of<AppModel>(context, listen: false).langCode == "en" ? "Products : " : "الاصناف:"),
                    const SizedBox(
                      width: 15,
                    ),
                    Column(
                      // mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(
                          widget.lineItem!.length,
                          (index) => Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                widget.lineItem![index].total != '0'
                                    ? widget.lineItem![index].name!
                                    : '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              ))), // Expanded(
                      //     child: Text(
                      //   order.paymentMethodTitle,
                      //   style: const TextStyle(fontWeight: FontWeight.bold),
                      //   textAlign: TextAlign.right,
                      // ))
                    ),
                  ],
                ),
              ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(S.of(context).orderDate),
              Text(
                DateFormat("dd/MM/yyyy").format(widget.order!.createdAt!),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        // if (widget.order.status != null)
        //   Padding(
        //     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: <Widget>[
        //         Text(S.of(context).status),
        //         Text(
        //           widget.order.status == 'canceled'
        //               ? "Canceled"
        //               : widget.order.status == 'ngenius_authorised'
        //                   ? 'Payment Authorised'
        //                   : widget.order.status == 'processing'
        //                       ? "Processing"
        //                       : widget.order.status == 'endpicking'
        //                           ? 'End picking'
        //                           : widget.order.status == 'actionrequired'
        //                               ? "Action Required"
        //                               : widget.order.status == 'delivered'
        //                                   ? 'Delivered'
        //                                   : widget.order.status == 'ontheway'
        //                                       ? "On The Way"
        //                                       : widget.order.status ==
        //                                               "order_placed"
        //                                           ? "Order Placed"
        //                                           : widget.order.status,

        //           // widget.order.status.toUpperCase(),
        //           style: TextStyle(
        //               color: kOrderStatusColor[widget.order.status] != null
        //                   ? HexColor(kOrderStatusColor[widget.order.status])
        //                   : Theme.of(context).accentColor,
        //               fontWeight: FontWeight.bold),
        //         )
        //       ],
        //     ),
        //   ),
        //

        if (widget.order!.status != null)
          FutureBuilder(
              future: getInvoice(orderId: widget.order!.id),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(S.of(context).status),
                          if (snapshot.data["success"] == 1)
                            Container(
                              // width: 155,
                              // color: Colors.red,
                              child: Row(
                                // mainAxisAlignment:
                                //     MainAxisAlignment.spaceBetween,
                                children: [
                                  //
                                  InkWell(
                                    onTap: () async {
                                      String invoiceUrl = "";
                                      try{
                                        EasyLoading.instance
                                          ..loadingStyle = EasyLoadingStyle.custom
                                          ..backgroundColor = Colors.transparent
                                          ..indicatorColor = Colors.transparent
                                          ..dismissOnTap = false
                                          ..textColor = Colors.transparent
                                          ..boxShadow = []
                                          ..userInteractions = false;
                                        await EasyLoading.show(
                                            indicator: SpinKitCubeGrid(
                                                color: Theme.of(context).primaryColor,
                                                size: 30.0),
                                            maskType: EasyLoadingMaskType.black);
                                        var invoice = await getInvoice(orderId: widget.order?.id);
                                        if(invoice != null) {
                                          invoiceUrl = invoice["data"];
                                        }
                                      }
                                      catch(e) {
                                        printLog(e.toString());
                                      }
                                      finally {
                                        EasyLoading.dismiss();
                                      }
                                      showModalBottomSheet(
                                        isScrollControlled: true,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(12))),
                                        context: context,
                                        builder: (context) {
                                          return FutureBuilder(
                                              future: viewFile(
                                                  url: invoiceUrl,
                                                  fileName:
                                                      "Invoice_${widget.order!.id}"),
                                              builder: (context, AsyncSnapshot snapshot) {
                                                // if (snapshot
                                                //     .hasError) {
                                                //   return Container(
                                                //       height: MediaQuery.of(context).size.height * 0.9,
                                                //       child: Center(child: Text('Could not generate invoice at this time')));
                                                // }
                                                if (snapshot.data == null) {
                                                  return Center(
                                                      child:
                                                          CircularProgressIndicator());
                                                }
                                                return Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.9,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40)),
                                                  child: PdfPreview(
                                                    build: (format) => snapshot
                                                        .data
                                                        .readAsBytes(), // _generatePdf(format, "this is test page"),
                                                  ),
                                                );
                                              });
                                        },
                                      );
                                    },
                                    child: Icon(Icons.print_rounded),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      if(Platform.isAndroid) {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: kLoadingWidget,
                                        );
                                        String invoiceUrl = "";
                                        var invoice = await getInvoice(orderId: widget.order?.id);
                                        if(invoice != null) {
                                          invoiceUrl = invoice["data"];
                                        }
                                        String result = await downloadFile(
                                            url: invoiceUrl,
                                            fileName:
                                            "Invoice_${widget.order!.id}",
                                            dir: "/storage/emulated/0/Download");
                                        Navigator.of(context, rootNavigator: true)
                                            .pop();
                                        if (result
                                            .contains("/storage/emulated/0/")) {
                                          SnackBar snackbar = SnackBar(
                                            content: Text(
                                                "Invoice is saved successfully in this location $result"),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackbar);
                                        } else {
                                          SnackBar snackbar = SnackBar(
                                            content: Text(
                                                "Something went wrong..please try again"),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackbar);
                                        }
                                      }
                                      else if(Platform.isIOS) {
                                        try {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: kLoadingWidget,
                                          );
                                          String invoiceUrl = "";
                                          var invoice = await getInvoice(orderId: widget.order?.id);
                                          if(invoice != null) {
                                            invoiceUrl = invoice["data"];
                                          }
                                          var downloadDir = await getApplicationDocumentsDirectory();
                                          HttpClient httpClient = HttpClient();
                                          File file;
                                          String filePath = '${downloadDir.path}/invoice_${widget.order?.id}.pdf';
                                          String myUrl = invoiceUrl;
                                          var request = await httpClient.getUrl(Uri.parse(myUrl));

                                          var response = await request.close();
                                          if(response.statusCode == 200) {
                                            var bytes = await consolidateHttpClientResponseBytes(response);
                                            file = File(filePath);
                                            await file.writeAsBytes(bytes);
                                            SnackBar snackbar = SnackBar(
                                              content: Text(
                                                  "Invoice is saved to Files/Ctown"),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackbar);
                                          }
                                        }
                                        catch(e) {
                                          printLog(e.toString());
                                        }
                                        finally {
                                          Navigator.of(context, rootNavigator: true).pop();
                                        }
                                      }
                                    },
                                    child: Icon(Icons.download_outlined),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  FutureBuilder(
                                      future: ordersubsteatus(),
                                      builder: (context, index) {
                                        return snapshot.data != null ? Text(
                                          text!.capitalize(),
                                          style: TextStyle(
                                              color: kOrderStatusColor[widget
                                                  .order!.status] !=
                                                  null
                                                  ? HexColor(
                                                  kOrderStatusColor[widget
                                                      .order!.status])
                                                  : Theme.of(context)
                                                  .colorScheme.secondary,
                                              fontWeight: FontWeight.bold),
                                        ) :const SizedBox.shrink();
                                      })
                                ],
                              ),
                            ),
                          if (snapshot.data["success"] == 0)
                            FutureBuilder(
                                future: ordersubsteatus(),
                                builder: (context, index) {
                                  return snapshot.data != null ?Text(
                                    text?.capitalize() ?? "",
                                    style: TextStyle(
                                        color: kOrderStatusColor[
                                        widget.order!.status] !=
                                            null
                                            ? HexColor(kOrderStatusColor[
                                        widget.order!.status])
                                            : Theme.of(context).colorScheme.secondary,
                                        fontWeight: FontWeight.bold),
                                  ) :SizedBox.shrink();
                                })
                          // Text(text == null ? 'Order Placed' : text,   style: TextStyle(
                          //               color: kOrderStatusColor[
                          //                           widget.order.status] !=
                          //                       null
                          //                   ? HexColor(kOrderStatusColor[
                          //                       widget.order.status])
                          //                   : Theme.of(context).accentColor,
                          //               fontWeight: FontWeight.bold),
                          //         )
                          // FutureBuilder(
                          //     future: orderstatus(
                          //         widget.lineItem[0].order_status_id),
                          //     builder: (context, snapshot) {
                          //       if (snapshot.data != null) {
                          //         if (snapshot.data["success"] == 1) {
                          //           return Text(
                          //             snapshot.data['data'][0]['status'] !=
                          //                     null
                          //                 ? snapshot.data['data'][0]['status']
                          //                 : '',
                          //             style: TextStyle(
                          //                 color: kOrderStatusColor[
                          //                             widget.order.status] !=
                          //                         null
                          //                     ? HexColor(kOrderStatusColor[
                          //                         widget.order.status])
                          //                     : Theme.of(context).accentColor,
                          //                 fontWeight: FontWeight.bold),
                          //           );
                          //         }
                          //       } else {
                          //         return Container();
                          //       }
                          //     })
                        ],
                      ));
                } else {
                  return Container();
                }
              }),

//
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(S.of(context).paymentMethod),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                  child: Text(
                widget.order!.paymentMethodTitle == "cashondelivery"
                    ? "Cash On Delivery"
                    : widget.order!.paymentMethodTitle!.contains("hosted") ? "Online Payment"
                    :widget.order!.paymentMethodTitle!,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(S.of(context).total1),
              Text(
                Tools.getCurrencyFormatted(widget.order!.total, currencyRate)!,
                // Tools.getCurrencyFormatted(total, currencyRate),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        if (widget.order!.mobile_payment_verify == 0.toString() &&
            widget.order!.paymentMethodTitle == 'tns_hosted')
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  "Note:-Please wait 1 Minute Your Payment is Processing",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

        const SizedBox(height: 20),

        widget.order!.status == "pending"
            ? FutureBuilder(
                future: noteFunction(widget.order!.id),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Text(snapshot.data));
                  }

                  return Container();
                })
            : Container(),

        //

        //
        widget.order!.status == "pending"
            ? Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <
                        Widget>[
                  ElevatedButton(
                      onPressed: () async {
                        String apiUrl = "https://up.ctown.jo/api/timeduration.php";
                        Map body = {"order_id": widget.order!.id};

                        var response =
                            await http.post(Uri.parse(apiUrl), body: json.encode(body));

                        var responseBody = json.decode(response.body);

                        if (response.statusCode == 200) {
                          setState(() {});
                          await showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                              top: Radius.circular(40),
                              //bottom: Radius.circular(80),
                            )),
                            builder: (context) => Container(
                                height: 150,
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.wysiwyg_rounded),
                                      title: Text(langCode == "en"? "Cash/Visa on Delivery" : "الدفع نقداً/فيزا عند التوصيل"),
                                      onTap: () async {
                                        print("cash on delivery");
                                        String? response = await MagentoApi()
                                            .updatePaymentMethod(
                                                widget.order!.id);
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
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackbar);

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
                                      title: Text(langCode == "en" ? "Pay now (Credit/Debit card)" : "الدفع الان (بواسطة البطاقة الائتمانية)"),
                                      onTap: () async {
                                        // print(widget.order!.id);
                                        // await cardPay(context, widget.order);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PaymentWebView(
                                                      isPaying2: false,
                                                      newOrder: widget.order,
                                                      onFinish: onfinish(widget.order),
                                                      url:
                                                      "${serverConfig['url']}/api/tnspaymentgatewaymobile.php?order_id=${widget.order!.id}&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}",
                                                    )));
                                      },
                                    ),
                                  ],
                                )),
                          );
                        } else {
                          SnackBar snackBar =
                              SnackBar(content: Text('Error during updating'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                      ),
                      child: Text(
                        langCode == "en" ?'Re-initiate Payment' : "اعادة طريقة الدفع",
                        style: TextStyle(color: Colors.white),
                      ))
                ]))
            : Container(),

        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <
              Widget>[
                FutureBuilder(
                  future: ordersubsteatus(),
                  builder: (context, snapshot) {
                    final langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
                    return snapshot.data != null && text == "delivered" ?
                    ElevatedButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: kLoadingWidget,
                          );
                          var result =
                          await MagentoApi().reorderFunction(widget.order!.id);

                          if (result["success"] == 1) {
                            Navigator.of(context, rootNavigator: true).pop();
                            CartModel cartModel =
                            Provider.of<CartModel>(context, listen: false);
                            var cookie =
                            Provider.of<UserModel>(context, listen: false).user !=
                                null
                                ? Provider.of<UserModel>(context, listen: false)
                                .user!
                                .cookie
                                : null;
                            if (cookie != null) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: kLoadingWidget,
                              );
                              await Services()
                                  .widget?.syncCartFromWebsite(cookie, cartModel, context, Provider.of<AppModel>(context, listen: false)
                                  .langCode ?? "en");
                              Navigator.of(context, rootNavigator: true).pop();
                            }

                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            // builder: (context) => MyCart(isReorder: true)));
                            MainTabControlDelegate.getInstance().tabAnimateTo(3);
                          } else {
                            Navigator.of(context, rootNavigator: true).pop();
                            SnackBar snackbar =
                            SnackBar(content: Text(result["message"]));
                            ScaffoldMessenger.of(context).showSnackBar(snackbar);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0)),
                        ),
                        child: Text(
                          langCode == "en" ? 'Re-Order' : "اعادة الطلب",
                          style: TextStyle(color: Colors.white),
                        )) : SizedBox.shrink();
                  },
                ),
            if (widget.order!.status == "delivered")
              SizedBox(
                width: 20,
              ),
            FutureBuilder(
                future: checkIfReturn(),
                builder: (context, snapshot) {
                  final langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
                  if (snapshot.data == null) {
                    return Container();
                    //  Center(child:CircularProgressIndicator());
                  }

                  return snapshot.data == true
                      ? ElevatedButton(
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReturnPolicy(
                                    orderId: int.parse(widget.order!.id!),
                                  ),
                                ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(20.0)),
                          ),
                          child: Text(
                            langCode == "en"? 'Return Order' : "إرجاع الطلب",
                            style: TextStyle(color: Colors.white),
                          ))
                      : Container();
                }),
          ]),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  cardPay(context, order) async {

    try {
      String apiUrl = "https://up.ctown.jo/api/repay.php";
      Map body = {};
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
        "paymentUrl": body['data']['_links']['payment']['href'],
        "redirectUrl": body['data']['merchantAttributes']['redirectUrl'],
        "cancelUrl": body['data']['merchantAttributes']['cancelUrl']
      };
      var cardDetails =
          Provider.of<PaymentMethodModel>(context, listen: false).cardDetails;
      print("card details $cardDetails");

      WebViewController controller = WebViewController();
      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(urlMap['paymentUrl']))
        ..setNavigationDelegate(NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
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
                        content:
                        const Text("Your payment was not successful!!"),
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                              S.of(context).ok,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
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
            return NavigationDecision.navigate;
          },
        ));
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WillPopScope(
              onWillPop: () async {
                // widget.onLoading(false);
                // isPaying = false;
                return true;
              },
              child: WebViewWidget(controller: controller,)
          ),
        ),
      );
    } catch (e) {
      // widget.onLoading(false);
      // isPaying = false;
      print("exception $e");
      print("starting delete cart");

      return Tools.showSnackBar(
          ScaffoldMessenger.of(context), 'Unable to process the request');
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
}
