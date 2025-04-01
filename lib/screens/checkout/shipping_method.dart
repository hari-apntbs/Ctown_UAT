import 'package:ctown/models/app_model.dart';
import 'package:ctown/widgets/home/clickandcollect_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/cart/cart_model.dart';
import '../../models/shipping_method_model.dart';
import '../../services/index.dart';

import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:ctown/screens/cart/cartProvider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ShippingMethods extends StatefulWidget {
  final Function? onBack;
  final Function? onNext;

  ShippingMethods({this.onBack, this.onNext});

  @override
  _ShippingMethodsState createState() => _ShippingMethodsState();
}

class _ShippingMethodsState extends State<ShippingMethods> {
  int? selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration.zero,
      () async {
        final shippingMethod =
            Provider.of<CartModel>(context, listen: false).shippingMethod;
        final shippingMethods =
            Provider.of<ShippingMethodModel>(context, listen: false)
                .shippingMethods;
        if (shippingMethods != null &&
            shippingMethods.isNotEmpty &&
            shippingMethod != null) {
          final index = shippingMethods
              .indexWhere((element) => element.id == shippingMethod.id);
          if (index > -1) {
            setState(() {
              selectedIndex = index;
            });
          }
        }
      },
    );
  }

  getDiscountsIfAny() async {
    final LocalStorage storage = LocalStorage('store');
    final userJson = await storage.getItem(kLocalKey["userInfo"]!);
    String url = "https://up.ctown.jo/rest/V1/carts/mine/payment-information?nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}";

    printLog("dfngsdgasdfgdfh");
    printLog(url);
    // print(userJson["cookie"]);
    var response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ' + userJson["cookie"],
    });
    if (response.statusCode == 200) {
      // print(response.body);
      var data = jsonDecode(response.body);

      Provider.of<CartProvider>(context, listen: false).setMagentoDiscount(
          double.parse(data["totals"]["discount_amount"].toString()));
      Provider.of<CartProvider>(context, listen: false).setCartGrandTotal(
          double.parse(data["totals"]["grand_total"].toString()));
      Provider.of<CartProvider>(context, listen: false).setBaseSubTotal(
          double.parse(data["totals"]["base_subtotal"].toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final shippingMethodModel = Provider.of<ShippingMethodModel>(context);
    final currency = Provider.of<CartModel>(context).currency;
    final currencyRates = Provider.of<CartModel>(context).currencyRates;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(S.of(context).shippingMethod,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 20),
        ListenableProvider.value(
          value: shippingMethodModel,
          child: Consumer<ShippingMethodModel>(
            builder: (context, model, child) {
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

              return Column(
                children: <Widget>[
                  for (int i = 0; i < model.shippingMethods!.length; i++)
                    Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: i == selectedIndex
                                ? Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.black : kGrey200
                                : Colors.transparent,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            child: Row(
                              children: <Widget>[
                                Radio(
                                  activeColor: Theme.of(context).primaryColor,
                                  value: i,
                                  groupValue: selectedIndex,
                                  onChanged: (dynamic i) {
                                    setState(() {
                                      selectedIndex = i;
                                    });
                                  },
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Services()
                                          .widget?.renderShippingPaymentTitle(context,
                                              model.shippingMethods![i].title=='Shipping charge'?
                                              Provider.of<AppModel>(context, listen: false).langCode=='en'?
                                              "Delivery Fee":'رسوم التوصيل': model.shippingMethods![i].title) ?? const SizedBox.shrink(),
                                      const SizedBox(height: 5),
                                      if (model.shippingMethods![i].cost! > 0.0 ||
                                          !isNotBlank(model
                                              .shippingMethods![i].classCost))
                                        Text(
                                          Tools.getCurrencyFormatted(
                                              model.shippingMethods![i].cost,
                                              currencyRates,
                                              currency: currency)!,
                                          style: const TextStyle(
                                              fontSize: 14, color: kGrey400),
                                        ),
                                      if (model.shippingMethods![i].cost ==
                                              0.0 &&
                                          isNotBlank(model
                                              .shippingMethods![i].classCost))
                                        Text(
                                          model.shippingMethods![i].classCost!,
                                          style: const TextStyle(
                                              fontSize: 14, color: kGrey400),
                                        )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        i < model.shippingMethods!.length - 1
                            ? const Divider(height: 1)
                            : Container()
                      ],
                    )
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ButtonTheme(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.yellow,
                  ),
                  onPressed: () async {
                    //

                    if (Provider.of<ClickNCollectProvider>(context,
                                listen: false)
                            .deliveryType ==
                        "clickandcollect") {
                           print("getting data");
                      await getDiscountsIfAny();
                    }
                    //
                     if (shippingMethodModel.shippingMethods!.isNotEmpty) {
                      Provider.of<CartModel>(context, listen: false)
                          .setShippingMethod(shippingMethodModel
                              .shippingMethods![selectedIndex!]);
                      widget.onNext!();
                    }
                  },
                  child: Text(S.of(context).continueToReview.toUpperCase()),
                ),
              ),
            ),
          ],
        ),
        Center(
          child: TextButton(
            onPressed: () {
              
           widget.onBack!();
            },
            child: Text(
              S.of(context).goBackToAddress,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 15,
                  color: kGrey400),
            ),
          ),
        )
      ],
    );
  }
}
