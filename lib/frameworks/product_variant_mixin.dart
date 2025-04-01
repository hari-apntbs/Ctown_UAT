import 'dart:convert' as convert;

import 'package:another_flushbar/flushbar.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart';

import '../common/config.dart';
import '../common/constants/general.dart';
import '../common/constants/route_list.dart';
import '../generated/l10n.dart';
import '../models/app_model.dart';
import '../models/index.dart'
    show
        Attribute,
        CartModel,
        Product,
        ProductModel,
        ProductVariation,
        UserModel,
        WishListModel;
import '../screens/cart/cart.dart';
import '../widgets/common/webview.dart';
import '../widgets/product/product_variant.dart';
import 'magento/services/magento.dart';

mixin ProductVariantMixin {
  Future<ProductVariation> updateVariation(List<ProductVariation> variations,
      Map<String, String> mapAttribute) async {
    if (variations.isNotEmpty) {
      bool checkVariation = await checkVariantLengths(variations, mapAttribute);
      var variation = variations.firstWhere((item) {
        bool isCorrect = true;
        for (var attribute in item.attributes) {
          if (attribute.option != mapAttribute[attribute.name] &&
              (attribute.id != null || checkVariation)) {
            isCorrect = false;
            break;
          }
        }
        if (isCorrect) {
          for (var key in mapAttribute.keys.toList()) {
            bool check = false;
            for (var attribute in item.attributes) {
              if (key == attribute.name) {
                check = true;
                break;
              }
            }
            if (!check) {
              Attribute att = Attribute()
                ..id = null
                ..name = key
                ..option = mapAttribute[key];
              item.attributes.add(att);
            }
          }
        }
        return isCorrect;
      }, orElse: () {
        return ProductVariation();
      });
      return variation;
    }
    return ProductVariation();
  }

  bool checkVariantLengths(variations, mapAttribute) {
    for (var variant in variations) {
      if (variant.attributes.length == mapAttribute.keys.toList().length) {
        bool check = true;
        for (var i = 0; i < variant.attributes.length; i++) {
          if (variant.attributes[i].option !=
              mapAttribute[variant.attributes[i].name]) {
            check = false;
            break;
          }
        }
        if (check) {
          return true;
        }
      }
    }
    return false;
  }

  bool isPurchased(
    ProductVariation productVariation,
    Product product,
    Map<String, String> mapAttribute,
    bool isAvailable,
  ) {
    bool inStock =
        productVariation != null ? productVariation.inStock! : product.inStock!;

    final isValidAttribute =
        product.attributes!.length == mapAttribute.length &&
            (product.attributes!.length == mapAttribute.length ||
                product.type != "variable");

    return inStock && isValidAttribute && isAvailable;
  }

  List<Widget> makeProductTitleWidget(BuildContext context,
      ProductVariation productVariation, Product product, bool isAvailable) {
    List<Widget> listWidget = [];

    bool inStock = (productVariation != null
            ? productVariation.inStock
            : product.inStock) ??
        false;

    String stockQuantity =
        product.stockQuantity != null ? ' (${product.stockQuantity}) ' : '';

    if (Provider.of<ProductModel>(context, listen: false).productVariation !=
        null) {
      stockQuantity = Provider.of<ProductModel>(context, listen: false)
                  .productVariation!
                  .stockQuantity !=
              null
          ? ' (${Provider.of<ProductModel>(context, listen: false).productVariation!.stockQuantity}) '
          : '';
    }

    if (isAvailable) {
      listWidget.add(
        product.status == true ? Container() : const SizedBox(height: 5.0),
      );

      listWidget.add(
        Row(
          children: <Widget>[
            if (kAdvanceConfig['showStockStatus'] as bool) ...[
              product.status == true
                  ? Container()
                  : Text(
                      "${S.of(context).availability}: ",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
              product.backOrdered
                  ? Text(
                      '${S.of(context).backOrder}',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: const Color(0xFFEAA601),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                    )
                  : product.status == true
                      ? Container()
                      : Text(
                          // '${S.of(context).inStock} ${stockQuantity ?? ''}'
                          S.of(context).outOfStock,
                          style:
                              Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color:
                                        // inStock
                                        product.status == true
                                            ? Theme.of(context).primaryColor
                                            : const Color(0xFFe74c3c),
                                    fontWeight: FontWeight.w600,
                                  ),
                        )
              // Text(
              //     inStock
              //         ? '${S.of(context).inStock} ${stockQuantity ?? ''}'
              //         : S.of(context).outOfStock,
              //     style: Theme.of(context).textTheme.subtitle2.copyWith(
              //           color: inStock
              //               ? Theme.of(context).primaryColor
              //               : const Color(0xFFe74c3c),
              //           fontWeight: FontWeight.w600,
              //         ),
              //   )
            ],
          ],
        ),
      );
      listWidget.add(
        const SizedBox(height: 5.0),
      );

      listWidget.add(
        Row(
          children: <Widget>[
            if (product.sku != null && product.sku != '') ...[
              if (product.package_info != null && product.package_info != "")
                Text(
                  S.of(context).units,
                  style: (Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 18,
                      )),
                ),
              Text(
                product.package_info ?? "",
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: inStock
                          ? Theme.of(context).primaryColor
                          : const Color(0xFFe74c3c),
                      fontWeight: FontWeight.w600,
                      // fontFamily: 'raleway',
                    ),
              ),
            ],
          ],
        ),
      );

      // listWidget.add(
      //   const SizedBox(height: 5.0),
      // );
      // listWidget.add(
      //   Row(
      //     children: <Widget>[
      //       // if (kAdvanceConfig['showStockStatus']) ...[
      //       Text(
      //         "Brand: ",
      //         style: Theme.of(context).textTheme.subtitle2,
      //       ),
      //     Text(
      //       product.brand,
      //       style: Theme.of(context).textTheme.subtitle2.copyWith(
      //         color: inStock
      //             ? Theme.of(context).primaryColor
      //             : const Color(0xFFe74c3c),
      //         fontWeight: FontWeight.w600,fontFamily: 'raleway',
      //       ),
      //     )
      //       //  ],
      //     ],
      //   ),
      // );
      // listWidget.add(
      //   const SizedBox(height: 5.0),
      // );
      // listWidget.add(
      //   Row(
      //     children: <Widget>[
      //       // if (kAdvanceConfig['showStockStatus']) ...[
      //       Text(
      //         "Country of Origin: ",
      //         style: Theme.of(context).textTheme.subtitle2,
      //       ),
      //       Text(
      //         product.country_of_manufacture,
      //         style: Theme.of(context).textTheme.subtitle2.copyWith(
      //           color: inStock
      //               ? Theme.of(context).primaryColor
      //               : const Color(0xFFe74c3c),
      //           fontWeight: FontWeight.w600,fontFamily: 'raleway',
      //         ),
      //       )
      //       //  ],
      //     ],
      //   ),
      // );
      listWidget.add(
        const SizedBox(height: 15.0),
      );
    }

    return listWidget;
  }

  List<Widget> makeBuyButtonWidget(
    BuildContext context,
    ProductVariation productVariation,
    Product product,
    Map<String, String> mapAttribute,
    int maxQuantity,
    int quantity,
    Function onChangeQuantity,
    bool isAvailable,
    bool isProductCard
  ) {
    final ThemeData theme = Theme.of(context);
    Size screenSize = MediaQuery.of(context).size;

    bool inStock = (productVariation.id != null
            ? productVariation.inStock
            : product.inStock) ??
        false;
    final isExternal = product.type == "external" ? true : false;
    bool loggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;
    if (!inStock && !isExternal) return [];
    if (!loggedIn) {
      return [
        if (!isExternal) const SizedBox(width: 10),
        if (!isExternal && product.status == true)
          Row(
            children: [
              if (product.type != "configurable")
                Expanded(
                  child: Container(
                    height: 32.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: QuantitySelection(
                      product: product,
                      price: product.price,
                      expanded: true,
                      value: quantity,
                      color: theme.colorScheme.secondary,
                      limitSelectQuantity:
                          maxQuantity > 300 ? 300 : maxQuantity,
                      onChanged: onChangeQuantity,
                    ),
                  ),
                ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamed(RouteList.login);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black,
                      ),
                      child: FittedBox(
                        child: Text(
                          S.of(context).addToCart,
                          style: TextStyle(fontSize: 11.7),
                          maxLines: 1,
                        ),
                      )),
                ),
              ),
            ],
          )
        // Row(
        //   children: [
        //     Expanded(
        //       child: Container(
        //         height: 32.0,
        //         alignment: Alignment.center,
        //         decoration: BoxDecoration(
        //           borderRadius: BorderRadius.circular(3),
        //         ),
        //         child: QuantitySelection(
        //           expanded: true,
        //           value: quantity,
        //           color: theme.primaryColor,
        //           limitSelectQuantity: product.max_sale_qty,
        //           onChanged: onChangeQuantity,
        //         ),
        //       ),
        //     ),
        //     const SizedBox(width: 10),
        //     if (isAvailable && inStock && !isExternal)
        //       Expanded(
        //         child: GestureDetector(
        //           onTap: () {
        //             Navigator.of(
        //               context,
        //               rootNavigator: true,
        //             ).pushNamed(RouteList.login);
        //           },
        //           child: Container(
        //             height: 50,
        //             decoration: BoxDecoration(
        //                 borderRadius: BorderRadius.circular(25.0),
        //                 color: Colors.green),
        //             child: Center(
        //               child: Text(
        //                 S.of(context).addToCart.toUpperCase(),
        //                 style: TextStyle(
        //                   color: Colors.black,
        //                   fontWeight: FontWeight.bold,
        //                   fontSize: 12,
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //   ],
        // ),
      ];
    } else {
      return [
        if (!isExternal) const SizedBox(width: 5),
        if (!isExternal && product.status == true)
          Column(
            children: [
              Row(
                children: [
                  if (product.type != "configurable")
                    Expanded(
                      child: Container(
                        height: 32.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: QuantitySelection(
                          product: product,
                          price: product.price,
                          expanded: true,
                          value: quantity,
                          color: theme.colorScheme.secondary,
                          limitSelectQuantity:
                              maxQuantity > 300 ? 300 : maxQuantity,
                          onChanged: onChangeQuantity,
                        ),
                      ),
                    ),
                  if (product.status == true)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 20, right: 20),
                        child: isProductCard &&  Provider.of<CartModel>(context, listen: false).isLoadingProduct(product.id) ?
                        Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20.0, bottom: 8),
                              child: SpinKitCubeGrid(
                                color: Theme.of(context).primaryColor,
                                size: 20.0,
                              ),
                            ),
                        )
                            :TextButton(
                            onPressed: () async {
                              if (quantity <= product.max_sale_qty!) {
                                CartModel cartModel = Provider.of<CartModel>(
                                    context,
                                    listen: false);
                                printLog(cartModel.productsInCart);

                                if (product.type == "configurable" &&
                                    product.variableprice == true) {
                                  printLog("=====================");
                                  printLog(onChangeQuantity);
                                  printLog(product.name);
                                  printLog(Provider.of<ProductModel>(context,
                                      listen: false)
                                      .productVariation!
                                      .name);

                                  addToCartConfigurable(context,
                                      product: product,
                                      quantity: quantity,
                                      name: productVariation.name,
                                      variation: productVariation,
                                      lang: Provider.of<AppModel>(context, listen: false).langCode, isProductCard: isProductCard);
                                } else if (product.type == "configurable" &&
                                    product.variableprice == false) {
                                  Flushbar(
                                    message: Provider.of<AppModel>(context, listen: false).langCode == "en" ? "Product weight is required" : "الرجاء اختيار الوزن",
                                    icon: Icon(
                                      Icons.info_outline,
                                      size: 28.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    duration: Duration(milliseconds: 1200),
                                    leftBarIndicatorColor:
                                    Theme.of(context).primaryColor,
                                  ).show(context);
                                } else {
                                  addToCartNormal(context, product, quantity,
                                      productVariation, mapAttribute, inStock, isProductCard);
                                }
                              } else {
                                printLog("success");
                                Flushbar(
                                  message:
                                  "The maximum you may purchase is ${product.max_sale_qty}",
                                  icon: Icon(
                                    Icons.info_outline,
                                    size: 28.0,
                                    color: Colors.blue[300],
                                  ),
                                  duration: Duration(seconds: 2),
                                  leftBarIndicatorColor: Colors.blue[300],
                                )..show(context);
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.yellow,
                              foregroundColor: Colors.black,
                            ),
                            child: FittedBox(
                              child: Text(
                                S.of(context).addToCart,
                                style: const TextStyle(fontSize: 11.7),
                                maxLines: 1,
                              ),
                            ))
                        // child: qty > 0 ? TextButton(
                        //     onPressed: () async {
                        //       if (quantity <= product.max_sale_qty!) {
                        //         CartModel cartModel = Provider.of<CartModel>(
                        //             context,
                        //             listen: false);
                        //         print(cartModel.productsInCart);
                        //
                        //         if (product.type == "configurable" &&
                        //             product.variableprice == true) {
                        //           print("=====================");
                        //           print(onChangeQuantity);
                        //           print(product.name);
                        //           print(Provider.of<ProductModel>(context,
                        //               listen: false)
                        //               .productVariation!
                        //               .name);
                        //
                        //           addToCartConfigurable(context,
                        //               product: product,
                        //               quantity: quantity,
                        //               name: productVariation.name,
                        //               variation: productVariation,
                        //           lang: Provider.of<AppModel>(context, listen: false).langCode);
                        //         } else if (product.type == "configurable" &&
                        //             product.variableprice == false) {
                        //           Flushbar(
                        //             message: "product weight is required",
                        //             icon: Icon(
                        //               Icons.info_outline,
                        //               size: 28.0,
                        //               color: Theme.of(context).primaryColor,
                        //             ),
                        //             duration: Duration(milliseconds: 1200),
                        //             leftBarIndicatorColor:
                        //             Theme.of(context).primaryColor,
                        //           )..show(context);
                        //         } else {
                        //           addToCartNormal(context, product, quantity,
                        //               productVariation, mapAttribute, inStock);
                        //         }
                        //       } else {
                        //         print("success");
                        //         Flushbar(
                        //           message:
                        //           "The maximum you may purchase is ${product.max_sale_qty}",
                        //           icon: Icon(
                        //             Icons.info_outline,
                        //             size: 28.0,
                        //             color: Colors.blue[300],
                        //           ),
                        //           duration: Duration(seconds: 2),
                        //           leftBarIndicatorColor: Colors.blue[300],
                        //         )..show(context);
                        //       }
                        //     },
                        //     style: TextButton.styleFrom(
                        //       backgroundColor: Colors.yellow,
                        //       foregroundColor: Colors.black,
                        //     ),
                        //     child: FittedBox(
                        //       child: Text(
                        //         S.of(context).addToCart,
                        //         style: const TextStyle(fontSize: 11.7),
                        //         maxLines: 1,
                        //       ),
                        //     ))
                        // : Text(
                        //   S.of(context).outOfStock,
                        //   textAlign: TextAlign.center,
                        //   style: const TextStyle(
                        //     color: kColorOutOfStock,
                        //     fontSize: 12.0,
                        //   ),
                        // ),
                      ),
                      // child: GestureDetector(
                      //   onTap: () async {
                      //     if (quantity <= product.max_sale_qty) {
                      //       CartModel cartModel =
                      //           Provider.of<CartModel>(context, listen: false);
                      //       print(cartModel.productsInCart);

                      //       if (product.type == "configurable" &&
                      //           product.variableprice == true) {
                      //         print("=====================");
                      //         print(onChangeQuantity);
                      //         print(product.name);
                      //         print(Provider.of<ProductModel>(context,
                      //                 listen: false)
                      //             .productVariation
                      //             .name);

                      //         addToCartConfigurable(context,
                      //             product: product,
                      //             quantity: quantity,
                      //             name: Provider.of<ProductModel>(context,
                      //                     listen: false)
                      //                 .productVariation
                      //                 .name);
                      //       } else if (product.type == "configurable" &&
                      //           product.variableprice == false) {
                      //         Flushbar(
                      //           message:
                      //               "product weight is required",
                      //           icon: Icon(
                      //             Icons.info_outline,
                      //             size: 28.0,
                      //             color: Theme.of(context).primaryColor,
                      //           ),
                      //           duration: Duration(seconds: 3),
                      //           leftBarIndicatorColor: Theme.of(context).primaryColor,
                      //         )..show(context);
                      //       } else {
                      //         addToCartNormal(context, product, quantity,
                      //             productVariation, mapAttribute, inStock);
                      //       }
                      //     } else {
                      //       print("success");
                      //       Flushbar(
                      //         message:
                      //             "The maximum you may purchase is ${product.max_sale_qty}",
                      //         icon: Icon(
                      //           Icons.info_outline,
                      //           size: 28.0,
                      //           color: Colors.blue[300],
                      //         ),
                      //         duration: Duration(seconds: 3),
                      //         leftBarIndicatorColor: Colors.blue[300],
                      //       )..show(context);
                      //     }
                      //   },
                      //   child: Container(
                      //     height: 50,
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(25),
                      //       color: Colors.yellow,
                      //     ),
                      //     child: Center(
                      //       child: Text(
                      //         S.of(context).addToCart.toUpperCase(),
                      //         style: TextStyle(
                      //           color: Colors.black,
                      //           fontWeight: FontWeight.bold,
                      //           fontSize: 12,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ),
                ],
              ),
            ],
          )
      ];
    }
  }

  void addToCartConfigurable(context,
      {required Product product,
      int? quantity,
      String? name,
      required ProductVariation variation,
      String? lang, required bool isProductCard}) async {
    CartModel cartModel = Provider.of<CartModel>(context, listen: false);
    try {
      cartModel.setLoadingProduct(product.id, true);
      if(!isProductCard) {
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
      }
      final LocalStorage storage = LocalStorage('store');
      final userJson = await storage.getItem(kLocalKey["userInfo"]!);
      String token = userJson["cookie"];
      final addProductToCart = cartModel.addProductToCart;

      if (token != "") {
        print("getting configuration");
        var wishListModel = Provider.of<WishListModel>(context, listen: false);
        String url = "https://up.ctown.jo/rest/V1/products/${product.sku}";
        var response = await http.get(Uri.parse(url), headers: {
          'Authorization': 'Bearer ' + serverConfig["accessToken"]!,
          "content-type": "application/json"
        });
        var responseBody;
        List config = [];
        List? values = [];

        if (response.statusCode == 200) {
          responseBody = convert.jsonDecode(response.body);
          values = responseBody["extension_attributes"]
              ["configurable_product_options"];
        }

        variation.attributes.forEach((element) {
          values!.forEach((e) {
            if (e["label"].toString().toLowerCase() ==
                element.name!.toLowerCase()) {
              element.option_id = e["attribute_id"];
            }
          });

          config.add({
            "option_id": "${element.option_id}",
            "option_value": "${element.id}"
          });
        });
        print("setting configuration");
        print("config $config");

        int? qty = quantity;
        MagentoApi()
            .addConfigProduct(cartModel, product.id, token, product.sku, qty, lang,
                configurations: config)
            .then((value) {
          if (value) {} else {
            cartModel.removeOutofStockItem(product.id);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    "Unable to add\nThe product is out of stock or not available")));
          }
        });
        await Future.delayed(const Duration(milliseconds: 1000));
        showFlash(
          context: context,
          duration: const Duration(milliseconds: 1200),
          builder: (context, controller) {
            return Flash(
              controller: controller,
              child: FlashBar(
                controller: controller,
                position: FlashPosition.top,
                backgroundColor: Theme.of(context).primaryColor,
                behavior: FlashBehavior.fixed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0),
                ),
                icon: const Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                title: Text(
                  name ?? product.name!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.0,
                  ),
                ),
                content: Text(
                  S.of(context).addToCartSucessfully,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                  ),
                ),
              ),
            );
          },
        );
        addProductToCart(
            product: product, quantity: quantity!, variation: variation);
        wishListModel.removeToWishlist(product);
      } else {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushNamed(RouteList.login);
      }
    } catch (e) {
      printLog(e.toString());
    } finally {
      cartModel.setLoadingProduct(product.id, false);
      if(!isProductCard) {
        EasyLoading.dismiss();
      }
    }
  }

  /// Add to Cart & Buy Now function
  void addToCartNormal(
      BuildContext context,
      Product product,
      int quantity,
      ProductVariation productVariation,
      Map<String, String> mapAttribute,
      bool inStock,
      bool isProductCard,
      [bool buyNow = false]) async {
    final cartModel = Provider.of<CartModel>(context, listen: false);
    try {
      cartModel.setLoadingProduct(product.id, true);
      int cartQty = 0;
      if(!isProductCard) {
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
      }

      if (!inStock) {
        return;
      }

      if (product.type == "external") {
        openWebView(context, product);
        return;
      }

      if (buyNow == true) {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              body: CartScreen(isModal: true, isBuyNow: true),
            ),
            fullscreenDialog: true,
          ),
        );
      }

      print("My test Cart Issue");

      if (cartModel.productsInCart.containsKey(product.id)) {
        print(cartModel.productsInCart[product.id]);
        cartQty = quantity - cartModel.productsInCart[product.id]!;
      } else {
        cartQty = quantity;
      }

      print(product.max_sale_qty);
      print(quantity);
      print(";;;;;;;;;;;;;;;;;;;;;;;");
      var userModel = Provider.of<UserModel>(context, listen: false);
      var wishListModel = Provider.of<WishListModel>(context, listen: false);
      // await Future.delayed(Duration(milliseconds: 1200));
      MagentoApi()
          .addItemsToCart(
        Provider.of<AppModel>(context, listen: false).langCode,
        cartModel,
        product.id,
        userModel.user?.cookie,
        product.sku,
        quantity,)
          .then((value) => null)
          .catchError((e) {
        cartModel.addProductToCartNew(
            context: context, product: product, quantity: -cartQty);
      });
      await Future.delayed(const Duration(milliseconds: 1100));
      var message = await cartModel.addProductToCartNew(
          context: context, product: product, quantity: cartQty);
      wishListModel.removeToWishlist(product);
      if (product.qty! > 0) {
        showFlash(
          context: context,
          duration: const Duration(milliseconds: 2000),
          builder: (context, controller) {
            return Flash(
              controller: controller,
              dismissDirections: [FlashDismissDirection.startToEnd],
              child: FlashBar(
                controller: controller,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0)
                ),
                position: FlashPosition.top,
                behavior: FlashBehavior.floating,
                backgroundColor: Colors.white,
                icon: const Icon(
                  Icons.check,
                  color: Colors.red,
                ),
                title: Text(
                  product.name ?? "",
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.0,
                  ),
                ),
                content: Text(
                  S.of(context).addToCartSucessfully,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 15.0,
                  ),
                ),
              ),
            );
          },
        );
      } else {
        showFlash(
          context: context,
          duration: const Duration(milliseconds: 2000),
          builder: (context, controller) {
            return Flash(
              controller: controller,
              position: FlashPosition.top,
              dismissDirections: [FlashDismissDirection.startToEnd],
              child: FlashBar(
                controller: controller,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0)
                ),
                behavior: FlashBehavior.floating,
                backgroundColor: Theme.of(context).primaryColor,
                title: Text(
                  product.name ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.0,
                  ),
                ),
                content: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                  ),
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      printLog(e.toString());
    } finally {
      cartModel.setLoadingProduct(product.id, false);
      if(!isProductCard) {
        EasyLoading.dismiss();
      }
    }
  }

  /// Support Affiliate product
  void openWebView(BuildContext context, Product product) {
    if (product.affiliateUrl == null || product.affiliateUrl!.isEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios),
            ),
          ),
          body: const Center(
            child: Text("Not found"),
          ),
        );
      }));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InAppWebView(
          url: product.affiliateUrl,
          title: product.name,
          appBarRequire: true,
        ),
      ),
    );
  }
}

//detailspagee

// import 'package:ctown/common/constants/general.dart';
// import 'package:flash/flash.dart';
// import 'package:flutter/material.dart';
// import 'package:localstorage/localstorage.dart';
// import 'package:provider/provider.dart';

// import '../common/config.dart';
// import '../common/constants/route_list.dart';
// import '../generated/l10n.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert' as convert;
// import '../models/index.dart'
//     show
//         Attribute,
//         CartModel,
//         Product,
//         ProductModel,
//         ProductVariation,
//         UserModel,
//         WishListModel;
// import '../screens/cart/cart.dart';
// import '../widgets/common/webview.dart';
// import '../widgets/product/product_variant.dart';
// import 'magento/services/magento.dart';

// mixin ProductVariantMixin {
//   ProductVariation updateVariation(
//       List<ProductVariation> variations, Map<String, String> mapAttribute) {
//     if (variations != null) {
//       var variation = variations.firstWhere((item) {
//         bool isCorrect = true;
//         for (var attribute in item.attributes) {
//           if (attribute.option != mapAttribute[attribute.name] &&
//               (attribute.id != null ||
//                   checkVariantLengths(variations, mapAttribute))) {
//             isCorrect = false;
//             break;
//           }
//         }
//         if (isCorrect) {
//           for (var key in mapAttribute.keys.toList()) {
//             bool check = false;
//             for (var attribute in item.attributes) {
//               if (key == attribute.name) {
//                 check = true;
//                 break;
//               }
//             }
//             if (!check) {
//               Attribute att = Attribute()
//                 ..id = null
//                 ..name = key
//                 ..option = mapAttribute[key];
//               item.attributes.add(att);
//             }
//           }
//         }
//         return isCorrect;
//       }, orElse: () {
//         return null;
//       });
//       return variation;
//     }
//     return null;
//   }

//   bool checkVariantLengths(variations, mapAttribute) {
//     for (var variant in variations) {
//       if (variant.attributes.length == mapAttribute.keys.toList().length) {
//         bool check = true;
//         for (var i = 0; i < variant.attributes.length; i++) {
//           if (variant.attributes[i].option !=
//               mapAttribute[variant.attributes[i].name]) {
//             check = false;
//             break;
//           }
//         }
//         if (check) {
//           return true;
//         }
//       }
//     }
//     return false;
//   }

//   bool isPurchased(
//     ProductVariation productVariation,
//     Product product,
//     Map<String, String> mapAttribute,
//     bool isAvailable,
//   ) {
//     bool inStock =
//         productVariation != null ? productVariation.inStock : product.inStock;

//     final isValidAttribute = product.attributes.length == mapAttribute.length &&
//         (product.attributes.length == mapAttribute.length ||
//             product.type != "variable");

//     return inStock && isValidAttribute && isAvailable;
//   }

//   List<Widget> makeProductTitleWidget(BuildContext context,
//       ProductVariation productVariation, Product product, bool isAvailable) {
//     List<Widget> listWidget = [];

//     bool inStock = (productVariation != null
//             ? productVariation.inStock
//             : product.inStock) ??
//         false;

//     String stockQuantity =
//         product.stockQuantity != null ? ' (${product.stockQuantity}) ' : '';

//     if (Provider.of<ProductModel>(context, listen: false).productVariation !=
//         null) {
//       stockQuantity = Provider.of<ProductModel>(context, listen: false)
//                   .productVariation
//                   .stockQuantity !=
//               null
//           ? ' (${Provider.of<ProductModel>(context, listen: false).productVariation.stockQuantity}) '
//           : '';
//     }

//     if (isAvailable) {
//       listWidget.add(
//         const SizedBox(height: 5.0),
//       );

//       listWidget.add(
//         Row(
//           children: <Widget>[
//             if (kAdvanceConfig['showStockStatus']) ...[
//               Text(
//                 "${S.of(context).availability}: ",
//                 style: Theme.of(context).textTheme.subtitle2,
//               ),
//               product.backOrdered != null && product.backOrdered
//                   ? Text(
//                       '${S.of(context).backOrder}',
//                       style: Theme.of(context).textTheme.subtitle2.copyWith(
//                             color: const Color(0xFFEAA601),
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                           ),
//                     )
//                   : Text(
//                       product.status == true
//                           ? '${S.of(context).inStock} ${stockQuantity ?? ''}'
//                           : S.of(context).outOfStock,
//                       style: Theme.of(context).textTheme.subtitle2.copyWith(
//                             color:
//                                 // inStock
//                                 product.status == true
//                                     ? Theme.of(context).primaryColor
//                                     : const Color(0xFFe74c3c),
//                             fontWeight: FontWeight.w600,
//                           ),
//                     )
//               // Text(
//               //     inStock
//               //         ? '${S.of(context).inStock} ${stockQuantity ?? ''}'
//               //         : S.of(context).outOfStock,
//               //     style: Theme.of(context).textTheme.subtitle2.copyWith(
//               //           color: inStock
//               //               ? Theme.of(context).primaryColor
//               //               : const Color(0xFFe74c3c),
//               //           fontWeight: FontWeight.w600,
//               //         ),
//               //   )
//             ],
//           ],
//         ),
//       );
//       listWidget.add(
//         const SizedBox(height: 5.0),
//       );

//       listWidget.add(
//         Row(
//           children: <Widget>[
//             if (product.sku != null && product.sku != '') ...[
//               Text(
//                 S.of(context).units,
//                 style: (Theme.of(context).textTheme.subtitle2
//                   ..copyWith(
//                     fontSize: 18,
//                   )),
//               ),
//               Text(
//                 product.unit_of_measurement,
//                 style: Theme.of(context).textTheme.subtitle2.copyWith(
//                       color: inStock
//                           ? Theme.of(context).primaryColor
//                           : const Color(0xFFe74c3c),
//                       fontWeight: FontWeight.w600,
//                       // fontFamily: 'raleway',
//                     ),
//               ),
//             ],
//           ],
//         ),
//       );

//       // listWidget.add(
//       //   const SizedBox(height: 5.0),
//       // );
//       // listWidget.add(
//       //   Row(
//       //     children: <Widget>[
//       //       // if (kAdvanceConfig['showStockStatus']) ...[
//       //       Text(
//       //         "Brand: ",
//       //         style: Theme.of(context).textTheme.subtitle2,
//       //       ),
//       //     Text(
//       //       product.brand,
//       //       style: Theme.of(context).textTheme.subtitle2.copyWith(
//       //         color: inStock
//       //             ? Theme.of(context).primaryColor
//       //             : const Color(0xFFe74c3c),
//       //         fontWeight: FontWeight.w600,fontFamily: 'raleway',
//       //       ),
//       //     )
//       //       //  ],
//       //     ],
//       //   ),
//       // );
//       // listWidget.add(
//       //   const SizedBox(height: 5.0),
//       // );
//       // listWidget.add(
//       //   Row(
//       //     children: <Widget>[
//       //       // if (kAdvanceConfig['showStockStatus']) ...[
//       //       Text(
//       //         "Country of Origin: ",
//       //         style: Theme.of(context).textTheme.subtitle2,
//       //       ),
//       //       Text(
//       //         product.country_of_manufacture,
//       //         style: Theme.of(context).textTheme.subtitle2.copyWith(
//       //           color: inStock
//       //               ? Theme.of(context).primaryColor
//       //               : const Color(0xFFe74c3c),
//       //           fontWeight: FontWeight.w600,fontFamily: 'raleway',
//       //         ),
//       //       )
//       //       //  ],
//       //     ],
//       //   ),
//       // );
//       listWidget.add(
//         const SizedBox(height: 15.0),
//       );
//     }

//     return listWidget;
//   }

//   List<Widget> makeBuyButtonWidget(
//     BuildContext context,
//     ProductVariation productVariation,
//     Product product,
//     Map<String, String> mapAttribute,
//     int maxQuantity,
//     int quantity,
//     Function addToCart,
//     Function onChangeQuantity,
//     bool isAvailable,
//   ) {
//     final ThemeData theme = Theme.of(context);

//     bool inStock = (productVariation != null
//             ? productVariation.inStock
//             : product.inStock) ??
//         false;
//     final isExternal = product.type == "external" ? true : false;
//     bool loggedIn = Provider.of<UserModel>(context).loggedIn;
//     if (!inStock && !isExternal) return [];
//     if (!loggedIn) {
//       return [
//         if (!isExternal) const SizedBox(width: 10),
//         if (!isExternal && product.status == true)
//           Row(
//             children: [
//               // Expanded(
//               //   child: Text(
//               //     S.of(context).selectTheQuantity + ":",
//               //     style: Theme.of(context).textTheme.subtitle1,
//               //   ),
//               // ),
//               Expanded(
//                 child: Container(
//                   height: 32.0,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(3),
//                   ),
//                   child: QuantitySelection(
//                     expanded: true,
//                     value: quantity,
//                     color: theme.accentColor,
//                     limitSelectQuantity: maxQuantity,
//                     onChanged: onChangeQuantity,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               if (isAvailable && inStock && !isExternal)
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.of(
//                         context,
//                         rootNavigator: true,
//                       ).pushNamed(RouteList.login);
//                     },
//                     child: Container(
//                       height: 50,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(25.0),
//                         color: Theme.of(context).primaryColor,
//                       ),
//                       child: Center(
//                         child: Text(
//                           S.of(context).addToCart.toUpperCase(),
//                           style: TextStyle(
//                             color: Theme.of(context).backgroundColor,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),

//         // const SizedBox(height: 10),
//         // Row(
//         //   children: <Widget>[
//         //     Expanded(
//         //         child:  GestureDetector(
//         //           onTap: () {
//         //             Navigator.of(
//         //               context,
//         //               rootNavigator: true,
//         //             ).pushNamed(RouteList.login);
//         //           },
//         //       child: Container(
//         //         height: 44,
//         //         decoration: BoxDecoration(
//         //           borderRadius: BorderRadius.circular(3),
//         //           color: isExternal
//         //               ? (inStock &&
//         //               (product.attributes.length ==
//         //                   mapAttribute.length) &&
//         //               isAvailable)
//         //               ? theme.primaryColor
//         //               : theme.disabledColor
//         //               : theme.primaryColor,
//         //         ),
//         //         child: Center(
//         //           child: Text(
//         //             ((inStock && isAvailable) || isExternal)
//         //                 ? S.of(context).buyNow.toUpperCase()
//         //                 : (isAvailable
//         //                 ? S.of(context).outOfStock.toUpperCase()
//         //                 : S.of(context).unavailable.toUpperCase()),
//         //             style: Theme.of(context).textTheme.button.copyWith(
//         //               color: Colors.white,
//         //             ),
//         //           ),
//         //         ),
//         //       ),
//         //         ),
//         //     ),
//         //     const SizedBox(width: 10),
//         //     if (isAvailable && inStock && !isExternal)
//         //       Expanded(
//         //         child:  GestureDetector(
//         //           onTap: () {
//         //             Navigator.of(
//         //               context,
//         //               rootNavigator: true,
//         //             ).pushNamed(RouteList.login);
//         //           },
//         //         child: Container(
//         //           height: 44,
//         //           decoration: BoxDecoration(
//         //             borderRadius: BorderRadius.circular(3),
//         //             color: Colors.orange,
//         //           ),
//         //           child: Center(
//         //             child: Text(
//         //               S.of(context).addToCart.toUpperCase(),
//         //               style: TextStyle(
//         //                 color: Theme.of(context).backgroundColor,
//         //                 fontWeight: FontWeight.bold,
//         //                 fontSize: 12,
//         //               ),
//         //             ),
//         //           ),
//         //         ),
//         //       ),
//         //       ),
//         //   ],
//         // )
//       ];
//     }
//     //tochange
//     return [
//       if (!isExternal) const SizedBox(width: 10),
//       if (!isExternal && product.status == true)
//         Row(
//           children: [
//             // Expanded(
//             //   child: Text(
//             //     S.of(context).selectTheQuantity + ":",
//             //     style: Theme.of(context).textTheme.subtitle1,
//             //   ),
//             // ),
//             if (product.type == "configurable")
//               Expanded(
//                 child: Container(
//                   height: 32.0,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(3),
//                   ),
//                   child: QuantitySelection(
//                     // expanded: true,
//                     // value: quantity,
//                     // color: theme.accentColor,
//                     // limitSelectQuantity: maxQuantity,
//                     // onChanged: onChangeQuantity,
//                     product: product,
//                     price: product.price,
//                     expanded: true,
//                     value: 3,
//                     // quantity,
//                     color: theme.accentColor,
//                     limitSelectQuantity: productVariation.stockQuantity > 300
//                         ? 300
//                         : productVariation.stockQuantity,
//                     onChanged: onChangeQuantity,
//                   ),
//                 ),
//               )
//             else
//               Expanded(
//                 child: Container(
//                   height: 32.0,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(3),
//                   ),
//                   child: QuantitySelection(
//                     // expanded: true,
//                     // value: quantity,
//                     // color: theme.accentColor,
//                     // limitSelectQuantity: maxQuantity,
//                     // onChanged: onChangeQuantity,
//                     product: product,
//                     price: product.price,
//                     expanded: true,
//                     value: quantity,
//                     color: theme.accentColor,
//                     limitSelectQuantity: maxQuantity > 300 ? 300 : maxQuantity,
//                     onChanged: onChangeQuantity,
//                   ),
//                 ),
//               ),
//             //// if (isAvailable && inStock && !isExternal)
//             if (product.status == true)
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () async {
//                     CartModel cartModel =
//                         Provider.of<CartModel>(context, listen: false);
//                     print(cartModel.productsInCart);

//                     if (product.type == "configurable") {
//                       print("=====================");
//                       print(Provider.of<ProductModel>(context, listen: false)
//                           .productVariation
//                           .id);
//                       print(Provider.of<ProductModel>(context, listen: false)
//                           .productVariation
//                           .sku);
//                       print(Provider.of<ProductModel>(context, listen: false)
//                           .productVariation
//                           .imageFeature);
//                       print(Provider.of<ProductModel>(context, listen: false)
//                           .productVariation
//                           .stockQuantity);
//                       print(Provider.of<ProductModel>(context, listen: false)
//                           .productVariation
//                           .regularPrice);
//                       print(Provider.of<ProductModel>(context, listen: false)
//                           .productVariation
//                           .salePrice);
//                       print(Provider.of<ProductModel>(context, listen: false)
//                           .productVariation);
//                       print("=====================");
//                       // print(product.id);
//                       // print(product.variations);
//                       addToCartConfigurable(
//                         context,
//                         product: product,
//                         quantity: 4,
//                       );
//                     } else {
//                       addToCart(false, inStock);
//                     }

//                     /*    addToCart(false, inStock);
//                     print(product.qty);
//                     //

//                     print(product.salePrice);
//                     print(product.regularPrice);
//                     print(product.price);*/
//                     /*
//                     print(product.images);
//                     print(product.imageFeature);

//                     print("qty");*/

//                     // print(model.productsInCart);
//                     // print()
//                   },
//                   child: Container(
//                     height: 50,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(25),
//                       color: Theme.of(context).primaryColor,
//                     ),
//                     child: Center(
//                       child: Text(
//                         S.of(context).addToCart.toUpperCase(),
//                         style: TextStyle(
//                           color: Theme.of(context).backgroundColor,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         )

//       ////
//       // const SizedBox(height: 10),
//       // Row(
//       //   children: <Widget>[
//       //     Expanded(
//       //       child: GestureDetector(
//       //         //onTap: () => print("jdfjd"),
//       //         onTap: () => addToCart(true, inStock),
//       //         child: Container(
//       //           height: 44,
//       //           decoration: BoxDecoration(
//       //             borderRadius: BorderRadius.circular(3),
//       //             color: isExternal
//       //                 ? (inStock &&
//       //                         (product.attributes.length ==
//       //                             mapAttribute.length) &&
//       //                         isAvailable)
//       //                     ? theme.primaryColor
//       //                     : theme.disabledColor
//       //                 : theme.primaryColor,
//       //           ),
//       //           child: Center(
//       //             child: Text(
//       //               ((inStock && isAvailable) || isExternal)
//       //                   ? S.of(context).buyNow.toUpperCase()
//       //                   : (isAvailable
//       //                       ? S.of(context).outOfStock.toUpperCase()
//       //                       : S.of(context).unavailable.toUpperCase()),
//       //               style: Theme.of(context).textTheme.button.copyWith(
//       //                     color: Colors.white,
//       //                   ),
//       //             ),
//       //           ),
//       //         ),
//       //       ),
//       //     ),
//       //     const SizedBox(width: 10),
//       //     if (isAvailable && inStock && !isExternal)
//       //       Expanded(
//       //         child: GestureDetector(
//       //
//       //           onTap: () => addToCart(false, inStock),
//       //           child: Container(
//       //             height: 44,
//       //             decoration: BoxDecoration(
//       //               borderRadius: BorderRadius.circular(3),
//       //               color: Colors.orange,
//       //             ),
//       //             child: Center(
//       //               child: Text(
//       //                 S.of(context).addToCart.toUpperCase(),
//       //                 style: TextStyle(
//       //                   color: Theme.of(context).backgroundColor,
//       //                   fontWeight: FontWeight.bold,
//       //                   fontSize: 12,
//       //                 ),
//       //               ),
//       //             ),
//       //           ),
//       //         ),
//       //       ),
//       //   ],
//       // )
//     ];
//   }
//   //

//   void addToCartConfigurable(context, {Product product, int quantity}) async {
//     var wishListModel = Provider.of<WishListModel>(context, listen: false);
//     print("getting configuration");
//     List config = [];
//     String url = "https://up.ctown.jo/rest/V1/products/${product.sku}";
//     var response = await http.get(url, headers: {
//       'Authorization': 'Bearer ' + serverConfig["accessToken"],
//       "content-type": "application/json"
//     });
//     var responseBody;
//     List values = [];

//     if (response.statusCode == 200) {
//       responseBody = convert.jsonDecode(response.body);
//       values =
//           responseBody["extension_attributes"]["configurable_product_options"];
//     }

//     Provider.of<ProductModel>(context, listen: false)
//         .productVariation
//         .attributes
//         .forEach((element) {
//       values.forEach((e) {
//         if (e["label"].toString().toLowerCase() == element.name.toLowerCase()) {
//           element.option_id = e["attribute_id"];
//         }
//       });

//       config.add({
//         "option_id": "${element.option_id}",
//         "option_value": "${element.id}"
//       });
//     });
//     print("setting configuration");
//     print("config $config");

//     final LocalStorage storage = LocalStorage('store');
//     final userJson = storage.getItem(kLocalKey["userInfo"]);

//     int qty = quantity;

//     CartModel cartModel = Provider.of<CartModel>(context, listen: false);
//     String token = userJson["cookie"];
//     final addProductToCart = cartModel.addProductToCart;

//     var message = await MagentoApi().addToCartConfigurable(
//         cartModel, product.id, token, product.sku, qty,
//         configurations: config);
//     print("mesg $message");
//     addProductToCart(
//         product: product,
//         quantity: 4,
//         variation:
//             Provider.of<ProductModel>(context, listen: false).productVariation);
//     if (message.isEmpty) {
//       await showFlash(
//         context: context,
//         duration: const Duration(seconds: 3),
//         builder: (context, controller) {
//           return Flash(
//             borderRadius: BorderRadius.circular(3.0),
//             backgroundColor: Theme.of(context).primaryColor,
//             // Theme.of(context).errorColor,
//             controller: controller,
//             style: FlashStyle.floating,
//             position: FlashPosition.top,
//             horizontalDismissDirection: HorizontalDismissDirection.horizontal,
//             child: FlashBar(
//               icon: const Icon(
//                 Icons.check,
//                 color: Colors.white,
//               ),
//               message: Text(
//                 message,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 18.0,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     } else {
//       await showFlash(
//         context: context,
//         duration: const Duration(seconds: 3),
//         builder: (context, controller) {
//           return Flash(
//             borderRadius: BorderRadius.circular(3.0),
//             backgroundColor: Theme.of(context).primaryColor,
//             controller: controller,
//             style: FlashStyle.floating,
//             position: FlashPosition.top,
//             horizontalDismissDirection: HorizontalDismissDirection.horizontal,
//             child: FlashBar(
//               icon: const Icon(
//                 Icons.check,
//                 color: Colors.white,
//               ),
//               title: Text(
//                 product.name,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 15.0,
//                 ),
//               ),
//               message: Text(
//                 S.of(context).addToCartSucessfully,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 15.0,
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//       wishListModel.removeToWishlist(product);
//     }
//   }

//   //

//   /// Add to Cart & Buy Now function
//   void addToCart(BuildContext context, Product product, int quantity,
//       ProductVariation productVariation, Map<String, String> mapAttribute,
//       [bool buyNow = false, bool inStock = false]) async {
//     if (!inStock) {
//       return;
//     }

//     final cartModel = Provider.of<CartModel>(context, listen: false);
//     if (product.type == "external") {
//       openWebView(context, product);
//       return;
//     }

//     final Map<String, String> _mapAttribute = Map.from(mapAttribute);
//     productVariation =
//         Provider.of<ProductModel>(context, listen: false).productVariation;

//     //my changes
//     var userModel = Provider.of<UserModel>(context, listen: false);
//     var wishListModel = Provider.of<WishListModel>(context, listen: false);

//     if (userModel.user == null && !userModel.loggedIn) {
//       Navigator.of(
//         context,
//         rootNavigator: true,
//       ).pushNamed(RouteList.login);
//     } else {
//       // try {
//       //   await
//       MagentoApi()
//           .addItemsToCart(
//               cartModel,
//               product.id,
//               userModel.user != null ? userModel.user.cookie : null,
//               product.sku,
//               quantity)
//           .then((value) => null)
//           .catchError((e) {
//         cartModel.addProductToCart(
//           context: context,
//           product: product,
//           quantity: -quantity,
//           variation: productVariation,
//           options: _mapAttribute,
//           //success: false
//         );
//       });
//       // } catch (e) {
//       //   await showFlash(
//       //     context: context,
//       //     duration: const Duration(seconds: 3),
//       //     builder: (context, controller) {
//       //       return Flash(
//       //         borderRadius: BorderRadius.circular(3.0),
//       //         backgroundColor: Theme.of(context).errorColor,
//       //         controller: controller,
//       //         style: FlashStyle.floating,
//       //         position: FlashPosition.top,
//       //         horizontalDismissDirection: HorizontalDismissDirection.horizontal,
//       //         child: FlashBar(
//       //           icon: const Icon(
//       //             Icons.check,
//       //             color: Colors.white,
//       //           ),
//       //           message: Text(
//       //             e.toString(),
//       //             style: const TextStyle(
//       //               color: Colors.white,
//       //               fontSize: 18.0,
//       //               fontWeight: FontWeight.w700,
//       //             ),
//       //           ),
//       //         ),
//       //       );
//       //     },
//       //   );
//       //   throw Exception(e.toString());
//       // }

//       String message = cartModel.addProductToCart(
//           context: context,
//           product: product,
//           quantity: quantity,
//           variation: productVariation,
//           options: _mapAttribute);

//       if (message.isNotEmpty) {
//         await showFlash(
//           context: context,
//           duration: const Duration(seconds: 3),
//           builder: (context, controller) {
//             return Flash(
//               borderRadius: BorderRadius.circular(3.0),
//               backgroundColor: Theme.of(context).errorColor,
//               controller: controller,
//               style: FlashStyle.floating,
//               position: FlashPosition.top,
//               horizontalDismissDirection: HorizontalDismissDirection.horizontal,
//               child: FlashBar(
//                 icon: const Icon(
//                   Icons.check,
//                   color: Colors.white,
//                 ),
//                 message: Text(
//                   message,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18.0,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       } else {
//         if (buyNow) {
//           await Navigator.push(
//             context,
//             MaterialPageRoute<void>(
//               builder: (BuildContext context) => Scaffold(
//                 backgroundColor: Theme.of(context).backgroundColor,
//                 body: CartScreen(isModal: true, isBuyNow: true),
//               ),
//               fullscreenDialog: true,
//             ),
//           );
//         }
//         await showFlash(
//           context: context,
//           duration: const Duration(seconds: 3),
//           builder: (context, controller) {
//             return Flash(
//               borderRadius: BorderRadius.circular(3.0),
//               backgroundColor: Theme.of(context).primaryColor,
//               controller: controller,
//               style: FlashStyle.floating,
//               position: FlashPosition.top,
//               horizontalDismissDirection: HorizontalDismissDirection.horizontal,
//               child: FlashBar(
//                 icon: const Icon(
//                   Icons.check,
//                   color: Colors.white,
//                 ),
//                 title: Text(
//                   product.name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 15.0,
//                   ),
//                 ),
//                 message: Text(
//                   S.of(context).addToCartSucessfully,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 15.0,
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//         wishListModel.removeToWishlist(product);
//       }
//     }
//   }

//   /// Support Affiliate product
//   void openWebView(BuildContext context, Product product) {
//     if (product.affiliateUrl == null || product.affiliateUrl.isEmpty) {
//       Navigator.push(context, MaterialPageRoute(builder: (context) {
//         return Scaffold(
//           appBar: AppBar(
//             leading: GestureDetector(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: const Icon(Icons.arrow_back_ios),
//             ),
//           ),
//           body: const Center(
//             child: Text("Not found"),
//           ),
//         );
//       }));
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => WebView(
//           url: product.affiliateUrl,
//           title: product.name,
//         ),
//       ),
//     );
//   }
// }
// //detailspagee

// import 'package:ctown/common/constants/general.dart';
// import 'package:flash/flash.dart';
// import 'package:flutter/material.dart';
// import 'package:localstorage/localstorage.dart';
// import 'package:provider/provider.dart';

// import '../common/config.dart';
// import '../common/constants/route_list.dart';
// import '../generated/l10n.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert' as convert;
// import '../models/index.dart'
//     show
//         Attribute,
//         CartModel,
//         Product,
//         ProductModel,
//         ProductVariation,
//         UserModel,
//         WishListModel;
// import '../screens/cart/cart.dart';
// import '../widgets/common/webview.dart';
// import '../widgets/product/product_variant.dart';
// import 'magento/services/magento.dart';

// mixin ProductVariantMixin {
//   ProductVariation updateVariation(
//       List<ProductVariation> variations, Map<String, String> mapAttribute) {
//     if (variations != null) {
//       var variation = variations.firstWhere((item) {
//         bool isCorrect = true;
//         for (var attribute in item.attributes) {
//           if (attribute.option != mapAttribute[attribute.name] &&
//               (attribute.id != null ||
//                   checkVariantLengths(variations, mapAttribute))) {
//             isCorrect = false;
//             break;
//           }
//         }
//         if (isCorrect) {
//           for (var key in mapAttribute.keys.toList()) {
//             bool check = false;
//             for (var attribute in item.attributes) {
//               if (key == attribute.name) {
//                 check = true;
//                 break;
//               }
//             }
//             if (!check) {
//               Attribute att = Attribute()
//                 ..id = null
//                 ..name = key
//                 ..option = mapAttribute[key];
//               item.attributes.add(att);
//             }
//           }
//         }
//         return isCorrect;
//       }, orElse: () {
//         return null;
//       });
//       return variation;
//     }
//     return null;
//   }

//   bool checkVariantLengths(variations, mapAttribute) {
//     for (var variant in variations) {
//       if (variant.attributes.length == mapAttribute.keys.toList().length) {
//         bool check = true;
//         for (var i = 0; i < variant.attributes.length; i++) {
//           if (variant.attributes[i].option !=
//               mapAttribute[variant.attributes[i].name]) {
//             check = false;
//             break;
//           }
//         }
//         if (check) {
//           return true;
//         }
//       }
//     }
//     return false;
//   }

//   bool isPurchased(
//     ProductVariation productVariation,
//     Product product,
//     Map<String, String> mapAttribute,
//     bool isAvailable,
//   ) {
//     bool inStock =
//         productVariation != null ? productVariation.inStock : product.inStock;

//     final isValidAttribute = product.attributes.length == mapAttribute.length &&
//         (product.attributes.length == mapAttribute.length ||
//             product.type != "variable");

//     return inStock && isValidAttribute && isAvailable;
//   }

//   List<Widget> makeProductTitleWidget(BuildContext context,
//       ProductVariation productVariation, Product product, bool isAvailable) {
//     List<Widget> listWidget = [];

//     bool inStock = (productVariation != null
//             ? productVariation.inStock
//             : product.inStock) ??
//         false;

//     String stockQuantity =
//         product.stockQuantity != null ? ' (${product.stockQuantity}) ' : '';

//     if (Provider.of<ProductModel>(context, listen: false).productVariation !=
//         null) {
//       stockQuantity = Provider.of<ProductModel>(context, listen: false)
//                   .productVariation
//                   .stockQuantity !=
//               null
//           ? ' (${Provider.of<ProductModel>(context, listen: false).productVariation.stockQuantity}) '
//           : '';
//     }

//     if (isAvailable) {
//       listWidget.add(
//         const SizedBox(height: 5.0),
//       );

//       listWidget.add(
//         Row(
//           children: <Widget>[
//             if (kAdvanceConfig['showStockStatus']) ...[
//               Text(
//                 "${S.of(context).availability}: ",
//                 style: Theme.of(context).textTheme.subtitle2,
//               ),
//               product.backOrdered != null && product.backOrdered
//                   ? Text(
//                       '${S.of(context).backOrder}',
//                       style: Theme.of(context).textTheme.subtitle2.copyWith(
//                             color: const Color(0xFFEAA601),
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                           ),
//                     )
//                   : Text(
//                       product.status == true
//                           ? '${S.of(context).inStock} ${stockQuantity ?? ''}'
//                           : S.of(context).outOfStock,
//                       style: Theme.of(context).textTheme.subtitle2.copyWith(
//                             color:
//                                 // inStock
//                                 product.status == true
//                                     ? Theme.of(context).primaryColor
//                                     : const Color(0xFFe74c3c),
//                             fontWeight: FontWeight.w600,
//                           ),
//                     )
//               // Text(
//               //     inStock
//               //         ? '${S.of(context).inStock} ${stockQuantity ?? ''}'
//               //         : S.of(context).outOfStock,
//               //     style: Theme.of(context).textTheme.subtitle2.copyWith(
//               //           color: inStock
//               //               ? Theme.of(context).primaryColor
//               //               : const Color(0xFFe74c3c),
//               //           fontWeight: FontWeight.w600,
//               //         ),
//               //   )
//             ],
//           ],
//         ),
//       );
//       listWidget.add(
//         const SizedBox(height: 5.0),
//       );

//       listWidget.add(
//         Row(
//           children: <Widget>[
//             if (product.sku != null && product.sku != '') ...[
//               Text(
//                 S.of(context).units,
//                 style: (Theme.of(context).textTheme.subtitle2
//                   ..copyWith(
//                     fontSize: 18,
//                   )),
//               ),
//               Text(
//                 product.unit_of_measurement,
//                 style: Theme.of(context).textTheme.subtitle2.copyWith(
//                       color: inStock
//                           ? Theme.of(context).primaryColor
//                           : const Color(0xFFe74c3c),
//                       fontWeight: FontWeight.w600,
//                       // fontFamily: 'raleway',
//                     ),
//               ),
//             ],
//           ],
//         ),
//       );

//       // listWidget.add(
//       //   const SizedBox(height: 5.0),
//       // );
//       // listWidget.add(
//       //   Row(
//       //     children: <Widget>[
//       //       // if (kAdvanceConfig['showStockStatus']) ...[
//       //       Text(
//       //         "Brand: ",
//       //         style: Theme.of(context).textTheme.subtitle2,
//       //       ),
//       //     Text(
//       //       product.brand,
//       //       style: Theme.of(context).textTheme.subtitle2.copyWith(
//       //         color: inStock
//       //             ? Theme.of(context).primaryColor
//       //             : const Color(0xFFe74c3c),
//       //         fontWeight: FontWeight.w600,fontFamily: 'raleway',
//       //       ),
//       //     )
//       //       //  ],
//       //     ],
//       //   ),
//       // );
//       // listWidget.add(
//       //   const SizedBox(height: 5.0),
//       // );
//       // listWidget.add(
//       //   Row(
//       //     children: <Widget>[
//       //       // if (kAdvanceConfig['showStockStatus']) ...[
//       //       Text(
//       //         "Country of Origin: ",
//       //         style: Theme.of(context).textTheme.subtitle2,
//       //       ),
//       //       Text(
//       //         product.country_of_manufacture,
//       //         style: Theme.of(context).textTheme.subtitle2.copyWith(
//       //           color: inStock
//       //               ? Theme.of(context).primaryColor
//       //               : const Color(0xFFe74c3c),
//       //           fontWeight: FontWeight.w600,fontFamily: 'raleway',
//       //         ),
//       //       )
//       //       //  ],
//       //     ],
//       //   ),
//       // );
//       listWidget.add(
//         const SizedBox(height: 15.0),
//       );
//     }

//     return listWidget;
//   }

//   List<Widget> makeBuyButtonWidget(
//     BuildContext context,
//     ProductVariation productVariation,
//     Product product,
//     Map<String, String> mapAttribute,
//     int maxQuantity,
//     int quantity,
//     Function addToCart,
//     Function onChangeQuantity,
//     bool isAvailable,
//   ) {
//     final ThemeData theme = Theme.of(context);

//     bool inStock = (productVariation != null
//             ? productVariation.inStock
//             : product.inStock) ??
//         false;
//     final isExternal = product.type == "external" ? true : false;
//     bool loggedIn = Provider.of<UserModel>(context).loggedIn;
//     if (!inStock && !isExternal) return [];
//     if (!loggedIn) {
//       return [
//         if (!isExternal) const SizedBox(width: 10),
//         if (!isExternal && product.status == true)
//           Row(
//             children: [
//               // Expanded(
//               //   child: Text(
//               //     S.of(context).selectTheQuantity + ":",
//               //     style: Theme.of(context).textTheme.subtitle1,
//               //   ),
//               // ),
//               Expanded(
//                 child: Container(
//                   height: 32.0,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(3),
//                   ),
//                   child: QuantitySelection(
//                     expanded: true,
//                     value: quantity,
//                     color: theme.accentColor,
//                     limitSelectQuantity: maxQuantity,
//                     onChanged: onChangeQuantity,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               if (isAvailable && inStock && !isExternal)
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       Navigator.of(
//                         context,
//                         rootNavigator: true,
//                       ).pushNamed(RouteList.login);
//                     },
//                     child: Container(
//                       height: 50,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(25.0),
//                         color: Theme.of(context).primaryColor,
//                       ),
//                       child: Center(
//                         child: Text(
//                           S.of(context).addToCart.toUpperCase(),
//                           style: TextStyle(
//                             color: Theme.of(context).backgroundColor,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),

//         // const SizedBox(height: 10),
//         // Row(
//         //   children: <Widget>[
//         //     Expanded(
//         //         child:  GestureDetector(
//         //           onTap: () {
//         //             Navigator.of(
//         //               context,
//         //               rootNavigator: true,
//         //             ).pushNamed(RouteList.login);
//         //           },
//         //       child: Container(
//         //         height: 44,
//         //         decoration: BoxDecoration(
//         //           borderRadius: BorderRadius.circular(3),
//         //           color: isExternal
//         //               ? (inStock &&
//         //               (product.attributes.length ==
//         //                   mapAttribute.length) &&
//         //               isAvailable)
//         //               ? theme.primaryColor
//         //               : theme.disabledColor
//         //               : theme.primaryColor,
//         //         ),
//         //         child: Center(
//         //           child: Text(
//         //             ((inStock && isAvailable) || isExternal)
//         //                 ? S.of(context).buyNow.toUpperCase()
//         //                 : (isAvailable
//         //                 ? S.of(context).outOfStock.toUpperCase()
//         //                 : S.of(context).unavailable.toUpperCase()),
//         //             style: Theme.of(context).textTheme.button.copyWith(
//         //               color: Colors.white,
//         //             ),
//         //           ),
//         //         ),
//         //       ),
//         //         ),
//         //     ),
//         //     const SizedBox(width: 10),
//         //     if (isAvailable && inStock && !isExternal)
//         //       Expanded(
//         //         child:  GestureDetector(
//         //           onTap: () {
//         //             Navigator.of(
//         //               context,
//         //               rootNavigator: true,
//         //             ).pushNamed(RouteList.login);
//         //           },
//         //         child: Container(
//         //           height: 44,
//         //           decoration: BoxDecoration(
//         //             borderRadius: BorderRadius.circular(3),
//         //             color: Colors.orange,
//         //           ),
//         //           child: Center(
//         //             child: Text(
//         //               S.of(context).addToCart.toUpperCase(),
//         //               style: TextStyle(
//         //                 color: Theme.of(context).backgroundColor,
//         //                 fontWeight: FontWeight.bold,
//         //                 fontSize: 12,
//         //               ),
//         //             ),
//         //           ),
//         //         ),
//         //       ),
//         //       ),
//         //   ],
//         // )
//       ];
//     }
//     //tochange
//     return [
//       if (!isExternal) const SizedBox(width: 10),
//       if (!isExternal && product.status == true)
//         Row(
//           children: [
//             // Expanded(
//             //   child: Text(
//             //     S.of(context).selectTheQuantity + ":",
//             //     style: Theme.of(context).textTheme.subtitle1,
//             //   ),
//             // ),
//             if (product.type != "configurable")
//               //   Expanded(
//               //     child: Container(
//               //       height: 32.0,
//               //       alignment: Alignment.center,
//               //       decoration: BoxDecoration(
//               //         borderRadius: BorderRadius.circular(3),
//               //       ),
//               //       child: QuantitySelection(
//               //         // expanded: true,
//               //         // value: quantity,
//               //         // color: theme.accentColor,
//               //         // limitSelectQuantity: maxQuantity,
//               //         // onChanged: onChangeQuantity,
//               //         product: product,
//               //         price: product.price,
//               //         expanded: true,
//               //         value: 3,
//               //         // quantity,
//               //         color: theme.accentColor,
//               //         limitSelectQuantity: productVariation.stockQuantity > 300
//               //             ? 300
//               //             : productVariation.stockQuantity,
//               //         onChanged: onChangeQuantity,
//               //       ),
//               //     ),
//               //   )
//               // else
//               Expanded(
//                 child: Container(
//                   height: 32.0,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(3),
//                   ),
//                   child: QuantitySelection(
//                     // expanded: true,
//                     // value: quantity,
//                     // color: theme.accentColor,
//                     // limitSelectQuantity: maxQuantity,
//                     // onChanged: onChangeQuantity,
//                     product: product,
//                     price: product.price,
//                     expanded: true,
//                     value: quantity,
//                     color: theme.accentColor,
//                     limitSelectQuantity: maxQuantity > 300 ? 300 : maxQuantity,
//                     onChanged: onChangeQuantity,
//                   ),
//                 ),
//               ),
//             //// if (isAvailable && inStock && !isExternal)
//             if (product.status == true)
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () async {
//                     CartModel cartModel =
//                         Provider.of<CartModel>(context, listen: false);
//                     print(cartModel.productsInCart);

//                     if (product.type == "configurable") {
//                       print("=====================");
//                       print(Provider.of<ProductModel>(context, listen: false)
//                           .productVariation
//                           .id);
//                       print(Provider.of<ProductModel>(context, listen: false)
//                           .productVariation
//                           .sku);
//                       print(Provider.of<ProductModel>(context, listen: false)
//                           .productVariation
//                           .name);
//                       // print(Provider.of<ProductModel>(context, listen: false)
//                       //     .productVariation
//                       //     .imageFeature);
//                       // print(Provider.of<ProductModel>(context, listen: false)
//                       //     .productVariation
//                       //     .stockQuantity);
//                       // print(Provider.of<ProductModel>(context, listen: false)
//                       //     .productVariation
//                       //     .regularPrice);
//                       // print(Provider.of<ProductModel>(context, listen: false)
//                       //     .productVariation
//                       //     .salePrice);
//                       // print(Provider.of<ProductModel>(context, listen: false)
//                       //     .productVariation);
//                       // print("=====================");
//                       // print(product.id);
//                       // print(product.variations);
//                       print(product.variations);
// print("IF");
//                           print(  Provider.of<ProductModel>(context, listen: false)
//                                   .productVariation
//                                   .name);

//                       // addToCartConfigurable(context,
//                       //     product: product,
//                       //     quantity: quantity,
//                       //     name:
//                       //         Provider.of<ProductModel>(context, listen: false)
//                       //             .productVariation
//                       //             .name);
//                     } else {
// print(product.variations);
// print("ELSE");
//                       // addToCart(false, inStock);
//                     }

//                     /*    addToCart(false, inStock);
//                     print(product.qty);
//                     //

//                     print(product.salePrice);
//                     print(product.regularPrice);
//                     print(product.price);*/
//                     /*
//                     print(product.images);
//                     print(product.imageFeature);

//                     print("qty");*/

//                     // print(model.productsInCart);
//                     // print()
//                   },
//                   child: Container(
//                     height: 50,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(25),
//                       color: Theme.of(context).primaryColor,
//                     ),
//                     child: Center(
//                       child: Text(
//                         S.of(context).addToCart.toUpperCase(),
//                         style: TextStyle(
//                           color: Theme.of(context).backgroundColor,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         )

//       ////
//       // const SizedBox(height: 10),
//       // Row(
//       //   children: <Widget>[
//       //     Expanded(
//       //       child: GestureDetector(
//       //         //onTap: () => print("jdfjd"),
//       //         onTap: () => addToCart(true, inStock),
//       //         child: Container(
//       //           height: 44,
//       //           decoration: BoxDecoration(
//       //             borderRadius: BorderRadius.circular(3),
//       //             color: isExternal
//       //                 ? (inStock &&
//       //                         (product.attributes.length ==
//       //                             mapAttribute.length) &&
//       //                         isAvailable)
//       //                     ? theme.primaryColor
//       //                     : theme.disabledColor
//       //                 : theme.primaryColor,
//       //           ),
//       //           child: Center(
//       //             child: Text(
//       //               ((inStock && isAvailable) || isExternal)
//       //                   ? S.of(context).buyNow.toUpperCase()
//       //                   : (isAvailable
//       //                       ? S.of(context).outOfStock.toUpperCase()
//       //                       : S.of(context).unavailable.toUpperCase()),
//       //               style: Theme.of(context).textTheme.button.copyWith(
//       //                     color: Colors.white,
//       //                   ),
//       //             ),
//       //           ),
//       //         ),
//       //       ),
//       //     ),
//       //     const SizedBox(width: 10),
//       //     if (isAvailable && inStock && !isExternal)
//       //       Expanded(
//       //         child: GestureDetector(
//       //
//       //           onTap: () => addToCart(false, inStock),
//       //           child: Container(
//       //             height: 44,
//       //             decoration: BoxDecoration(
//       //               borderRadius: BorderRadius.circular(3),
//       //               color: Colors.orange,
//       //             ),
//       //             child: Center(
//       //               child: Text(
//       //                 S.of(context).addToCart.toUpperCase(),
//       //                 style: TextStyle(
//       //                   color: Theme.of(context).backgroundColor,
//       //                   fontWeight: FontWeight.bold,
//       //                   fontSize: 12,
//       //                 ),
//       //               ),
//       //             ),
//       //           ),
//       //         ),
//       //       ),
//       //   ],
//       // )
//     ];
//   }

//   //
//   void addToCartConfigurable(context,
//       {Product product, int quantity, String name}) async {
//     var wishListModel = Provider.of<WishListModel>(context, listen: false);
//     print("getting configuration");
//     List config = [];
//     String url = "https://up.ctown.jo/rest/V1/products/${product.sku}";
//     var response = await http.get(url, headers: {
//       'Authorization': 'Bearer ' + serverConfig["accessToken"],
//       "content-type": "application/json"
//     });
//     var responseBody;
//     List values = [];

//     if (response.statusCode == 200) {
//       responseBody = convert.jsonDecode(response.body);
//       values =
//           responseBody["extension_attributes"]["configurable_product_options"];
//     }

//     Provider.of<ProductModel>(context, listen: false)
//         .productVariation
//         .attributes
//         .forEach((element) {
//       values.forEach((e) {
//         if (e["label"].toString().toLowerCase() == element.name.toLowerCase()) {
//           element.option_id = e["attribute_id"];
//         }
//       });

//       config.add({
//         "option_id": "${element.option_id}",
//         "option_value": "${element.id}"
//       });
//     });
//     print("setting configuration");
//     print("config $config");

//     final LocalStorage storage = LocalStorage('store');
//     final userJson = storage.getItem(kLocalKey["userInfo"]);

//     int qty = quantity;

//     CartModel cartModel = Provider.of<CartModel>(context, listen: false);
//     String token = userJson["cookie"];
//     final addProductToCart = cartModel.addProductToCart;

//     addProductToCart(
//         product: product,
//         quantity: quantity,
//         variation:
//             Provider.of<ProductModel>(context, listen: false).productVariation);

//     await showFlash(
//       context: context,
//       duration: const Duration(seconds: 3),
//       builder: (context, controller) {
//         return Flash(
//           borderRadius: BorderRadius.circular(3.0),
//           backgroundColor: Theme.of(context).primaryColor,
//           controller: controller,
//           style: FlashStyle.floating,
//           position: FlashPosition.top,
//           horizontalDismissDirection: HorizontalDismissDirection.horizontal,
//           child: FlashBar(
//             icon: const Icon(
//               Icons.check,
//               color: Colors.white,
//             ),
//             title: Text(
//               name ?? product.name,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w700,
//                 fontSize: 15.0,
//               ),
//             ),
//             message: Text(
//               S.of(context).addToCartSucessfully,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 15.0,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//     // await
//     MagentoApi().addToCartConfigurable(
//         cartModel, product.id, token, product.sku, qty,
//         configurations: config);

//     wishListModel.removeToWishlist(product);
//   }
//   /*
//   void addToCartConfigurable(context, {Product product, int quantity}) async {
//     var wishListModel = Provider.of<WishListModel>(context, listen: false);
//     print("getting configuration");
//     List config = [];
//     String url = "https://up.ctown.jo/rest/V1/products/${product.sku}";
//     var response = await http.get(url, headers: {
//       'Authorization': 'Bearer ' + serverConfig["accessToken"],
//       "content-type": "application/json"
//     });
//     var responseBody;
//     List values = [];

//     if (response.statusCode == 200) {
//       responseBody = convert.jsonDecode(response.body);
//       values =
//           responseBody["extension_attributes"]["configurable_product_options"];
//     }

//     Provider.of<ProductModel>(context, listen: false)
//         .productVariation
//         .attributes
//         .forEach((element) {
//       values.forEach((e) {
//         if (e["label"].toString().toLowerCase() == element.name.toLowerCase()) {
//           element.option_id = e["attribute_id"];
//         }
//       });

//       config.add({
//         "option_id": "${element.option_id}",
//         "option_value": "${element.id}"
//       });
//     });
//     print("setting configuration");
//     print("config $config");

//     final LocalStorage storage = LocalStorage('store');
//     final userJson = storage.getItem(kLocalKey["userInfo"]);

//     int qty = quantity;

//     CartModel cartModel = Provider.of<CartModel>(context, listen: false);
//     String token = userJson["cookie"];
//     final addProductToCart = cartModel.addProductToCart;

//     var message = await MagentoApi().addToCartConfigurable(
//         cartModel, product.id, token, product.sku, qty,
//         configurations: config);
//     print("mesg $message");
//     addProductToCart(
//         product: product,
//         quantity: quantity,
//         variation:
//             Provider.of<ProductModel>(context, listen: false).productVariation);
//     if (message.isEmpty) {
//       await showFlash(
//         context: context,
//         duration: const Duration(seconds: 3),
//         builder: (context, controller) {
//           return Flash(
//             borderRadius: BorderRadius.circular(3.0),
//             backgroundColor: Theme.of(context).primaryColor,
//             // Theme.of(context).errorColor,
//             controller: controller,
//             style: FlashStyle.floating,
//             position: FlashPosition.top,
//             horizontalDismissDirection: HorizontalDismissDirection.horizontal,
//             child: FlashBar(
//               icon: const Icon(
//                 Icons.check,
//                 color: Colors.white,
//               ),
//               message: Text(
//                 message,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 18.0,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     } else {
//       await showFlash(
//         context: context,
//         duration: const Duration(seconds: 3),
//         builder: (context, controller) {
//           return Flash(
//             borderRadius: BorderRadius.circular(3.0),
//             backgroundColor: Theme.of(context).primaryColor,
//             controller: controller,
//             style: FlashStyle.floating,
//             position: FlashPosition.top,
//             horizontalDismissDirection: HorizontalDismissDirection.horizontal,
//             child: FlashBar(
//               icon: const Icon(
//                 Icons.check,
//                 color: Colors.white,
//               ),
//               title: Text(
//                 product.name,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 15.0,
//                 ),
//               ),
//               message: Text(
//                 S.of(context).addToCartSucessfully,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 15.0,
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//       wishListModel.removeToWishlist(product);
//     }
//   }
// */
//   //

//   /// Add to Cart & Buy Now function
//   void addToCart(BuildContext context, Product product, int quantity,
//       ProductVariation productVariation, Map<String, String> mapAttribute,
//       [bool buyNow = false, bool inStock = false]) async {
//     if (!inStock) {
//       return;
//     }

//     final cartModel = Provider.of<CartModel>(context, listen: false);
//     if (product.type == "external") {
//       openWebView(context, product);
//       return;
//     }

//     final Map<String, String> _mapAttribute = Map.from(mapAttribute);
//     productVariation =
//         Provider.of<ProductModel>(context, listen: false).productVariation;

//     //my changes
//     var userModel = Provider.of<UserModel>(context, listen: false);
//     var wishListModel = Provider.of<WishListModel>(context, listen: false);

//     if (userModel.user == null && !userModel.loggedIn) {
//       Navigator.of(
//         context,
//         rootNavigator: true,
//       ).pushNamed(RouteList.login);
//     } else {
//       // try {
//       //   await
//       MagentoApi()
//           .addItemsToCart(
//               cartModel,
//               product.id,
//               userModel.user != null ? userModel.user.cookie : null,
//               product.sku,
//               quantity)
//           .then((value) => null)
//           .catchError((e) {
//         cartModel.addProductToCart(
//           context: context,
//           product: product,
//           quantity: -quantity,
//           variation: productVariation,
//           options: _mapAttribute,
//           //success: false
//         );
//       });
//       // } catch (e) {
//       //   await showFlash(
//       //     context: context,
//       //     duration: const Duration(seconds: 3),
//       //     builder: (context, controller) {
//       //       return Flash(
//       //         borderRadius: BorderRadius.circular(3.0),
//       //         backgroundColor: Theme.of(context).errorColor,
//       //         controller: controller,
//       //         style: FlashStyle.floating,
//       //         position: FlashPosition.top,
//       //         horizontalDismissDirection: HorizontalDismissDirection.horizontal,
//       //         child: FlashBar(
//       //           icon: const Icon(
//       //             Icons.check,
//       //             color: Colors.white,
//       //           ),
//       //           message: Text(
//       //             e.toString(),
//       //             style: const TextStyle(
//       //               color: Colors.white,
//       //               fontSize: 18.0,
//       //               fontWeight: FontWeight.w700,
//       //             ),
//       //           ),
//       //         ),
//       //       );
//       //     },
//       //   );
//       //   throw Exception(e.toString());
//       // }

//       String message = cartModel.addProductToCart(
//           context: context,
//           product: product,
//           quantity: quantity,
//           variation: productVariation,
//           options: _mapAttribute);
//       if (message.isNotEmpty) {
//         await showFlash(
//           context: context,
//           duration: const Duration(seconds: 3),
//           builder: (context, controller) {
//             return Flash(
//               borderRadius: BorderRadius.circular(3.0),
//               backgroundColor: Theme.of(context).errorColor,
//               controller: controller
//               style: FlashStyle.floating,
//               position: FlashPosition.top,
//               horizontalDismissDirection: HorizontalDismissDirection.horizontal,
//               child: FlashBar(
//                 icon: const Icon(
//                   Icons.check,
//                   color: Colors.white,
//                 ),
//                 message: Text(
//                   message,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18.0,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       } else {
//         if (buyNow) {
//           await Navigator.push(
//             context,
//             MaterialPageRoute<void>(
//               builder: (BuildContext context) => Scaffold(
//                 backgroundColor: Theme.of(context).backgroundColor,
//                 body: CartScreen(isModal: true, isBuyNow: true),
//               ),
//               fullscreenDialog: true,
//             ),
//           );
//         }
//         await showFlash(
//           context: context,
//           duration: const Duration(seconds: 3),
//           builder: (context, controller) {
//             return Flash(
//               borderRadius: BorderRadius.circular(3.0),
//               backgroundColor: Theme.of(context).primaryColor,
//               controller: controller,
//               style: FlashStyle.floating,
//               position: FlashPosition.top,
//               horizontalDismissDirection: HorizontalDismissDirection.horizontal,
//               child: FlashBar(
//                 icon: const Icon(
//                   Icons.check,
//                   color: Colors.white,
//                 ),
//                 title: Text(
//                   product.name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w700,
//                     fontSize: 15.0,
//                   ),
//                 ),
//                 message: Text(
//                   S.of(context).addToCartSucessfully,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 15.0,
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//         wishListModel.removeToWishlist(product);
//       }
//     }
//   }

//   /// Support Affiliate product
//   void openWebView(BuildContext context, Product product) {
//     if (product.affiliateUrl == null || product.affiliateUrl.isEmpty) {
//       Navigator.push(context, MaterialPageRoute(builder: (context) {
//         return Scaffold(
//           appBar: AppBar(
//             leading: GestureDetector(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: const Icon(Icons.arrow_back_ios),
//             ),
//           ),
//           body: const Center(
//             child: Text("Not found"),
//           ),
//         );
//       }));
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => WebView(
//           url: product.affiliateUrl,
//           title: product.name,
//         ),
//       ),
//     );
//   }
// }
// //detailspagee

// // import 'package:ctown/common/constants/general.dart';
// // import 'package:flash/flash.dart';
// // import 'package:flutter/material.dart';
// // import 'package:localstorage/localstorage.dart';
// // import 'package:provider/provider.dart';

// // import '../common/config.dart';
// // import '../common/constants/route_list.dart';
// // import '../generated/l10n.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert' as convert;
// // import '../models/index.dart'
// //     show
// //         Attribute,
// //         CartModel,
// //         Product,
// //         ProductModel,
// //         ProductVariation,
// //         UserModel,
// //         WishListModel;
// // import '../screens/cart/cart.dart';
// // import '../widgets/common/webview.dart';
// // import '../widgets/product/product_variant.dart';
// // import 'magento/services/magento.dart';

// // mixin ProductVariantMixin {
// //   ProductVariation updateVariation(
// //       List<ProductVariation> variations, Map<String, String> mapAttribute) {
// //     if (variations != null) {
// //       var variation = variations.firstWhere((item) {
// //         bool isCorrect = true;
// //         for (var attribute in item.attributes) {
// //           if (attribute.option != mapAttribute[attribute.name] &&
// //               (attribute.id != null ||
// //                   checkVariantLengths(variations, mapAttribute))) {
// //             isCorrect = false;
// //             break;
// //           }
// //         }
// //         if (isCorrect) {
// //           for (var key in mapAttribute.keys.toList()) {
// //             bool check = false;
// //             for (var attribute in item.attributes) {
// //               if (key == attribute.name) {
// //                 check = true;
// //                 break;
// //               }
// //             }
// //             if (!check) {
// //               Attribute att = Attribute()
// //                 ..id = null
// //                 ..name = key
// //                 ..option = mapAttribute[key];
// //               item.attributes.add(att);
// //             }
// //           }
// //         }
// //         return isCorrect;
// //       }, orElse: () {
// //         return null;
// //       });
// //       return variation;
// //     }
// //     return null;
// //   }

// //   bool checkVariantLengths(variations, mapAttribute) {
// //     for (var variant in variations) {
// //       if (variant.attributes.length == mapAttribute.keys.toList().length) {
// //         bool check = true;
// //         for (var i = 0; i < variant.attributes.length; i++) {
// //           if (variant.attributes[i].option !=
// //               mapAttribute[variant.attributes[i].name]) {
// //             check = false;
// //             break;
// //           }
// //         }
// //         if (check) {
// //           return true;
// //         }
// //       }
// //     }
// //     return false;
// //   }

// //   bool isPurchased(
// //     ProductVariation productVariation,
// //     Product product,
// //     Map<String, String> mapAttribute,
// //     bool isAvailable,
// //   ) {
// //     bool inStock =
// //         productVariation != null ? productVariation.inStock : product.inStock;

// //     final isValidAttribute = product.attributes.length == mapAttribute.length &&
// //         (product.attributes.length == mapAttribute.length ||
// //             product.type != "variable");

// //     return inStock && isValidAttribute && isAvailable;
// //   }

// //   List<Widget> makeProductTitleWidget(BuildContext context,
// //       ProductVariation productVariation, Product product, bool isAvailable) {
// //     List<Widget> listWidget = [];

// //     bool inStock = (productVariation != null
// //             ? productVariation.inStock
// //             : product.inStock) ??
// //         false;

// //     String stockQuantity =
// //         product.stockQuantity != null ? ' (${product.stockQuantity}) ' : '';

// //     if (Provider.of<ProductModel>(context, listen: false).productVariation !=
// //         null) {
// //       stockQuantity = Provider.of<ProductModel>(context, listen: false)
// //                   .productVariation
// //                   .stockQuantity !=
// //               null
// //           ? ' (${Provider.of<ProductModel>(context, listen: false).productVariation.stockQuantity}) '
// //           : '';
// //     }

// //     if (isAvailable) {
// //       listWidget.add(
// //         const SizedBox(height: 5.0),
// //       );

// //       listWidget.add(
// //         Row(
// //           children: <Widget>[
// //             if (kAdvanceConfig['showStockStatus']) ...[
// //               Text(
// //                 "${S.of(context).availability}: ",
// //                 style: Theme.of(context).textTheme.subtitle2,
// //               ),
// //               product.backOrdered != null && product.backOrdered
// //                   ? Text(
// //                       '${S.of(context).backOrder}',
// //                       style: Theme.of(context).textTheme.subtitle2.copyWith(
// //                             color: const Color(0xFFEAA601),
// //                             fontSize: 12,
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                     )
// //                   : Text(
// //                       product.status == true
// //                           ? '${S.of(context).inStock} ${stockQuantity ?? ''}'
// //                           : S.of(context).outOfStock,
// //                       style: Theme.of(context).textTheme.subtitle2.copyWith(
// //                             color:
// //                                 // inStock
// //                                 product.status == true
// //                                     ? Theme.of(context).primaryColor
// //                                     : const Color(0xFFe74c3c),
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                     )
// //               // Text(
// //               //     inStock
// //               //         ? '${S.of(context).inStock} ${stockQuantity ?? ''}'
// //               //         : S.of(context).outOfStock,
// //               //     style: Theme.of(context).textTheme.subtitle2.copyWith(
// //               //           color: inStock
// //               //               ? Theme.of(context).primaryColor
// //               //               : const Color(0xFFe74c3c),
// //               //           fontWeight: FontWeight.w600,
// //               //         ),
// //               //   )
// //             ],
// //           ],
// //         ),
// //       );
// //       listWidget.add(
// //         const SizedBox(height: 5.0),
// //       );

// //       listWidget.add(
// //         Row(
// //           children: <Widget>[
// //             if (product.sku != null && product.sku != '') ...[
// //               Text(
// //                 S.of(context).units,
// //                 style: (Theme.of(context).textTheme.subtitle2
// //                   ..copyWith(
// //                     fontSize: 18,
// //                   )),
// //               ),
// //               Text(
// //                 product.unit_of_measurement,
// //                 style: Theme.of(context).textTheme.subtitle2.copyWith(
// //                       color: inStock
// //                           ? Theme.of(context).primaryColor
// //                           : const Color(0xFFe74c3c),
// //                       fontWeight: FontWeight.w600,
// //                       // fontFamily: 'raleway',
// //                     ),
// //               ),
// //             ],
// //           ],
// //         ),
// //       );

// //       // listWidget.add(
// //       //   const SizedBox(height: 5.0),
// //       // );
// //       // listWidget.add(
// //       //   Row(
// //       //     children: <Widget>[
// //       //       // if (kAdvanceConfig['showStockStatus']) ...[
// //       //       Text(
// //       //         "Brand: ",
// //       //         style: Theme.of(context).textTheme.subtitle2,
// //       //       ),
// //       //     Text(
// //       //       product.brand,
// //       //       style: Theme.of(context).textTheme.subtitle2.copyWith(
// //       //         color: inStock
// //       //             ? Theme.of(context).primaryColor
// //       //             : const Color(0xFFe74c3c),
// //       //         fontWeight: FontWeight.w600,fontFamily: 'raleway',
// //       //       ),
// //       //     )
// //       //       //  ],
// //       //     ],
// //       //   ),
// //       // );
// //       // listWidget.add(
// //       //   const SizedBox(height: 5.0),
// //       // );
// //       // listWidget.add(
// //       //   Row(
// //       //     children: <Widget>[
// //       //       // if (kAdvanceConfig['showStockStatus']) ...[
// //       //       Text(
// //       //         "Country of Origin: ",
// //       //         style: Theme.of(context).textTheme.subtitle2,
// //       //       ),
// //       //       Text(
// //       //         product.country_of_manufacture,
// //       //         style: Theme.of(context).textTheme.subtitle2.copyWith(
// //       //           color: inStock
// //       //               ? Theme.of(context).primaryColor
// //       //               : const Color(0xFFe74c3c),
// //       //           fontWeight: FontWeight.w600,fontFamily: 'raleway',
// //       //         ),
// //       //       )
// //       //       //  ],
// //       //     ],
// //       //   ),
// //       // );
// //       listWidget.add(
// //         const SizedBox(height: 15.0),
// //       );
// //     }

// //     return listWidget;
// //   }

// //   List<Widget> makeBuyButtonWidget(
// //     BuildContext context,
// //     ProductVariation productVariation,
// //     Product product,
// //     Map<String, String> mapAttribute,
// //     int maxQuantity,
// //     int quantity,
// //     Function addToCart,
// //     Function onChangeQuantity,
// //     bool isAvailable,
// //   ) {
// //     final ThemeData theme = Theme.of(context);

// //     bool inStock = (productVariation != null
// //             ? productVariation.inStock
// //             : product.inStock) ??
// //         false;
// //     final isExternal = product.type == "external" ? true : false;
// //     bool loggedIn = Provider.of<UserModel>(context).loggedIn;
// //     if (!inStock && !isExternal) return [];
// //     if (!loggedIn) {
// //       return [
// //         if (!isExternal) const SizedBox(width: 10),
// //         if (!isExternal && product.status == true)
// //           Row(
// //             children: [
// //               // Expanded(
// //               //   child: Text(
// //               //     S.of(context).selectTheQuantity + ":",
// //               //     style: Theme.of(context).textTheme.subtitle1,
// //               //   ),
// //               // ),
// //               Expanded(
// //                 child: Container(
// //                   height: 32.0,
// //                   alignment: Alignment.center,
// //                   decoration: BoxDecoration(
// //                     borderRadius: BorderRadius.circular(3),
// //                   ),
// //                   child: QuantitySelection(
// //                     expanded: true,
// //                     value: quantity,
// //                     color: theme.accentColor,
// //                     limitSelectQuantity: maxQuantity,
// //                     onChanged: onChangeQuantity,
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(width: 10),
// //               if (isAvailable && inStock && !isExternal)
// //                 Expanded(
// //                   child: GestureDetector(
// //                     onTap: () {
// //                       Navigator.of(
// //                         context,
// //                         rootNavigator: true,
// //                       ).pushNamed(RouteList.login);
// //                     },
// //                     child: Container(
// //                       height: 50,
// //                       decoration: BoxDecoration(
// //                         borderRadius: BorderRadius.circular(25.0),
// //                         color: Theme.of(context).primaryColor,
// //                       ),
// //                       child: Center(
// //                         child: Text(
// //                           S.of(context).addToCart.toUpperCase(),
// //                           style: TextStyle(
// //                             color: Theme.of(context).backgroundColor,
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 12,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //             ],
// //           ),

// //         // const SizedBox(height: 10),
// //         // Row(
// //         //   children: <Widget>[
// //         //     Expanded(
// //         //         child:  GestureDetector(
// //         //           onTap: () {
// //         //             Navigator.of(
// //         //               context,
// //         //               rootNavigator: true,
// //         //             ).pushNamed(RouteList.login);
// //         //           },
// //         //       child: Container(
// //         //         height: 44,
// //         //         decoration: BoxDecoration(
// //         //           borderRadius: BorderRadius.circular(3),
// //         //           color: isExternal
// //         //               ? (inStock &&
// //         //               (product.attributes.length ==
// //         //                   mapAttribute.length) &&
// //         //               isAvailable)
// //         //               ? theme.primaryColor
// //         //               : theme.disabledColor
// //         //               : theme.primaryColor,
// //         //         ),
// //         //         child: Center(
// //         //           child: Text(
// //         //             ((inStock && isAvailable) || isExternal)
// //         //                 ? S.of(context).buyNow.toUpperCase()
// //         //                 : (isAvailable
// //         //                 ? S.of(context).outOfStock.toUpperCase()
// //         //                 : S.of(context).unavailable.toUpperCase()),
// //         //             style: Theme.of(context).textTheme.button.copyWith(
// //         //               color: Colors.white,
// //         //             ),
// //         //           ),
// //         //         ),
// //         //       ),
// //         //         ),
// //         //     ),
// //         //     const SizedBox(width: 10),
// //         //     if (isAvailable && inStock && !isExternal)
// //         //       Expanded(
// //         //         child:  GestureDetector(
// //         //           onTap: () {
// //         //             Navigator.of(
// //         //               context,
// //         //               rootNavigator: true,
// //         //             ).pushNamed(RouteList.login);
// //         //           },
// //         //         child: Container(
// //         //           height: 44,
// //         //           decoration: BoxDecoration(
// //         //             borderRadius: BorderRadius.circular(3),
// //         //             color: Colors.orange,
// //         //           ),
// //         //           child: Center(
// //         //             child: Text(
// //         //               S.of(context).addToCart.toUpperCase(),
// //         //               style: TextStyle(
// //         //                 color: Theme.of(context).backgroundColor,
// //         //                 fontWeight: FontWeight.bold,
// //         //                 fontSize: 12,
// //         //               ),
// //         //             ),
// //         //           ),
// //         //         ),
// //         //       ),
// //         //       ),
// //         //   ],
// //         // )
// //       ];
// //     }
// //     //tochange
// //     return [
// //       if (!isExternal) const SizedBox(width: 10),
// //       if (!isExternal && product.status == true)
// //         Row(
// //           children: [
// //             // Expanded(
// //             //   child: Text(
// //             //     S.of(context).selectTheQuantity + ":",
// //             //     style: Theme.of(context).textTheme.subtitle1,
// //             //   ),
// //             // ),
// //             if (product.type == "configurable")
// //               Expanded(
// //                 child: Container(
// //                   height: 32.0,
// //                   alignment: Alignment.center,
// //                   decoration: BoxDecoration(
// //                     borderRadius: BorderRadius.circular(3),
// //                   ),
// //                   child: QuantitySelection(
// //                     // expanded: true,
// //                     // value: quantity,
// //                     // color: theme.accentColor,
// //                     // limitSelectQuantity: maxQuantity,
// //                     // onChanged: onChangeQuantity,
// //                     product: product,
// //                     price: product.price,
// //                     expanded: true,
// //                     value: 3,
// //                     // quantity,
// //                     color: theme.accentColor,
// //                     limitSelectQuantity: productVariation.stockQuantity > 300
// //                         ? 300
// //                         : productVariation.stockQuantity,
// //                     onChanged: onChangeQuantity,
// //                   ),
// //                 ),
// //               )
// //             else
// //               Expanded(
// //                 child: Container(
// //                   height: 32.0,
// //                   alignment: Alignment.center,
// //                   decoration: BoxDecoration(
// //                     borderRadius: BorderRadius.circular(3),
// //                   ),
// //                   child: QuantitySelection(
// //                     // expanded: true,
// //                     // value: quantity,
// //                     // color: theme.accentColor,
// //                     // limitSelectQuantity: maxQuantity,
// //                     // onChanged: onChangeQuantity,
// //                     product: product,
// //                     price: product.price,
// //                     expanded: true,
// //                     value: quantity,
// //                     color: theme.accentColor,
// //                     limitSelectQuantity: maxQuantity > 300 ? 300 : maxQuantity,
// //                     onChanged: onChangeQuantity,
// //                   ),
// //                 ),
// //               ),
// //             //// if (isAvailable && inStock && !isExternal)
// //             if (product.status == true)
// //               Expanded(
// //                 child: GestureDetector(
// //                   onTap: () async {
// //                     CartModel cartModel =
// //                         Provider.of<CartModel>(context, listen: false);
// //                     print(cartModel.productsInCart);

// //                     if (product.type == "configurable") {
// //                       print("=====================");
// //                       print(Provider.of<ProductModel>(context, listen: false)
// //                           .productVariation
// //                           .id);
// //                       print(Provider.of<ProductModel>(context, listen: false)
// //                           .productVariation
// //                           .sku);
// //                       print(Provider.of<ProductModel>(context, listen: false)
// //                           .productVariation
// //                           .imageFeature);
// //                       print(Provider.of<ProductModel>(context, listen: false)
// //                           .productVariation
// //                           .stockQuantity);
// //                       print(Provider.of<ProductModel>(context, listen: false)
// //                           .productVariation
// //                           .regularPrice);
// //                       print(Provider.of<ProductModel>(context, listen: false)
// //                           .productVariation
// //                           .salePrice);
// //                       print(Provider.of<ProductModel>(context, listen: false)
// //                           .productVariation);
// //                       print("=====================");
// //                       // print(product.id);
// //                       // print(product.variations);
// //                       addToCartConfigurable(
// //                         context,
// //                         product: product,
// //                         quantity: 4,
// //                       );
// //                     } else {
// //                       addToCart(false, inStock);
// //                     }

// //                     /*    addToCart(false, inStock);
// //                     print(product.qty);
// //                     //

// //                     print(product.salePrice);
// //                     print(product.regularPrice);
// //                     print(product.price);*/
// //                     /*
// //                     print(product.images);
// //                     print(product.imageFeature);

// //                     print("qty");*/

// //                     // print(model.productsInCart);
// //                     // print()
// //                   },
// //                   child: Container(
// //                     height: 50,
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(25),
// //                       color: Theme.of(context).primaryColor,
// //                     ),
// //                     child: Center(
// //                       child: Text(
// //                         S.of(context).addToCart.toUpperCase(),
// //                         style: TextStyle(
// //                           color: Theme.of(context).backgroundColor,
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 12,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         )

// //       ////
// //       // const SizedBox(height: 10),
// //       // Row(
// //       //   children: <Widget>[
// //       //     Expanded(
// //       //       child: GestureDetector(
// //       //         //onTap: () => print("jdfjd"),
// //       //         onTap: () => addToCart(true, inStock),
// //       //         child: Container(
// //       //           height: 44,
// //       //           decoration: BoxDecoration(
// //       //             borderRadius: BorderRadius.circular(3),
// //       //             color: isExternal
// //       //                 ? (inStock &&
// //       //                         (product.attributes.length ==
// //       //                             mapAttribute.length) &&
// //       //                         isAvailable)
// //       //                     ? theme.primaryColor
// //       //                     : theme.disabledColor
// //       //                 : theme.primaryColor,
// //       //           ),
// //       //           child: Center(
// //       //             child: Text(
// //       //               ((inStock && isAvailable) || isExternal)
// //       //                   ? S.of(context).buyNow.toUpperCase()
// //       //                   : (isAvailable
// //       //                       ? S.of(context).outOfStock.toUpperCase()
// //       //                       : S.of(context).unavailable.toUpperCase()),
// //       //               style: Theme.of(context).textTheme.button.copyWith(
// //       //                     color: Colors.white,
// //       //                   ),
// //       //             ),
// //       //           ),
// //       //         ),
// //       //       ),
// //       //     ),
// //       //     const SizedBox(width: 10),
// //       //     if (isAvailable && inStock && !isExternal)
// //       //       Expanded(
// //       //         child: GestureDetector(
// //       //
// //       //           onTap: () => addToCart(false, inStock),
// //       //           child: Container(
// //       //             height: 44,
// //       //             decoration: BoxDecoration(
// //       //               borderRadius: BorderRadius.circular(3),
// //       //               color: Colors.orange,
// //       //             ),
// //       //             child: Center(
// //       //               child: Text(
// //       //                 S.of(context).addToCart.toUpperCase(),
// //       //                 style: TextStyle(
// //       //                   color: Theme.of(context).backgroundColor,
// //       //                   fontWeight: FontWeight.bold,
// //       //                   fontSize: 12,
// //       //                 ),
// //       //               ),
// //       //             ),
// //       //           ),
// //       //         ),
// //       //       ),
// //       //   ],
// //       // )
// //     ];
// //   }
// //   //

// //   void addToCartConfigurable(context, {Product product, int quantity}) async {
// //     var wishListModel = Provider.of<WishListModel>(context, listen: false);
// //     print("getting configuration");
// //     List config = [];
// //     String url = "https://up.ctown.jo/rest/V1/products/${product.sku}";
// //     var response = await http.get(url, headers: {
// //       'Authorization': 'Bearer ' + serverConfig["accessToken"],
// //       "content-type": "application/json"
// //     });
// //     var responseBody;
// //     List values = [];

// //     if (response.statusCode == 200) {
// //       responseBody = convert.jsonDecode(response.body);
// //       values =
// //           responseBody["extension_attributes"]["configurable_product_options"];
// //     }

// //     Provider.of<ProductModel>(context, listen: false)
// //         .productVariation
// //         .attributes
// //         .forEach((element) {
// //       values.forEach((e) {
// //         if (e["label"].toString().toLowerCase() == element.name.toLowerCase()) {
// //           element.option_id = e["attribute_id"];
// //         }
// //       });

// //       config.add({
// //         "option_id": "${element.option_id}",
// //         "option_value": "${element.id}"
// //       });
// //     });
// //     print("setting configuration");
// //     print("config $config");

// //     final LocalStorage storage = LocalStorage('store');
// //     final userJson = storage.getItem(kLocalKey["userInfo"]);

// //     int qty = quantity;

// //     CartModel cartModel = Provider.of<CartModel>(context, listen: false);
// //     String token = userJson["cookie"];
// //     final addProductToCart = cartModel.addProductToCart;

// //     var message = await MagentoApi().addToCartConfigurable(
// //         cartModel, product.id, token, product.sku, qty,
// //         configurations: config);
// //     print("mesg $message");
// //     addProductToCart(
// //         product: product,
// //         quantity: 4,
// //         variation:
// //             Provider.of<ProductModel>(context, listen: false).productVariation);
// //     if (message.isEmpty) {
// //       await showFlash(
// //         context: context,
// //         duration: const Duration(seconds: 3),
// //         builder: (context, controller) {
// //           return Flash(
// //             borderRadius: BorderRadius.circular(3.0),
// //             backgroundColor: Theme.of(context).primaryColor,
// //             // Theme.of(context).errorColor,
// //             controller: controller,
// //             style: FlashStyle.floating,
// //             position: FlashPosition.top,
// //             horizontalDismissDirection: HorizontalDismissDirection.horizontal,
// //             child: FlashBar(
// //               icon: const Icon(
// //                 Icons.check,
// //                 color: Colors.white,
// //               ),
// //               message: Text(
// //                 message,
// //                 style: const TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 18.0,
// //                   fontWeight: FontWeight.w700,
// //                 ),
// //               ),
// //             ),
// //           );
// //         },
// //       );
// //     } else {
// //       await showFlash(
// //         context: context,
// //         duration: const Duration(seconds: 3),
// //         builder: (context, controller) {
// //           return Flash(
// //             borderRadius: BorderRadius.circular(3.0),
// //             backgroundColor: Theme.of(context).primaryColor,
// //             controller: controller,
// //             style: FlashStyle.floating,
// //             position: FlashPosition.top,
// //             horizontalDismissDirection: HorizontalDismissDirection.horizontal,
// //             child: FlashBar(
// //               icon: const Icon(
// //                 Icons.check,
// //                 color: Colors.white,
// //               ),
// //               title: Text(
// //                 product.name,
// //                 style: const TextStyle(
// //                   color: Colors.white,
// //                   fontWeight: FontWeight.w700,
// //                   fontSize: 15.0,
// //                 ),
// //               ),
// //               message: Text(
// //                 S.of(context).addToCartSucessfully,
// //                 style: const TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 15.0,
// //                 ),
// //               ),
// //             ),
// //           );
// //         },
// //       );
// //       wishListModel.removeToWishlist(product);
// //     }
// //   }

// //   //

// //   /// Add to Cart & Buy Now function
// //   void addToCart(BuildContext context, Product product, int quantity,
// //       ProductVariation productVariation, Map<String, String> mapAttribute,
// //       [bool buyNow = false, bool inStock = false]) async {
// //     if (!inStock) {
// //       return;
// //     }

// //     final cartModel = Provider.of<CartModel>(context, listen: false);
// //     if (product.type == "external") {
// //       openWebView(context, product);
// //       return;
// //     }

// //     final Map<String, String> _mapAttribute = Map.from(mapAttribute);
// //     productVariation =
// //         Provider.of<ProductModel>(context, listen: false).productVariation;

// //     //my changes
// //     var userModel = Provider.of<UserModel>(context, listen: false);
// //     var wishListModel = Provider.of<WishListModel>(context, listen: false);

// //     if (userModel.user == null && !userModel.loggedIn) {
// //       Navigator.of(
// //         context,
// //         rootNavigator: true,
// //       ).pushNamed(RouteList.login);
// //     } else {
// //       // try {
// //       //   await
// //       MagentoApi()
// //           .addItemsToCart(
// //               cartModel,
// //               product.id,
// //               userModel.user != null ? userModel.user.cookie : null,
// //               product.sku,
// //               quantity)
// //           .then((value) => null)
// //           .catchError((e) {
// //         cartModel.addProductToCart(
// //           context: context,
// //           product: product,
// //           quantity: -quantity,
// //           variation: productVariation,
// //           options: _mapAttribute,
// //           //success: false
// //         );
// //       });
// //       // } catch (e) {
// //       //   await showFlash(
// //       //     context: context,
// //       //     duration: const Duration(seconds: 3),
// //       //     builder: (context, controller) {
// //       //       return Flash(
// //       //         borderRadius: BorderRadius.circular(3.0),
// //       //         backgroundColor: Theme.of(context).errorColor,
// //       //         controller: controller,
// //       //         style: FlashStyle.floating,
// //       //         position: FlashPosition.top,
// //       //         horizontalDismissDirection: HorizontalDismissDirection.horizontal,
// //       //         child: FlashBar(
// //       //           icon: const Icon(
// //       //             Icons.check,
// //       //             color: Colors.white,
// //       //           ),
// //       //           message: Text(
// //       //             e.toString(),
// //       //             style: const TextStyle(
// //       //               color: Colors.white,
// //       //               fontSize: 18.0,
// //       //               fontWeight: FontWeight.w700,
// //       //             ),
// //       //           ),
// //       //         ),
// //       //       );
// //       //     },
// //       //   );
// //       //   throw Exception(e.toString());
// //       // }

// //       String message = cartModel.addProductToCart(
// //           context: context,
// //           product: product,
// //           quantity: quantity,
// //           variation: productVariation,
// //           options: _mapAttribute);

// //       if (message.isNotEmpty) {
// //         await showFlash(
// //           context: context,
// //           duration: const Duration(seconds: 3),
// //           builder: (context, controller) {
// //             return Flash(
// //               borderRadius: BorderRadius.circular(3.0),
// //               backgroundColor: Theme.of(context).errorColor,
// //               controller: controller,
// //               style: FlashStyle.floating,
// //               position: FlashPosition.top,
// //               horizontalDismissDirection: HorizontalDismissDirection.horizontal,
// //               child: FlashBar(
// //                 icon: const Icon(
// //                   Icons.check,
// //                   color: Colors.white,
// //                 ),
// //                 message: Text(
// //                   message,
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 18.0,
// //                     fontWeight: FontWeight.w700,
// //                   ),
// //                 ),
// //               ),
// //             );
// //           },
// //         );
// //       } else {
// //         if (buyNow) {
// //           await Navigator.push(
// //             context,
// //             MaterialPageRoute<void>(
// //               builder: (BuildContext context) => Scaffold(
// //                 backgroundColor: Theme.of(context).backgroundColor,
// //                 body: CartScreen(isModal: true, isBuyNow: true),
// //               ),
// //               fullscreenDialog: true,
// //             ),
// //           );
// //         }
// //         await showFlash(
// //           context: context,
// //           duration: const Duration(seconds: 3),
// //           builder: (context, controller) {
// //             return Flash(
// //               borderRadius: BorderRadius.circular(3.0),
// //               backgroundColor: Theme.of(context).primaryColor,
// //               controller: controller,
// //               style: FlashStyle.floating,
// //               position: FlashPosition.top,
// //               horizontalDismissDirection: HorizontalDismissDirection.horizontal,
// //               child: FlashBar(
// //                 icon: const Icon(
// //                   Icons.check,
// //                   color: Colors.white,
// //                 ),
// //                 title: Text(
// //                   product.name,
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontWeight: FontWeight.w700,
// //                     fontSize: 15.0,
// //                   ),
// //                 ),
// //                 message: Text(
// //                   S.of(context).addToCartSucessfully,
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 15.0,
// //                   ),
// //                 ),
// //               ),
// //             );
// //           },
// //         );
// //         wishListModel.removeToWishlist(product);
// //       }
// //     }
// //   }

// //   /// Support Affiliate product
// //   void openWebView(BuildContext context, Product product) {
// //     if (product.affiliateUrl == null || product.affiliateUrl.isEmpty) {
// //       Navigator.push(context, MaterialPageRoute(builder: (context) {
// //         return Scaffold(
// //           appBar: AppBar(
// //             leading: GestureDetector(
// //               onTap: () {
// //                 Navigator.pop(context);
// //               },
// //               child: const Icon(Icons.arrow_back_ios),
// //             ),
// //           ),
// //           body: const Center(
// //             child: Text("Not found"),
// //           ),
// //         );
// //       }));
// //       return;
// //     }

// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => WebView(
// //           url: product.affiliateUrl,
// //           title: product.name,
// //         ),
// //       ),
// //     );
// //   }
// // }
// // //detailspagee
