import 'package:another_flushbar/flushbar.dart';
import 'package:ctown/common/constants.dart';
import 'package:ctown/common/constants/route_list.dart';
import 'package:ctown/models/cart/cart_base.dart';
import 'package:ctown/models/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';

class AnimatedAddCartButton extends StatefulWidget {
  final int? quantity;
  final Widget? productPrice;
  final Function? onPressed;
  final String? productName;
  CartModel? cartModel;
  final String? productId;
  final int? qtyAvailable;
  final String? cartProducts;
  final productsInCart;
  final product;
  final String? price;
  Product? product1;
  final int? max_sale_qty;
  final String? producttype;
  final bool isLoading;

  AnimatedAddCartButton(
      {super.key,
      this.qtyAvailable,
      this.product1,
      this.onPressed,
      this.quantity,
      this.max_sale_qty,
      this.cartModel,
      this.productsInCart,
      this.productId,
      this.productPrice,
      this.productName,
      this.producttype,
      this.product,
      this.cartProducts,
      this.price,
      this.isLoading = false});

  @override
  _AnimatedAddCartButtonState createState() => _AnimatedAddCartButtonState();
}

class _AnimatedAddCartButtonState extends State<AnimatedAddCartButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  //Animation _animation;
  int selectedQty = 0;
  bool isLoading = false;
  bool isPresent = false;
  late Size screenSize;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    for (int i = 0; i < widget.productsInCart.length; i++) {
      if (widget.productsInCart[i] == widget.productId) {
        isPresent = true;
        break;
      }
    }
    if (widget.productName == "Bbq Skewers") {
      if (widget.qtyAvailable != null && widget.qtyAvailable! < 1) {
        isPresent = false;
        print("not in the cart");
      }
    }

    isPresent ? _animationController.value = 1 : _animationController.value = 0;
    if (widget.quantity == null) {
      _animationController.value = 0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    if (widget.quantity == null) {
      _animationController.value = 0;
    }
    else {
      if(widget.cartModel!.productsInCart.containsKey(widget.productId)) {
        _animationController.value = 1;
      }
      else {
        _animationController.value = 0;
      }
    }
    return Container(
      width: 140,
      child: Stack(
        children: [
          Positioned(
            left: -10.0,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => Transform(
                transform: Matrix4.translationValues(_animationController.value * 10, 0.0, 0.0),
                child: Opacity(
                  opacity: _animationController.value,
                  child: IconButton(
                    padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                    icon: Icon(
                      Icons.remove_circle,
                      color: Theme.of(context).primaryColor,
                      size: 24.0,
                    ),
                    onPressed: () async {
                      print("=============");
                      print(widget.quantity);
                      print("*********");
                      if (widget.quantity == null) {
                        setState(() {
                          _animationController.value = 0;
                        });
                      }
                      if (widget.quantity != null && widget.quantity! > 1) {
                        setState(() {
                          isLoading = true;
                        });
                        await widget.onPressed!(-1);
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -10.0,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => Transform(
                transform: Matrix4.translationValues(-_animationController.value * 10, 0.0, 0.0),
                child: Opacity(
                  opacity: _animationController.value,
                  child: IconButton(
                    padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                    icon: Icon(
                      Icons.add_circle,
                      color: Theme.of(context).primaryColor,
                      size: 24.0,
                    ),
                    onPressed: () async {
                      print("max_qty");
                      print(widget.max_sale_qty);
                      print("center");
                      if (widget.quantity != null && widget.max_sale_qty != null && widget.quantity! < widget.max_sale_qty!) {
                        print("=============");
                        print(widget.quantity);
                        print("*********");
                        if (widget.quantity == null) {
                          setState(() {
                            _animationController.value = 0;
                          });
                        }

                        if (widget.qtyAvailable != null && widget.quantity != null && widget.qtyAvailable! > widget.quantity!) {
                          setState(() {
                            isLoading = true;
                          });
                          await widget.onPressed!(1);
                          setState(() {
                            isLoading = false;
                          });
                        }
                      } else {
                        print("sucess");
                        Flushbar(
                          message: "The maximum you may purchase is ${widget.max_sale_qty}",
                          icon: Icon(
                            Icons.info_outline,
                            size: 28.0,
                            color: Colors.blue[300],
                          ),
                          duration: const Duration(seconds: 2),
                          leftBarIndicatorColor: Colors.blue[300],
                        ).show(context);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return widget.isLoading
                    ? Padding(
                        padding: const EdgeInsets.only(top: 15.0, bottom: 13.0),
                        child: SpinKitCubeGrid(
                          color: Theme.of(context).primaryColor,
                          size: 20.0,
                        ),
                      )
                    : Opacity(
                        opacity: _animationController.value,
                        child: TextButton(
                          onPressed: () async {
                            if (widget.quantity == null) {
                              setState(() {
                                _animationController.value = 0;
                              });
                            } else {
                              selectedQty = widget.quantity!;
                              selectedQty = await showModalBottomSheet(
                                useRootNavigator: true,
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, setState) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                //Text("sample text"),
                                                widget.productPrice ?? const SizedBox.shrink(),
                                                const Spacer(),
                                                GestureDetector(
                                                  onTap: () async {
                                                    if (selectedQty != 0 && widget.quantity != null) {
                                                      print("runnning");
                                                      Navigator.of(context).pop(selectedQty);
                                                      await widget.onPressed!(selectedQty - widget.quantity!);
                                                      // Navigator.of(context,rootNavigator:true).pop();
                                                      print("finished");
                                                      print("loading");
                                                    }

                                                    // Navigator.of(context)
                                                    //     .pop(selectedQty);
                                                  },
                                                  child: Text(
                                                    "Update",
                                                    style: TextStyle(
                                                      color: Theme.of(context).primaryColor,
                                                      decoration: TextDecoration.underline,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Divider(),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: List.generate(
                                                widget.qtyAvailable ?? 0,
                                                (index) => ListTile(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedQty = index + 1;
                                                    });
                                                  },
                                                  dense: true,
                                                  title: Text(
                                                    "${index + 1}",
                                                  ),
                                                  trailing: selectedQty == index + 1 ? const Icon(Icons.check) : null,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                              setState(() {
                                isLoading = true;
                              });
                              // if (selectedQty != null) {
                              //   await widget.onPressed(selectedQty - widget.quantity);
                              // }

                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Text(
                                  '${widget.quantity != null ? widget.quantity : 0}',
                                ),
                        ),
                      );
              },
            ),
          ),
          Offstage(
            offstage: _animationController.value == 1,
            child: Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, snapshot) {
                  return Transform.translate(
                    offset: Offset(0, _animationController.value * 30),
                    child: Opacity(
                      opacity: 1 - _animationController.value,
                      child: SizedBox(
                        width: 120,
                        child: TextButton(
                            onPressed: () async {
                              print(widget.price);
                              if (widget.producttype == "configurable") {
                                Navigator.of(
                                  context,
                                  //rootNavigator: !isBigScreen(context), // Push in tab for tablet (IPad)
                                ).pushNamed(
                                  RouteList.productDetail,
                                  arguments: widget.product,
                                );
                              } else {
                                if (Provider.of<UserModel>(context, listen: false).loggedIn) {
                                  _animationController.forward();
                                  setState(() {
                                    isLoading = true;
                                  });

                                  await widget.onPressed!(1);

                                  // if (!isSuccess) {
                                  // _animationController.reset();
                                  // }

                                  setState(() {
                                    isLoading = false;
                                  });
                                } else {
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pushNamed(RouteList.login);
                                }
                              }
                            },
                            style: TextButton.styleFrom(backgroundColor: Colors.yellow, foregroundColor: Colors.black),
                            child: widget.producttype == "configurable"
                                ? Text(S.of(context).view, style: const TextStyle(fontSize: 11.7))
                                : Text(S.of(context).addToCart, style: const TextStyle(fontSize: 11.7))),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
