import 'dart:convert';

import 'package:ctown/models/payment_method_model.dart';
import 'package:ctown/screens/cart/cartProvider.dart';
import 'package:ctown/widgets/home/clickandcollect_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//

import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show AppModel, CartModel, Product, TaxModel, UserModel;
import '../../screens/base.dart';
import '../../services/index.dart';
import '../../widgets/common/expansion_info.dart';
import '../../widgets/product/cart_item.dart';

class ReviewScreen extends StatefulWidget {
  final Function? onBack;
  final Function? onNext;

  ReviewScreen({this.onBack, this.onNext});

  @override
  _ReviewState createState() => _ReviewState();
}

class _ReviewState extends BaseScreen<ReviewScreen> {
  TextEditingController note = TextEditingController();

  List<String> contollers = [];
  // contollers.add(note.text)

  var cookie;

  @override
  void initState() {
    note.text = Provider.of<CartModel>(context, listen: false).notes ?? "";
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
    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    Provider.of<TaxModel>(context, listen: false)
        .getTaxes(Provider.of<CartModel>(context, listen: false), (taxesTotal) {
      Provider.of<CartModel>(context, listen: false).taxesTotal = taxesTotal;
      setState(() {});
    });
  }

  getDiscountsIfAny() async {
    final LocalStorage storage = LocalStorage('store');
    final userJson = await storage.getItem(kLocalKey["userInfo"]!);
    final cartmodel = Provider.of<CartModel>(context, listen: false).address;
    String url =
        "https://up.ctown.jo/rest/V1/carts/mine/payment-information?address_id=${cartmodel?.id}&nocache=${DateTime.now().microsecond}${DateTime.now().microsecond}${DateTime.now().microsecond}";

    printLog("cvsadhhgjacxvhd");
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
      return data;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final taxModel = Provider.of<TaxModel>(context);
    final currency = Provider.of<AppModel>(context).currency;

    return Consumer<CartModel>(
      builder: (context, model, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            kPaymentConfig['EnableShipping'] as bool
                ? ExpansionInfo(
                    title: S.of(context).shippingAddress,
                    children: <Widget>[
                      ShippingAddressInfo(),
                    ],
                  )
                : Container(),
            Container(
                height: 1, decoration: const BoxDecoration(color: kGrey200)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(S.of(context).orderDetail,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            ...getProducts(model, context),
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
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  Selector<CartProvider, double>(
                    selector: (context, provider) => provider.baseSubTotal,
                    builder: (context, subTotal, child) {
                      return Text(
                        // Tools.getCurrencyFormatted(
                        //     model.getSubTotal(), currencyRate,
                        //     currency: model.currency),
                        Tools.getCurrencyFormatted(
                            subTotal,
                            currencyRate,
                            currency: model.currency)!,
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Services().widget?.renderShippingMethodInfo(context) ?? const SizedBox.shrink(),
            // if (model.getCoupon() != '')

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
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    Text(
                      // model.getCoupon(),
                      "-${Tools.getCurrencyFormatted(-Provider.of<CartProvider>(context, listen: false).magentoPromotionsDiscount, currencyRate, currency: currency)}",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
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
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
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
                        return CircularProgressIndicator();
                      }),
                  // Text(
                  //   // Tools.getCurrencyFormatted(model.getTotal(), currencyRate,
                  //   //     currency: model.currency),
                  //   Tools.getCurrencyFormatted(
                  //       (Provider.of<CartProvider>(context, listen: false)
                  //           .cartGrandTotal),
                  //       currencyRate,
                  //       currency: model.currency),
                  //   style: Theme.of(context).textTheme.subtitle1.copyWith(
                  //         fontSize: 20,
                  //         color: Theme.of(context).accentColor,
                  //         fontWeight: FontWeight.w600,
                  //         decoration: TextDecoration.underline,
                  //       ),
                  // )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              S.of(context).yourNote,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,),
            ),
            const SizedBox(
              height: 6,
            ),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white :Colors.black,
                    width: 0.2,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextField(
                  maxLines: 5,
                  controller: note,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                      hintText: S.of(context).writeYourNote,
                      hintStyle: TextStyle(fontSize: 14,
                          color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white :Colors.black),
                      border: InputBorder.none),
                  textInputAction: TextInputAction.done,
                )),
            const SizedBox(
              height: 20,
            ),
            Row(children: [
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
                      final cartModel =
                          Provider.of<CartModel>(context, listen: false);
                      List dates = [];
                      cartModel.productsInCart.keys.forEach((key) {
                        String productId = Product.cleanProductID(key);
                        Product product = cartModel.getProductById(productId);
                        dates.add(product.delivery_date!.trim());
                      });
                      printLog("uhuhsdfasdcashdhas");
                      printLog(dates);

                      if (Provider.of<CartProvider>(context, listen: false)
                              .cartGrandTotal ==
                          0.0) {
                        printLog(Provider.of<CartProvider>(context, listen: false)
                            .magentoPromotionsDiscount);
                        printLog(Provider.of<CartProvider>(context, listen: false)
                            .cartGrandTotal);

                        printLog("getting data");
                        await getDiscountsIfAny();
                      }
                      widget.onNext!();
                      if (note.text != null && note.text.isNotEmpty) {
                        Provider.of<CartModel>(context, listen: false)
                            .setOrderNotes(note.text);
                      }
                    },
                    child: Text(S.of(context).continueToPayment.toUpperCase()),
                  ),
                ),
              ),
            ]),
            if (kPaymentConfig['EnableShipping'] as bool &&
                kPaymentConfig['EnableAddress'] as bool)
              Center(
                  child: TextButton(
                      onPressed: () {
                        widget.onBack!();
                      },
                      child: Text(S.of(context).goBackToShipping,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 15,
                              color: kGrey400))))
          ],
        );
      },
    );
  }

  List<Widget> getProducts(CartModel model, BuildContext context) {
    return model.productsInCart.keys.map(
      (key) {
        String productId = Product.cleanProductID(key);

        return Column(
          children: [
            ShoppingCartRow(
              product: model.getProductById(productId),
              variation: model.getProductVariationById(key),
              quantity: model.productsInCart[key],
              options: model.productsMetaDataInCart[key],
              lang: Provider.of<AppModel>(context, listen: false).langCode ?? "en",
            ),
            //  Notes(),
          ],
        );
      },
    ).toList();
  }
}

class ShippingAddressInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);
    final address = cartModel.address;

    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    S.of(context).firstName + " :",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address?.firstName ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    S.of(context).lastName + " :",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address?.lastName ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    S.of(context).email + " :",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address?.email ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    S.of(context).streetName + " :",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address?.street ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    S.of(context).city + " :",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address?.city ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    S.of(context).stateProvince + " :",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address?.state ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                )
              ],
            ),
          ),
          FutureBuilder(
            future: Services().widget?.getCountryName(context, address?.country),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 120,
                        child: Text(
                          S.of(context).country + " :",
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          snapshot.data,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Text(
                    S.of(context).phoneNumber + " :",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    address?.phoneNumber ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
