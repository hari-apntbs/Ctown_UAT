import 'package:ctown/models/app_model.dart';
import 'package:ctown/models/payment_method_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../models/index.dart' show Order, UserModel, PointModel;
import '../../screens/base.dart';
import '../../services/index.dart';
import "package:ctown/screens/orders/orders.dart";

import '../../tabbar.dart';

class OrderedSuccess extends StatefulWidget {
  final Order? order;
  final bool? isModal;

  final PageController? controller;
  OrderedSuccess({this.order, this.isModal, this.controller});

  @override
  _OrderedSuccessState createState() => _OrderedSuccessState();
}

class _OrderedSuccessState extends BaseScreen<OrderedSuccess> {
  @override
  void afterFirstLayout(BuildContext context) {
    final user = Provider.of<UserModel>(context, listen: false).user;
    if (user != null && user.cookie != null) {
      Services().updatePoints(user.cookie, widget.order);
      Provider.of<PointModel>(context, listen: false).getMyPoint(user.cookie);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    return ListView(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(color: Theme.of(context).primaryColorLight),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  S.of(context).itsOrdered,
                  style: TextStyle(
                      fontSize: 16, color: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      S.of(context).orderNo,
                      style: TextStyle(
                          fontSize: 14, color: Theme.of(context).colorScheme.secondary),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        "#${widget.order!.increment_id}",
                        style: TextStyle(
                            fontSize: 14, color: Theme.of(context).colorScheme.secondary),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        Text(
          S.of(context).orderSuccessTitle1,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Theme.of(context).colorScheme.secondary),
        ),
        const SizedBox(height: 15),
        Text(
          Provider.of<PaymentMethodModel>(context, listen: false)
                          .selectedMethod ==
                      "checkmo" ||
                  Provider.of<PaymentMethodModel>(context, listen: false)
                          .selectedMethod ==
                      "msp_cashondelivery"
              ? Provider.of<AppModel>(context, listen: false).langCode != "en"
                  ? "شكرًا لك على طلبك ${widget.order!.increment_id != null ? widget.order!.increment_id : "null"}. تم حجز مبلغ بقيمة ${Provider.of<PaymentMethodModel>(context, listen: false).total != null ? Provider.of<PaymentMethodModel>(context, listen: false).total.toStringAsFixed(3) : "null total"} درهمًا على بطاقة الائتمان الخاصة بك. سيتم إرسال القيمة النهائية لطلبك في وقت التسليم."
                  : "Thank you for your order ${widget.order!.increment_id != null ? widget.order!.increment_id : "null"}. A Hold of AED ${Provider.of<PaymentMethodModel>(context, listen: false).total != null ? Provider.of<PaymentMethodModel>(context, listen: false).total.toStringAsFixed(3) : "null total"} is placed on your CC. Final bill will be submitted at time of delivery."
              : S.of(context).orderSuccessMsg1,
          style: TextStyle(
              color: Theme.of(context).colorScheme.secondary, height: 1.4, fontSize: 14),
        ),
        if (userModel.user != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Row(children: [
              Expanded(
                child: ButtonTheme(
                  height: 50,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // Navigator.of(context).pushNamed(
                      //   "/orders",
                      // );
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyOrders(
                                    fromWhere: "success",
                                  )));
                    },
                    child: Text(
                      S.of(context).showAllMyOrdered.toUpperCase(),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        const SizedBox(height: 40),
        Text(
          S.of(context).orderSuccessTitle2,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Theme.of(context).colorScheme.secondary),
        ),
        const SizedBox(height: 10),
        Text(
          S.of(context).orderSuccessMsg2,
          style: TextStyle(
              color: Theme.of(context).colorScheme.secondary, height: 1.4, fontSize: 14),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Row(
            children: [
              Expanded(
                child: ButtonTheme(
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Theme.of(context).colorScheme.secondary),
                          borderRadius: BorderRadius.circular(25.0)
                      )
                    ),
                    child: Text(
                      S.of(context).backToShop.toUpperCase(),
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    ),
                    onPressed: () {
                      if (widget.isModal != null && widget.isModal == true) {
                        // Navigator.of(context)
                        //     .popUntil((route) => route.isFirst);
                        Navigator.of(context).pop();
                        MainTabControlDelegate.getInstance().changeTab("home");
                      } else {
                        // widget.controller.animateToPage(
                        //   0,
                        //   duration: const Duration(milliseconds: 250),
                        //   curve: Curves.easeInOut,
                        // );
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
