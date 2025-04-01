import 'dart:async';

import 'package:ctown/screens/detail/product_variant.dart';
import 'package:ctown/services/service_config.dart';
import 'package:ctown/widgets/common/animated_add_cart_button.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../frameworks/magento/services/magento.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show AppModel, CartModel, Product, ProductModel, ProductVariation, RecentModel, User, UserModel, WishListModel;
import '../../routes/aware.dart';
import '../../screens/index.dart' show ProductDetailScreen;
import '../../services/index.dart';
import '../common/sale_progress_bar.dart';
import '../common/start_rating.dart';
import 'heart_button.dart';

class ProductItemTileView extends StatelessWidget {
  final Product? item;
  final EdgeInsets? padding;
  final bool showProgressBar;

  ProductItemTileView({
    this.item,
    this.padding,
    this.showProgressBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTapProduct(context),
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(width: 8),
            Flexible(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2.0),
                child: Stack(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 15.0),
                      child: getImageFeature(
                        () => onTapProduct(context),
                      ),
                    ),
                    if ((item!.onSale ?? false) &&
                        item!.regularPrice!.isNotEmpty &&
                        double.parse(item!.price!) /
                                double.parse(item!.regularPrice.toString()) <
                            1)
                      InkWell(
                        onTap: () => onTapProduct(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(8))),
                          child: Text(
                            '${(100 - double.parse(item!.price!) / double.parse(item!.regularPrice.toString()) * 100).toInt()} %',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            if (item != null)
              Flexible(
                flex: 3,
                child: _ProductDescription(
                  item: item,
                  showProgressBar: showProgressBar,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget getImageFeature(onTapProduct) {
    return GestureDetector(
      onTap: onTapProduct,
      child: Tools.image(
        url: item!.imageFeature,
        size: kSize.medium,
        isResize: true,
        // height: _height,
        fit: BoxFit.fitHeight,
      ),
    );
  }

  onTapProduct(context) {
    if (item!.imageFeature == '') return;
    Provider.of<RecentModel>(context, listen: false).addRecentProduct(item);

    eventBus.fire('detail');

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => RouteAwareWidget(
          'detail',
          child: ProductDetailScreen(product: item),
        ),
        fullscreenDialog: kIsWeb,
      ),
    );
  }
}

class _ProductDescription extends StatefulWidget {
  final Product? item;
  final bool? showProgressBar;
  final User? user;

  const _ProductDescription(
      {Key? key, this.item, this.showProgressBar, this.user})
      : super(key: key);

  @override
  __ProductDescriptionState createState() => __ProductDescriptionState();
}

class __ProductDescriptionState extends State<_ProductDescription>
    with SingleTickerProviderStateMixin {
  Timer? _debounce;
  var qnty = 10;
  var tapCount = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    UserModel userModel = Provider.of<UserModel>(context);
    final cartModel = Provider.of<CartModel>(context);
    final currency = Provider.of<AppModel>(context, listen: false).currency;
    var quantity = cartModel.productsInCart[widget.item!.id] != null
        ? cartModel.productsInCart[widget.item!.id]
        : 0;
    bool loggedIn = Provider.of<UserModel>(context).loggedIn;
    bool isSale = (widget.item!.onSale ?? false);
    WishListModel wishListModel = Provider.of<WishListModel>(context);
    var salePercent = 0;

    double regularPrice = 0.0;
    var priceProduct = Tools.getPriceProductValue(
      widget.item,
      currency,
      onSale: true,
    );
    Widget _productPricing = Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[
        Text(
          widget.item!.type == 'grouped'
              ? '${S.of(context).from} ${Tools.getPriceProduct(widget.item, currencyRate, currency, onSale: true)}'
              : priceProduct == '0.0'
                  ? S.of(context).loading
                  : Config().isListingType()
                      ? Tools.getCurrencyFormatted(
                          widget.item!.price ?? widget.item!.regularPrice ?? '0',
                          null)!
                      : Tools.getPriceProduct(
                          widget.item, currencyRate, currency,
                          onSale: true)!,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
              )
              .apply(fontSizeFactor: 0.8),
        ),

        /// Not show regular price for variant product (product.regularPrice = "").
        if (isSale &&
            (salePercent != 0 &&
                salePercent != 100) && // not show sale percent if 0 or 100
            widget.item!.type != 'variable') ...[
          const SizedBox(width: 5),
          Text(
            widget.item!.type == 'grouped'
                ? ''
                : regularPrice < double.parse(widget.item!.salePrice!)
                    ? ""
                    : Tools.getPriceProduct(widget.item, currencyRate, currency,
                        onSale: false)!,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                  decoration: TextDecoration.lineThrough,
                )
                .apply(fontSizeFactor: 0.8),
          ),
        ]
      ],
    );
    void _showFlashNotification(
        Product? product, String message, context, bool isError, offset) {
      if (message.isNotEmpty) {
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
                backgroundColor: Colors.white, // Theme.of(context).errorColor,
                behavior: FlashBehavior.floating,
                // icon: const Icon(
                //   Icons.check,
                //   color: Colors.red,
                // ),
                content: Text(
                  message,
                  style: TextStyle(
                    color: isError ? Colors.red : Colors.red,
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
                behavior: FlashBehavior.floating,
                backgroundColor: Colors.white, // Theme.of(context).primaryColor,
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
                  offset <= 0
                      ? "Have been removed from your cart"
                      : S.of(context).addToCartSucessfully,
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

    Future<bool> _addToCart(BuildContext context, CartModel cartModel, int offset,
        UserModel userModel, WishListModel wishListModel) async {
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
                color: Theme.of(context).primaryColor,
                size: 30.0),
            maskType: EasyLoadingMaskType.black);
        final addProductToCart =
            Provider.of<CartModel>(context, listen: false).addProductToCartNew;
        // try {
        var key = "${widget.item?.id}";
        int total = !cartModel.productsInCart.containsKey(key)
            ? offset
            : (cartModel.productsInCart[key] ?? 0 + offset);
        print(cartModel.productsInCart[key]);
        // !cartModel.productsInCart.containsKey(key)
        //     ? offset
        //     : (cartModel.productsInCart[key] + offset);
        // await
        print("offset $offset");
        await Future.delayed(Duration(milliseconds: 1000));
        MagentoApi()
            .addItemsToCart(
            Provider.of<AppModel>(context, listen: false).langCode,
            cartModel,
            widget.item?.id,
            userModel.user != null ? userModel.user?.cookie : null,
            widget.item?.sku, total)
            .then((value) => null)
            .catchError((e) {
          print(' catcherror - $e');
          addProductToCart(
            product: widget.item,
            quantity: -offset,
            context: context,
            // success: false
          );
        });
        String message = addProductToCart(
            product: widget.item, quantity: offset, context: context);
        _showFlashNotification(widget.item, message, context, false, offset);
        setState(() {
          qnty = 1;
        });
        wishListModel.removeToWishlist(widget.item);
      }
      catch(e) {
        printLog(e.toString());
      }
      finally {
        EasyLoading.dismiss();
      }
      return true;
    }

    Future<void> _onPressed(int qnty1) async {
      try {
        // var totalQty = cartModel.productsInCart[widget.item.id] != null
        //     ? cartModel.productsInCart[widget.item.id] + qnty
        //     : 0 + qnty;
        // printLog(qnty1);
        if (widget.user == null) {
          if (!loggedIn) {
            await Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamed(RouteList.login);
          } else {
            // if (
            //     /*totalQty*/ totalqnty > 1) {
            if (_debounce?.isActive ?? false) {
              _debounce!.cancel();
            }
            _debounce = Timer(
              const Duration(milliseconds: 500),
                  () {
                if (tapCount != 0)
                  _addToCart(
                      context, cartModel, tapCount, userModel, wishListModel);
                tapCount = 0;
              },
            );

            setState(() {
              if (quantity! + tapCount + qnty1 > 0) {
                tapCount += qnty1;
                qnty += qnty1;
              }
            });
            //return status;
            // printLog('====${cartModel.productsInCart[widget.item.id]}===');
            // }
          }
        } else {
          // if (/*totalQty*/ totalqnty > 1) {
          if (_debounce?.isActive ?? false) {
            _debounce!.cancel();
          }
          _debounce = Timer(
            const Duration(milliseconds: 500),
                () {
              if (tapCount != 0)
                _addToCart(
                    context, cartModel, tapCount, userModel, wishListModel);
              tapCount = 0;
            },
          );

          setState(() {
            if (quantity! + tapCount + qnty1 > 0) {
              tapCount += qnty1;
              qnty += qnty1;
            }
          });
          //return status;
          // printLog('====${cartModel.productsInCart[widget.item.id]}===');
          // }
        }
      }
      catch(e) {
        printLog(e.toString());
      }
    }

    // final ThemeData theme = Theme.of(context);
    // final addProductToCart =
    //     Provider.of<CartModel>(context, listen: false).addProductToCart;
    // final cartModel = Provider.of<CartModel>(context);
    // final userModel = Provider.of<UserModel>(context);

    // final currency = Provider.of<AppModel>(context, listen: false).currency;
    // final currencyRate = Provider.of<AppModel>(context).currencyRate;

    final isTablet = Tools.isTablet(MediaQuery.of(context));

    // // bool isSale = (item.onSale ?? false) &&
    // //     double.parse(Tools.getPriceProductValue(item, currency, onSale: true)) <
    // //         double.parse(Tools.getPriceProductValue(item, currency, onSale: false));
    // bool isSale = (widget.item.onSale ?? false);

    double ratingCountFontSize = isTablet ? 16.0 : 12.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10),
            if (widget.item!.categoryName != null)
              Text(
                widget.item!.categoryName!.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            if (widget.item!.type != "configurable")
              Text(
                widget.item!.name!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.0,
                ),
              ),
            if (widget.item!.type != "configurable") const SizedBox(height: 4),
            if (widget.item!.type != "configurable")
              if (widget.item!.tagLine != null)
                Text(
                  '${widget.item!.tagLine}',
                  maxLines: 1,
                  style: const TextStyle(fontSize: 13),
                ),
            if (isSale) const SizedBox(width: 5),
            if (widget.item!.type != "configurable")
              Wrap(
                children: <Widget>[
                  Text(
                    widget.item!.type == 'grouped'
                        ? 'From ${Tools.getPriceProduct(widget.item, currencyRate, currency, onSale: true)}'
                        : Tools.getPriceProduct(
                            widget.item, currencyRate, currency,
                            onSale: true)!,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 14,
                          color: theme.colorScheme.secondary,
                        ),
                  ),
                  const SizedBox(width: 10),
                  /*if (isSale)
                    Text(
                      Tools.getCurrencyFormatted(
                        widget.item.regularPrice,
                        currencyRate,
                        currency: currency,
                      ),
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            fontSize: 16,
                            color:
                                Theme.of(context).accentColor.withOpacity(0.5),
                            decoration: TextDecoration.lineThrough,
                          ),
                    ),*/
                ],
              ),
            if (widget.item!.type != "configurable")
              SizedBox(height: (widget.showProgressBar ?? false) ? 16 : 20),
            if (widget.item!.type != "configurable") _buildStockStatus(context),
            if (widget.item!.type != "configurable") const SizedBox(height: 6),
            if (widget.item!.type != "configurable")
              if (kAdvanceConfig['EnableRating'] as bool)
                if (kAdvanceConfig['hideEmptyProductListRating'] == false ||
                    (widget.item!.ratingCount != null &&
                        widget.item!.ratingCount! > 0))
                  if (widget.item!.type != "configurable")
                    SmoothStarRating(
                      allowHalfRating: true,
                      starCount: 5,
                      rating: widget.item!.averageRating ?? 0.0,
                      size: 14,
                      label: Text(
                        widget.item!.ratingCount == 0 ||
                                widget.item!.ratingCount == null
                            ? ''
                            : '${widget.item!.ratingCount} ',
                        style: TextStyle(
                          fontSize: ratingCountFontSize,
                        ),
                      ),
                      spacing: 0.0,
                    ),
            if (widget.item!.type != "configurable") const SizedBox(height: 15),
            if (widget.item!.type != "configurable")
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (!widget.item!.isEmptyProduct() &&
                      widget.item!.type != "variable" &&
                      widget.item!.inStock != null &&
                      widget.item!.inStock!)
                    Consumer<CartModel>(builder: (context, model, child) {
                      return AnimatedAddCartButton(
                        // quantity: cartModel.productsInCart[widget.item.id],
                        quantity: cartModel.productsInCart[widget.item!.id],
                        qtyAvailable:
                            widget.item!.qty != null ? widget.item!.qty : 0,
                        cartModel: cartModel,
                        productPrice: _productPricing,
                        max_sale_qty: widget.item!.max_sale_qty,
                        producttype: widget.item!.type,
                        onPressed: _onPressed,
                        productId: widget.item!.id,
                        product: widget.item,
                        productsInCart: model.item.keys.toList(),
                        productName: widget.item!.name,
                        cartProducts: model.item.toString(),
                      );
                    }),
                  // FlatButton(
                  //   color: Theme.of(context).primaryColor,
                  //   textColor: Colors.white,
                  //   child: Text(
                  //     S.of(context).addToCart),
                  //   onPressed: () async {
                  //     var msg = addProductToCart(product: item);
                  //     // try {
                  //     // await
                  //     MagentoApi()
                  //         .addItemsToCart(
                  //             cartModel,
                  //             item.id,
                  //             userModel.user != null
                  //                 ? userModel.user.cookie
                  //                 : null,
                  //             item.sku,
                  //             1)
                  //         .then((value) => null)
                  //         .catchError((e) {
                  //       addProductToCart(
                  //         product: item, quantity: -1,
                  //         //  success: false
                  //       );
                  //     });
                  //     // } catch (e) {
                  //     //   throw Exception(e.toString());
                  //     // }
                  //     return msg;
                  //   },
                  // ),
                  const Spacer(),
                  HeartButton(product: widget.item, size: 18),
                  const SizedBox(width: 8),
                ],
              ),
            if (widget.item!.type == "configurable")
              Row(children: [
                Expanded(
                    child: SingleChildScrollView(
                        child: ProductVariant(widget.item, true))),
                // const Spacer(),
                HeartButton(product: widget.item, size: 18)
              ]),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStatus(BuildContext context) {
    if (widget.showProgressBar ?? false) {
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: SaleProgressBar(
            width: MediaQuery.of(context).size.width, product: widget.item),
      );
    }

    if (kAdvanceConfig['showStockStatus'] as bool && !widget.item!.isEmptyProduct()) {
      if (widget.item!.backOrdered != null && widget.item!.backOrdered) {
        return Text(
          '${S.of(context).backOrder}',
          style: const TextStyle(
            color: kColorBackOrder,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        );
      }
      if (widget.item!.inStock != null) {
        return Text(
          widget.item!.inStock! ? '' : S.of(context).outOfStock,
          style: TextStyle(
            color: widget.item!.inStock! ? kColorInStock : kColorOutOfStock,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        );
      }
    }
    return const SizedBox();
  }
}
