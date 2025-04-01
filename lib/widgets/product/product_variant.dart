import 'dart:async';
import 'dart:math';

import 'package:ctown/frameworks/magento/services/magento.dart';
import 'package:ctown/models/app_model.dart';
import 'package:ctown/models/cart/cart_model.dart';
import 'package:ctown/models/entities/index.dart';
import 'package:ctown/models/entities/product.dart';
import 'package:ctown/models/user_model.dart';
import 'package:ctown/models/wishlist_model.dart';
import 'package:ctown/screens/detail/product_title.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../common/config/products.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../widgets/common/tooltip.dart' as tool_tip;

enum VariantLayout { inline, dropdown }

class BasicSelection extends StatelessWidget {
  final Map<String, String>? imageUrls;
  final List? salePrice;
  final List? onSale;

  final List options;
  final List? options1;
  final String? value;
  final Product? product;

  final String? title;
  final String? type;
  final Function? onChanged;
  final bool? isProductCard;

  final VariantLayout? layout;
  BasicSelection(
      {required this.options,
      required this.title,
      required this.value,
      this.type,
      this.layout,
      this.onChanged,
      this.imageUrls,
      this.options1,
      this.product,
      this.salePrice,
      this.onSale,
      this.isProductCard});

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    if (type == "option") {
      return OptionSelection(
        onSale: onSale,
        salePrice: salePrice,
        options1: options1,
        product: product,
        options: options,
        value: value,
        title: title,
        onChanged: onChanged,
        isProductCard: isProductCard,
      );
    }

    if (type == "image") {
      return ImageSelection(
        imageUrls: imageUrls,
        options: options as List<String?>,
        value: value,
        title: title,
        onChanged: onChanged,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                child: Text(
                  "${title![0].toUpperCase()}${title!.substring(1)}",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                padding: const EdgeInsets.only(bottom: 10),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 0.0,
          runSpacing: 12.0,
          children: <Widget>[
            for (var item in options)
              tool_tip.Tooltip(
                message: item.toString(),
                child: Container(
                  //height: type == "color" ? 26 : 30,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    margin: const EdgeInsets.only(right: 15.0),
                    decoration: type == "color"
                        ? BoxDecoration(
                            color: item.toUpperCase() == value!.toUpperCase()
                                ? HexColor(kNameToHex[item
                                        .toString()
                                        .replaceAll(' ', "_")
                                        .toLowerCase()] ??
                                    "#ffffff")
                                : HexColor(kNameToHex[item
                                            .toString()
                                            .replaceAll(' ', "_")
                                            .toLowerCase()] ??
                                        "#ffffff")
                                    .withOpacity(0.6),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              width: 1.0,
                              color: Theme.of(context)
                                  .colorScheme.secondary
                                  .withOpacity(0.3),
                            ),
                          )
                        : BoxDecoration(
                            color: item.toUpperCase() == value!.toUpperCase()
                                ? primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme.secondary
                                  .withOpacity(0.3),
                            ),
                          ),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        onChanged!(item);
                      },
                      child: type == "color"
                          ? SizedBox(
                              height: 25,
                              width: 25,
                              child: item == value
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : Container(),
                            )
                          : Container(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0),
                              child: Padding(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    color: item == value
                                        ? Colors.white
                                        : Theme.of(context).colorScheme.secondary,
                                    fontSize: 14,
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.only(top: 5, bottom: 5),
                              ),
                            ),
                    ),
                  ),
                ),
              )
          ],
        ),
      ],
    );
  }
}

class OptionSelection extends StatefulWidget {
  final List options;
  final List? salePrice;
  final List? onSale;
  final List? options1;
  final Product? product;

  final String? value;
  final String? title;
  final Function? onChanged;
  final VariantLayout? layout;
  final bool? isProductCard;

  OptionSelection(
      {required this.options,
      required this.value,
      this.title,
      this.layout,
      this.onChanged,
      this.options1,
      this.product,
      this.salePrice,
      this.onSale,
      this.isProductCard});

  @override
  _OptionSelectionState createState() => _OptionSelectionState();
}

class _OptionSelectionState extends State<OptionSelection> {
  String? productprice;
  String? price1 = 'Select';
  //   final String currency = Provider.of<AppModel>(context).currency;
  // final Map<String, dynamic> currencyRate =
  //     Provider.of<AppModel>(context).currencyRate;

  showOptions(BuildContext context, String? cookie, CartModel cartModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      print(widget.options);
                      print(widget.options1);
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.only(top: 8.0, bottom: 8.0, right: 16.0),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.blueAccent,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (int i = 0; i < widget.options.length; i++)
                        ListTile(
                            onTap: () async {
                              print("price");
                              print(widget.options[i]);
                              print(widget.options1![i]);
                              setState(() {
                                // productprice=widget.options1[i];
                                price1 = widget.options[i];
                                widget.product!.variableprice = true;
                              });

                              print(productprice);

                              await widget.onChanged!(widget.options[i]);
                              // onChanged();
                              print(widget.product);
                              Navigator.pop(context);
                              // Future.delayed(const Duration(milliseconds: 700),
                              //         () async {
                              //       printLog("Test Date4:" +
                              //           DateTime.now().toIso8601String());
                              //       await Services().widget?.syncCartFromWebsite(
                              //           cookie, cartModel, context);
                              //     });
                            },
                            title: Text(
                                Provider.of<AppModel>(context, listen: false)
                                            .langCode ==
                                        'en'
                                    ? "${widget.options[i]}     ${Tools.getCurrencyFormatted(widget.onSale![0] == true ? widget.salePrice![i] != null ? widget.salePrice![i] : widget.options1![i] : widget.options1![i] ?? "0.0", Provider.of<AppModel>(context).currencyRate, currency: Provider.of<AppModel>(context).currency)}"
                                    : "${Tools.getCurrencyFormatted(widget.onSale![0] == true ? widget.salePrice![i] != null ? widget.salePrice![i] : widget.options1![i] : widget.options1![i] ?? "0.0", Provider.of<AppModel>(context).currencyRate, currency: Provider.of<AppModel>(context).currency)}     ${widget.options[i]}",
                                textAlign: TextAlign.center)),
                      Container(
                        height: 1,
                        decoration: const BoxDecoration(color: kGrey200),
                      ),
                      ListTile(
                        title: Text(
                          S.of(context).selectTheSize,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    CartModel cartModel = Provider.of<CartModel>(context);
    var cookie = Provider.of<UserModel>(context, listen: false).user != null
        ? Provider.of<UserModel>(context, listen: false).user!.cookie
        : null;
    int indexKG = widget.options.indexOf("1 KG");
    String optionValue = widget.value!.isNotEmpty && indexKG != -1
        ? widget.options.isNotEmpty
            ? widget.options[indexKG]
            : ""
        : '';

    String option1Value = widget.value!.isNotEmpty && indexKG != -1
        ? widget.options1 != null && widget.options1!.isNotEmpty
            ? widget.options1![indexKG]
            : ""
        : '';

    String? salePrice = widget.value!.isNotEmpty && indexKG != -1
        ? widget.salePrice != null && widget.salePrice!.isNotEmpty
            ? widget.salePrice![indexKG]
            : ""
        : "";

    List<dynamic>? saleList =
        widget.value!.isNotEmpty && indexKG != -1 ? widget.onSale : [];
    String langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
    return Column(
      children: [
        ProductTitle(widget.product, optionValue, productprice, option1Value,
            salePrice, saleList, widget.isProductCard),
        const SizedBox(height: 5.0),
        GestureDetector(
          onTap: () => showOptions(context, cookie, cartModel),
          child: Container(
            height: 42,
            width: 160,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Expanded(
                  //   child: Text(
                  //       "${title[0].toUpperCase()}${title.substring(1)}",
                  //       style: const TextStyle(
                  //           fontWeight: FontWeight.bold, fontSize: 18)),
                  // ),
                  Expanded(
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                          border: Border.all(color: kGrey600, width: 1.4)),
                      // color:Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            langCode == "en" ? price1! : "اختر الوزن",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.keyboard_arrow_down,
                              size: 16, color: kGrey600)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  color() {
    var res = MagentoApi().getProductVariations(widget.product!,
        Provider.of<AppModel>(context, listen: false).langCode);
    print(res);
  }
}

class ColorSelection extends StatelessWidget {
  final List<String> options;
  final String value;
  final Function? onChanged;
  final VariantLayout? layout;

  ColorSelection(
      {required this.options,
      required this.value,
      this.layout,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (layout == VariantLayout.dropdown) {
      return GestureDetector(
        onTap: () => showOptions(context),
        child: Container(
          decoration:
              BoxDecoration(border: Border.all(width: 1.0, color: kGrey200)),
          height: 42,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(S.of(context).color,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        color: kNameToHex[value.toLowerCase()] != null
                            ? HexColor(kNameToHex[value.toLowerCase()])
                            : Colors.transparent)),
                const SizedBox(width: 5),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: kGrey600)
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 25,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            Center(
              child: Text(
                S.of(context).color,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 15.0),
            for (var item in options)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
                margin: const EdgeInsets.only(right: 20.0),
                decoration: BoxDecoration(
                  color: item == value
                      ? HexColor(kNameToHex[item.toLowerCase()])
                      : HexColor(kNameToHex[item.toLowerCase()])
                          .withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                      width: 1.0,
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
                ),
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    onChanged!(item);
                  },
                  child: SizedBox(
                    height: 25,
                    width: 25,
                    child: item == value
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : Container(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void showOptions(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final option in options)
                ListTile(
                  onTap: () {
                    onChanged!(option);
                    Navigator.pop(context);
                  },
                  title: Center(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        border: Border.all(
                            width: 1.0, color: Theme.of(context).colorScheme.secondary),
                        color: HexColor(kNameToHex[option.toLowerCase()]),
                      ),
                    ),
                  ),
                ),
              Container(
                height: 1,
                decoration: const BoxDecoration(color: kGrey200),
              ),
              ListTile(
                title: Text(
                  S.of(context).selectTheColor,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class QuantitySelection extends StatefulWidget {
  final int? limitSelectQuantity;
  final int? value;
  final double width;
  final double height;
  final Function? onChanged;
  final Color color;

  final price;
  final Product? product;
  final bool useNewDesign;
  final bool enabled;
  final bool expanded;

  QuantitySelection({
    required this.value,
    this.width = 40.0,
    this.product,
    this.price,
    this.height = 42.0,
    this.limitSelectQuantity = 100,
    required this.color,
    this.onChanged,
    this.useNewDesign = true,
    this.enabled = true,
    this.expanded = false,
  });

  @override
  _QuantitySelectionState createState() => _QuantitySelectionState();
}

class _QuantitySelectionState extends State<QuantitySelection> {
  final TextEditingController _textController = TextEditingController();
  Timer? _debounce;

  Timer? _changeQuantityTimer;

  @override
  void initState() {
    super.initState();
    _textController.text = "${widget.value}";
    _textController.addListener(_onQuantityChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onQuantityChanged);
    _changeQuantityTimer?.cancel();
    _debounce?.cancel();
    _textController.dispose();
    super.dispose();
  }

  int get currentQuantity => int.tryParse(_textController.text) ?? -1;

  bool _validateQuantity([int? value]) {
    if ((value ?? currentQuantity) <= 0) {
      _textController.text = "1";
      return false;
    }

    // if ((value ?? currentQuantity) > widget.limitSelectQuantity) {
    //   _textController.text = "${widget.limitSelectQuantity}";
    //   return false;
    // }

    return true;
  }

  void changeQuantity(int value, {bool forceUpdate = false}) {
    if (!_validateQuantity(value)) {
      return;
    }

    if (value != currentQuantity || forceUpdate == true) {
      _textController.text = "$value";
    }
  }

  void _onQuantityChanged() {
    if (!_validateQuantity()) {
      return;
    }

    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () {
        if (widget.onChanged != null) {
          widget.onChanged!(currentQuantity);

          // Navigator.of(context, rootNavigator: true).pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useNewDesign == true) {
      final _iconPadding = EdgeInsets.all(
        max(
          ((widget.height ?? 32.0) - 24.0 - 8) * 0.5,
          0.0,
        ),
      );
      final currency = Provider.of<AppModel>(context, listen: false).currency;
      final currencyRate = Provider.of<AppModel>(context).currencyRate;

      void _showFlashNotification(
          Product? product, String message, context, bool isError) {
        if (message.isNotEmpty) {
          showFlash(
            context: context,
            duration: const Duration(seconds: 3),
            builder: (context, controller) {
              return Flash(
                controller: controller,
                dismissDirections: FlashDismissDirection.values,
                child: FlashBar(
                  controller: controller,
                  position: FlashPosition.top,
                  behavior: FlashBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  backgroundColor: isError ? Colors.red : Colors.white,
                  content: Text(
                    message,
                    style: TextStyle(
                      color: isError ? Colors.white : Colors.red,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          showFlash(
            context: context,
            duration: const Duration(seconds: 3),
            builder: (context, controller) {
              return Flash(
                controller: controller,
                dismissDirections: [FlashDismissDirection.startToEnd],
                child: FlashBar(
                  controller: controller,
                  position: FlashPosition.top,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  backgroundColor:
                      Colors.white, // Theme.of(context).primaryColor,
                  behavior: FlashBehavior.floating,

                  icon: const Icon(
                    Icons.check,
                    color: Colors.red,
                  ),
                  title: Text(
                    product!.name!,
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
        }
      }

      Future<bool> _addToCart(BuildContext context, CartModel cartModel,
          int offset, UserModel userModel, WishListModel wishListModel) async {
        try {
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
          final addProductToCart =
              Provider.of<CartModel>(context, listen: false)
                  .addProductToCartNew;
          var key = "${widget.product!.id}";
          int total = !cartModel.productsInCart.containsKey(key)
              ? offset
              : (cartModel.productsInCart[key]! + offset);
          printLog("asudausdbdfhgbhdbfhg");
          printLog("Product Max Sale Qty: ${widget.product!.maxSaleQty}");
          printLog("Total Qty: $total");
          if (total <= widget.product!.maxSaleQty!) {
            await Future.delayed(Duration(milliseconds: 1500));
            MagentoApi()
                .addItemsToCart(
                    Provider.of<AppModel>(context, listen: false).langCode,
                    cartModel,
                    widget.product!.id,
                    userModel.user != null ? userModel.user!.cookie : null,
                    widget.product!.sku,
                    total,)
                .then((value) => null)
                .catchError((e) {
              printLog(' catchError - $e');
              addProductToCart(
                product: widget.product,
                quantity: -offset,
                context: context,
                // success: false
              );
            });
            String message = addProductToCart(
                product: widget.product, quantity: offset, context: context);
            printLog("my message $message");
            _showFlashNotification(widget.product, message, context, false);
            changeQuantity(currentQuantity + offset);
            wishListModel.removeToWishlist(widget.product);
          } else {
            _showFlashNotification(
                widget.product,
                "The requested qty exceeds the maximum qty allowed in shopping cart",
                context,
                true);
          }
        } catch (e) {
          printLog(e.toString());
        } finally {
          EasyLoading.dismiss();
        }
        return true;
      }

      Future<void> _onPressed(int qnty1) async {
        CartModel cartModel = Provider.of<CartModel>(context, listen: false);
        UserModel userModel = Provider.of<UserModel>(context, listen: false);
        WishListModel wishListModel =
            Provider.of<WishListModel>(context, listen: false);
        bool loggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;
        var tapCount = 0;
        if (userModel.user == null) {
          if (!loggedIn) {
            await Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamed(RouteList.login);
          } else {
            _addToCart(context, cartModel, tapCount, userModel, wishListModel);
          }
        } else {
          _addToCart(context, cartModel, qnty1, userModel, wishListModel);
        }
      }

      final _textField = GestureDetector(
          onTap: () async {
            int selectedQty = 0;
            Product product;
            bool loggedIn =
                Provider.of<UserModel>(context, listen: false).loggedIn;

            if (loggedIn) {
              await showModalBottomSheet(
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
                                // Text("sample text"),
                                Text("$currency " + widget.product!.price!),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () async {
                                    printLog('selected');
                                    if (selectedQty != null) {
                                      await _onPressed(selectedQty);
                                    }
                                    Navigator.of(context).pop(selectedQty);
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
                                widget.product!.qty!,
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
                                  trailing: selectedQty == index + 1
                                      ? const Icon(Icons.check)
                                      : null,
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
            } else {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(RouteList.login);
            }
          },
          child: Container(
            height: widget.height,
            width: widget.expanded == true ? null : widget.width,
            padding: EdgeInsets.only(bottom: 7),
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: kGrey200),
              borderRadius: BorderRadius.circular(3),
            ),
            alignment: Alignment.center,
            child: TextField(
              readOnly: widget.enabled == false,
              //// enabled: widget.enabled == true,
              enabled: false,
              controller: _textController,

              maxLines: 1,
              style: TextStyle(
                color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white : Colors.grey,
              ),
              maxLength: "${widget.limitSelectQuantity ?? 100}".length,
              onEditingComplete: _validateQuantity,
              onSubmitted: (_) => _validateQuantity(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: "",
              ),
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: false,
              ),
              textAlign: TextAlign.center,
            ),
          ));
      return Row(
        children: [
          widget.enabled == true
              ? IconButton(
                  padding: _iconPadding,
                  onPressed: () {
                    bool loggedIn =
                        Provider.of<UserModel>(context, listen: false).loggedIn;
                    if (loggedIn) changeQuantity(currentQuantity - 1);
                  },
                  icon: Center(
                      child: Icon(
                    Icons.arrow_back_ios,
                    size: 15,
                    color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white : Colors.grey,
                  )),
                )
              : const SizedBox.shrink(),
          widget.expanded == true
              ? Expanded(
                  child: _textField,
                )
              : _textField,
          widget.enabled == true
              ? IconButton(
                  padding: _iconPadding,
                  onPressed: () {
                    //    print(widget.product.qty);
                    // print(currentQuantity);

                    bool loggedIn =
                        Provider.of<UserModel>(context, listen: false).loggedIn;
                    if (loggedIn) {
                      if (widget.product!.qty! > currentQuantity) {
                        changeQuantity(currentQuantity + 1);
                      }
                    }
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white : Colors.grey,
                  ),
                )
              : const SizedBox.shrink(),
        ],
      );
    }
    return GestureDetector(
      onTap: () {
        if (widget.onChanged != null) {
          showOptions(context);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1.0, color: kGrey200),
          borderRadius: BorderRadius.circular(3),
        ),
        height: widget.height,
        width: widget.width,
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: 2.0,
              horizontal: (widget.onChanged != null) ? 5.0 : 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Text(
                    widget.value.toString(),
                    style: TextStyle(fontSize: 14, color: widget.color),
                  ),
                ),
              ),
              if (widget.onChanged != null)
                const SizedBox(
                  width: 5.0,
                ),
              if (widget.onChanged != null)
                Icon(Icons.keyboard_arrow_down,
                    size: 14, color: Theme.of(context).colorScheme.secondary)
            ],
          ),
        ),
      ),
    );
  }

  void showOptions(context) {
    showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (int option = 1;
                          option <= widget.limitSelectQuantity!;
                          option++)
                        ListTile(
                            onTap: () async {
                              widget.onChanged!(option);
                              print("yyy");
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: kLoadingWidget,
                              );

                              Future.delayed(const Duration(milliseconds: 3000),
                                  () async {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              });

                              Future.delayed(const Duration(milliseconds: 3000),
                                  () async {
                                // String url =
                                //     "https://up.ctown.jo/rest/V1/carts/mine/payment-information";
                                // final LocalStorage storage =
                                //     LocalStorage('store');
                                // final userJson =
                                //     storage.getItem(kLocalKey["userInfo"]);
                                // var response = await http.get(url, headers: {
                                //   'Authorization':
                                //       'Bearer ' + userJson["cookie"],
                                // });
                                // if (response.statusCode == 200) {
                                //   print("====================");
                                //   var data = jsonDecode(response.body);
                                //   print(data["totals"]["grand_total"]);
                                //   print(data["totals"]["discount_amount"]);
                                //   // setState(() {
                                //   //   _magentoDiscountAmount =
                                //   //       double.parse(data["totals"]["discount_amount"].toString());
                                //   // });

                                //   // print("magento discount $_magentoDiscountAmount");
                                //   // setState(() {
                                //   print("data start set");
                                //   Provider.of<CartProvider>(context,
                                //           listen: false)
                                //       .setMagentoDiscount(double.parse(
                                //           data["totals"]["discount_amount"]
                                //               .toString()));
                                //   Provider.of<CartProvider>(context,
                                //           listen: false)
                                //       .setCartGrandTotal(double.parse(
                                //           data["totals"]["grand_total"]
                                //               .toString()));
                                //   print("data setting");
                                //   Provider.of<CartProvider>(context,
                                //           listen: false)
                                //       .setBaseSubTotal(double.parse(
                                //           data["totals"]["base_subtotal"]
                                //               .toString()));
                                //   // });
                                // }
                                Navigator.of(context).pop();
                              });
                            },
                            title: Text(
                              option.toString(),
                              textAlign: TextAlign.center,
                            )),
                    ],
                  ),
                ),
              ),
              Container(
                height: 1,
                decoration: const BoxDecoration(color: kGrey200),
              ),
              ListTile(
                title: Text(
                  S.of(context).selectTheQuantity,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        });
  }
}

class ImageSelection extends StatelessWidget {
  final Map<String, String>? imageUrls;
  final List<String?> options;
  final String? value;
  final String? title;
  final Function? onChanged;
  final VariantLayout? layout;

  ImageSelection({
    required this.options,
    required this.value,
    this.title,
    this.layout,
    this.onChanged,
    this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    final double size =
        kProductDetail["attributeImagesSize"] as double? ?? 30.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                child: Text(
                  "${title![0].toUpperCase()}${title!.substring(1)}",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                padding: const EdgeInsets.only(bottom: 10),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 0.0,
          runSpacing: 12.0,
          children: <Widget>[
            for (var item in options)
              tool_tip.Tooltip(
                message: item.toString(),
                child: Container(
                  height: size + 2,
                  width: size + 2,
                  margin: const EdgeInsets.only(right: 15.0),
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                        width: 1.0,
                        color: Theme.of(context).colorScheme.secondary.withOpacity(
                            item!.toUpperCase() == value!.toUpperCase()
                                ? 0.6
                                : 0.3),
                      ),
                    ),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        onChanged!(item);
                      },
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Tools.image(
                              url: imageUrls![item],
                              height: size,
                              width: size,
                            ),
                          ),
                          if (item.toUpperCase() == value!.toUpperCase())
                            Positioned.fill(
                              child: Container(
                                color: Theme.of(context)
                                    .colorScheme.surface
                                    .withOpacity(0.6),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
          ],
        ),
      ],
    );
  }
}

// import 'dart:async';
// import 'dart:math';
// import 'package:ctown/frameworks/magento/services/magento.dart';

// import 'package:ctown/models/app_model.dart';
// import 'package:ctown/models/cart/cart_model.dart';
// import 'package:ctown/models/entities/product.dart';
// import 'package:ctown/models/user_model.dart';
// import 'package:ctown/models/wishlist_model.dart';
// import 'package:flash/flash.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../common/config/products.dart';
// import '../../common/constants.dart';
// import '../../common/tools.dart';
// import '../../generated/l10n.dart';
// import '../../widgets/common/tooltip.dart' as tool_tip;

// enum VariantLayout { inline, dropdown }

// class BasicSelection extends StatelessWidget {
//   final Map<String, String> imageUrls;
//   final List<String> options;
//   final String value;
//   final String title;
//   final String type;
//   final Function onChanged;
//   final VariantLayout layout;

//   BasicSelection(
//       {@required this.options,
//       @required this.title,
//       @required this.value,
//       this.type,
//       this.layout,
//       this.onChanged,
//       this.imageUrls});

//   @override
//   Widget build(BuildContext context) {
//     Color primaryColor = Theme.of(context).primaryColor;

//     if (type == "option") {
//       return OptionSelection(
//         options: options,
//         value: value,
//         title: title,
//         onChanged: onChanged,
//       );
//     }

//     if (type == "image") {
//       return ImageSelection(
//         imageUrls: imageUrls,
//         options: options,
//         value: value,
//         title: title,
//         onChanged: onChanged,
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.max,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: <Widget>[
//         Row(
//           children: <Widget>[
//             Expanded(
//               child: Padding(
//                 child: Text(
//                   "${title[0].toUpperCase()}${title.substring(1)}",
//                   style: Theme.of(context).textTheme.headline6,
//                 ),
//                 padding: const EdgeInsets.only(bottom: 10),
//               ),
//             ),
//           ],
//         ),
//         Wrap(
//           spacing: 0.0,
//           runSpacing: 12.0,
//           children: <Widget>[
//             for (var item in options)
//               tool_tip.Tooltip(
//                 message: item.toString(),
//                 child: Container(
//                   //height: type == "color" ? 26 : 30,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     curve: Curves.easeIn,
//                     margin: const EdgeInsets.only(right: 15.0),
//                     decoration: type == "color"
//                         ? BoxDecoration(
//                             color: item.toUpperCase() == value.toUpperCase()
//                                 ? HexColor(kNameToHex[item
//                                         .toString()
//                                         .replaceAll(' ', "_")
//                                         .toLowerCase()] ??
//                                     "#ffffff")
//                                 : HexColor(kNameToHex[item
//                                             .toString()
//                                             .replaceAll(' ', "_")
//                                             .toLowerCase()] ??
//                                         "#ffffff")
//                                     .withOpacity(0.6),
//                             borderRadius: BorderRadius.circular(25),
//                             border: Border.all(
//                               width: 1.0,
//                               color: Theme.of(context)
//                                   .accentColor
//                                   .withOpacity(0.3),
//                             ),
//                           )
//                         : BoxDecoration(
//                             color: item.toUpperCase() == value.toUpperCase()
//                                 ? primaryColor
//                                 : Colors.transparent,
//                             borderRadius: BorderRadius.circular(5.0),
//                             border: Border.all(
//                               color: Theme.of(context)
//                                   .accentColor
//                                   .withOpacity(0.3),
//                             ),
//                           ),
//                     child: InkWell(
//                       splashColor: Colors.transparent,
//                       highlightColor: Colors.transparent,
//                       onTap: () {
//                         onChanged(item);
//                       },
//                       child: type == "color"
//                           ? SizedBox(
//                               height: 25,
//                               width: 25,
//                               child: item == value
//                                   ? const Icon(
//                                       Icons.check,
//                                       color: Colors.white,
//                                       size: 16,
//                                     )
//                                   : Container(),
//                             )
//                           : Container(
//                               padding: const EdgeInsets.only(
//                                   left: 10.0, right: 10.0),
//                               child: Padding(
//                                 child: Text(
//                                   item,
//                                   style: TextStyle(
//                                     color: item == value
//                                         ? Colors.white
//                                         : Theme.of(context).accentColor,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 padding:
//                                     const EdgeInsets.only(top: 5, bottom: 5),
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//               )
//           ],
//         ),
//       ],
//     );
//   }
// }

// class OptionSelection extends StatelessWidget {
//   final List<String> options;
//   final String value;
//   final String title;
//   final Function onChanged;
//   final VariantLayout layout;

//   OptionSelection({
//     @required this.options,
//     @required this.value,
//     this.title,
//     this.layout,
//     this.onChanged,
//   });

//   showOptions(context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         return SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               for (final option in options)
//                 ListTile(
//                     onTap: () {
//                       onChanged(option);
//                       Navigator.pop(context);
//                     },
//                     title: Text(option, textAlign: TextAlign.center)),
//               Container(
//                 height: 1,
//                 decoration: const BoxDecoration(color: kGrey200),
//               ),
//               ListTile(
//                 title: Text(
//                   S.of(context).selectTheSize,
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => showOptions(context),
//       child: Container(
//         height: 42,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 2.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Expanded(
//                 child: Text("${title[0].toUpperCase()}${title.substring(1)}",
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 18)),
//               ),
//               Text(
//                 value,
//                 style: TextStyle(
//                   color: Theme.of(context).accentColor,
//                   fontSize: 13,
//                 ),
//               ),
//               const SizedBox(width: 5),
//               const Icon(Icons.keyboard_arrow_down, size: 16, color: kGrey600)
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ColorSelection extends StatelessWidget {
//   final List<String> options;
//   final String value;
//   final Function onChanged;
//   final VariantLayout layout;

//   ColorSelection(
//       {@required this.options,
//       @required this.value,
//       this.layout,
//       this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     if (layout == VariantLayout.dropdown) {
//       return GestureDetector(
//         onTap: () => showOptions(context),
//         child: Container(
//           decoration:
//               BoxDecoration(border: Border.all(width: 1.0, color: kGrey200)),
//           height: 42,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Expanded(
//                   child: Text(S.of(context).color,
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 14)),
//                 ),
//                 Container(
//                     height: 20,
//                     width: 20,
//                     decoration: BoxDecoration(
//                         color: kNameToHex[value.toLowerCase()] != null
//                             ? HexColor(kNameToHex[value.toLowerCase()])
//                             : Colors.transparent)),
//                 const SizedBox(width: 5),
//                 const Icon(Icons.keyboard_arrow_down, size: 16, color: kGrey600)
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     return Container(
//       height: 25,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: <Widget>[
//             Center(
//               child: Text(
//                 S.of(context).color,
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//               ),
//             ),
//             const SizedBox(width: 15.0),
//             for (var item in options)
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeIn,
//                 margin: const EdgeInsets.only(right: 20.0),
//                 decoration: BoxDecoration(
//                   color: item == value
//                       ? HexColor(kNameToHex[item.toLowerCase()])
//                       : HexColor(kNameToHex[item.toLowerCase()])
//                           .withOpacity(0.6),
//                   borderRadius: BorderRadius.circular(20.0),
//                   border: Border.all(
//                       width: 1.0,
//                       color: Theme.of(context).accentColor.withOpacity(0.5)),
//                 ),
//                 child: InkWell(
//                   splashColor: Colors.transparent,
//                   highlightColor: Colors.transparent,
//                   onTap: () {
//                     onChanged(item);
//                   },
//                   child: SizedBox(
//                     height: 25,
//                     width: 25,
//                     child: item == value
//                         ? const Icon(
//                             Icons.check,
//                             color: Colors.white,
//                             size: 16,
//                           )
//                         : Container(),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   void showOptions(context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               for (final option in options)
//                 ListTile(
//                   onTap: () {
//                     onChanged(option);
//                     Navigator.pop(context);
//                   },
//                   title: Center(
//                     child: Container(
//                       width: 30,
//                       height: 30,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(3.0),
//                         border: Border.all(
//                             width: 1.0, color: Theme.of(context).accentColor),
//                         color: HexColor(kNameToHex[option.toLowerCase()]),
//                       ),
//                     ),
//                   ),
//                 ),
//               Container(
//                 height: 1,
//                 decoration: const BoxDecoration(color: kGrey200),
//               ),
//               ListTile(
//                 title: Text(
//                   S.of(context).selectTheColor,
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class QuantitySelection extends StatefulWidget {
//   final int limitSelectQuantity;
//   final int value;
//   final double width;
//   final double height;
//   final Function onChanged;
//   final Color color;
//   final price;
//   final Product product;
//   final bool useNewDesign;
//   final bool enabled;
//   final bool expanded;

//   QuantitySelection({
//     @required this.value,
//     this.width = 40.0,
//     this.product,
//     this.price,
//     this.height = 42.0,
//     this.limitSelectQuantity = 100,
//     @required this.color,
//     this.onChanged,
//     this.useNewDesign = true,
//     this.enabled = true,
//     this.expanded = false,
//   });

//   @override
//   _QuantitySelectionState createState() => _QuantitySelectionState();
// }

// class _QuantitySelectionState extends State<QuantitySelection> {
//   final TextEditingController _textController = TextEditingController();
//   Timer _debounce;

//   Timer _changeQuantityTimer;

//   @override
//   void initState() {
//     super.initState();
//     _textController.text = "${widget.value}";
//     _textController.addListener(_onQuantityChanged);
//   }

//   @override
//   void dispose() {
//     _textController?.removeListener(_onQuantityChanged);
//     _changeQuantityTimer?.cancel();
//     _debounce?.cancel();
//     _textController?.dispose();
//     super.dispose();
//   }

//   int get currentQuantity => int.tryParse(_textController.text) ?? -1;

//   bool _validateQuantity([int value]) {
//     if ((value ?? currentQuantity) <= 0) {
//       _textController.text = "1";
//       return false;
//     }

//     // if ((value ?? currentQuantity) > widget.limitSelectQuantity) {
//     //   _textController.text = "${widget.limitSelectQuantity}";
//     //   return false;
//     // }

//     return true;
//   }

//   void changeQuantity(int value, {bool forceUpdate = false}) {
//     if (!_validateQuantity(value)) {
//       return;
//     }

//     if (value != currentQuantity || forceUpdate == true) {
//       _textController.text = "$value";
//     }
//   }

//   void _onQuantityChanged() {
//     if (!_validateQuantity()) {
//       return;
//     }

//     if (_debounce?.isActive ?? false) {
//       _debounce.cancel();
//     }
//     _debounce = Timer(
//       const Duration(milliseconds: 300),
//       () {
//         if (widget.onChanged != null) {
//           widget.onChanged(currentQuantity);

//           // Navigator.of(context, rootNavigator: true).pop();
//         }
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.useNewDesign == true) {
//       final _iconPadding = EdgeInsets.all(
//         max(
//           ((widget.height ?? 32.0) - 24.0 - 8) * 0.5,
//           0.0,
//         ),
//       );
//       final currency = Provider.of<AppModel>(context, listen: false).currency;
//       final currencyRate = Provider.of<AppModel>(context).currencyRate;

//       //

//       void _showFlashNotification(
//           Product product, String message, context, bool isError) {
//         if (message.isNotEmpty) {
//           showFlash(
//             context: context,
//             duration: const Duration(seconds: 3),
//             builder: (context, controller) {
//               return Flash(
//                 borderRadius: BorderRadius.circular(3.0),
//                 backgroundColor: Colors.white, // Theme.of(context).errorColor,
//                 controller: controller,
//                 style: FlashStyle.floating,
//                 position: FlashPosition.top,
//                 horizontalDismissDirection:
//                     HorizontalDismissDirection.horizontal,
//                 child: FlashBar(
//                   // icon: const Icon(
//                   //   Icons.check,
//                   //   color: Colors.blue,
//                   // ),
//                   message: Text(
//                     message,
//                     style: TextStyle(
//                       color: isError ? Colors.red : Colors.blue,
//                       fontSize: 18.0,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         } else {
//           showFlash(
//             context: context,
//             duration: const Duration(seconds: 3),
//             builder: (context, controller) {
//               return Flash(
//                 borderRadius: BorderRadius.circular(3.0),
//                 backgroundColor:
//                     Colors.white, // Theme.of(context).primaryColor,
//                 controller: controller,
//                 style: FlashStyle.floating,
//                 position: FlashPosition.top,
//                 horizontalDismissDirection:
//                     HorizontalDismissDirection.horizontal,
//                 child: FlashBar(
//                   icon: const Icon(
//                     Icons.check,
//                     color: Colors.blue,
//                   ),
//                   title: Text(
//                     product.name,
//                     style: const TextStyle(
//                       color: Colors.blue,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 15.0,
//                     ),
//                   ),
//                   message: Text(
//                     S.of(context).addToCartSucessfully,
//                     style: const TextStyle(
//                       color: Colors.blue,
//                       fontSize: 15.0,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         }
//       }

//       bool _addToCart(BuildContext context, CartModel cartModel, int offset,
//           UserModel userModel, WishListModel wishListModel) {
//         final addProductToCart =
//             Provider.of<CartModel>(context, listen: false).addProductToCartNew;
//         // try {
//         var key = "${widget.product.id}";
//         int total = !cartModel.productsInCart.containsKey(key)
//             ? offset
//             : (cartModel.productsInCart[key] + offset);
//         // await
//         MagentoApi()
//             .addItemsToCart(
//                 cartModel,
//                 widget.product.id,
//                 userModel.user != null ? userModel.user.cookie : null,
//                 widget.product.sku,
//                 total)
//             .then((value) => null)
//             .catchError((e) {
//           print(' catcherror - $e');
//           addProductToCart(
//             product: widget.product,
//             quantity: -offset,
//             context: context,
//             // success: false
//           );
//         });
//         String message = addProductToCart(
//             product: widget.product, quantity: offset, context: context);
//         print("my message $message");
//         _showFlashNotification(widget.product, message, context, false);
//         // setState(() {
//         //   qnty = 1;
//         // });
//         wishListModel.removeToWishlist(widget.product);
//         return true;
//       }

//       Future<void> _onPressed(int qnty1) async {
//         CartModel cartModel = Provider.of<CartModel>(context, listen: false);
//         UserModel userModel = Provider.of<UserModel>(context, listen: false);
//         WishListModel wishListModel =
//             Provider.of<WishListModel>(context, listen: false);
//         bool loggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;
//         var tapCount = 0;

//         // var totalQty = cartModel.productsInCart[widget.item.id] != null
//         //     ? cartModel.productsInCart[widget.item.id] + qnty
//         //     : 0 + qnty;
//         // printLog(qnty1);
//         if (userModel.user == null) {
//           if (!loggedIn) {
//             await Navigator.of(
//               context,
//               rootNavigator: true,
//             ).pushNamed(RouteList.login);
//           } else {
//             _addToCart(context, cartModel, tapCount, userModel, wishListModel);
//           }
//         } else {
//           _addToCart(context, cartModel, qnty1, userModel, wishListModel);
//         }
//       }

//       final _textField = GestureDetector(
//           onTap: () async {
//             int selectedQty = 0;
//             await showModalBottomSheet(
//               useRootNavigator: true,
//               context: context,
//               builder: (context) {
//                 return StatefulBuilder(
//                   builder: (context, setState) => Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       Container(
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             children: [
//                               // Text("sample text"),
//                               Text("$currency " + (double.parse(widget.product.price)).toString()),
//                               const Spacer(),
//                               GestureDetector(
//                                 onTap: () async {
//                                   printLog('selected');
//                                   if (selectedQty != null) {
//                                     await _onPressed(selectedQty);

//                                     _textController.text =
//                                         selectedQty.toString();
//                                   }
//                                   Navigator.of(context).pop(selectedQty);
//                                 },
//                                 child: Text(
//                                   "Update",
//                                   style: TextStyle(
//                                     color: Theme.of(context).primaryColor,
//                                     decoration: TextDecoration.underline,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const Divider(),
//                       Expanded(
//                         child: SingleChildScrollView(
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: List.generate(
//                               widget.product.qty != null
//                                   ? widget.product.qty
//                                   : 0,
//                               (index) => ListTile(
//                                 onTap: () {
//                                   setState(() {
//                                     selectedQty = index + 1;
//                                   });
//                                 },
//                                 dense: true,
//                                 title: Text(
//                                   "${index + 1}",
//                                 ),
//                                 trailing: selectedQty == index + 1
//                                     ? const Icon(Icons.check)
//                                     : null,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             );
//           },
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 4.0),
//             height: widget.height,
//             width: widget.expanded == true ? null : widget.width,
//             decoration: BoxDecoration(
//               border: Border.all(width: 1.0, color: kGrey200),
//               borderRadius: BorderRadius.circular(3),
//             ),
//             alignment: Alignment.center,
//             child: TextField(
//               readOnly: widget.enabled == false,
//               //// enabled: widget.enabled == true,
//               enabled: false,
//               controller: _textController,

//               maxLines: 1,
//               maxLength: "${widget.limitSelectQuantity ?? 100}".length,
//               onEditingComplete: _validateQuantity,
//               onSubmitted: (_) => _validateQuantity(),
//               decoration: const InputDecoration(
//                 border: InputBorder.none,
//                 counterText: "",
//               ),
//               keyboardType: const TextInputType.numberWithOptions(
//                 signed: false,
//                 decimal: false,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ));
//       return Row(
//         children: [
//           widget.enabled == true
//               ? IconButton(
//                   padding: _iconPadding,
//                   onPressed: () {
//                     changeQuantity(currentQuantity - 1);
//                   },
//                   icon: const Center(
//                       child: Icon(
//                     Icons.arrow_back_ios,
//                     size: 15,
//                   )),
//                 )
//               : const SizedBox.shrink(),
//           widget.expanded == true
//               ? Expanded(
//                   child: _textField,
//                 )
//               : _textField,
//           widget.enabled == true
//               ? IconButton(
//                   padding: _iconPadding,
//                   onPressed: () {
//                     //    print(widget.product.qty);
//                     // print(currentQuantity);
//                     if (widget.product.qty > currentQuantity) {
//                       changeQuantity(currentQuantity + 1);
//                     }
//                   },
//                   icon: const Icon(
//                     Icons.arrow_forward_ios,
//                     size: 15,
//                   ),
//                 )
//               : const SizedBox.shrink(),
//         ],
//       );
//     }
//     return GestureDetector(
//       onTap: () {
//         if (widget.onChanged != null) {
//           showOptions(context);
//         }
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           border: Border.all(width: 1.0, color: kGrey200),
//           borderRadius: BorderRadius.circular(3),
//         ),
//         height: widget.height,
//         width: widget.width,
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//               vertical: 2.0,
//               horizontal: (widget.onChanged != null) ? 5.0 : 10.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Expanded(
//                 child: Center(
//                   child: Text(
//                     widget.value.toString(),
//                     style: TextStyle(fontSize: 14, color: widget.color),
//                   ),
//                 ),
//               ),
//               if (widget.onChanged != null)
//                 const SizedBox(
//                   width: 5.0,
//                 ),
//               if (widget.onChanged != null)
//                 Icon(Icons.keyboard_arrow_down,
//                     size: 14, color: Theme.of(context).accentColor)
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void showOptions(context) {
//     showModalBottomSheet(
//         context: context,
//         useRootNavigator: true,
//         builder: (BuildContext context) {
//           return Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       for (int option = 1;
//                           option <= widget.limitSelectQuantity;
//                           option++)
//                         ListTile(
//                             onTap: () {
// // Center(child:CircularProgressIndicator());

//                               // Navigator.of(context, rootNavigator: true).pop();
// //  Timer(Duration(seconds: 1), ()async{
// //    print("fucked up");
// //      await  showDialog(
// //               context: context,
// //               builder: kLoadingWidget,
// //               useRootNavigator: false
// //             );
// //     Navigator.of(context).pop();
// //     });

//                               widget.onChanged(option);

//                               showDialog(
//                                 barrierDismissible: false,
//                                 context: context,
//                                 builder: kLoadingWidget,
//                               );
//                               Future.delayed(const Duration(milliseconds: 3000),
//                                   () async {
//                                 await Navigator.of(context, rootNavigator: true)
//                                     .pop();
//                               });

//                               Future.delayed(const Duration(milliseconds: 3000),
//                                   () async {
//                                 await Navigator.of(context).pop();
//                               });
//                             },
//                             title: Text(
//                               option.toString(),
//                               textAlign: TextAlign.center,
//                             )),
//                     ],
//                   ),
//                 ),
//               ),
//               Container(
//                 height: 1,
//                 decoration: const BoxDecoration(color: kGrey200),
//               ),
//               ListTile(
//                 title: Text(
//                   S.of(context).selectTheQuantity,
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ],
//           );
//         });
//   }
// }

// class ImageSelection extends StatelessWidget {
//   final Map<String, String> imageUrls;
//   final List<String> options;
//   final String value;
//   final String title;
//   final Function onChanged;
//   final VariantLayout layout;

//   ImageSelection({
//     @required this.options,
//     @required this.value,
//     this.title,
//     this.layout,
//     this.onChanged,
//     this.imageUrls,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final double size = kProductDetail["attributeImagesSize"] ?? 30.0;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.max,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: <Widget>[
//         Row(
//           children: <Widget>[
//             Expanded(
//               child: Padding(
//                 child: Text(
//                   "${title[0].toUpperCase()}${title.substring(1)}",
//                   style: Theme.of(context).textTheme.headline6,
//                 ),
//                 padding: const EdgeInsets.only(bottom: 10),
//               ),
//             ),
//           ],
//         ),
//         Wrap(
//           spacing: 0.0,
//           runSpacing: 12.0,
//           children: <Widget>[
//             for (var item in options)
//               tool_tip.Tooltip(
//                 message: item.toString(),
//                 child: Container(
//                   height: size + 2,
//                   width: size + 2,
//                   margin: const EdgeInsets.only(right: 15.0),
//                   child: Container(
//                     padding: const EdgeInsets.all(2.0),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(5.0),
//                       border: Border.all(
//                         width: 1.0,
//                         color: Theme.of(context).accentColor.withOpacity(
//                             item.toUpperCase() == value.toUpperCase()
//                                 ? 0.6
//                                 : 0.3),
//                       ),
//                     ),
//                     child: InkWell(
//                       splashColor: Colors.transparent,
//                       highlightColor: Colors.transparent,
//                       onTap: () {
//                         onChanged(item);
//                       },
//                       child: Stack(
//                         children: [
//                           Positioned.fill(
//                             child: Tools.image(
//                               url: imageUrls[item],
//                               height: size,
//                               width: size,
//                             ),
//                           ),
//                           if (item.toUpperCase() == value.toUpperCase())
//                             Positioned.fill(
//                               child: Container(
//                                 color: Theme.of(context)
//                                     .backgroundColor
//                                     .withOpacity(0.6),
//                                 child: const Icon(
//                                   Icons.check_circle_rounded,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//           ],
//         ),
//       ],
//     );
//   }
// }

// // import 'dart:async';
// // import 'dart:math';

// // import 'package:flutter/material.dart';

// // import '../../common/config/products.dart';
// // import '../../common/constants.dart';
// // import '../../common/tools.dart';
// // import '../../generated/l10n.dart';
// // import '../../widgets/common/tooltip.dart' as tool_tip;

// // enum VariantLayout { inline, dropdown }

// // class BasicSelection extends StatelessWidget {
// //   final Map<String, String> imageUrls;
// //   final List<String> options;
// //   final String value;
// //   final String title;
// //   final String type;
// //   final Function onChanged;
// //   final VariantLayout layout;

// //   BasicSelection(
// //       {@required this.options,
// //       @required this.title,
// //       @required this.value,
// //       this.type,
// //       this.layout,
// //       this.onChanged,
// //       this.imageUrls});

// //   @override
// //   Widget build(BuildContext context) {
// //     Color primaryColor = Theme.of(context).primaryColor;

// //     if (type == "option") {
// //       return OptionSelection(
// //         options: options,
// //         value: value,
// //         title: title,
// //         onChanged: onChanged,
// //       );
// //     }

// //     if (type == "image") {
// //       return ImageSelection(
// //         imageUrls: imageUrls,
// //         options: options,
// //         value: value,
// //         title: title,
// //         onChanged: onChanged,
// //       );
// //     }

// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       mainAxisSize: MainAxisSize.max,
// //       mainAxisAlignment: MainAxisAlignment.start,
// //       children: <Widget>[
// //         Row(
// //           children: <Widget>[
// //             Expanded(
// //               child: Padding(
// //                 child: Text(
// //                   "${title[0].toUpperCase()}${title.substring(1)}",
// //                   style: Theme.of(context).textTheme.headline6,
// //                 ),
// //                 padding: const EdgeInsets.only(bottom: 10),
// //               ),
// //             ),
// //           ],
// //         ),
// //         Wrap(
// //           spacing: 0.0,
// //           runSpacing: 12.0,
// //           children: <Widget>[
// //             for (var item in options)
// //               tool_tip.Tooltip(
// //                 message: item.toString(),
// //                 child: Container(
// //                   //height: type == "color" ? 26 : 30,
// //                   child: AnimatedContainer(
// //                     duration: const Duration(milliseconds: 300),
// //                     curve: Curves.easeIn,
// //                     margin: const EdgeInsets.only(right: 15.0),
// //                     decoration: type == "color"
// //                         ? BoxDecoration(
// //                             color: item.toUpperCase() == value.toUpperCase()
// //                                 ? HexColor(kNameToHex[item
// //                                         .toString()
// //                                         .replaceAll(' ', "_")
// //                                         .toLowerCase()] ??
// //                                     "#ffffff")
// //                                 : HexColor(kNameToHex[item
// //                                             .toString()
// //                                             .replaceAll(' ', "_")
// //                                             .toLowerCase()] ??
// //                                         "#ffffff")
// //                                     .withOpacity(0.6),
// //                             borderRadius: BorderRadius.circular(25),
// //                             border: Border.all(
// //                               width: 1.0,
// //                               color: Theme.of(context)
// //                                   .accentColor
// //                                   .withOpacity(0.3),
// //                             ),
// //                           )
// //                         : BoxDecoration(
// //                             color: item.toUpperCase() == value.toUpperCase()
// //                                 ? primaryColor
// //                                 : Colors.transparent,
// //                             borderRadius: BorderRadius.circular(5.0),
// //                             border: Border.all(
// //                               color: Theme.of(context)
// //                                   .accentColor
// //                                   .withOpacity(0.3),
// //                             ),
// //                           ),
// //                     child: InkWell(
// //                       splashColor: Colors.transparent,
// //                       highlightColor: Colors.transparent,
// //                       onTap: () {
// //                         onChanged(item);
// //                       },
// //                       child: type == "color"
// //                           ? SizedBox(
// //                               height: 25,
// //                               width: 25,
// //                               child: item == value
// //                                   ? const Icon(
// //                                       Icons.check,
// //                                       color: Colors.white,
// //                                       size: 16,
// //                                     )
// //                                   : Container(),
// //                             )
// //                           : Container(
// //                               padding: const EdgeInsets.only(
// //                                   left: 10.0, right: 10.0),
// //                               child: Padding(
// //                                 child: Text(
// //                                   item,
// //                                   style: TextStyle(
// //                                     color: item == value
// //                                         ? Colors.white
// //                                         : Theme.of(context).accentColor,
// //                                     fontSize: 14,
// //                                   ),
// //                                 ),
// //                                 padding:
// //                                     const EdgeInsets.only(top: 5, bottom: 5),
// //                               ),
// //                             ),
// //                     ),
// //                   ),
// //                 ),
// //               )
// //           ],
// //         ),
// //       ],
// //     );
// //   }
// // }

// // class OptionSelection extends StatelessWidget {
// //   final List<String> options;
// //   final String value;
// //   final String title;
// //   final Function onChanged;
// //   final VariantLayout layout;

// //   OptionSelection({
// //     @required this.options,
// //     @required this.value,
// //     this.title,
// //     this.layout,
// //     this.onChanged,
// //   });

// //   showOptions(context) {
// //     showModalBottomSheet(
// //       context: context,
// //       // https://github.com/instasoft/support/issues/4814#issuecomment-684179116
// //       isScrollControlled: true,
// //       builder: (BuildContext context) {
// //         return SingleChildScrollView(
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: <Widget>[
// //               for (final option in options)
// //                 ListTile(
// //                     onTap: () {
// //                       onChanged(option);
// //                       Navigator.pop(context);
// //                     },
// //                     title: Text(option, textAlign: TextAlign.center)),
// //               Container(
// //                 height: 1,
// //                 decoration: const BoxDecoration(color: kGrey200),
// //               ),
// //               ListTile(
// //                 title: Text(
// //                   S.of(context).selectTheSize,
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: () => showOptions(context),
// //       child: Container(
// //         height: 42,
// //         child: Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 2.0),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: <Widget>[
// //               Expanded(
// //                 child: Text("${title[0].toUpperCase()}${title.substring(1)}",
// //                     style: const TextStyle(
// //                         fontWeight: FontWeight.bold, fontSize: 18)),
// //               ),
// //               Text(
// //                 value,
// //                 style: TextStyle(
// //                   color: Theme.of(context).accentColor,
// //                   fontSize: 13,
// //                 ),
// //               ),
// //               const SizedBox(width: 5),
// //               const Icon(Icons.keyboard_arrow_down, size: 16, color: kGrey600)
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class ColorSelection extends StatelessWidget {
// //   final List<String> options;
// //   final String value;
// //   final Function onChanged;
// //   final VariantLayout layout;

// //   ColorSelection(
// //       {@required this.options,
// //       @required this.value,
// //       this.layout,
// //       this.onChanged});

// //   @override
// //   Widget build(BuildContext context) {
// //     if (layout == VariantLayout.dropdown) {
// //       return GestureDetector(
// //         onTap: () => showOptions(context),
// //         child: Container(
// //           decoration:
// //               BoxDecoration(border: Border.all(width: 1.0, color: kGrey200)),
// //           height: 42,
// //           child: Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 10.0),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: <Widget>[
// //                 Expanded(
// //                   child: Text(S.of(context).color,
// //                       style: const TextStyle(
// //                           fontWeight: FontWeight.bold, fontSize: 14)),
// //                 ),
// //                 Container(
// //                     height: 20,
// //                     width: 20,
// //                     decoration: BoxDecoration(
// //                         color: kNameToHex[value.toLowerCase()] != null
// //                             ? HexColor(kNameToHex[value.toLowerCase()])
// //                             : Colors.transparent)),
// //                 const SizedBox(width: 5),
// //                 const Icon(Icons.keyboard_arrow_down, size: 16, color: kGrey600)
// //               ],
// //             ),
// //           ),
// //         ),
// //       );
// //     }

// //     return Container(
// //       height: 25,
// //       child: SingleChildScrollView(
// //         scrollDirection: Axis.horizontal,
// //         child: Row(
// //           children: <Widget>[
// //             Center(
// //               child: Text(
// //                 S.of(context).color,
// //                 style:
// //                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
// //               ),
// //             ),
// //             const SizedBox(width: 15.0),
// //             for (var item in options)
// //               AnimatedContainer(
// //                 duration: const Duration(milliseconds: 300),
// //                 curve: Curves.easeIn,
// //                 margin: const EdgeInsets.only(right: 20.0),
// //                 decoration: BoxDecoration(
// //                   color: item == value
// //                       ? HexColor(kNameToHex[item.toLowerCase()])
// //                       : HexColor(kNameToHex[item.toLowerCase()])
// //                           .withOpacity(0.6),
// //                   borderRadius: BorderRadius.circular(20.0),
// //                   border: Border.all(
// //                       width: 1.0,
// //                       color: Theme.of(context).accentColor.withOpacity(0.5)),
// //                 ),
// //                 child: InkWell(
// //                   splashColor: Colors.transparent,
// //                   highlightColor: Colors.transparent,
// //                   onTap: () {
// //                     onChanged(item);
// //                   },
// //                   child: SizedBox(
// //                     height: 25,
// //                     width: 25,
// //                     child: item == value
// //                         ? const Icon(
// //                             Icons.check,
// //                             color: Colors.white,
// //                             size: 16,
// //                           )
// //                         : Container(),
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   void showOptions(context) {
// //     showModalBottomSheet(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return SingleChildScrollView(
// //           scrollDirection: Axis.vertical,
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: <Widget>[
// //               for (final option in options)
// //                 ListTile(
// //                   onTap: () {
// //                     onChanged(option);
// //                     Navigator.pop(context);
// //                   },
// //                   title: Center(
// //                     child: Container(
// //                       width: 30,
// //                       height: 30,
// //                       decoration: BoxDecoration(
// //                         borderRadius: BorderRadius.circular(3.0),
// //                         border: Border.all(
// //                             width: 1.0, color: Theme.of(context).accentColor),
// //                         color: HexColor(kNameToHex[option.toLowerCase()]),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               Container(
// //                 height: 1,
// //                 decoration: const BoxDecoration(color: kGrey200),
// //               ),
// //               ListTile(
// //                 title: Text(
// //                   S.of(context).selectTheColor,
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }

// // class QuantitySelection extends StatefulWidget {
// //   final int limitSelectQuantity;
// //   final int value;
// //   final double width;
// //   final double height;
// //   final Function onChanged;
// //   final Color color;
// //   final bool useNewDesign;
// //   final bool enabled;
// //   final bool expanded;

// //   QuantitySelection({
// //     @required this.value,
// //     this.width = 40.0,
// //     this.height = 42.0,
// //     this.limitSelectQuantity = 100,
// //     @required this.color,
// //     this.onChanged,
// //     this.useNewDesign = true,
// //     this.enabled = true,
// //     this.expanded = false,
// //   });

// //   @override
// //   _QuantitySelectionState createState() => _QuantitySelectionState();
// // }

// // class _QuantitySelectionState extends State<QuantitySelection> {
// //   final TextEditingController _textController = TextEditingController();
// //   Timer _debounce;

// //   Timer _changeQuantityTimer;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _textController.text = "${widget.value}";
// //     _textController.addListener(_onQuantityChanged);
// //   }

// //   @override
// //   void dispose() {
// //     _textController?.removeListener(_onQuantityChanged);
// //     _changeQuantityTimer?.cancel();
// //     _debounce?.cancel();
// //     _textController?.dispose();
// //     super.dispose();
// //   }

// //   int get currentQuantity => int.tryParse(_textController.text) ?? -1;

// //   bool _validateQuantity([int value]) {
// //     if ((value ?? currentQuantity) <= 0) {
// //       _textController.text = "1";
// //       return false;
// //     }

// //     if ((value ?? currentQuantity) > widget.limitSelectQuantity) {
// //       _textController.text = "${widget.limitSelectQuantity}";
// //       return false;
// //     }
// //     return true;
// //   }

// //   void changeQuantity(int value, {bool forceUpdate = false}) {
// //     if (!_validateQuantity(value)) {
// //       return;
// //     }

// //     if (value != currentQuantity || forceUpdate == true) {
// //       _textController.text = "$value";
// //     }
// //   }

// //   void _onQuantityChanged() {
// //     if (!_validateQuantity()) {
// //       return;
// //     }

// //     if (_debounce?.isActive ?? false) {
// //       _debounce.cancel();
// //     }
// //     _debounce = Timer(
// //       const Duration(milliseconds: 300),
// //       () {
// //         if (widget.onChanged != null) {
// //           widget.onChanged(currentQuantity);
// //         }
// //       },
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     if (widget.useNewDesign == true) {
// //       final _iconPadding = EdgeInsets.all(
// //         max(
// //           ((widget.height ?? 32.0) - 24.0 - 8) * 0.5,
// //           0.0,
// //         ),
// //       );
// //       final _textField = Container(
// //         margin: const EdgeInsets.symmetric(horizontal: 4.0),
// //         height: widget.height,
// //         width: widget.expanded == true ? null : widget.width,
// //         decoration: BoxDecoration(
// //           border: Border.all(width: 1.0, color: kGrey200),
// //           borderRadius: BorderRadius.circular(3),
// //         ),
// //         alignment: Alignment.center,
// //         child: TextField(
// //           readOnly: widget.enabled == false,
// //           enabled: widget.enabled == true,
// //           controller: _textController,
// //           maxLines: 1,
// //           maxLength: "${widget.limitSelectQuantity ?? 100}".length,
// //           onEditingComplete: _validateQuantity,
// //           onSubmitted: (_) => _validateQuantity(),
// //           decoration: const InputDecoration(
// //             border: InputBorder.none,
// //             counterText: "",
// //           ),
// //           keyboardType: const TextInputType.numberWithOptions(
// //             signed: false,
// //             decimal: false,
// //           ),
// //           textAlign: TextAlign.center,
// //         ),
// //       );
// //       return Row(
// //         children: [
// //           widget.enabled == true
// //               ? IconButton(
// //                   padding: _iconPadding,
// //                   onPressed: () => changeQuantity(currentQuantity - 1),
// //                   icon: const Center(
// //                       child: Icon(
// //                     Icons.arrow_back_ios,
// //                     size: 15,
// //                   )),
// //                 )
// //               : const SizedBox.shrink(),
// //           widget.expanded == true
// //               ? Expanded(
// //                   child: _textField,
// //                 )
// //               : _textField,
// //           widget.enabled == true
// //               ? IconButton(
// //                   padding: _iconPadding,
// //                   onPressed: () => changeQuantity(currentQuantity + 1),
// //                   icon: const Icon(
// //                     Icons.arrow_forward_ios,
// //                     size: 15,
// //                   ),
// //                 )
// //               : const SizedBox.shrink(),
// //         ],
// //       );
// //     }
// //     return GestureDetector(
// //       onTap: () {
// //         if (widget.onChanged != null) {
// //           showOptions(context);
// //         }
// //       },
// //       child: Container(
// //         decoration: BoxDecoration(
// //           border: Border.all(width: 1.0, color: kGrey200),
// //           borderRadius: BorderRadius.circular(3),
// //         ),
// //         height: widget.height,
// //         width: widget.width,
// //         child: Padding(
// //           padding: EdgeInsets.symmetric(
// //               vertical: 2.0,
// //               horizontal: (widget.onChanged != null) ? 5.0 : 10.0),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: <Widget>[
// //               Expanded(
// //                 child: Center(
// //                   child: Text(
// //                     widget.value.toString(),
// //                     style: TextStyle(fontSize: 14, color: widget.color),
// //                   ),
// //                 ),
// //               ),
// //               if (widget.onChanged != null)
// //                 const SizedBox(
// //                   width: 5.0,
// //                 ),
// //               if (widget.onChanged != null)
// //                 Icon(Icons.keyboard_arrow_down,
// //                     size: 14, color: Theme.of(context).accentColor)
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   void showOptions(context) {
// //     showModalBottomSheet(
// //         context: context,
// //         useRootNavigator: true,
// //         builder: (BuildContext context) {
// //           return Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: <Widget>[
// //               Expanded(
// //                 child: SingleChildScrollView(
// //                   child: Column(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: <Widget>[
// //                       for (int option = 1;
// //                           option <= widget.limitSelectQuantity;
// //                           option++)
// //                         ListTile(
// //                             onTap: () {
// //                               widget.onChanged(option);
// //                               showDialog(
// //                                 context: context,
// //                                 builder: kLoadingWidget,
// //                               );
// //                               Future.delayed(const Duration(milliseconds: 3000),
// //                                   () async {
// //                                 await Navigator.of(context, rootNavigator: true)
// //                                     .pop();
// //                               });

// //                               Future.delayed(const Duration(milliseconds: 3000),
// //                                   () async {
// //                                 await Navigator.of(context).pop();
// //                               });
// //                               // Navigator.pop(context);
// //                             },
// //                             title: Text(
// //                               option.toString(),
// //                               textAlign: TextAlign.center,
// //                             )),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //               Container(
// //                 height: 1,
// //                 decoration: const BoxDecoration(color: kGrey200),
// //               ),
// //               ListTile(
// //                 title: Text(
// //                   S.of(context).selectTheQuantity,
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ),
// //             ],
// //           );
// //         });
// //   }
// // }

// // class ImageSelection extends StatelessWidget {
// //   final Map<String, String> imageUrls;
// //   final List<String> options;
// //   final String value;
// //   final String title;
// //   final Function onChanged;
// //   final VariantLayout layout;

// //   ImageSelection({
// //     @required this.options,
// //     @required this.value,
// //     this.title,
// //     this.layout,
// //     this.onChanged,
// //     this.imageUrls,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     final double size = kProductDetail["attributeImagesSize"] ?? 30.0;
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       mainAxisSize: MainAxisSize.max,
// //       mainAxisAlignment: MainAxisAlignment.start,
// //       children: <Widget>[
// //         Row(
// //           children: <Widget>[
// //             Expanded(
// //               child: Padding(
// //                 child: Text(
// //                   "${title[0].toUpperCase()}${title.substring(1)}",
// //                   style: Theme.of(context).textTheme.headline6,
// //                 ),
// //                 padding: const EdgeInsets.only(bottom: 10),
// //               ),
// //             ),
// //           ],
// //         ),
// //         Wrap(
// //           spacing: 0.0,
// //           runSpacing: 12.0,
// //           children: <Widget>[
// //             for (var item in options)
// //               tool_tip.Tooltip(
// //                 message: item.toString(),
// //                 child: Container(
// //                   height: size + 2,
// //                   width: size + 2,
// //                   margin: const EdgeInsets.only(right: 15.0),
// //                   child: Container(
// //                     padding: const EdgeInsets.all(2.0),
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(5.0),
// //                       border: Border.all(
// //                         width: 1.0,
// //                         color: Theme.of(context).accentColor.withOpacity(
// //                             item.toUpperCase() == value.toUpperCase()
// //                                 ? 0.6
// //                                 : 0.3),
// //                       ),
// //                     ),
// //                     child: InkWell(
// //                       splashColor: Colors.transparent,
// //                       highlightColor: Colors.transparent,
// //                       onTap: () {
// //                         onChanged(item);
// //                       },
// //                       child: Stack(
// //                         children: [
// //                           Positioned.fill(
// //                             child: Tools.image(
// //                               url: imageUrls[item],
// //                               height: size,
// //                               width: size,
// //                             ),
// //                           ),
// //                           if (item.toUpperCase() == value.toUpperCase())
// //                             Positioned.fill(
// //                               child: Container(
// //                                 color: Theme.of(context)
// //                                     .backgroundColor
// //                                     .withOpacity(0.6),
// //                                 child: const Icon(
// //                                   Icons.check_circle_rounded,
// //                                 ),
// //                               ),
// //                             ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               )
// //           ],
// //         ),
// //       ],
// //     );
// //   }
// // }
