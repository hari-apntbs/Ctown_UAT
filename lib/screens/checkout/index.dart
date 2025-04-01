import 'package:ctown/models/entities/address.dart';
import 'package:ctown/screens/settings/address_book.dart';
import 'package:ctown/widgets/home/clickandcollect_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show AppModel, CartModel, Order, ShippingMethodModel, UserModel;
import '../../screens/base.dart';
import '../../services/index.dart';
import '../../widgets/common/checkout_countdown_timer.dart';
import 'address_review_screen.dart';
import 'payment.dart';
import 'review_screen.dart';
import 'success.dart';

class Checkout extends StatefulWidget {
  final PageController? controller;
  final bool? isModal;
  final int? checkoutTimelimit;
  final List<Address>? listAddress;

  Checkout(
      {this.controller,
      this.isModal,
      this.checkoutTimelimit,
      this.listAddress});

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends BaseScreen<Checkout> {
  int tabIndex = 0;
  Order? newOrder;
  bool isPayment = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (Provider.of<ClickNCollectProvider>(context, listen: false)
            .deliveryType ==
        "clickandcollect") {
      print("seeting tab index");

      // setState(() {
      tabIndex = 1;
      // });
      print(tabIndex);
    }
  }

  void setLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (!(kPaymentConfig['EnableAddress'] as bool)) {
      setState(() {
        tabIndex = 1;
      });
      if (!(kPaymentConfig['EnableShipping'] as bool)) {
        setState(() {
          tabIndex = 2;
        });
        if (!(kPaymentConfig['EnableReview'] as bool)) {
          setState(() {
            tabIndex = 3;
            isPayment = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);
    final langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";

    Widget progressBar = Row(
      children: <Widget>[
        kPaymentConfig['EnableAddress'] as bool
            ? Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      tabIndex = 0;
                    });
                  },
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          S.of(context).address.toUpperCase(),
                          style: TextStyle(
                              color: tabIndex == 0
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).colorScheme.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      tabIndex >= 0
                          ? ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(2.0),
                                  bottomLeft: Radius.circular(2.0)),
                              child: Container(
                                  height: 3.0,
                                  color: Theme.of(context).primaryColor),
                            )
                          : Divider(
                              height: 2, color: Theme.of(context).colorScheme.secondary)
                    ],
                  ),
                ),
              )
            : Container(),
        kPaymentConfig['EnableShipping'] as bool
            ? Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (cartModel.address != null && (cartModel.address?.isValid())!) {
                      setState(() {
                        tabIndex = 1;
                      });
                    }
                  },
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          langCode == "en" ? "DELIVERY" : "التوصيل",
                          style: TextStyle(
                              color: tabIndex == 1
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).colorScheme.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      tabIndex >= 1
                          ? Container(
                              height: 3.0,
                              color: Theme.of(context).primaryColor)
                          : Divider(
                              height: 2, color: Theme.of(context).colorScheme.secondary)
                    ],
                  ),
                ),
              )
            : Container(),
        kPaymentConfig['EnableReview'] as bool
            ? Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (cartModel.shippingMethod != null) {
                      setState(() {
                        tabIndex = 2;
                      });
                    }
                  },
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          S.of(context).review.toUpperCase(),
                          style: TextStyle(
                            color: tabIndex == 2
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).colorScheme.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      tabIndex >= 2
                          ? Container(
                              height: 3.0,
                              color: Theme.of(context).primaryColor)
                          : Divider(
                              height: 2, color: Theme.of(context).colorScheme.secondary)
                    ],
                  ),
                ),
              )
            : Container(),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (cartModel.shippingMethod != null) {
                setState(() {
                  tabIndex = 3;
                });
              }
            },
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Text(
                    S.of(context).payment.toUpperCase(),
                    style: TextStyle(
                      color: tabIndex == 3
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                tabIndex >= 3
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(2.0),
                            bottomRight: Radius.circular(2.0)),
                        child: Container(
                            height: 3.0, color: Theme.of(context).primaryColor),
                      )
                    : Divider(height: 2, color: Theme.of(context).colorScheme.secondary)
              ],
            ),
          ),
        )
      ],
    );

    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              S.of(context).checkout,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
            leading: newOrder == null ?
            Center(
              child: GestureDetector(
                onTap: () {
                  if(tabIndex == 0) {
                    Navigator.pop(context);
                  }
                  else {
                    setState(() {
                      tabIndex -= 1;
                    });
                  }
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ) : const SizedBox.shrink(),
            actions: <Widget>[
              if (widget.checkoutTimelimit != 0 && newOrder == null)
                CheckoutCountDownTimer(
                  Duration(minutes: widget.checkoutTimelimit!),
                  onEnd: () {
                    Navigator.of(context).pushNamed(RouteList.dashboard);
                  },
                  textColor: Colors.white,
                ),
              // if (widget.isModal != null && widget.isModal == true)
              //   IconButton(
              //     icon: const Icon(Icons.close, size: 24),
              //     onPressed: () {
              //       if (Navigator.of(context).canPop()) {
              //         Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
              //       } else {
              //         ExpandingBottomSheet.of(context, isNullOk: true)?.close();
              //       }
              //     },
              //   ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: newOrder != null
                        ? PopScope(
                          canPop: false,
                          child: OrderedSuccess(
                              order: newOrder,
                              isModal: widget.isModal,
                              controller: widget.controller,
                            ),
                        )
                        : Column(
                            children: <Widget>[
                              !isPayment ? progressBar : Container(),
                              Expanded(
                                child: ListView(
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 10),
                                  children: <Widget>[renderContent()],
                                ),
                              )
                            ],
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
        isLoading
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.white.withOpacity(0.36),
                child: kLoadingWidget(context),
              )
            : Container()
      ],
    );
  }

  Widget renderContent() {
    switch (tabIndex) {
      case 0:
        print("case 0 is active");
        final cartModel = Provider.of<CartModel>(context, listen: false);
        print("My test");
        print("CartModel: ${cartModel.address}");
        print("ListAddress: ${widget.listAddress}");
        return cartModel.address != null &&
                (cartModel.address?.isValid())! &&
                widget.listAddress!.isNotEmpty
            ? AddressReviewScreen(
                onNext: () {
                  Future.delayed(Duration.zero, () {
                    print("tab $tabIndex");
                    setState(() {
                      if (kPaymentConfig['EnableShipping'] as bool) {
                        tabIndex = 1;
                      } else {
                        tabIndex = 2;
                      }
                    });
                    print("tab $tabIndex");
                  });
                },
              )
            :Container(
              child:   ButtonTheme(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0.0,
              foregroundColor: Theme.of(context).colorScheme.secondary,
              backgroundColor: Theme.of(context).primaryColorLight,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddressBook()));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  FontAwesomeIcons.solidAddressBook,
                  size: 16,
                ),
                const SizedBox(width: 10.0),
                Text(
                  S.of(context).selectAddress.toUpperCase(),
                ),
              ],
            ),
          ),
        ),
            );
            //  ShippingAddress(onNext: () {
            //     Future.delayed(Duration.zero, () {
            //       print("tab $tabIndex");
            //       setState(() {
            //         if (kPaymentConfig['EnableShipping']) {
            //           tabIndex = 1;
            //         } else {
            //           tabIndex = 2;
            //         }
            //       });
            //     });
            //     print("tab $tabIndex");
            //   });
      case 1:
        print("case 1 is active");
        if (Provider.of<ClickNCollectProvider>(context, listen: false)
                .deliveryType ==
            "clickandcollect") {
          print(" is running");
          final token =
              Provider.of<UserModel>(context, listen: false).user != null
                  ? Provider.of<UserModel>(context, listen: false).user!.cookie
                  : null;
          CartModel cartModel = Provider.of<CartModel>(context, listen: false);
          Provider.of<ShippingMethodModel>(context, listen: false)
              .getShippingMethods(
                  cartModel: cartModel,
                  token: token,
                  checkoutId: cartModel.getCheckoutId(),
                  clickNCollectProvider: Provider.of<ClickNCollectProvider>(
                      context,
                      listen: false));
        }
        return Services().widget?.renderShippingMethods(context, onBack: () {
          if (Provider.of<ClickNCollectProvider>(context, listen: false)
                  .deliveryType ==
              "homedelivery")
            setState(() {
              tabIndex -= 1;
            });
        }, onNext: () {
          setState(() {
            tabIndex = 2;
          });
        }) ?? const SizedBox.shrink();
      case 2:
        print("case 2 is active");
        return
            //  ClickAndCollect();

            ReviewScreen(onBack: () {
          if (kPaymentConfig['EnableShipping'] as bool &&
              kPaymentConfig['EnableAddress'] as bool) {
            setState(() {
              tabIndex -= 1;
            });
          }
        }, onNext: () {
          setState(() {
            tabIndex = 3;
          });
        });
      case 3:
      default:
        return PaymentMethods(
            onBack: () {
              setState(() {
                tabIndex -= 1;
              });
            },
            onFinish: (order) {
              setState(() {
                newOrder = order;
              });
              Provider.of<CartModel>(context, listen: false).clearCart();
            },
            onLoading: setLoading);
    }
  }
  /*  case 0:
        final cartModel = Provider.of<CartModel>(context, listen: false);
        return cartModel.address != null && cartModel.address.isValid()
            ? AddressReviewScreen(
                onNext: () {
                  Future.delayed(Duration.zero, () {
                    setState(() {
                      if (kPaymentConfig['EnableShipping']) {
                        tabIndex = 1;
                      } else {
                        tabIndex = 2;
                      }
                    });
                  });
                },
              )
            : ShippingAddress(onNext: () {
                Future.delayed(Duration.zero, () {
                  setState(() {
                    if (kPaymentConfig['EnableShipping']) {
                      tabIndex = 1;
                    } else {
                      tabIndex = 2;
                    }
                  });
                });
              });
      case 1:
        return Services().widget.renderShippingMethods(context, onBack: () {
          setState(() {
            tabIndex -= 1;
          });
        }, onNext: () {
          setState(() {
            tabIndex = 2;
          });
        });
      case 2:
        return ReviewScreen(onBack: () {
          if (kPaymentConfig['EnableShipping'] &&
              kPaymentConfig['EnableAddress']) {
            setState(() {
              tabIndex -= 1;
            });
          }
        }, onNext: () {
          setState(() {
            tabIndex = 3;
          });
        });
      case 3:
      default:
        return PaymentMethods(
            onBack: () {
              setState(() {
                tabIndex -= 1;
              });
            },
            onFinish: (order) {
              setState(() {
                newOrder = order;
              });
              Provider.of<CartModel>(context, listen: false).clearCart();
            },
            onLoading: setLoading);
  }  }*/

}
