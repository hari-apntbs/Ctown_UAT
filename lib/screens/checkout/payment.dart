import 'dart:convert';

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../frameworks/magento/services/magento.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show
    AppModel,
    BookingInfo,
    CartModel,
    Order,
    PaymentMethodModel,
    Product,
    TaxModel,
    UserModel;
import '../../services/index.dart';
import "../../widgets/home/clickandcollect_provider.dart";
import '../../widgets/payment/credit/index.dart';
import '../../widgets/payment/payment_webview.dart';
import '../cart/cartProvider.dart';
import '../cart/my_cart.dart';
import 'webview_checkout_success.dart';

class PaymentMethods extends StatefulWidget {
  final Function? onBack;
  final Function? onFinish;
  final Function(bool)? onLoading;

  PaymentMethods({this.onBack, this.onFinish, this.onLoading});

  @override
  _PaymentMethodsState createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods> {
  String? selectedId;
  int? selectedIndex;
  bool isPaying = false;
  Order? newOrder;
  double magentoDiscountAmount = 0.0;
  double grandTotal = 0.0;
  double shippingRate = 0.0;
  var cookie;
  CustomPopupMenuController _controller = CustomPopupMenuController();
  List<String> payment = ["يرجى العلم أن هذا الخيار مخصص للدفع عبر البوابة الإلكترونية باستخدام بطاقتك الائتمانية (سحب مباشر). للاستمرار، يرجى الضغط على ‘موافق’ من ثم اتمام الطلب.",
  "Dear valued customer, we would like to inform you that you have chosen to pay through the online gateway using your Credit/Debit card. To complete the process, please click 'Accept' then place order."];
  final ScrollController verticalScroll = ScrollController();
  final tooltipkey = GlobalKey<TooltipState>();

  @override
  void initState() {
    super.initState();
    // getDiscountsIfAny();

    Future.delayed(Duration.zero, () {
      final cartModel = Provider.of<CartModel>(context, listen: false);
      final userModel = Provider.of<UserModel>(context, listen: false);

      final clickNCollectProvider =
      Provider.of<ClickNCollectProvider>(context, listen: false);
      cookie = Provider.of<UserModel>(context, listen: false).user != null
          ? Provider.of<UserModel>(context, listen: false).user!.cookie
          : null;
      Provider.of<PaymentMethodModel>(context, listen: false).getPaymentMethods(
        cartModel: cartModel,
        shippingMethod: cartModel.shippingMethod,
        token: userModel.user != null ? userModel.user!.cookie : null,
        lang: Provider.of<AppModel>(context, listen: false).langCode ?? "en"
      );

      if (kPaymentConfig["EnableReview"] != true) {
        Provider.of<TaxModel>(context, listen: false).getTaxes(
            Provider.of<CartModel>(context, listen: false), (taxesTotal) {
          Provider.of<CartModel>(context, listen: false).taxesTotal =
              taxesTotal;
          setState(() {});
        });
      }
    });
  }

  getDiscountsIfAny() async {
    final LocalStorage storage = LocalStorage('store');
    final userJson = await storage.getItem(kLocalKey["userInfo"]!);
    final cartModel = Provider.of<CartModel>(context, listen: false).address;
    String url =
        "https://up.ctown.jo/rest/V1/carts/mine/payment-information?address_id=${cartModel?.id}&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}";
    printLog("cvbfgsdfxcnvhcgf");
    printLog(url);
    printLog("payment working");
    printLog(userJson["cookie"]);
    var response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ' + userJson["cookie"],
    });
    printLog(response.statusCode);
    if (response.statusCode == 200) {
      printLog(response.body);
      var data = jsonDecode(response.body);

      grandTotal = double.parse(data["totals"]["grand_total"].toString());
      shippingRate = double.parse(data["totals"]["shipping_amount"].toString());
      magentoDiscountAmount =
          double.parse(data["totals"]["discount_amount"].toString());
      return data;
    }
    else {
      return null;
    }
    // printLog({"grandTotal": grandTotal, "discount": magentoDiscountAmount});
    // return {
    //   "grandTotal": grandTotal,
    //   "discount": magentoDiscountAmount,
    //   'shipping_amount': shippingRate
    // };
    // model.getTotal({data["totals"]["discount_amount"]});
  }

  _buildCustomPopup() {
    return CustomPopupMenu(
      child: Container(
        child: const Icon(Icons.info),
      ),
      menuBuilder: () => RawScrollbar(
        thumbColor: Colors.black54,
        controller: verticalScroll,
        thumbVisibility: true,
        radius: const Radius.circular(20),
        thickness: 7,
        child: Container(
          height: 150,
          width: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0,),
            border: Border.all(width: 2),
            color: Colors.grey.shade400,
          ),
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
          child: ListView(
            controller: verticalScroll,
            children: [
              Text(
                payment[0],
                style: TextStyle(fontSize: 13, color: Colors.black),
                textDirection: TextDirection.rtl,
              ),
              Text(
                payment[1],
                style: TextStyle(fontSize: 13, color: Colors.black),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
      ),
      pressType: PressType.singleClick,
      verticalMargin: -10,
      controller: _controller,
    );
  }

  showPaymentDialog(context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Wrap(
                  direction: Axis.vertical,
                  children: [
                    Text("الدفع الإلكتروني",
                    textDirection: TextDirection.rtl,),
                    Text("Online payment")
                  ],
                ),
                IconButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      setState(() {
                        selectedId = "";
                      });
                    },
                    icon: Icon(Icons.clear,
                    color: Theme.of(context).primaryColor,)
                )
              ],
            ),
            content: Wrap(
              direction: Axis.horizontal,
              children: [
                Text(payment[0],
                textDirection: TextDirection.rtl),
                Text(payment[1],
                textDirection: TextDirection.ltr,)
              ],
            ),
            actionsPadding: EdgeInsets.only(top: 0, bottom: 8, right: 12, left: 12),
            actions: [
              FilledButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  style: FilledButton.styleFrom(
                    foregroundColor: Colors.white
                  ),
                child:  Wrap(
                  direction: Axis.horizontal,
                  children: [
                    Text("موافق",
                    textDirection: TextDirection.rtl,),
                    Text(" / Accept")
                  ],
                ),
              )
            ],
          );
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final paymentMethodModel = Provider.of<PaymentMethodModel>(context);
    final taxModel = Provider.of<TaxModel>(context);
    final currency = Provider.of<AppModel>(context).currency;

    return ListenableProvider.value(
        value: paymentMethodModel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(S.of(context).paymentMethods,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 5),
            Text(
              S.of(context).chooseYourPaymentMethod,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
            Consumer<PaymentMethodModel>(builder: (context, model, child) {
              if (model.isLoading) {
                return Container(height: 100, child: kLoadingWidget(context));
              }

              if (model.message != null) {
                return Container(
                  height: 100,
                  child: Center(
                      child: Text(model.message!,
                          style: const TextStyle(color: kErrorRed))),
                );
              }

              // if (selectedId == null && model.paymentMethods.isNotEmpty) {
              //   selectedId =
              //       model.paymentMethods.firstWhere((item) => item.enabled).id;
              // }

              return Column(
                children: <Widget>[
                  for (int i = 0; i < model.paymentMethods.length; i++)
                    model.paymentMethods[i].enabled! ? Column(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            setState(() {
                              selectedId = model.paymentMethods[i].id;
                            });
                            if(selectedId == "ngeniusonline" || selectedId == "qatar_creditcard"){
                              showPaymentDialog(context);
                            }
                            printLog("iiahfszjhasdfasf");
                            printLog(selectedId);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: model.paymentMethods[i].id ==
                                    selectedId
                                    ? Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.black : kGrey200
                                    : Colors.transparent),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 5),
                              child: Column(
                                children: [
                                  Row(
                                    children: <Widget>[
                                      Radio(
                                          activeColor: Theme.of(context)
                                              .primaryColor,
                                          value:
                                          model.paymentMethods[i].id,
                                          groupValue: selectedId,
                                          onChanged: (dynamic i) {
                                            setState(() {
                                              selectedId = i;
                                            });
                                            if(selectedId == "ngeniusonline" || selectedId == "qatar_creditcard") {
                                              showPaymentDialog(context);
                                            }
                                          }),
                                      const SizedBox(width: 5),
                                      model.paymentMethods[i].id ==
                                          'qatar_creditcard' ? Icon(Icons.credit_card, color: Theme.of(context).colorScheme.secondary,)  :
                                      model.paymentMethods[i].id ==
                                          'cashondelivery' ? Row(
                                        children: [
                                          Image.asset("assets/images/cash_image.png", height: 50, width: 50, color: Theme.of(context).colorScheme.secondary,),
                                          // Container(height: 20, width: 1, color: Theme.of(context).accentColor, margin: EdgeInsets.only(left: 5),),
                                          Image.asset("assets/images/cashondelivery.png", height: 40, width: 40, color: Theme.of(context).colorScheme.secondary,)
                                        ],
                                      ) : SizedBox.shrink(),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: <Widget>[
                                            if (Payments[model
                                                .paymentMethods[i]
                                                .id] !=
                                                null)
                                              Image.asset(
                                                Payments[model
                                                    .paymentMethods[i]
                                                    .id]!,
                                                width: 120,
                                                height: 30,
                                              ),

                                            if (Payments[model
                                                .paymentMethods[i]
                                                .id] ==
                                                null)
                                              Services().widget?.renderShippingPaymentTitle(
                                                  context, model.paymentMethods[i].id ==
                                                  'cashondelivery'
                                                  ? Provider.of<AppModel>(context, listen: false)
                                                  .langCode ==
                                                  'en'
                                                  ? model.paymentMethods[i].title
                                                  : 'الدفع نقداً/ فيزا عند التوصيل'
                                                  : model.paymentMethods[i].id ==
                                                  'qatar_creditcard'
                                                  ? Provider.of<AppModel>(context, listen: false).langCode ==
                                                  'en'
                                                  ? 'Pay now (Credit/Debit card)'
                                                  : "الدفع الان (بواسطة البطاقة الائتمانية)"
                                                  : model.paymentMethods[i].title) ?? const SizedBox.shrink(),
                                          ],
                                        ),
                                      ),
                                      model.paymentMethods[i].id == "ngeniusonline" || model.paymentMethods[i].id == "qatar_creditcard"?
                                      _buildCustomPopup() : SizedBox.shrink(),
                                    ],
                                  ),
                                  /*


                                          model.paymentMethods[i].title
                                                    .contains('CreditCard') &&
                                                model.paymentMethods[i].id ==
                                                    selectedId
                                            ? model.cardDetails.isEmpty
                                                ? const Text(
                                                    'No card details available')
                                                : Column(
                                                    children: List.generate(
                                                      model.cardDetails.length,
                                                      (index) => RadioListTile<
                                                          CardDetails>(
                                                        activeColor:
                                                            Theme.of(context)
                                                                .primaryColor,
                                                        value: model
                                                            .cardDetails[index],
                                                        groupValue: selectedIndex !=
                                                                null
                                                            ? model.cardDetails[
                                                                selectedIndex]
                                                            : null,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            selectedIndex =
                                                                model
                                                                    .cardDetails
                                                                    .indexOf(
                                                                        value);
                                                          });
                                                        },
                                                        title: Text(model
                                                            .cardDetails[index]
                                                            .pan),
                                                        subtitle: Text(model
                                                            .cardDetails[index]
                                                            .expiry),
                                                      ),
                                                    ),
                                                  )
                                            : Container(),*/
                                ],
                              ),
                            ),
                            //payment options
                          ),
                        ),
                        const Divider(height: 0.5, thickness: 0.3,)
                      ],
                    )
                        : Container()
                ],
              );
            }),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    S.of(context).subtotal,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    // Tools.getCurrencyFormatted(
                    //     cartModel.getSubTotal(), currencyRate,
                    //     currency: cartModel.currency),
                      Tools.getCurrencyFormatted(
                          Provider.of<CartProvider>(context, listen: false)
                              .baseSubTotal,
                          currencyRate,
                          currency: cartModel.currency)!,
                      style: const TextStyle(fontSize: 14, color: kGrey400))
                ],
              ),
            ),

            Services().widget?.renderShippingMethodInfo(context) ?? const SizedBox.shrink(),
            // if (cartModel.getCoupon() != '')

            if (Provider.of<CartProvider>(context, listen: false)
                .magentoPromotionsDiscount <
                0)
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      S.of(context).discount,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      // cartModel.getCoupon(),
                      "-${Tools.getCurrencyFormatted(-Provider.of<CartProvider>(context, listen: false).magentoPromotionsDiscount, currencyRate, currency: currency)}",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontSize: 14,
                        color:
                        Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                      ),
                    )
                  ],
                ),
              ),
            Services().widget?.renderTaxes(taxModel, context) ?? const SizedBox.shrink(),
            Services().widget?.renderRewardInfo(context) ?? const SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    S.of(context).total1,
                    style: TextStyle(
                        fontSize: 16, color: Theme.of(context).colorScheme.secondary),
                  ),
                  FutureBuilder(
                      future: getDiscountsIfAny(),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.data != null) {
                          return Text(
                            'JOD ${snapshot.data["totals"]["grand_total"]}',
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          );
                        }
                        else if(snapshot.data == null && snapshot.connectionState == ConnectionState.done) {
                          return const SizedBox.shrink();
                        }
                        return const CircularProgressIndicator();
                      }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: ButtonTheme(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      ),
                    ),
                    onPressed: () async {
                      if (selectedId == null) {
                        SnackBar snackBar = const SnackBar(
                            content: Text("Please choose a payment method"));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        // printLog(Provider.of<CartProvider>(context, listen: false)
                        //     .cartGrandTotal);
                      } else {
                        printLog("total");
                        printLog(Provider.of<ClickNCollectProvider>(context,
                            listen: false)
                            .deliveryType);
                        printLog(Provider.of<ClickNCollectProvider>(context,
                            listen: false)
                            .storeId);
                        Provider.of<PaymentMethodModel>(context, listen: false)
                            .setTotal(Provider.of<CartProvider>(context,
                            listen: false)
                            .cartGrandTotal);
                        printLog(
                            Provider.of<CartProvider>(context, listen: false)
                                .cartGrandTotal);
                        paymentMethodModel.paymentMethods.forEach((element) {
                          printLog(element.id);
                        });
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: kLoadingWidget,
                        );
                        bool available = await checkForSlotAvailability();
                        Navigator.of(context).pop();
                        if(available) {
                          isPaying
                              ? showSnackBar
                              : placeOrder(paymentMethodModel, cartModel);
                        }
                        else {
                          String message = "";
                          if(Provider.of<AppModel>(context, listen: false).langCode == "en") {
                            message = "Selected delivery slot is unavailable. Please choose another time slot.";
                          }
                          else {
                            message = "الوقت المحدد للتوصيل غير متاح. يرجى اختيار وقت آخر.";
                          }
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                        }
                      }
                      // printLog(selectedId);
                    },
                    child: Text(S.of(context).placeMyOrder.toUpperCase(),
                      style: TextStyle(
                          color: Colors.black
                      ),),
                  ),
                ),
              ),
            ]),
            Center(
              child: TextButton(
                onPressed: () {
                  isPaying ? showSnackBar : widget.onBack!();
                },
                child: Text(
                  S.of(context).goBackToReview,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            )
          ],
        ));
  }

  void showSnackBar() {
    Tools.showSnackBar(
        ScaffoldMessenger.of(context), S.of(context).orderStatusProcessing);
  }

  Future<List<TimeSlot>> loadData() async {
    List<TimeSlot> slotData = [];
    try {
      Time time;
      TimeSlot timeSlot;
      final res =
      await http.get(Uri.parse('https://up.ctown.jo/api/grocery_slot.php'));
      printLog("final res ${res.body}");
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

        slotData.add(timeSlot);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
    return slotData;
  }

  Future<bool> checkForSlotAvailability() async {
    bool available = false;
    try {
      List<TimeSlot> slots = await loadData();
      if(slots.isNotEmpty) {
        final cartProvider = Provider.of<CartModel>(context, listen: false);
        String productId = Product.cleanProductID(cartProvider.productsInCart.keys.first);
        Product product = cartProvider.getProductById(productId);
        String deliveryDate = product.delivery_date ?? "";
        if(deliveryDate != "") {
          printLog(deliveryDate);
          List<String> parts = deliveryDate.split(' ');
          String date = parts[0];
          String timeRange = parts[1] + ' ' + parts[2] +' '+ parts[3];
          TimeSlot selectedTimeSlot = slots.where((element) => element.date == date).first;
          if(selectedTimeSlot.date == date) {
            List<Time> time = selectedTimeSlot.time ?? [];
            if(time.isNotEmpty) {
              if(time.any((ele) => ele.timeSlt == timeRange)) {
                available = true;
              }
              else {
                available = false;
              }
            }
            printLog(selectedTimeSlot);
          }
          else {
            available = true;
          }
        }
      }
    }
    catch(e) {
      printLog(e.toString());
    }
    return available;
  }

  void placeOrder(paymentMethodModel, cartModel) async {
    widget.onLoading!(true);
    isPaying = true;
    if (paymentMethodModel.paymentMethods?.isNotEmpty ?? false) {
      final paymentMethod = paymentMethodModel.paymentMethods
          .firstWhere((item) => item.id == selectedId);

      Provider.of<CartModel>(context, listen: false)
          .setPaymentMethod(paymentMethod);

      /// Use Credit card
      if (
      // paymentMethod.id == "msp_cashondelivery"
      kPaymentConfig["EnableCreditCard"] == true) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreditCardPayment(
              onFinish: (number) {
                if (number == null) {
                  widget.onLoading!(false);
                  isPaying = false;
                  return;
                } else {
                  createOrder(paid: true).then((value) {
                    widget.onLoading!(false);
                    isPaying = false;
                  });
                }
              },
            ),
          ),
        );

        return;
      }

      /// Use Native payment
      // if (isNotBlank(PaypalConfig["paymentMethodId"]) &&
      //     paymentMethod.id.contains(PaypalConfig["paymentMethodId"]) &&
      //     PaypalConfig["enabled"] == true) {
      //   await Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => PaypalPayment(
      //         onFinish: (number) {
      //           if (number == null) {
      //             widget.onLoading(false);
      //             isPaying = false;
      //             return;
      //           } else {
      //             createOrder(paid: true).then((value) {
      //               widget.onLoading(false);
      //               isPaying = false;
      //             });
      //           }
      //         },
      //       ),
      //     ),
      //   );
      // } else if (isNotBlank(PaypalConfig["paymentMethodId"]) &&
      //     paymentMethod.id.contains(TapConfig["paymentMethodId"]) &&
      //     TapConfig["enabled"] == true) {
      //   await Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => TapPayment(onFinish: (number) {
      //               createOrder(paid: true);
      //               isPaying = false;
      //             })),
      //   );
      // } else if (isNotBlank(kStripeConfig["paymentMethodId"]) &&
      //     paymentMethod.id.contains(kStripeConfig["paymentMethodId"]) &&
      //     kStripeConfig["enabled"] == true) {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (_) => StripePayment(
      //         onFinish: (success) {
      //           if (success == true) {
      //             createOrder(paid: true).then((value) {
      //               widget.onLoading(false);
      //               isPaying = false;
      //             });
      //           } else {
      //             widget.onLoading(false);
      //             isPaying = false;
      //             return;
      //           }
      //         },
      //       ),
      //     ),
      //   );
      // } else if (paymentMethod.id.contains(RazorpayConfig["paymentMethodId"]) && RazorpayConfig["enabled"] == true) {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (_) => RazorPayment(
      //         razorKey: RazorpayConfig["keyId"],
      //         amount: cartModel.getTotal() * 100.toInt(),
      //         name: cartModel.address.firstName + " " + cartModel.address.lastName,
      //         currency: "INR",
      //         contact: cartModel.address.phoneNumber,
      //         email: cartModel.address.email,
      //         onFinish: (response) {
      //           if (response != null) {
      //             createOrder(paid: true).then((value) {
      //               widget.onLoading(false);
      //               isPaying = false;
      //             });
      //           } else {
      //             widget.onLoading(false);
      //             isPaying = false;
      //             return;
      //           }
      //         },
      //       ),
      //     ),
      //   );
      // } else

      if (paymentMethod.id == 'checkmo' ||
          paymentMethod.id == 'msp_cashondelivery') {
        /// Use WebView Payment per frameworks
        ///
        ///
        ///
        ///
        Provider.of<PaymentMethodModel>(context, listen: false)
            .setSelectedMethod(paymentMethod.id);
        bool? isSuccess;
        try {
          if (newOrder == null) {
            await createOrder();
          }
          var cardDetails =
              Provider.of<PaymentMethodModel>(context, listen: false)
                  .cardDetails;
          printLog("card or cod postorder details");
          var urlMap = await MagentoApi().postOrderDetails(
            // cartModel.getTotal(),

              Provider.of<CartProvider>(context, listen: false).cartGrandTotal,
              orderId: newOrder!.id,
              cardId:
              selectedIndex != null ? cardDetails![selectedIndex!].id : null);
          printLog("URL Map");
          printLog(urlMap);
          var merchentId = urlMap['merchentId'];
          var amount = urlMap['amount'];
          var currency = urlMap['currency'];
          var orderId = urlMap['orderId'];
          var session = urlMap['session'];
          var successIndicator = urlMap['successIndicator'];

          printLog(merchentId);
          printLog(amount);
          printLog(orderId);
          // previous version 49
          var htmlContent = """ 
          
<html>
    <head>
        <meta name='viewport' content='width=device-width, initial-scale=2'>
        <script src="https://test-network.mtf.gateway.mastercard.com/checkout/version/61/checkout.js"
                data-error="errorCallback"
                data-cancel="https://up.ctown.jo">
        </script>

        <script type="text/javascript">
            function errorCallback(error) {
                  console.log(JSON.stringify(error));
            }
            Checkout.configure({
                  merchant:'$merchentId',
                  order:{
                    amount: function () {
                        return $amount;
                    },
                    currency:'$currency',
                    description:'order goods',
                    id:'$orderId',
                  },
                  interaction: {
                      merchant: {
                            name: 'A & H IPG',
                            address: {
                                line1: '200 Sample St',
                                line2: '1234 Example Town'            
                            }  
                      }
                   },
                   session: { 
                	id: '$session'
            			}
            });
            Checkout.showPaymentPage();
        </script>
    </head>
    <body>
    </body>
</html>
          """;
          /* """

<html>
    <head>
        <meta name='viewport' content='width=device-width, initial-scale=2'>
        <script src="https://test-gateway.mastercard.com/checkout/version/60/checkout.js"
                data-error="errorCallback"
                data-cancel="https://up.ctown.jo">
        </script>

        <script type="text/javascript">
            function errorCallback(error) {
                  console.log(JSON.stringify(error));
            }
            Checkout.configure({
                  merchant:'$merchentId',
                  order:{
                    amount: function () {
                        return $amount;
                    },
                    currency:'$currency',
                    description:'order goods',
                    id:'$orderId',
                  },
                  interaction: {
                      merchant: {
                            name: 'A & H IPG',
                            address: {
                                line1: '200 Sample St',
                                line2: '1234 Example Town'
                            }
                      }
                   },
                   session: {
                	id: '$session'
            			}
            });
            Checkout.showPaymentPage();
        </script>
    </head>
    <body>
    </body>
</html>
          """;*/

          WebViewController controller = WebViewController();
          controller
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(NavigationDelegate(
              onNavigationRequest: (NavigationRequest request) async {
                printLog("req url");
                printLog(request.url);
                if (request.url.contains('https://up.ctown.jo')) {
                  final uri = Uri.parse(request.url);
                  String? resultIndicator =
                  uri.queryParameters['resultIndicator'];
                  if (resultIndicator != null &&
                      resultIndicator == successIndicator) {
                    if (newOrder != null) {
                      bool success = await MagentoApi().submitPaymentSuccess(newOrder!.id);
                      widget.onFinish!(newOrder);
                      widget.onLoading!(false);
                      isPaying = false;
                      // newOrder = null;
                      if (success) {
                        isSuccess = true;
                        await Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) =>
                                    WebviewCheckoutSuccess(
                                        order: newOrder)));
                      }
                    }
                  } else {
                    /// handle payment failure
                    widget.onLoading!(false);
                    isPaying = false;
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          title: Text(S.of(context).orderStatusFailed),
                          // content: Text("${err?.message ?? err}"),
                          content: const Text(
                              "Your payment was not successful!!"),
                          actions: <Widget>[
                            TextButton(
                              child: Text(
                                S.of(context).ok,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                              onPressed: () async {
                                // Navigator.of(context).pop();
                                isSuccess = false;
                                Navigator.pop(context);
                                Navigator.pop(context);
                                // await Navigator.pushReplacementNamed(context, "/orders");
                              },
                            )
                          ],
                        );
                      },
                    );
                  }
                  //  else {
                  //   widget.onLoading(false);
                  //   isPaying = false;
                  //   Navigator.of(context).pop();
                  // }
                  //// Navigator.of(context).pop();
                  //
                }

                //              // if (request.url.contains(urlMap['cancelUrl'])) {
                //   widget.onLoading(false);
                //   isPaying = false;
                //   Navigator.of(context).pop();
                // }

                return NavigationDecision.navigate;
              },
            ))
            ..loadRequest(Uri.parse(Uri.dataFromString(
              htmlContent,
              mimeType: 'text/html',
              encoding: Encoding.getByName('utf-8'),
            ).toString(),));
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WillPopScope(
                  onWillPop: () async {
                    widget.onLoading!(false);
                    isPaying = false;
                    return true;
                  },
                  child: WebViewWidget(controller: controller)
              ),
            ),
          );
        } catch (e) {
          widget.onLoading!(false);
          isPaying = false;
          printLog("exception $e");
          printLog("starting delete cart");

          return Tools.showSnackBar(
              ScaffoldMessenger.of(context), 'Unable to process the request');
        } finally {
          // await Services().deleteItemFromCart(
          //     cartModel.productsInCart.keys.toList(),
          //     cookie != null ? cookie : null);
          cartModel.clearCart();
          printLog("is success $isSuccess");
          printLog("successfully emptied cart item");
          // Navigator.pop(context);
          printLog(isSuccess);
          if (isSuccess == false || isSuccess == null) {
            await Navigator.pushReplacementNamed(context, "/orders");
          }
        }
      } else if (paymentMethod.id == "tns_hosted") {
        printLog(paymentMethod.id);
        printLog("qatar credit card");

        Provider.of<PaymentMethodModel>(context, listen: false)
            .setSelectedMethod(paymentMethod.id);
        bool? isSuccess;
        try {
          if (newOrder == null) {
            await createOrder();
          }
          var cardDetails =
              Provider.of<PaymentMethodModel>(context, listen: false)
                  .cardDetails;
          printLog("card or cod postorder details");
          var urlMap = await MagentoApi().postOrderDetailsForCreditCard(
            // cartModel.getTotal(),

              Provider.of<CartProvider>(context, listen: false).cartGrandTotal,
              orderId: newOrder!.id,
              cardId:
              selectedIndex != null ? cardDetails![selectedIndex!].id : null);
          printLog("URL Map");
          printLog(urlMap);
          var merchentId = urlMap['merchentId'];
          var amount = urlMap['amount'];
          var currency = urlMap['currency'];
          var orderId = urlMap['orderId'];
          var session = urlMap['session'];
          var successIndicator = urlMap['successIndicator'];

          printLog(merchentId);
          printLog(amount);
          printLog(orderId);
          var htmlContent = """ 
<html>
    <head>
        <meta name='viewport' content='width=device-width, initial-scale=2'>
        <script src="https://test-network.mtf.gateway.mastercard.com/checkout/version/61/checkout.js"
                data-error="errorCallback"
                data-cancel="https://up.ctown.jo">
        </script>

        <script type="text/javascript">
            function errorCallback(error) {
                  console.log(JSON.stringify(error));
            }
            Checkout.configure({
                  merchant:'$merchentId',
                  order:{
                    amount: function () {
                        return $amount;
                    },
                    currency:'$currency',
                    description:'order goods',
                    id:'$orderId',
                  },
                  interaction: {
                      merchant: {
                            name: 'CTOWN',
                            address: {
                                line1: '200 Sample St',
                                line2: '1234 Example Town'            
                            }  
                      }
                   },
                   session: { 
                	id: '$session'
            			}
            });
            Checkout.showPaymentPage();
        </script>
    </head>
    <body>
    </body>
</html>
          """;
          /*

          """
<html>
    <head>
        <meta name='viewport' content='width=device-width, initial-scale=2'>
        <script src="https://test-gateway.mastercard.com/checkout/version/60/checkout.js"
                data-error="errorCallback"
                data-cancel="https://up.ctown.jo">
        </script>

        <script type="text/javascript">
            function errorCallback(error) {
                  console.log(JSON.stringify(error));
            }
            Checkout.configure({
                  merchant:'$merchentId',
                  order:{
                    amount: function () {
                        return $amount;
                    },
                    currency:'$currency',
                    description:'order goods',
                    id:'$orderId',
                  },
                  interaction: {
                      merchant: {
                            name: 'A & H IPG',
                            address: {
                                line1: '200 Sample St',
                                line2: '1234 Example Town'
                            }
                      }
                   },
                   session: {
                	id: '$session'
            			}
            });
            Checkout.showPaymentPage();
        </script>
    </head>
    <body>
    </body>
</html>
          """;*/

          WebViewController webController = WebViewController();
          webController
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(NavigationDelegate(
              onNavigationRequest: (NavigationRequest request) async {
                printLog("req url");
                printLog(request.url);
                if (request.url.contains('https://up.ctown.jo')) {
                  final uri = Uri.parse(request.url);
                  String? resultIndicator =
                  uri.queryParameters['resultIndicator'];
                  if (resultIndicator != null &&
                      resultIndicator == successIndicator) {
                    if (newOrder != null) {
                      bool success = await MagentoApi().submitPaymentSuccess(newOrder!.id);
                      widget.onFinish!(newOrder);
                      widget.onLoading!(false);
                      isPaying = false;
                      // newOrder = null;
                      if (success) {
                        isSuccess = true;
                        await Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) =>
                                    WebviewCheckoutSuccess(
                                        order: newOrder)));
                      }
                    }
                  } else {
                    /// handle payment failure
                    widget.onLoading!(false);
                    isPaying = false;
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          title: Text(S.of(context).orderStatusFailed),
                          // content: Text("${err?.message ?? err}"),
                          content: const Text(
                              "Your payment was not successful!!"),
                          actions: <Widget>[
                            TextButton(
                              child: Text(
                                S.of(context).ok,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                              onPressed: () async {
                                // Navigator.of(context).pop();
                                isSuccess = false;
                                Navigator.pop(context);
                                Navigator.pop(context);
                                // await Navigator.pushReplacementNamed(context, "/orders");
                              },
                            )
                          ],
                        );
                      },
                    );
                  }
                  //  else {
                  //   widget.onLoading(false);
                  //   isPaying = false;
                  //   Navigator.of(context).pop();
                  // }

//
//
                  //// Navigator.of(context).pop();

                  //
                }

                //              // if (request.url.contains(urlMap['cancelUrl'])) {
                //   widget.onLoading(false);
                //   isPaying = false;
                //   Navigator.of(context).pop();
                // }

                return NavigationDecision.navigate;
              },
            ))
            ..loadRequest(Uri.parse(Uri.dataFromString(
              htmlContent,
              mimeType: 'text/html',
              encoding: Encoding.getByName('utf-8'),
            ).toString()));
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WillPopScope(
                  onWillPop: () async {
                    widget.onLoading!(false);
                    isPaying = false;
                    return true;
                  },
                  child: WebViewWidget(controller: webController)
              ),
            ),
          );
        } catch (e) {
          widget.onLoading!(false);
          isPaying = false;
          printLog("exception $e");
          printLog("starting delete cart");

          return Tools.showSnackBar(
              ScaffoldMessenger.of(context), 'Unable to process the request');
        } finally {
          // await Services().deleteItemFromCart(
          //     cartModel.productsInCart.keys.toList(),
          //     cookie != null ? cookie : null);
          cartModel.clearCart();
          printLog("is success $isSuccess");
          printLog("successfully emptied cart item");
          // Navigator.pop(context);
          printLog(isSuccess);
          if (isSuccess == false || isSuccess == null) {
            await Navigator.pushReplacementNamed(context, "/orders");
          }
        }
        return;
      } else if (paymentMethod.id == 'qatar_creditcard') {
        Provider.of<PaymentMethodModel>(context, listen: false)
            .setSelectedMethod(paymentMethod.id);
        bool? isSuccess;
        try {
          printLog("Payment Test");
          if (newOrder == null) {
            await createOrder();
          }
          printLog("card or cod postorder details");
          printLog("URL Map");

          if(newOrder != null) {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PaymentWebView(
                      isPaying2: isPaying,
                      newOrder: newOrder,
                      onLoading: widget.onLoading,
                      onFinish: widget.onFinish,
                      url:
                      "${serverConfig['url']}/api/tnspaymentgatewaymobile.php?order_id=${newOrder!.id}&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}",
                    )));
          }
        } catch (e) {
          widget.onLoading!(false);
          isPaying = false;
          printLog("exception $e");
          printLog("starting delete cart");

          return Tools.showSnackBar(
              ScaffoldMessenger.of(context), 'Unable to process the request');
        } finally {
          cartModel.clearCart();
          printLog("is success $isSuccess");
          printLog("successfully emptied cart item");
          // if (isSuccess == false || isSuccess == null) {
          //   await Navigator.pushReplacementNamed(context, "/orders");
          // }
        }
      } else {
        Services().widget?.placeOrder(
          context,
          cartModel: cartModel,
          onLoading: widget.onLoading,
          paymentMethod: paymentMethod,
          lang: Provider.of<AppModel>(context, listen: false).langCode ?? "en",
          success: (Order order) async {
            for (var item in order.lineItems) {
              Product? product = cartModel.getProductById(item.productId);
              if (product?.bookingInfo != null) {
                product!.bookingInfo!.idOrder = order.id;
                bool? booking = await createBooking(product.bookingInfo);

                Tools.showSnackBar(ScaffoldMessenger.of(context),
                    booking! ? 'Booking success!' : 'Booking error!');
              }
            }
            widget.onFinish!(order);
            widget.onLoading!(false);
            isPaying = false;
          },
          error: (message) {
            widget.onLoading!(false);

            if (message != null) {
              Tools.showSnackBar(ScaffoldMessenger.of(context), message);
            }

            isPaying = false;
          },
        );
      }
      // }
    }
  }

  Future<bool?> createBooking(BookingInfo? bookingInfo) async {
    final booking = await  Services().createBooking(bookingInfo);
    return booking;
  }

  Future<void> createOrder({paid = false, cod = false}) async {
    widget.onLoading!(true);
    await Services().widget?.createOrder(
      context,
      paid: paid,
      cod: cod,
      onLoading: widget.onLoading,
      success: (order) {
        if (!cod) {
          newOrder = order;
        } else {
          widget.onFinish!(order);
        }
      },
      error: (message) {
        Tools.showSnackBar(ScaffoldMessenger.of(context), message);
      },
    );
    widget.onLoading!(false);
  }
}

