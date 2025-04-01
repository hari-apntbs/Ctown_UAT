import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app.dart';
import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../frameworks/magento/services/magento.dart';
import '../../generated/l10n.dart';
import '../../models/entities/address.dart';
import '../../models/entities/coupon.dart';
import '../../models/index.dart'
    show AppModel, CartModel, Coupons, Product, UserModel, WishListModel;
import '../../services/index.dart';
import '../../tabbar.dart';
import '../../values/radii.dart';
import '../../values/values.dart';
import '../../widgets/appbar.dart';
import '../../widgets/home/clickandcollect_provider.dart';
import '../../widgets/product/cart_item.dart';
import '../../widgets/product/product_bottom_sheet.dart';
import '../index.dart';
import '../settings/address_book.dart';
import 'address_selector_widget.dart';
import 'cartProvider.dart';
import 'cart_sumary.dart';
import 'empty_cart.dart';
import 'wishlist.dart';

class TimeSlot {
  String? date;
  List<Time>? time;

  TimeSlot({this.date, this.time});

  // TimeSlot.fromJson(Map<String, dynamic> json) {
  //   date = json['date'];
  //   if (json['time'] != null) {
  //     time = List<Time>();
  //     json['time'].forEach((v) {
  //       time.add(Time.fromJson(v));
  //     });
  //   }
  // }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = Map<String, dynamic>();
  //   data['date'] = date;
  //   if (time != null) {
  //     data['time'] = time.map((v) => v.toJson()).toList();
  //   }
  //   return data;
  // }
}

class Time {
  String? id;
  String? timeSlt;
  bool? active;

  Time({this.id, this.timeSlt, this.active});

  // Time.fromJson(Map<String, dynamic> json) {
  //   id = json['id'];
  //   timeSlt = json['start_time'];
  //   active = json['active'];
  // }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = Map<String, dynamic>();
  //   data['id'] = id;
  //   data['start_time'] = timeSlt;
  //   data['active'] = active;
  //   return data;
  // }
}

class MyCart extends StatefulWidget {
  final PageController? controller;
  final bool? isModal;
  final bool? isBuyNow;
  final bool isReorder;

  MyCart(
      {this.controller,
      this.isModal,
      this.isBuyNow = false,
      this.isReorder = false});

  @override
  _MyCartState createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> with SingleTickerProviderStateMixin {
  bool isLoading = false;
  String errMsg = '';
  List<TimeSlot>? data;
  int selectedIndex = -1;
  int selecteddate = -1;
  String? userselectedDate;
  String? userselectedTime;
  DateTime now = DateTime.now();
  int? _minCartOrderValue = -1;
  List<Address> listAddress = [];
  String cartId = "";
  String userToken = "";

  final services = Services();
  Coupons? coupons;
  bool _enable = true;
  bool _loading = false;
  Map<String, dynamic>? defaultCurrency =
      kAdvanceConfig['DefaultCurrency'] as Map<String, dynamic>?;
  double _magentoDiscountAmount = 0.0;
  double _grandTotal = 0.0;
  late RefreshController _controller;

  Future<void> getCoupon() async {
    try {
      coupons = await services.getCoupons();
    } catch (e) {
//      print(e.toString());
    }
  }

  void showError(String message) {
    setState(() => _loading = false);
    final snackBar = SnackBar(
      content: Text(S.of(context).warning(message)),
      duration: const Duration(seconds: 10),
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {},
      ),
    );
    // ignore: deprecated_member_use
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Check coupon code
  void checkCoupon(String couponCode, CartModel model) {
    if (couponCode.isEmpty) {
      showError(S.of(context).pleaseFillCode);
      return;
    }

    setState(() => _loading = true);

    Services().widget?.applyCoupon(context, coupons: coupons, code: couponCode,
        success: (Discount discount) async {
      await model.updateDiscount(discount: discount);
      showError(S.of(context).couponMsgSuccess);
      setState(() {
        _enable = false;
        _loading = false;
      });
    }, error: showError);
  }

  ///
  late CartProvider cartprovider;
  final ScrollController _controllerOne = ScrollController();
  double? _lastScrollPosition;
  @override
  void initState() {
    super.initState();
    _controller = RefreshController();
    Provider.of<ClickNCollectProvider>(context, listen: false)
        .initializeTypeAndStoreId();
    _getMinOrderValue();
    _controllerOne.addListener(() {
      // Save scroll position when it changes
      _lastScrollPosition = _controllerOne.offset;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerOne.dispose();
    super.dispose();
  }

  Future<void> getAddress() async {
    var user = Provider.of<UserModel>(context, listen: false).user;
    if (user != null) {
      final result = await Services().getCustomerInfo(user.id, user.cookie,
          Provider.of<AppModel>(context, listen: false).langCode ?? "en");
      if (result != null && result['addresses'] != null) {
        for (var address in result['addresses']) {
          final add = Address.fromMagentoJson(Map.from(address));
          if (!listAddress.contains(add)) {
            listAddress.add(add);
          }
        }
      }
      printLog("My test15");
      printLog(listAddress);
      printLog(listAddress.length);
    }
  }

  _getMinOrderValue() async {
    final LocalStorage storage = LocalStorage('store');
    final userJson = await storage.getItem(kLocalKey["userInfo"]!);
    if (userJson != null) {
      String token = userJson["cookie"];
      String qoute = await MagentoApi().getQuoteId(
          token: token,
          lang: Provider.of<AppModel>(context, listen: false).langCode ?? "en");
      cartId = qoute;
      userToken = token;
      await MagentoApi().getMinimumOrderValue(qoute).then(
            (value) => value == -1
                ? _minCartOrderValue = kCartDetail['minAllowTotalCartValue']
                : _minCartOrderValue = value,
          );
    }
  }

  Future<List<TimeSlot>?> loadData() async {
    if (data != null) {
      return data;
    }
    try {
      Time time;
      TimeSlot timeSlot;
      data = [];
      final res =
          await http.get(Uri.parse('https://up.ctown.jo/api/grocery_slot.php'));
      printLog("final res ${res.body}");
      // printLog(res.body);
      List response = jsonDecode(res.body)['data'];
      for (int i = 0; i < response.length; i++) {
        List<Time> timeList = [];

        for (int j = 0; j < response[i]['time'].length; j++) {
          if (response[i]['time'][j]['type'] == "enabled") {
            var slot = response[i]['time'][j]['start_time'] +
                '-' +
                response[i]['time'][j]['end_time'];
            time = Time(
              id: response[i]['time'][j]['id'],
              timeSlt: slot,
              active: true,
            );
          } else {
            var slot = response[i]['time'][j]['start_time'] +
                '-' +
                response[i]['time'][j]['end_time'];
            time = Time(
              id: response[i]['time'][j]['id'],
              timeSlt: slot,
              active: false,
            );
          }
          if (time.active!) timeList.add(time);
        }
        timeSlot = TimeSlot(
          date: response[i]['date'],
          time: timeList,
        );

        data!.add(timeSlot);
      }
      setState(() {});
    } catch (e) {
      throw Exception(e.toString());
    }
    return data;
  }

  List<Widget> _createShoppingCartRows(CartModel model, BuildContext context) {
    printLog("Available qty array");
    printLog(cartprovider.avail_qty);
    printLog(cartprovider.avail_qty.length);
    if (cartprovider.avail_qty.length > 0) {
      List<String?> productIds = [];
      // CartProvider cartProvider =
      //     Provider.of<CartProvider>(context, listen: false);
      // var productIds = cartProvider.productIds;
      var swap_var;
      for (int counter = 0;
          counter < cartprovider.avail_qty.length - 1;
          counter++) {
        for (int counter1 = 0;
            counter1 < cartprovider.avail_qty.length - counter - 1;
            counter1++) {
          if (cartprovider.avail_qty[counter1]["qty"] >
              cartprovider.avail_qty[counter1 + 1]
                  ["qty"]) /* For decreasing order use < */
          {
            swap_var = cartprovider.avail_qty[counter1];
            cartprovider.avail_qty[counter1] =
                cartprovider.avail_qty[counter1 + 1];
            cartprovider.avail_qty[counter1 + 1] = swap_var;
          }
        }
      }
      print(
          "===============================================\n========================");
      print(cartprovider.avail_qty);
      cartprovider.avail_qty.forEach((element) {
        productIds.add(element["product_id"]);
      });

      return productIds.map(
        (key) {
          String? availableQuantity;
          String? message;
          String? message1;
          cartprovider.avail_qty.forEach((element) {
            if (element["product_id"] == key) {
              availableQuantity = element["qty"].toString();
              message = element["message"];
              message1 = element["message1"];
              //  break;
            }
          });
          // (cartprovider.avail_qty.length>0)
          String productId = Product.cleanProductID(key);
          Product product = model.getProductById(productId);
          return ShoppingCartRow(
            product: product,
            variation: model.getProductVariationById(key),
            quantity: model.productsInCart[key],
            options: model.productsMetaDataInCart[key],
            lang:
                Provider.of<AppModel>(context, listen: false).langCode ?? "en",
            data: {
              "qty": availableQuantity,
              "message": message,
              "message1": message1
            },
            onRemove: () async {
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
                      color: Theme.of(context).primaryColor, size: 30.0),
                  maskType: EasyLoadingMaskType.black);
              await model.removeItemFromCart(key, context);
              EasyLoading.dismiss();
            },
            onChangeQuantity: (val) async {
              String message =
                  await Provider.of<CartModel>(context, listen: false)
                      .updateQuantity(product, key, val, context: context);
              if (message.isNotEmpty) {
                final snackBar = SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 1),
                );
                Future.delayed(
                    const Duration(milliseconds: 300),
                    // ignore: deprecated_member_use
                    () => ScaffoldMessenger.of(context).showSnackBar(snackBar));
              }
              Future.delayed(const Duration(seconds: 2), () async {
                getDiscountsIfAny();
                /*await Services().widget.syncCartFromWebsite(
                    Provider.of<UserModel>(context, listen: false).user != null
                        ? Provider.of<UserModel>(context, listen: false)
                            .user
                            .cookie
                        : null,
                    Provider.of<CartModel>(context),
                    context);*/
              });
            },
          );
        },
      ).toList();
    }
//
    return model.productsInCart.keys.map(
      (key) {
        // (cartprovider.avail_qty.length>0)
        String productId = Product.cleanProductID(key);
        Product product = model.getProductById(productId);
        // print("product   key $key   ${product.name}");
        // print(model.productsInCart[key]);
        // print("=====");
        return ShoppingCartRow(
            product: product,
            variation: model.getProductVariationById(key),
            quantity: model.productsInCart[key],
            options: model.productsMetaDataInCart[key],
            lang:
                Provider.of<AppModel>(context, listen: false).langCode ?? "en",
            onRemove: () async {
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
                      color: Theme.of(context).primaryColor, size: 30.0),
                  maskType: EasyLoadingMaskType.black);
              await model.removeItemFromCart(key, context);
              EasyLoading.dismiss();
            },
            onChangeQuantity: (val) async {
              String message =
                  await Provider.of<CartModel>(context, listen: false)
                      .updateQuantity(product, key, val, context: context);
              print("message $message");
              Future.delayed(const Duration(seconds: 6), () async {
                getDiscountsIfAny();
                /*await Services().widget.syncCartFromWebsite(
                    Provider.of<UserModel>(context, listen: false).user != null
                        ? Provider.of<UserModel>(context, listen: false)
                            .user
                            .cookie
                        : null,
                    Provider.of<CartModel>(context),
                    context);*/
              });
              return message;
              //  final snackBar = SnackBar(
              //             content: Text(
              //               message
              //             ),
              //             duration: const Duration(seconds: 1),
              //           );

              //              Scaffold.of(context).showSnackBar(snackBar);

              // }

              // Navigator.pop(context);
              // if (message.isNotEmpty) {
              //   final snackBar = SnackBar(
              //     content: Text(
              //       'sdffffg'
              //     ),
              //     duration: const Duration(seconds: 1),
              //   );
              //   Future.delayed(
              //       const Duration(milliseconds: 300),
              //       // ignore: deprecated_member_use
              //       () => Scaffold.of(context).showSnackBar(snackBar));

              // }
            });
      },
    ).toList();
  }

  final itemSize = 100.0;
  _loginWithResult(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          fromCart: true,
        ),
        fullscreenDialog: kIsWeb,
      ),
    );

    if (result != null && result.name != null) {
      Tools.showSnackBar(ScaffoldMessenger.of(context),
          S.of(context).welcome + " ${result.name} !");

      setState(() {});
    }
  }

  getDiscountsIfAny() async {
    final cartmodel = Provider.of<CartModel>(context, listen: false).address;
    String url =
        "https://up.ctown.jo/rest/V1/carts/mine/payment-information?address_id=${cartmodel?.id}&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}";
    final LocalStorage storage = LocalStorage('store');
    final userJson = await storage.getItem(kLocalKey["userInfo"]!);
    if (userJson != null) {
      print("usertoken");
      print(userJson["cookie"]);
      printLog("csdgfghjasfdxcvf");
      printLog(url);
      var response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer ' + userJson["cookie"],
      });
      print(userJson["cookie"]);
      if (response.statusCode == 200) {
        print("====================");
        var data = jsonDecode(response.body);
        print(data["totals"]["grand_total"]);
        print(data["totals"]["discount_amount"]);
        Provider.of<CartProvider>(context, listen: false).setMagentoDiscount(
            double.parse(data["totals"]["discount_amount"].toString()));
        Provider.of<CartProvider>(context, listen: false).setCartGrandTotal(
            double.parse(data["totals"]["grand_total"].toString()));
        Provider.of<CartProvider>(context, listen: false).setBaseSubTotal(
            double.parse(data["totals"]["base_subtotal"].toString()));
      }
    }
    // model.getTotal({data["totals"]["discount_amount"]});
  }

  getDiscounts() async {
    final cartmodel = Provider.of<CartModel>(context, listen: false).address;
    String url =
        "https://up.ctown.jo/rest/V1/carts/mine/payment-information?address_id=${cartmodel?.id}&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}";
    final LocalStorage storage = LocalStorage('store');
    final userJson = await storage.getItem(kLocalKey["userInfo"]!);
    print("usertoken");
    print(userJson["cookie"]);
    print(userJson["cookie"]);
    var response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ' + userJson["cookie"],
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      return {
        "grandTotal": data["totals"]["grand_total"],
        "discount": data["totals"]["discount_amount"]
      };
    }
  }

  Future<void> _onScrollsToTop(ScrollsToTopEvent event) async {
    _controllerOne.animateTo(0,
        duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    printLog("[Cart] build");
    final localTheme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    CartModel cartModel = Provider.of<CartModel>(context,listen: false);
    var cookie = Provider.of<UserModel>(context, listen: false).user?.cookie;
    cartprovider = Provider.of<CartProvider>(context);

    return SmartRefresher(
        controller: _controller,
        onRefresh: () async {
          if (cookie != null) {
            await Services().widget?.syncCartFromWebsite(
                cookie,
                cartModel,
                context,
                Provider.of<AppModel>(context, listen: false).langCode ?? "en");
            selectedIndex = -1;
            selecteddate = -1;
            userselectedTime = null;
            userselectedDate = null;
          }
          selectedIndex = -1;
          selecteddate = -1;
          userselectedTime = null;
          userselectedDate = null;
          _controller.refreshCompleted();
          cartModel.refreshCart(false);
        },
        child: Platform.isIOS
            ? ScrollsToTop(
                onScrollsToTop: _onScrollsToTop,
                child: Scaffold(
                  floatingActionButton: FloatingActionButton.extended(
                    onPressed: cartModel.calculatingDiscount
                        ? null
                        : () async {
                      try {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: kLoadingWidget,
                        );
                        getDiscountsIfAny();
                        await getAddress();
                        await onCheckout(cartModel);
                      }
                      catch(e) {
                        printLog(e.toString());
                      }
                      finally {
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                    },
                    isExtended: true,
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    icon: const Icon(Icons.payment, size: 20),
                    label: cartModel.totalCartQuantity > 0
                        ? (isLoading
                        ? Text(S.of(context).loading.toUpperCase())

                        : Text(S.of(context).checkout.toUpperCase()))
                        : Text(
                      S.of(context).startShopping.toUpperCase(),
                    ),
                  ),
                  floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
                  appBar: Platform.isAndroid ? AppBar(
                    automaticallyImplyLeading: false,
                    titleSpacing: 0,
                    title: Container(
                      height: 45,
                      child: AppLocal(
                        scanBarcode: "Search",
                      ),
                    ),
                  ) : AppBar(
                    automaticallyImplyLeading: false,
                    titleSpacing: 0,
                    title: Container(
                      padding: const EdgeInsets.only(top: 4),
                      height: 55,
                      width: double.infinity,
                      color: Theme.of(context).primaryColor,
                      child: AppLocal2(
                        scanBarcode: "Search",
                      ),
                    ),
                  ),

                  body:
                  FutureBuilder(
                    future: loadData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Consumer<CartModel>(
                        builder: (context, model, child) {
                          if (_lastScrollPosition != null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _controllerOne.jumpTo(_lastScrollPosition!);
                            });
                          }
                          return GestureDetector(
                            onTap: () {
                              FocusScopeNode currentFocus =
                              FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                            },
                            child: Container(
                              height: screenSize.height - 80,
                              width: screenSize.width,
                              child: SingleChildScrollView(
                                controller: _controllerOne,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 80.0),
                                  child: Column(
                                    children: [
                                      if (_controller.headerStatus != RefreshStatus.refreshing)
                                        const AddressSelectorWidget(true),
                                      model.totalCartQuantity > 0 ? Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width *
                                                0.8,
                                            height:
                                            70, //MediaQuery.of(context).size.height * 0.1,
                                            decoration: const BoxDecoration(
                                              borderRadius:
                                              Radii.k5pxRadius,
                                            ),
                                            margin: const EdgeInsets.only(
                                                left: 2, top: 15, right: 0),
                                            child: Center(
                                              child:
                                              ListView.builder(
                                                  scrollDirection:
                                                  Axis.horizontal,
                                                  itemCount:
                                                  data!.length,
                                                  itemBuilder:
                                                      (context, i) {
                                                    String deliveryDate =  DateFormat('dd MMM', 'en')
                                                        .format(DateTime.parse(data![i].date ?? ""));
                                                    return Column(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(
                                                                    () {
                                                                  selectedIndex =
                                                                      i;
                                                                  printLog(
                                                                      "testing date");
                                                                  printLog(
                                                                      userselectedDate);
                                                                });
                                                          },
                                                          child: Center(
                                                            child: Card(
                                                              shape: RoundedRectangleBorder(
                                                                  side: BorderSide(
                                                                    color: selectedIndex != i
                                                                        ? Colors.white
                                                                        : Colors.red,
                                                                  ),
                                                                  borderRadius: BorderRadius.circular(10.0)),
                                                              color: selectedIndex != i
                                                                  ? Colors
                                                                  .white
                                                                  : Colors
                                                                  .red,
                                                              child:
                                                              Container(
                                                                padding:
                                                                const EdgeInsets.all(8),
                                                                margin: const EdgeInsets.only(
                                                                    left:
                                                                    0),
                                                                decoration: const BoxDecoration(),
                                                                child:
                                                                Container(
                                                                  width: MediaQuery.of(context).size.width * 0.2,
                                                                  child:
                                                                  Column(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment.spaceAround,
                                                                    children: [
                                                                      Center(
                                                                        child: FittedBox(
                                                                          child: Text(
                                                                            DateFormat('EEEE').format(DateTime.parse(data![i].date!)),
                                                                            style: TextStyle(
                                                                                color: selectedIndex != i ? Colors.black : Colors.white,
                                                                                height: 1.5,
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Center(
                                                                        child: FittedBox(
                                                                          child: Directionality(
                                                                            textDirection: ui.TextDirection.ltr,
                                                                            child: Text(deliveryDate,
                                                                              style: TextStyle(
                                                                                  color: selectedIndex != i ? Colors.black : Colors.white,
                                                                                  height: 1.5,
                                                                                  fontWeight: FontWeight.bold),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                            ),
                                          ),
                                          selectedIndex == -1
                                              ? Container()
                                              : data![selectedIndex]
                                              .time!
                                              .length <=
                                              0 ? Container(
                                              height: MediaQuery.of(
                                                  context)
                                                  .size
                                                  .height *
                                                  0.05,
                                              child: const Text(
                                                  "No slots Available"))
                                              : Container(
                                              height: MediaQuery.of(
                                                  context)
                                                  .size
                                                  .height *
                                                  0.06,
                                              child:
                                              ListView.builder(
                                                  scrollDirection: Axis
                                                      .horizontal,
                                                  itemCount: data![
                                                  selectedIndex]
                                                      .time!
                                                      .length, //getTime(selectedIndex).length,
                                                  itemBuilder:
                                                      (context,
                                                      index) {
                                                    bool isActive = data![
                                                    selectedIndex]
                                                        .time![
                                                    index]
                                                        .active!;
                                                    return GestureDetector(
                                                      onTap: isActive
                                                          ? () {
                                                        selecteddate = index;
                                                        _updateItemDeliveryDateTime(model);
                                                        setState(() {});
                                                      }
                                                          : null,
                                                      child:
                                                      Center(
                                                        child:
                                                        Card(
                                                          shape: RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                color: isActive
                                                                    ? selecteddate != index
                                                                    ? Colors.white
                                                                    : Colors.red
                                                                    : Colors.grey,
                                                              ),
                                                              borderRadius: BorderRadius.circular(10.0)),
                                                          color: isActive
                                                              ? selecteddate != index
                                                              ? Colors.white
                                                              : Colors.red
                                                              : Colors.grey,
                                                          child: Container(
                                                              padding: const EdgeInsets.all(5),
                                                              margin: const EdgeInsets.only(left: 5),
                                                              decoration: const BoxDecoration(),
                                                              child: Container(
                                                                  width: MediaQuery.of(context).size.width / 2,
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons.access_time_outlined,
                                                                        color: isActive
                                                                            ? selecteddate != index
                                                                            ? Colors.black
                                                                            : Colors.white
                                                                            : Colors.black,
                                                                      ),
                                                                      Expanded(
                                                                          child: Text(
                                                                            data![selectedIndex].time![index].timeSlt!,
                                                                            style: TextStyle(
                                                                              fontSize: 13.0,
                                                                              color: isActive
                                                                                  ? selecteddate != index
                                                                                  ? Colors.black
                                                                                  : Colors.white
                                                                                  : Colors.black,
                                                                            ),
                                                                            textDirection: ui.TextDirection.ltr,
                                                                            textAlign: TextAlign.center,
                                                                          ))
                                                                    ],
                                                                  ))),
                                                        ),
                                                      ),
                                                    );
                                                  }))
                                        ],
                                      )
                                          : Container(),
                                      if (model.totalCartQuantity > 0)
                                        Container(
                                          margin:
                                          const EdgeInsets.only(top: 10.0),
                                          decoration: BoxDecoration(
                                              color:
                                              Theme.of(context).primaryColor),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 15.0, top: 4.0),
                                            child: Container(
                                              width: screenSize.width,
                                              child: Container(
                                                width: screenSize.width /
                                                    (2 /
                                                        (screenSize.height /
                                                            screenSize.width)),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const SizedBox(
                                                      width: 25.0,
                                                    ),
                                                    Provider.of<AppModel>(context, listen: false).langCode == "en" ?
                                                    Text(
                                                      S.of(context)
                                                          .total
                                                          .toUpperCase(),
                                                      style: localTheme
                                                          .textTheme.titleMedium!
                                                          .copyWith(
                                                          fontWeight:
                                                          FontWeight.w600,
                                                          color: Colors.white,
                                                          fontSize: 14),
                                                    ) : const SizedBox.shrink(),
                                                    const SizedBox(width: 8.0),
                                                    Provider.of<AppModel>(context, listen: false).langCode == "en" ?
                                                    Text(
                                                      '${model.totalCartQuantity} ${S.of(context).items}',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold
                                                        // fontFamily: 'raleway',
                                                      ),
                                                    ) : Text(
                                                      '${S.of(context).items} ${model.totalCartQuantity}',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold
                                                        // fontFamily: 'raleway',
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                25.0),
                                                            side: const BorderSide(
                                                                color: Colors.white)),
                                                        backgroundColor: Colors.white,
                                                        foregroundColor: Colors.white,
                                                        elevation: 0.1,
                                                      ),
                                                      child: Text(
                                                        S.of(context).clearCart.toUpperCase(),
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                context)
                                                                .primaryColor,
                                                            fontSize: 12),
                                                      ),
                                                      onPressed: () async {
                                                        // await getDiscountsIfAny();
                                                        await showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                AlertDialog(
                                                                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                                                  title: Text(Provider.of<AppModel>(context, listen: false).langCode ==
                                                                      'en'
                                                                      ? "Are You Sure "
                                                                      : "هل أنت متأكد"),
                                                                  content: Text(Provider.of<AppModel>(context, listen: false).langCode ==
                                                                      'en'
                                                                      ? "Do you want to clear cart"
                                                                      : 'هل تريد مسح عربة التسوق'),
                                                                  actions: <Widget>[
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context).pop(false);
                                                                      },
                                                                      child:
                                                                      Text(S.of(context).no),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () async {
                                                                        print("cart cleared");
                                                                        final LocalStorage storage = LocalStorage('store');
                                                                        final userJson = await storage.getItem(kLocalKey["userInfo"]!);
                                                                        final langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "";

                                                                        try {
                                                                          showDialog(
                                                                            barrierDismissible: false,
                                                                            context: context,
                                                                            builder: kLoadingWidget,
                                                                          );
                                                                          var result = await MagentoApi().clearCart(token: userJson["cookie"], lang: langCode);
                                                                          if (result) {
                                                                            model.clearCart();
                                                                          }
                                                                        } catch (e) {
                                                                          model.clearCart();
                                                                          printLog(e.toString());
                                                                        } finally {
                                                                          Navigator.of(context, rootNavigator: true).pop();
                                                                        }
                                                                        Navigator.of(context).pop(true);
                                                                      },
                                                                      child:
                                                                      Text(S.of(context).yes),
                                                                    ),
                                                                  ],
                                                                ));
                                                      },
                                                    ),
                                                    const SizedBox(width: 10,)
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (model.totalCartQuantity > 0)
                                        const Divider(
                                          height: 1,
                                          indent: 25,
                                        ),
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          const SizedBox(height: 16.0),
                                          if (model.totalCartQuantity > 0)
                                            Column(
                                              children: _createShoppingCartRows(
                                                  model, context),
                                            ),
                                          if (model.totalCartQuantity > 0)
                                            ShoppingCartSummary(
                                              model: model,
                                              couponselected: userselectedDate,
                                            ),
                                          if (model.totalCartQuantity == 0 && !model.refreshing && _controller.headerStatus !=
                                              RefreshStatus.refreshing)
                                            EmptyCart(),
                                          if(model.refreshing)
                                            const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          if (errMsg.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 15, vertical: 10),
                                              child: Text(
                                                errMsg,
                                                style: const TextStyle(
                                                    color: Colors.red),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          const SizedBox(height: 4.0),
                                          WishList()
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // ),
                ),
              )
            : Scaffold(
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: cartModel.calculatingDiscount
                      ? null
                      : () async {
                    try {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: kLoadingWidget,
                      );
                      getDiscountsIfAny();
                      await getAddress();
                      await onCheckout(cartModel);
                    }
                    catch(e) {
                      printLog(e.toString());
                    }
                    finally {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                        },
                  isExtended: true,
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  icon: const Icon(Icons.payment, size: 20),
                  label: cartModel.totalCartQuantity > 0
                      ? (isLoading
                          ? Text(S.of(context).loading.toUpperCase())
                          : Text(S.of(context).checkout.toUpperCase()))
                      : Text(
                          S.of(context).startShopping.toUpperCase(),
                        ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                appBar: Platform.isAndroid
                    ? AppBar(
                        //  Colors.white,
                        automaticallyImplyLeading: false,
                        titleSpacing: 0,
                        title: Container(
                          height: 45,
                          child: AppLocal(
                              scanBarcode: "Search",
                          ),
                  ),
                      )
                    : AppBar(
                        automaticallyImplyLeading: false,
                        titleSpacing: 0,
                        title: Container(
                          padding: const EdgeInsets.only(top: 4),
                          height: 55,
                          width: double.infinity,
                          color: Theme.of(context).primaryColor,
                          child: AppLocal2(
                            scanBarcode: "Search",
                          ),
                        ),
                      ),


                body: FutureBuilder(
                  future: loadData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Consumer<CartModel>(
                      builder: (context, model, child) {
                        if (_lastScrollPosition != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _controllerOne.jumpTo(_lastScrollPosition!);
                          });
                        }
                        return GestureDetector(
                          onTap: () {
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                          },
                          child: Container(
                            height: screenSize.height - 80,
                            width: screenSize.width,
                            child: SingleChildScrollView(
                              controller: _controllerOne,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 80.0),
                                child: Column(
                                  children: [
                                    if (_controller.headerStatus !=
                                        RefreshStatus.refreshing)
                                      const AddressSelectorWidget(true),
                                    model.totalCartQuantity > 0
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                height:
                                                    70, //MediaQuery.of(context).size.height * 0.1,
                                                decoration: const BoxDecoration(
                                                  borderRadius:
                                                      Radii.k5pxRadius,
                                                ),
                                                margin: const EdgeInsets.only(
                                                    left: 2, top: 15, right: 0),
                                                child: Center(
                                                  child:
                                                      ListView.builder(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount:
                                                              data!.length,
                                                          itemBuilder:
                                                              (context, i) {
                                                                String deliveryDate = DateFormat('dd MMM', 'en')
                                                                    .format(DateTime.parse(data![i].date ?? ""));
                                                            return Column(
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      selectedIndex =
                                                                          i;
                                                                      printLog(
                                                                          "testing date");
                                                                      printLog(
                                                                          userselectedDate);
                                                                    });
                                                                  },
                                                                  child: Center(
                                                                    child: Card(
                                                                      shape: RoundedRectangleBorder(
                                                                          side: BorderSide(
                                                                            color: selectedIndex != i
                                                                                ? Colors.white
                                                                                : Colors.red,
                                                                          ),
                                                                          borderRadius: BorderRadius.circular(10.0)),
                                                                      color: selectedIndex != i
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .red,
                                                                      child:
                                                                          Container(
                                                                        padding:
                                                                            const EdgeInsets.all(8),
                                                                        margin: const EdgeInsets.only(
                                                                            left:
                                                                                0),
                                                                        decoration: const BoxDecoration(),
                                                                        child:
                                                                        Container(
                                                                          width: MediaQuery.of(context).size.width * 0.2,
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceAround,
                                                                            children: [
                                                                              Center(
                                                                                child: FittedBox(
                                                                                  child: Text(
                                                                                    DateFormat('EEEE').format(DateTime.parse(data![i].date!)),
                                                                                    style: TextStyle(
                                                                                        color: selectedIndex != i ? Colors.black : Colors.white,
                                                                                        height: 1.5,
                                                                                        fontSize: 14,
                                                                                        // fontFamily: 'raleway',
                                                                                        fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Center(
                                                                                child: FittedBox(
                                                                                  child: Directionality(
                                                                                    textDirection: ui.TextDirection.ltr,
                                                                                    child: Text(
                                                                                      deliveryDate,
                                                                                      style: TextStyle(
                                                                                          color: selectedIndex != i ? Colors.black : Colors.white,
                                                                                          height: 1.5,
                                                                                          fontSize: 14,
                                                                                          // fontFamily: 'raleway',
                                                                                          fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          }),
                                                ),
                                              ),
                                              selectedIndex == -1
                                                  ? Container()
                                                  : data![selectedIndex]
                                                              .time!
                                                              .length <=
                                                          0
                                                      ? Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.05,
                                                          child: const Text(
                                                              "No slots Available"))
                                                      : Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.06,
                                                          child:
                                                              ListView.builder(
                                                                  //  gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
                                                                  scrollDirection: Axis
                                                                      .horizontal,
                                                                  itemCount: data![
                                                                          selectedIndex]
                                                                      .time!
                                                                      .length, //getTime(selectedIndex).length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    bool isActive = data![
                                                                            selectedIndex]
                                                                        .time![
                                                                            index]
                                                                        .active!;
                                                                    return GestureDetector(
                                                                      onTap: isActive
                                                                          ? () {
                                                                              selecteddate = index;
                                                                              _updateItemDeliveryDateTime(model);
                                                                              setState(() {});
                                                                            }
                                                                          : null,
                                                                      child:
                                                                      Center(
                                                                        child:
                                                                        Card(
                                                                          shape: RoundedRectangleBorder(
                                                                              side: BorderSide(
                                                                                color: isActive
                                                                                    ? selecteddate != index
                                                                                    ? Colors.white
                                                                                    : Colors.red
                                                                                    : Colors.grey,
                                                                              ),
                                                                              borderRadius: BorderRadius.circular(10.0)),
                                                                          color: isActive
                                                                              ? selecteddate != index
                                                                              ? Colors.white
                                                                              : Colors.red
                                                                              : Colors.grey,
                                                                          child: Container(
                                                                              padding: const EdgeInsets.all(5),
                                                                              margin: const EdgeInsets.only(left: 5),
                                                                              decoration: const BoxDecoration(),
                                                                              child: Container(
                                                                                  width: MediaQuery.of(context).size.width / 2,
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Icon(
                                                                                        Icons.access_time_outlined,
                                                                                        color: isActive
                                                                                            ? selecteddate != index
                                                                                            ? Colors.black
                                                                                            : Colors.white
                                                                                            : Colors.black,
                                                                                      ),
                                                                                      Expanded(
                                                                                          child: Text(
                                                                                            data![selectedIndex].time![index].timeSlt!,
                                                                                            style: TextStyle(
                                                                                              fontSize: 13.0,
                                                                                              color: isActive
                                                                                                  ? selecteddate != index
                                                                                                  ? Colors.black
                                                                                                  : Colors.white
                                                                                                  : Colors.black,
                                                                                              //  fontSize: MediaQuery.of(context).size.width * 0.001
                                                                                            ),
                                                                                            textDirection: ui.TextDirection.ltr,
                                                                                            textAlign: TextAlign.center,
                                                                                          ))
                                                                                    ],
                                                                                  ))),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }))
                                            ],
                                          )
                                        : Container(),
                                    if (model.totalCartQuantity > 0)
                                      Container(
                                        margin:
                                            const EdgeInsets.only(top: 10.0),
                                        decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 15.0, top: 4.0),
                                          child: Container(
                                            width: screenSize.width,
                                            child: Container(
                                              width: screenSize.width /
                                                  (2 /
                                                      (screenSize.height /
                                                          screenSize.width)),
                                              child: Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 25.0,
                                                  ),
                                                  Provider.of<AppModel>(context, listen: false).langCode == "en" ?
                                                  Text(
                                                    S.of(context)
                                                        .total
                                                        .toUpperCase(),
                                                    style: localTheme
                                                        .textTheme.titleMedium!
                                                        .copyWith(
                                                        fontWeight:
                                                        FontWeight.w600,
                                                        color: Colors.white,
                                                        fontSize: 14),
                                                  ) : const SizedBox.shrink(),
                                                  const SizedBox(width: 8.0),
                                                  Provider.of<AppModel>(context, listen: false).langCode == "en" ?
                                                  Text(
                                                    '${model.totalCartQuantity} ${S.of(context).items}',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold
                                                      // fontFamily: 'raleway',
                                                    ),
                                                  ) : Text(
                                                    '${S.of(context).items} ${model.totalCartQuantity}',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              25.0),
                                                          side: const BorderSide(
                                                              color: Colors.white)),
                                                      backgroundColor: Colors.white,
                                                      foregroundColor: Colors.white,
                                                      elevation: 0.1,
                                                    ),
                                                    child: Text(
                                                      S.of(context)
                                                          .clearCart
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                          color: Theme.of(
                                                              context)
                                                              .primaryColor,
                                                          fontSize: 12),
                                                    ),
                                                    onPressed: () async {
                                                      // await getDiscountsIfAny();
                                                      await showDialog(
                                                          context: context,
                                                          builder:
                                                              (context) =>
                                                              AlertDialog(
                                                                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                                                title: Text(Provider.of<AppModel>(context, listen: false).langCode ==
                                                                    'en'
                                                                    ? "Are You Sure "
                                                                    : "هل أنت متأكد"),
                                                                content: Text(Provider.of<AppModel>(context, listen: false).langCode ==
                                                                    'en'
                                                                    ? "Do you want to clear cart"
                                                                    : 'هل تريد مسح عربة التسوق'),
                                                                actions: <
                                                                    Widget>[
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(context).pop(false);
                                                                    },
                                                                    child:
                                                                    Text(S.of(context).no),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () async {
                                                                      print("cart cleared");
                                                                      final LocalStorage storage = LocalStorage('store');
                                                                      final userJson = await storage.getItem(kLocalKey["userInfo"]!);
                                                                      final langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "";

                                                                      try {
                                                                        showDialog(
                                                                          barrierDismissible: false,
                                                                          context: context,
                                                                          builder: kLoadingWidget,
                                                                        );
                                                                        var result = await MagentoApi().clearCart(token: userJson["cookie"], lang: langCode);
                                                                        if (result) {
                                                                          model.clearCart();
                                                                        }
                                                                      } catch (e) {
                                                                        model.clearCart();
                                                                        printLog(e.toString());
                                                                      } finally {
                                                                        Navigator.of(context, rootNavigator: true).pop();
                                                                      }
                                                                      Navigator.of(context).pop(true);
                                                                    },
                                                                    child:
                                                                    Text(S.of(context).yes),
                                                                  ),
                                                                ],
                                                              ));
                                                    },
                                                  ),
                                                  const SizedBox(width: 10,)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (model.totalCartQuantity > 0)
                                      const Divider(
                                        height: 1,
                                        indent: 25,
                                      ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const SizedBox(height: 16.0),
                                        if (model.totalCartQuantity > 0)
                                          Column(
                                            children: _createShoppingCartRows(
                                                model, context),
                                          ),
                                        if (model.totalCartQuantity > 0)
                                          ShoppingCartSummary(
                                            model: model,
                                            couponselected: userselectedDate,
                                          ),
                                        if (model.totalCartQuantity == 0 && !model.refreshing && _controller.headerStatus !=
                                            RefreshStatus.refreshing)
                                          EmptyCart(),
                                        if(model.refreshing)
                                          const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        if (errMsg.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 10),
                                            child: Text(
                                              errMsg,
                                              style: const TextStyle(
                                                  color: Colors.red),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        const SizedBox(height: 4.0),
                                        WishList()
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                // ),
              ));
  }

  Future onCheckout(CartModel model) async {
    bool isLoggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;
    final currency = Provider.of<AppModel>(context, listen: false).currency;

    if (isLoading) return;
    if (_minCartOrderValue != null) {
      if (_minCartOrderValue.toString().isNotEmpty) {
        double totalValue = model.getSubTotal();
        String? minValue = Tools.getCurrencyFormatted(
            _minCartOrderValue, currencyRate,
            currency: currency);
        if (totalValue < _minCartOrderValue! && model.totalCartQuantity > 0) {
          showFlash(
            context: context,
            duration: const Duration(seconds: 3),
            builder: (context, controller) {
              return SafeArea(
                child: Flash(
                  controller: controller,
                  dismissDirections: [FlashDismissDirection.startToEnd],
                  child: FlashBar(
                    controller: controller,
                    position: FlashPosition.top,
                    backgroundColor: Theme.of(context).colorScheme.error,
                    behavior: FlashBehavior.fixed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    content: Text(
                      Provider.of<AppModel>(context, listen: false).langCode ==
                              'en'
                          ? 'Total order\'s value must be at least $minValue'
                          : "يجب ان لا يقل إجمالي قيمة الطلب عن $minValue",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            },
          );

          return;
        }
      }
    }

    if (model.totalCartQuantity == 0) {
      if (widget.isModal == true) {
        try {
          ExpandingBottomSheet.of(context)!.close();
        } catch (e) {
          await Navigator.of(context).pushNamed(RouteList.dashboard);
        }
      } else {
        MainTabControlDelegate.getInstance().tabAnimateTo(0);
      }
    } else if (isLoggedIn || kPaymentConfig['GuestCheckout'] == true) {
      // if (!(model.address?.isValid() ?? false)) {
      if ((model.address?.state == null)) {
        showFlash(
          context: context,
          duration: const Duration(seconds: 3),
          builder: (context, controller) {
            return SafeArea(
              child: Flash(
                controller: controller,
                dismissDirections: [FlashDismissDirection.startToEnd],
                child: FlashBar(
                  controller: controller,
                  position: FlashPosition.top,
                  backgroundColor: Theme.of(context).colorScheme.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  behavior: FlashBehavior.fixed,
                  icon: const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  content: const Text(
                    'Please select delivery address before proceeding',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          },
        );
        return;
      }

      /// check if delivery slot selected
      // var slotNotSelected = false;
      var slotNotSelected =
          // selectedIndex == null;
          (userselectedDate == null ||
              userselectedTime == null ||
              selectedIndex == -1);
      if (slotNotSelected) {
        showFlash(
          context: context,
          duration: const Duration(seconds: 3),
          builder: (context, controller) {
            return SafeArea(
              child: Flash(
                controller: controller,
                dismissDirections: [FlashDismissDirection.startToEnd],
                child: FlashBar(
                  controller: controller,
                  position: FlashPosition.top,
                  backgroundColor: Theme.of(context).colorScheme.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  behavior: FlashBehavior.fixed,
                  icon: const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  content: Text(
                    Provider.of<AppModel>(context, listen: false).langCode ==
                            "en"
                        ? 'Please select delivery date and time before proceeding'
                        : 'يرجى تحديد التاريخ ووقت التسليم قبل المتابعة.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          },
        );
        return;
      }
      await _updateItemDeliveryDateTime(model);
      await isCartProductsAvailable(context);
    } else {
      _loginWithResult(context);
    }
  }

  getSavedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore') ?? "";
    if (result != "") {
      return jsonDecode(result);
    } else {
      return null;
    }
  }

  Future isCartProductsAvailable(context) async {
    try {
      String lang =
          Provider.of<AppModel>(context, listen: false).langCode ?? "en";
      var store1 = await getSavedStore();
      var storeCode = lang == "en"
          ? store1["store_en"]["code"]
          : store1["store_ar"]["code"];
      // String apiUrl = "https://up.ctown.jo/api/checkstockproduct.php";
      String apiUrl = "https://up.ctown.jo/api/checkstockproduct.php?store_code=$storeCode&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}";
      // String apiUrl = "https://up.ctown.jo/api/test/checkstockproducttest.php";
      // String apiUrl = "https://up.ctown.jo/api/checkstockproduct.php?store_code=$storeCode&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}";
      Map body = {"item": []};
      String a = "2334-1234";
      String result = "";
      if (a.contains("-")) {
        result = a.split("-")[0];
      }
      CartModel cartModel = Provider.of<CartModel>(context, listen: false);
      var cookie = Provider.of<UserModel>(context, listen: false).user != null
          ? Provider.of<UserModel>(context, listen: false).user!.cookie
          : null;

      cartModel.productsInCart.forEach((k, v) => body["item"].add(
          {"product_id": k!.contains("-") ? k.split("-")[1] : k, "qty": v}));

      print(json.encode(body));
      //// body={"product_id":["24740","27700"]};
      var response =
          await http.post(Uri.parse(apiUrl), body: json.encode(body));
      var responseBody = json.decode(response.body);
      print("API RESPONSE");
      // print(cartModel.);
      if (responseBody["success"] == 0) {
        List<dynamic> stockData = responseBody['data'];
        print("OUT OF STOCK PRODUCT");
        await Services().widget?.syncCartFromWebsite(
            cookie!,
            cartModel,
            context,
            Provider.of<AppModel>(context, listen: false).langCode ?? "en");
        if (stockData.isNotEmpty) {
          cartModel.outOfStockItems.clear();
          for (var item in stockData) {
            if (cartModel.productsInCart.keys.contains(item['product_id'])) {
              int qty = cartModel.productsInCart[item['product_id']] ?? 0;
              if (qty > item['qty']) {
                cartModel.addOutOfStock(item['product_id']);
              }
            } else {
              cartModel.addOutOfStock(item['product_id']);
            }
          }
        }
        String message = responseBody["message_en"];
        if(lang == "en") {
          message = responseBody["message_en"];
        }
        else {
          message = responseBody["message_ar"];
        }
        SnackBar snackbar = SnackBar(content: Text(message));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      } else {
        deleteDuplicateProducts(context);
        print("checkout");
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  Future deleteDuplicateProducts(context) async {
    try {
      String quoteId =
          "${Provider.of<CartModel>(context, listen: false).cartId}";
      String apiUrl = "https://up.ctown.jo/api/checkoutvalidation.php";
      Map body = {"item": [], "quote_id": quoteId, "token": "$userToken"};
      String a = "2334-1234";
      String result = "";
      if (a.contains("-")) {
        result = a.split("-")[0];
      }
      CartModel cartModel = Provider.of<CartModel>(context, listen: false);
      var cookie = Provider.of<UserModel>(context, listen: false).user != null
          ? Provider.of<UserModel>(context, listen: false).user!.cookie
          : null;

      cartModel.productsInCart.forEach((k, v) => body["item"].add(
          {"product_id": k!.contains("-") ? k.split("-")[1] : k, "qty": v}));

      print(json.encode(body));
      //// body={"product_id":["24740","27700"]};
      if (quoteId != "") {
        var response =
            await http.post(Uri.parse(apiUrl), body: json.encode(body));
        var responseBody = json.decode(response.body);
        print("API RESPONSE");
        // print(cartModel.);

        if (responseBody["success"] == 0) {
          List<dynamic> stockData = responseBody['data'];
          print("OUT OF STOCK PRODUCT");
          await Services().widget?.syncCartFromWebsite(
              cookie!,
              cartModel,
              context,
              Provider.of<AppModel>(context, listen: false).langCode ?? "en");
          if (stockData.isNotEmpty) {
            cartModel.outOfStockItems.clear();
            for (var item in stockData) {
              if (cartModel.productsInCart.keys.contains(item['product_id'])) {
                int qty = cartModel.productsInCart[item['product_id']] ?? 0;
                if (qty > item['qty']) {
                  cartModel.addOutOfStock(item['product_id']);
                }
              } else {
                cartModel.addOutOfStock(item['product_id']);
              }
            }
          }
          SnackBar snackbar = SnackBar(content: Text(responseBody["message"]));
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        } else {
          await doCheckout();
          print("checkout");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Something went wrong. Please try again later")));
        printLog("=======quote id is going empty");
      }
    } catch (e) {
      printLog(e.toString());
      showError("Please try again later");
    }
  }

  Future<void> doCheckout() async {
    showLoading();
    var minutes = await MagentoApi().getCheckoutTime();
    await Services().widget?.doCheckout(context, success: () async {
      hideLoading('');
      selectedIndex = -1;
      selecteddate = -1;
      if (listAddress.isNotEmpty) {
        await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => Checkout(
              isModal: true,
              checkoutTimelimit: minutes,
              listAddress: listAddress,
            ),
          ),
        );
      } else {
        await Navigator.push(
            context, MaterialPageRoute(builder: (context) => AddressBook()));
      }
    }, error: (message) async {
      if (message ==
          Exception("Token expired. Please logout then login again")
              .toString()) {
        setState(() {
          isLoading = false;
        });
        //logout
        await Provider.of<WishListModel>(context, listen: false)
            .clearWishList();
        final userModel = Provider.of<UserModel>(context, listen: false);
        final _auth = FirebaseAuth.instance;
        await userModel.logout();
        await _auth.signOut();
        _loginWithResult(context);
      } else {
        hideLoading(message);
        Future.delayed(const Duration(seconds: 3), () {
          setState(() => errMsg = '');
        });
      }
    }, loading: (isLoading) {
      setState(() {
        this.isLoading = isLoading;
      });
    });
  }

  void showLoading() {
    setState(() {
      isLoading = true;
      errMsg = '';
    });
  }

  void hideLoading(error) {
    setState(() {
      isLoading = false;
      errMsg = error;
    });
  }

  myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(),
    );
  }


  String? getSlotId(int i, int j) {
    if (data == null) return null;
    return data![i].time![j].id;
  }

  _updateItemDeliveryDateTime(CartModel model) {
    if (selectedIndex != -1 && selecteddate != -1) {
      userselectedDate = data![selectedIndex].date;
      userselectedTime = data![selectedIndex]
          .time![selecteddate]
          .timeSlt; //getTime(selectedIndex)[selecteddate];

      model.productsInCart.keys.forEach((key) {
        printLog("Selected date cart");

        String productId = Product.cleanProductID(key);
        Product product = model.getProductById(productId);
        if (product.delivery_from == "5453") {
          product.delivery_date = userselectedDate! + " " + userselectedTime!;
          if (product.options == null) {
            product.options = [
              {'slot_id': getSlotId(selectedIndex, selecteddate)}
            ];
          } else {
            bool found = false;
            product.options!.forEach((element) {
              if (element.containsKey('slot_id')) {
                element['slot_id'] = getSlotId(selectedIndex, selecteddate);
                found = true;
              }
            });
            if (!found) {
              product.options!
                  .add({'slot_id': getSlotId(selectedIndex, selecteddate)});
            }
          }

          printLog("usfsdnvsjdfgsdhfgs");
          printLog(product.delivery_date);
        }
      });
    }
  }
}
