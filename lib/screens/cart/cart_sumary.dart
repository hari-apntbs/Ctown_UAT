import 'dart:async';
import 'dart:convert';

import 'package:ctown/common/constants/general.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import "package:http/http.dart" as http;
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../common/config.dart';
import '../../common/constants/colors.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show AppModel, CartModel, Coupons, Discount, UserModel;
import '../../services/index.dart';
import 'point_reward.dart';

class ShoppingCartSummary extends StatefulWidget {
  ShoppingCartSummary({this.model, this.onApplyCoupon, this.couponselected});
  final couponselected;

  final CartModel? model;
  final Function? onApplyCoupon;

  @override
  _ShoppingCartSummaryState createState() => _ShoppingCartSummaryState();
}

class _ShoppingCartSummaryState extends State<ShoppingCartSummary> {
  final services = Services();
  Coupons? coupons;
  bool _enable = true;
  bool _loading = false;
  int selectedIndex = -1;
  Map<String, dynamic>? defaultCurrency = kAdvanceConfig['DefaultCurrency'] as Map<String, dynamic>?;
  double magentoDiscountAmount = 0.0;
  double grandTotal = 0.0;
  double subtotal = 0.0;
  double shippingrate = 0.0;
  TextEditingController _loyaltyPointsController = TextEditingController();
  late StreamController _userController;
  FocusNode? _loyaltyNode;
  late UserModel userModel;

  List couponCodes = [];
//   getDiscountsIfAny() async {
//     String url =
//         "https://online.ajmanmarkets.ae/rest/V1/carts/mine/payment-information";
//     print(url);
//     final LocalStorage storage = LocalStorage('store');
//     final userJson = storage.getItem(kLocalKey["userInfo"]);

//     print("cookie");
//     print(userJson["cookie"]);
//     var response = await http.get(url, headers: {
//       'Authorization': 'Bearer ' + userJson["cookie"],
//     });
//     if (response.statusCode == 200) {
//       print("====================");
//       var data = jsonDecode(response.body);
//       print(data["totals"]["grand_total"]);
//       print(data["totals"]["discount_amount"]);
//       print("shpping cart summary");

//       setState(() {
//         _grandTotal = double.parse(data["totals"]["grand_total"].toString());
//         _magentoDiscountAmount =
//             double.parse(data["totals"]["discount_amount"].toString());
//       });
// /** dfgdfgd
//  dffdf
// */

//       print("magento discount $_magentoDiscountAmount");
//     }
//     return _grandTotal;
//     // model.getTotal({data["totals"]["discount_amount"]});
//   }

  getDiscountsIfAny() async {
    final LocalStorage storage = LocalStorage('store');
    final userJson = await storage.getItem(kLocalKey["userInfo"]!);
    String url =
        "https://up.ctown.jo/rest/V1/carts/mine/payment-information?nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}";
    printLog("ghdfhgsdfgdfgfg");
    printLog(url);
    printLog(userJson["cookie"]);
    var response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ' + userJson["cookie"],
    });
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      grandTotal = double.parse(data["totals"]["grand_total"].toString());
      subtotal = double.parse(data["totals"]["subtotal"].toString());
      shippingrate = double.parse(data["totals"]["shipping_amount"].toString());
      magentoDiscountAmount =
          double.parse(data["totals"]["discount_amount"].toString());
      printLog("fghfjhsfgsdfgdfgh");
      printLog(subtotal);
    }
    // print({"grandTotal": grandTotal, "discount": magentoDiscountAmount});
    return {
      "grandTotal": grandTotal,
      "discount": magentoDiscountAmount,
      'shipping_amount': shippingrate,
      'subtotal': subtotal,
    };
    // model.getTotal({data["totals"]["discount_amount"]});
  }

  loadDetails() async {
    await getDiscountsIfAny().then((res) async {
      _userController.add(res);
      return res;
    });
  }

  couponcode() async {
    try {
      var url =
          "https://up.ctown.jo/api/loyalty_redeemption.php?id=${userModel.user!.id}";
      print(url);
      final LocalStorage storage = LocalStorage('store');
      final userJson = await storage.getItem(kLocalKey["userInfo"]!);
      printLog(userJson["cookie"]);
      printLog("vengadesah");
      if (userJson == null || userJson["cookie"] == null) {
        printLog("Error: Missing user information in storage.");
        return;
      }
      var res = await http.get(Uri.parse(url));
      final response = jsonDecode(res.body);
      if (response["success"] == 1) {
        couponCodes = response["data"];
        return response['data'];
      }
    }
    catch(e) {
      printLog(e.toString());
    }
  }

  Future couponremove() async {
    final LocalStorage storage = LocalStorage('store');
    final userJson = await storage.getItem(kLocalKey["userInfo"]!);
    String apiUrl = "https://up.ctown.jo/api/mobilecoupon.php";
    Map body = {"id": userModel.user!.id, "token": userJson["cookie"]};
    print(userJson["cookie"]);
    var response = await http.post(Uri.parse(apiUrl), body: jsonEncode(body));

    print(response.statusCode);
    print(userModel.user!.id);
    if (response.statusCode == 200) {
      print("print1");
      await loadDetails();
      return true;
    }
    print("sasa");
    return false;
  }

  redeemLoyalty() async {
    final LocalStorage storage = LocalStorage('store');
    final userJson = await storage.getItem(kLocalKey["userInfo"]!);
    String cartQuoteUrl = "https://up.ctown.jo/index.php/rest/V1/carts/mine";
    var res = await http.get(Uri.parse(cartQuoteUrl),
        headers: {'Authorization': 'Bearer ' + userJson["cookie"]});

    final cartInfo = jsonDecode(res.body);
    print(cartInfo["id"]);
    String url = "https://up.ctown.jo/api/loyalty_redeem.php";
    Map body = {
      "quote_id": cartInfo["id"],
      "grand_total": widget.model!.getTotal(),
      // grandTotal != 0 ? grandTotal : widget.model.getTotal(),
      "discount_amount": double.parse(_loyaltyPointsController.text)
    };
    print(json.encode(body));
    var response = await http.post(Uri.parse(url), body: jsonEncode(body));
    print(response.body);
  }

//
  getLoyalty(String url, id) async {
    Map<String, dynamic> _queryParams = {};
    _queryParams['id'] = id;
    print("user id");
    print(_queryParams);
    var uri = Uri(
      scheme: 'https',
      host: 'ahmarket.com',
      path: '/api/getloyalty.php',
      fragment: 'baz',
      queryParameters: _queryParams,
    );

    var res = await http.get(uri);
    var responseBody;
    if (res.statusCode == 200) {
      responseBody = jsonDecode(res.body);
      print("getting loyalty");
      print(responseBody);
      return responseBody;
    }
    return responseBody;
  }

  @override
  void initState() {
    super.initState();
    if (widget.model!.couponObj != null && widget.model!.couponObj!.amount! > 0) {
      _enable = false;
    }
    getCoupon();
    _loyaltyNode = FocusNode();
    _userController = StreamController.broadcast();
    loadDetails();
    printLog("discounts if any run");
  }

  @override
  void dispose() {
    // _userController.close();R
    _userController.close();
    super.dispose();
  }

  Future<void> getCoupon() async {
    try {
      coupons = await services.getCoupons();
    } catch (e) {
//      print(e.toString());
    }
  }

  void showErrorMsg(String message, bool error) {
    showFlash(
      context: context,
      duration: const Duration(milliseconds: 2500),
      builder: (context, controller) {
        return Flash(
          controller: controller,
          position: FlashPosition.bottom,
          dismissDirections: [FlashDismissDirection.endToStart],
          child: FlashBar(
            controller: controller,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0)
            ),
            behavior: FlashBehavior.floating,
            backgroundColor: error ? Theme.of(context).primaryColor : Colors.white,
            title: const SizedBox.shrink(),
            content: Text(
              message,
              style: TextStyle(
                color: error ? Colors.white : Theme.of(context).primaryColor,
                fontSize: 15.0,
              ),
            ),
          ),
        );
      },
    );
  }

  void showError(String message) {
    FocusScope.of(context).unfocus;
    setState(() => _loading = false);
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 10),
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {},
      ),
    );
    // ignore: deprecated_member_use
    ScaffoldMessenger.of(App.navigatorKey.currentState!.context).showSnackBar(snackBar);
  }

  /// Check coupon code
  void checkCoupon(String couponCode) {
    if (couponCode.isEmpty) {
      showErrorMsg(S.of(context).pleaseFillCode, true);
      return;
    }

    setState(() => _loading = true);

    Services().widget?.applyCoupon(context, coupons: coupons, code: couponCode,
        success: (Discount discount) async {
      await widget.model!.updateDiscount(discount: discount);
      await loadDetails();
      showErrorMsg(S.of(context).couponMsgSuccess, false);
      setState(() {
        _enable = false;
        _loading = false;
      });
    }, error: showError);
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<AppModel>(context).currency;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final smallAmountStyle = TextStyle(color: Theme.of(context).colorScheme.secondary);
    final largeAmountStyle =
        TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 16);
    // final formatter =
    //     NumberFormat.currency(symbol: defaultCurrency['symbol'], decimalDigits: defaultCurrency['decimalDigits']);
    final couponController = TextEditingController();

    //String couponMsg = S.of(context).couponMsgSuccess;
    // if (widget.model.couponObj != null) {
    //   if (widget.model.couponObj.discountType == "percent") {
    //     couponMsg += "${widget.model.couponObj.amount}%";
    //   } else {
    //     couponMsg += " - ${formatter.format(widget.model.couponObj.amount)}";
    //   }
    // }
    final screenSize = MediaQuery.of(context).size;
    userModel = Provider.of<UserModel>(context, listen: false);
    return userModel.loggedIn
        ? Container(
            width: screenSize.width,
            child: Container(
              width: screenSize.width /
                  (2 / (screenSize.height / screenSize.width)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (kAdvanceConfig['EnableCouponCode'] as bool? ?? true)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(
                                  top: 20.0, bottom: 20.0),
                              decoration: _enable
                                  ? BoxDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor)
                                  : const BoxDecoration(
                                      color: Color(0xFFF1F2F3)),
                              child: TextField(
                                controller: couponController,
                                enabled: _enable && !_loading,
                                decoration: InputDecoration(
                                    labelText: _enable
                                        ? S.of(context).couponCode
                                        : widget.model!.couponObj!.code,
                                    labelStyle: TextStyle(color: _enable ? Colors.grey : Colors.black),
                                    //hintStyle: TextStyle(color: _enable ? Colors.grey : Colors.black),
                                    contentPadding: const EdgeInsets.all(2)),
                              ),
                            ),
                          ),
                          Container(
                            width: 10,
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: const BorderSide(
                                      color:kGrey200)),
                              elevation: 0.0,
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              foregroundColor: Theme.of(context).primaryColor,
                            ),
                            label: Text(
                                _loading || widget.model!.calculatingDiscount
                                    ? S.of(context).loading
                                    : _enable
                                        ? S.of(context).apply
                                        : S.of(context).remove),
                            icon: const Icon(
                              FontAwesomeIcons.clipboardCheck,
                              size: 15,
                            ),
                            onPressed: !widget.model!.calculatingDiscount
                                ? () {
                                    if (_enable) {
                                      String message = "";
                                      String lanCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
                                      if(lanCode == "en") {
                                        message = "You don’t have a voucher yet! Please proceed to checkout.";
                                      }
                                      else {
                                        message = "لا يوجد لديك قسيمة حتى الآن! يرجى المتابعة إلى إتمام الشراء.";
                                      }
                                      if(widget.couponselected == null) {
                                        showErrorMsg(message, true);
                                      }
                                      else {
                                        if(couponCodes.isEmpty) {
                                          showErrorMsg(message, true);
                                        }
                                        else {
                                          bool valid = couponCodes.any((element) => element["voucherBarcode"] == couponController.text);
                                          if(valid) {
                                            checkCoupon(couponController.text);
                                            Future.delayed(const Duration(seconds: 2),
                                                loadDetails);
                                          }
                                          else {
                                            showErrorMsg(message, true);
                                          }
                                        }
                                      }
                                    } else {
                                      couponremove();
                                      Future.delayed(const Duration(seconds: 1),
                                          loadDetails);
                                      showErrorMsg(S.of(context).couponcode, false);
                                      setState(() {
                                        couponremove();
                                        _enable = true;
                                        widget.model!.resetCoupon();
                                        widget.model!.discountAmount = 0.0;
                                        selectedIndex = -1;
                                      });
                                    }
                                  }
                                : null,
                          )
                        ],
                      ),
                    ),
                  PointReward(model: widget.model),
                  if (widget.couponselected != null)
                    FutureBuilder(
                        future: couponcode(),
                        builder: (context, AsyncSnapshot snapshot) {
                          final langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
                          List liveCoupons = [];
                          if (snapshot.data != null) {
                            liveCoupons = snapshot.data.where((element) => DateTime.parse(element['expiryDate']).isAfter(DateTime.now())).toList();
                            print("voucherBarceeeode");

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    width: screenSize.width * 1,
                                    height: screenSize.height * 0.05,
                                    color: Theme.of(context).primaryColor,

                                    // padding: EdgeInsets.all(10),
                                    child: Container(
                                        margin: EdgeInsets.only(left: 20),
                                        child: Center(
                                            child: Text(
                                              langCode == "en"? "Apply Promo Code" : "تطبيق القسيمة",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        )))),
                                const SizedBox(height: 10),
                                Container(
                                  height: 100,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      itemCount: liveCoupons.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            print("failuree");
                                            print(liveCoupons[index]
                                                ['voucherBarcode']);
                                            couponController.text = liveCoupons[index]['voucherBarcode'];
                                            setState(() {
                                              if (_enable) {
                                                checkCoupon(liveCoupons[index]
                                                    ['voucherBarcode']);
                                                setState(() {
                                                  selectedIndex = index;
                                                });
                                              }
                                            });
                                          },
                                          child: Stack(
                                            children: [
                                              Container(
                                                  height: 60,
                                                  margin: const EdgeInsets.only(
                                                      right: 25, left: 10),
                                                  // padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      border: Border.all(
                                                          color: Colors.black,
                                                          width: 2)),
                                                  child: selectedIndex != index
                                                      ? Image.asset(
                                                          "assets/images/cupon.png")
                                                      : Image.asset(
                                                          "assets/images/cupon2.png")

                                                  // Center(
                                                  //   child: Text(
                                                  //     snapshot.data[index]
                                                  //             ['voucherBarcode']
                                                  //         .toString(),
                                                  //     style: const TextStyle(
                                                  //         color: Colors.white),
                                                  //   ),
                                                  // )
                                                  ),
                                              //  Positioned(
                                              //   top: 25,
                                              //   left: 60,
                                              //   child: selectedIndex !=index? Text("Flat"):Text("")),
                                              //    Positioned(
                                              //   top: 25,
                                              //   left: 110,
                                              //   child: selectedIndex !=index? Text(
                                              //     snapshot.data[index]
                                              //             ['amount']
                                              //         .toString(),style:TextStyle(
                                              //         color: Colors.white),):Text("")
                                              //   // Text(snapshot.data[index]['amount'].toString())
                                              //   )
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            );
                          }
                          return Container();
                        }),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 15.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(S.of(context).products,
                                      style: smallAmountStyle),
                                ),
                                Text(
                                  "x${widget.model!.totalCartQuantity}",
                                  style: smallAmountStyle,
                                ),
                              ],
                            ),
                            StreamBuilder(
                              stream: _userController.stream,
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.none:
                                    return const Center(
                                      child: Text('None'),
                                    );
                                    break;
                                  case ConnectionState.waiting:
                                    return Column(children: [
                                      const SizedBox(height: 10),
                                      // CircularProgressIndicator()
                                      Row(
                                        children: [
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                print(grandTotal);
                                                print(magentoDiscountAmount);
                                              },
                                              child: Text(
                                                  Provider.of<AppModel>(context,
                                                                  listen: false)
                                                              .langCode ==
                                                          'en'
                                                      ? "Subtotal"
                                                      : 'المجموع',
                                                  style: largeAmountStyle),
                                            ),
                                          ),
                                          widget.model!.calculatingDiscount
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.0,
                                                  ),
                                                )
                                              : Text(
                                                  "${Tools.getCurrencyFormatted((widget.model!.getTotal() - widget.model!.getShippingCost()!), currencyRate, currency: currency)}",

                                                  style: largeAmountStyle,
                                                ),
                                        ],
                                      )
                                    ]);
                                    break;
                                  case ConnectionState.active:
                                    return Center(
                                        child: Column(children: [
                                      if (magentoDiscountAmount < 0)
                                        Column(children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                S.of(context).discount,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .colorScheme.secondary,
                                                ),
                                              ),
                                              Text(
                                                // widget.model.getCoupon(),
                                                "${Tools.getCurrencyFormatted(magentoDiscountAmount, currencyRate, currency: currency)}",
                                                // style: Theme.of(context).textTheme.subtitle1.copyWith(
                                                //       fontSize: 14,
                                                //       color: Theme.of(context).accentColor,
                                                //       fontWeight: FontWeight.w600,
                                                //     ),
                                                style: smallAmountStyle,
                                              )
                                            ],
                                          ),
                                        ]),
                                      if (subtotal != 0.0)
                                        const SizedBox(height: 10),
                                      if (subtotal != 0.0)
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                  Provider.of<AppModel>(context,
                                                                  listen: false)
                                                              .langCode ==
                                                          'en'
                                                      ? "Subtotal"
                                                      : 'المجموع',
                                                  style: largeAmountStyle),
                                            ),
                                            Text(
                                                // 'JOD ${subtotal + magentoDiscountAmount}',
                                                "${Tools.getCurrencyFormatted((widget.model!.getTotal() - widget.model!.getShippingCost()!), currencyRate, currency: currency)}",
                                                style: largeAmountStyle),
                                          ],
                                        ),
                                      // if (shippingrate != 0.0)
                                      //   const SizedBox(height: 10),
                                      // if (shippingrate != 0.0)
                                      //   Row(
                                      //     children: [
                                      //       Expanded(
                                      //         child: Text(
                                      //             Provider.of<AppModel>(context,
                                      //                             listen: false)
                                      //                         .langCode ==
                                      //                     'en'
                                      //                 ? "Shipping Charge"
                                      //                 : 'قيمة التوصيل ',
                                      //             style: largeAmountStyle),
                                      //       ),
                                      //       Text('JOD $shippingrate',
                                      //           style: largeAmountStyle),
                                      //     ],
                                      //   ),
                                      // const SizedBox(height: 10),
                                      // Row(
                                      //   children: [
                                      //     Expanded(
                                      //       child: InkWell(
                                      //         onTap: () {
                                      //           print(grandTotal);
                                      //           print(magentoDiscountAmount);
                                      //         },
                                      //         child: Text(
                                      //             '${S.of(context).total1}:',
                                      //             style: largeAmountStyle),
                                      //       ),
                                      //     ),
                                      //     widget.model.calculatingDiscount
                                      //         ? const SizedBox(
                                      //             width: 20,
                                      //             height: 20,
                                      //             child:
                                      //                 CircularProgressIndicator(
                                      //               strokeWidth: 2.0,
                                      //             ),
                                      //           )
                                      //         : Text(
                                      //             // "${Tools.getCurrencyFormatted((widget.model.getTotal() + _magentoDiscountAmount) - widget.model.getShippingCost(), currencyRate, currency: currency)}",

                                      //             "${Tools.getCurrencyFormatted(grandTotal, currencyRate, currency: currency)}",

                                      //             style: largeAmountStyle,
                                      //           ),
                                      //   ],
                                      // )
                                    ])
                                        // Text(
                                        //   snapshot.data == null
                                        //       ? 'Null'
                                        //       : snapshot.data.toString(),
                                        //   style: Theme.of(context).textTheme.display1,
                                        // ),
                                        );
                                    break;
                                  case ConnectionState.done:
                                    print(
                                        'Done is fucking here ${snapshot.data}');
                                    if (snapshot.hasData) {
                                      Column(children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              S.of(context).discount,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context)
                                                    .colorScheme.secondary,
                                              ),
                                            ),
                                            Text(
                                              // widget.model.getCoupon(),
                                              "${Tools.getCurrencyFormatted(magentoDiscountAmount, currencyRate, currency: currency)}",
                                              // style: Theme.of(context).textTheme.subtitle1.copyWith(
                                              //       fontSize: 14,
                                              //       color: Theme.of(context).accentColor,
                                              //       fontWeight: FontWeight.w600,
                                              //     ),
                                              style: smallAmountStyle,
                                            )
                                          ],
                                        ),
                                        if (subtotal != 0.0)
                                          const SizedBox(height: 10),
                                        if (subtotal != 0.0)
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                    Provider.of<AppModel>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .langCode ==
                                                            'en'
                                                        ? "Subtotal"
                                                        : 'المجموع',
                                                    style: largeAmountStyle),
                                              ),
                                              Text(
                                                  'JOD ${subtotal + magentoDiscountAmount}',
                                                  style: largeAmountStyle),
                                            ],
                                          ),
                                        // if (shippingrate != 0.0)
                                        //   const SizedBox(height: 10),
                                        // if (shippingrate != 0.0)
                                        //   Row(
                                        //     children: [
                                        //       Expanded(
                                        //         child: Text(
                                        //             Provider.of<AppModel>(
                                        //                             context,
                                        //                             listen:
                                        //                                 false)
                                        //                         .langCode ==
                                        //                     'en'
                                        //                 ? "Shipping Charge"
                                        //                 : 'قيمة التوصيل ',
                                        //             style: largeAmountStyle),
                                        //       ),
                                        //       Text('JOD $shippingrate',
                                        //           style: largeAmountStyle),
                                        //     ],
                                        //   ),
                                        // const SizedBox(height: 10),
                                        // Row(
                                        //   children: [
                                        //     Expanded(
                                        //       child: InkWell(
                                        //         onTap: () {
                                        //           print(grandTotal);
                                        //           print(magentoDiscountAmount);
                                        //         },
                                        //         child: Text(
                                        //             '${S.of(context).total1}:',
                                        //             style: largeAmountStyle),
                                        //       ),
                                        //     ),
                                        //     widget.model.calculatingDiscount
                                        //         ? const SizedBox(
                                        //             width: 20,
                                        //             height: 20,
                                        //             child:
                                        //                 CircularProgressIndicator(
                                        //               strokeWidth: 2.0,
                                        //             ),
                                        //           )
                                        //         : Text(
                                        //             // "${Tools.getCurrencyFormatted((widget.model.getTotal() + _magentoDiscountAmount) - widget.model.getShippingCost(), currencyRate, currency: currency)}",

                                        //             "${Tools.getCurrencyFormatted(grandTotal, currencyRate, currency: currency)}",

                                        //             style: largeAmountStyle,
                                        //           ),
                                        //   ],
                                        // )
                                      ]);
                                    } else if (snapshot.hasError) {
                                      return Text('Has Error');
                                    } else {
                                      return Text('Error');
                                    }
                                    break;
                                }
                                return Text('Non in Switch');
                              },
                            ),

                            // if (widget.model.getCoupon() != '' ||
                            //     _magentoDiscountAmount < 0)
                            //   Row(
                            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //     crossAxisAlignment: CrossAxisAlignment.center,
                            //     children: <Widget>[
                            //       Text(
                            //         S.of(context).discount,
                            //         style: TextStyle(
                            //           fontSize: 14,
                            //           color: Theme.of(context).accentColor,
                            //         ),
                            //       ),
                            //       Text(
                            //         // widget.model.getCoupon(),
                            //         "${Tools.getCurrencyFormatted(_magentoDiscountAmount, currencyRate, currency: currency)}",
                            //         // style: Theme.of(context).textTheme.subtitle1.copyWith(
                            //         //       fontSize: 14,
                            //         //       color: Theme.of(context).accentColor,
                            //         //       fontWeight: FontWeight.w600,
                            //         //     ),
                            //         style: smallAmountStyle,
                            //       )
                            //     ],
                            //   ),
                            // if (widget.model.rewardTotal > 0)
                            //   const SizedBox(height: 10),
                            // if (widget.model.rewardTotal > 0)
                            //   Row(
                            //     children: [
                            //       Expanded(
                            //         child: Text(S.of(context).cartDiscount,
                            //             style: smallAmountStyle),
                            //       ),
                            //       Text(
                            //         Tools.getCurrencyFormatted(
                            //             widget.model.rewardTotal, currencyRate,
                            //             currency: currency),
                            //         style: smallAmountStyle,
                            //       ),
                            //     ],
                            //   ),
                            // const SizedBox(height: 10),
                            // _grandTotal > 0 &&
                            //         widget.model.getTotal() < _grandTotal + 2
                            //     // ||
                            //     // Provider.of<CartProvider>(context, listen: false)
                            //     //             .cartGrandTotal ==
                            //     //         _grandTotal
                            //     ? Row(
                            //         children: [
                            //           Expanded(
                            //             child: InkWell(
                            //               onTap: () {
                            //                 print(_grandTotal);
                            //                 print(_magentoDiscountAmount);
                            //               },
                            //               child: Text('${S.of(context).total1}:',
                            //                   style: largeAmountStyle),
                            //             ),
                            //           ),
                            //           widget.model.calculatingDiscount
                            //               ? const SizedBox(
                            //                   width: 20,
                            //                   height: 20,
                            //                   child: CircularProgressIndicator(
                            //                     strokeWidth: 2.0,
                            //                   ),
                            //                 )
                            //               : Text(
                            //                   // Tools.getCurrencyFormatted(
                            //                   //     widget.model.getTotal() -
                            //                   //         widget.model.getShippingCost(),
                            //                   //     currencyRate,
                            //                   //     currency: currency),

                            //                   // "${Tools.getCurrencyFormatted((widget.model.getTotal() + _magentoDiscountAmount) - widget.model.getShippingCost(), currencyRate, currency: currency)}",

                            //                   "${Tools.getCurrencyFormatted(_grandTotal, currencyRate, currency: currency)}",

                            //                   style: largeAmountStyle,
                            //                   // style: Theme.of(context)
                            //                   //     .textTheme
                            //                   //     .subtitle2
                            //                   //     .copyWith(
                            //                   //       color: Colors.black12,
                            //                   //       // fontFamily: 'raleway',
                            //                   //       fontWeight: FontWeight.w600,
                            //                   // ),
                            //                 ),
                            //         ],
                            //       )
                            //     : FutureBuilder(
                            //         future: getDiscountsIfAny(),
                            //         builder: (context, snapshot) {
                            //           return Row(
                            //             children: [
                            //               Expanded(
                            //                 child: InkWell(
                            //                   onTap: () {
                            //                     print(_grandTotal);
                            //                     print(_magentoDiscountAmount);
                            //                   },
                            //                   child: Text('${S.of(context).total1}:',
                            //                       style: largeAmountStyle),
                            //                 ),
                            //               ),
                            //               widget.model.calculatingDiscount
                            //                   ? const SizedBox(
                            //                       width: 20,
                            //                       height: 20,
                            //                       child: CircularProgressIndicator(
                            //                         strokeWidth: 2.0,
                            //                       ),
                            //                     )
                            //                   : Text(
                            //                       // Tools.getCurrencyFormatted(
                            //                       //     widget.model.getTotal() -
                            //                       //         widget.model.getShippingCost(),
                            //                       //     currencyRate,
                            //                       //     currency: currency),

                            //                       // "${Tools.getCurrencyFormatted((widget.model.getTotal() + _magentoDiscountAmount) - widget.model.getShippingCost(), currencyRate, currency: currency)}",

                            //                       "${Tools.getCurrencyFormatted(snapshot.data, currencyRate, currency: currency)}",

                            //                       style: largeAmountStyle,
                            //                       // style: Theme.of(context)
                            //                       //     .textTheme
                            //                       //     .subtitle2
                            //                       //     .copyWith(
                            //                       //       color: Colors.black12,
                            //                       //       // fontFamily: 'raleway',
                            //                       //       fontWeight: FontWeight.w600,
                            //                       // ),
                            //                     ),
                            //             ],
                            //           );
                            //         },
                            //       )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        : Container();
  }
}

