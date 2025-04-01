import 'dart:async';
import 'dart:math' as math;

import 'package:ctown/models/entities/product_variation.dart';
import 'package:ctown/screens/detail/product_variant.dart';
import 'package:ctown/widgets/common/animated_add_cart_button.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../../common/config/general.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../frameworks/magento/services/magento.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show
        AppModel,
        CartModel,
        Product,
        ProductModel,
        RecentModel,
        User,
        UserModel,
        WishListModel;
import '../../services/index.dart';
import '../../services/service_config.dart';
import '../common/sale_progress_bar.dart';
import 'heart_button.dart';

class ProductCard extends StatefulWidget {
  final Product? item;
  final double? width;
  final double? maxWidth;
  final double? marginRight;
  final kSize size;
  final bool showCart;
  final bool showHeart;
  final bool showProgressBar;
  final height;
  final bool hideDetail;
  final offset;
  final tablet;
  final double ratioProductImage;
  final User? user;
  final bool? fromHome;

  ProductCard(
      {this.item,
      this.width,
      this.maxWidth,
      this.size = kSize.medium,
      this.showHeart = false,
      this.showCart = false,
      this.showProgressBar = false,
      this.height,
      this.offset,
      this.hideDetail = false,
      this.tablet,
      this.marginRight = 6.0,
      this.ratioProductImage = 1.2,
      this.user,
      this.fromHome});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  var qnty = 10;
  Timer? _debounce;
  var tapCount = 0;
  List<dynamic>? data;
  ProductVariation? productVariation;
  bool addProduct = false;
  @override
  void initState() {
    //getdata('https://online.ajmanmarkets.ae/api/categories.php');
    super.initState();
  }

  Future getdata(String url) async {
    //final res = await http.get(url);
    //data = jsonDecode(res.body)['data'];
    //print(data[0]);
    data = [];
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    CartModel cartModel = Provider.of<CartModel>(context);
    UserModel userModel = Provider.of<UserModel>(context);
    final currency = Provider.of<AppModel>(context, listen: false).currency;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    bool loggedIn = Provider.of<UserModel>(context).loggedIn;
    var salePercent = 0;
    var quantity = cartModel.productsInCart[widget.item!.id] != null
        ? cartModel.productsInCart[widget.item!.id]!
        : 0;
    var offset = quantity > 0 ? qnty - 1 : qnty;
    WishListModel wishListModel = Provider.of<WishListModel>(context);
    if (widget.item == null) return Container();

    double? regularPrice = 0.0;
    var productImage = widget.width! * (widget.ratioProductImage ?? 1.2);

    // ignore: unrelated_type_equality_checks
    if (widget.item!.regularPrice != null &&
        widget.item!.regularPrice!.isNotEmpty &&
        widget.item!.regularPrice != '0.0') {
      regularPrice = double.tryParse(widget.item!.regularPrice.toString())!;
    }

    final gauss = widget.offset != null
        ? math.exp(-(math.pow(widget.offset.abs() - 0.5, 2) / 0.08))
        : 0.0;

    /// Calculate the Sale price
    // bool isSale = (widget.item.onSale ?? false) &&
    //     double.parse(Tools.getPriceProductValue(widget.item, currency, onSale: true)) <
    //         double.parse(Tools.getPriceProductValue(widget.item, currency, onSale: false));
    bool isSale = (widget.item!.onSale ?? false);

    if (isSale && regularPrice != 0.0 && widget.item!.salePrice != null) {
      bool isSalePrice = double.parse(widget.item!.price!) >
          double.parse(widget.item!.salePrice!);
      salePercent = (isSalePrice == true
              ? double.parse(widget.item!.salePrice!)
              : double.parse(widget.item!.price!) - regularPrice) *
          100 ~/
          regularPrice;
    }

    if (widget.item!.type == 'variable') {
      isSale = widget.item!.onSale ?? false;
    }

    if (widget.hideDetail) {
      return _buildImageFeature(
        () => _onTapProduct(context),
      );
    }

    var priceProduct = Tools.getPriceProductValue(
      widget.item,
      currency,
      onSale: true,
    );

    /// Sold by widget
    Widget _soldByStore = widget.item!.store != null &&
            widget.item!.store!.name != ""
        ? Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              S.of(context).soldBy + " " + widget.item!.store!.name!,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          )
        : SizedBox.shrink();

    /// product name
    Widget _productTitle = Container(
        //height: MediaQuery.of(context).size.height * .05,
        child: Text(
      (widget.item?.name ?? "") + '\n' ?? '',
      //  widget?.item?.name ??
      //      '' '\n',
      // widget.item.name + '\n' + widget.item.unit_of_measurement  + '\n',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600
      ),
      maxLines: 2,
    ));
    // Widget _productDeliverydate = Text(
    //   widget.item.delivery_date + '\n' ??  '',
    //   // item.name + '\n' + item.unit_of_measurement  + '\n',
    //   style: Theme.of(context).textTheme.subtitle2,
    //   maxLines: 1,
    // );
    Widget _productMeasurement = Text(
      widget.item?.package_info ?? '' '\n',
      //widget.item.unit_of_measurement + '\n' ??  '',
      // item.name + '\n' + item.unit_of_measurement  + '\n',
      style: Theme.of(context).textTheme.titleSmall!.copyWith(
            fontSize: 14,
            // fontFamily: 'raleway',
          ),
      maxLines: 2,
    );

    /// Product Pricing
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
                          widget.item!.price ??
                              widget.item!.regularPrice ??
                              '0',
                          null)!
                      : Tools.getPriceProduct(
                          widget.item, currencyRate, currency,
                          onSale: widget.item!.onSale)!,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              )
              .apply(fontSizeFactor: 0.8),
        ),

        /// Not show regular price fo
        /// r variant product (product.regularPrice = "").
        if (isSale &&
            (salePercent != 0 &&
                salePercent != 100) && // not show sale percent if 0 or 100
            widget.item!.type == 'simple') ...[
          /*const SizedBox(width: 5),
          Text(
            widget.item.type == 'grouped'
                ? ''
                : regularPrice < double.parse(widget.item.salePrice)
                    ? ""
                    : Tools.getCurrencyFormatted(
                        regularPrice,
                        currencyRate,
                        currency: currency,
                      ),
            style: Theme.of(context)
                .textTheme
                .caption
                .copyWith(
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).primaryColor.withOpacity(0.6),
                  decoration: TextDecoration.lineThrough,
                )
                .apply(fontSizeFactor: 0.8),
          ),*/
        ]
      ],
    );

    /// Product Stock Status
    Widget _stockStatus = _buildStockStatus(context);

    Future<void> _onPressed(int qnty1) async {
      try {
        if (widget.user == null) {
          if (!loggedIn) {
            // Navigate to login if not logged in
            await Navigator.of(context, rootNavigator: true).pushNamed(RouteList.login);
            return;
          }
        }

        // Handle debounce logic to prevent multiple rapid API calls
        if (_debounce?.isActive ?? false) {
          _debounce!.cancel();
        }

        _debounce = Timer(const Duration(milliseconds: 500), () async {
          if (tapCount != 0) {
            // Add to cart after debounce duration
            await _addToCart(context, cartModel, tapCount, userModel, wishListModel);
            tapCount = 0; // Reset tap count after adding to cart
          }
        });

        // Update the UI with the new quantity
        setState(() {
          if (quantity + tapCount + qnty1 > 0) {
            tapCount += qnty1;
            qnty += qnty1;
          }
        });
      } catch (e) {
        printLog(e.toString());
      }
    }

    /// Show Cart button
    // Widget _showCart = (widget.showCart &&
    //         !widget.item.isEmptyProduct() &&
    //         widget.item.inStock != null &&
    //         widget.item.inStock &&
    //         widget.item.type != "variable")
    //     ? SizedBox(
    //         width: 20,
    //         child: IconButton(
    //             padding: const EdgeInsets.only(left: 0.0, right: 0.0),
    //             icon: const Icon(Icons.add_shopping_cart, size: 16),
    //             onPressed: () async {
    //               if (widget.user == null) {
    //                 if (!loggedIn) {
    //                   await Navigator.of(
    //                     context,
    //                     rootNavigator: true,
    //                   ).pushNamed(RouteList.login);
    //                 } else {
    //                   await _addToCart(
    //                       context, cartModel, offset, userModel, wishListModel);
    //                 }
    //               } else {
    //                 await _addToCart(
    //                     context, cartModel, offset, userModel, wishListModel);
    //               }
    //             }),
    //       )
    //     : SizedBox(
    //         width: 20,
    //         child: IconButton(
    //             padding: const EdgeInsets.only(left: 0.0, right: 0.0),
    //             icon: const Icon(Icons.add_shopping_cart, size: 18),
    //             onPressed: () async {
    //               if (widget.user == null) {
    //                 if (!loggedIn) {
    //                   await Navigator.of(
    //                     context,
    //                     rootNavigator: true,
    //                   ).pushNamed(RouteList.login);
    //                 } else {
    //                   await _addToCart(
    //                       context, cartModel, offset, userModel, wishListModel);
    //                 }
    //               } else {
    //                 await _addToCart(
    //                     context, cartModel, offset, userModel, wishListModel);
    //               }
    //             }),
    //       );

    /// Show Stock status & Rating
    Widget _productStockRating = widget.item!.isEmptyProduct()
        ? const SizedBox.shrink()
        : Align(
            alignment: Alignment.bottomLeft,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _stockStatus,
                        // _rating,
                        // widget.item.inStock
                        if (widget.item!.type != "configurable")
                          // widget.item!.status == true &&
                          //         widget.item!.price != '0.00' &&  widget.item!.qty! > 0
                          widget.item!.status == true &&
                              widget.item!.price != '0.00'
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Consumer<CartModel>(
                                        builder: (context, model, child) {
                                      return !model.productsInCart.containsKey(widget.item?.id) && addProduct ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 28.0),
                                          child: SpinKitCubeGrid(
                                            color: Theme.of(context).primaryColor,
                                            size: 20.0,
                                          ),
                                        ),
                                      ) : AnimatedAddCartButton(
                                        // quantity: cartModel.productsInCart[widget.item.id],
                                        quantity: cartModel
                                            .productsInCart[widget.item!.id],
                                        qtyAvailable: widget.item!.qty != null
                                            ? widget.item!.qty
                                            : 0,
                                        cartModel: cartModel,
                                        productPrice: _productPricing,
                                        max_sale_qty: widget.item!.max_sale_qty,
                                        producttype: widget.item!.type,
                                        onPressed: _onPressed,
                                        productId: widget.item!.id,
                                        product: widget.item,
                                        productsInCart:
                                        model.item.keys.toList(),
                                        productName: widget.item!.name,
                                        cartProducts: model.item.toString(),
                                        price: widget.item!.price,
                                        isLoading: addProduct,
                                      );
                                    })
                                  ],
                                )
                              : Container(height: 30)
                      ],
                    ),
                  ),
                  // const SizedBox(width: 10),
                ],
              ),
            ),
          );

    Widget _productImage = Stack(
      children: <Widget>[
        Container(
          constraints: const BoxConstraints(maxHeight: 162),
          // constraints: BoxConstraints(maxHeight: productImage),
          child: Transform.translate(
            offset: Offset(18 * gauss, 0.0),
            child: _buildImageFeature(
              () => _onTapProduct(context),
            ),
          ),
        ),

        /// Not show sale percent for variant product (product.regularPrice = "").
        if (isSale &&
            (widget.item!.regularPrice?.isNotEmpty ?? false) &&
            regularPrice != null &&
            regularPrice != 0.0 &&
            (salePercent != 0 &&
                salePercent != 100)) // not show sale percent if 0 or 100
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
              decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(12))),
              child: Text(
                Provider.of<AppModel>(context, listen: false).langCode == "en"
                    ? "Offer"
                    : "عرض",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )
                    .apply(fontSizeFactor: 0.7),
              ),
            ),
          ),

        /// Show On Sale label for variant product.
        // if (isSale && widget.item.type == 'variable')
        //   Align(
        //     alignment: Alignment.topLeft,
        //     child: Container(
        //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        //       decoration: const BoxDecoration(
        //           color: Colors.redAccent,
        //           borderRadius:
        //               BorderRadius.only(bottomRight: Radius.circular(8))),
        //       child: Text(
        //         /*S.of(context).onSale*/ Provider.of<AppModel>(context,
        //                         listen: false)
        //                     .langCode ==
        //                 "en"
        //             ? "Offer"
        //             : "عرض",
        //         style: const TextStyle(
        //             fontSize: 12,
        //             fontWeight: FontWeight.w600,
        //             color: Colors.white),
        //       ),
        //     ),
        //   ),
      ],
    );
    Widget _configurableproductImage = Stack(
      children: <Widget>[
        Container(
          constraints: const BoxConstraints(maxHeight: 145),
          child: Transform.translate(
            offset: Offset(18 * gauss, 0.0),
            child: _buildImageFeature(
              () => _onTapProduct(context),
            ),
          ),
        ),

        /// Not show sale percent for variant product (product.regularPrice = "").
        /*if (isSale &&
            (widget.item.regularPrice?.isNotEmpty ?? false) &&
            regularPrice != null &&
            regularPrice != 0.0 &&
            (salePercent != 0 &&
                salePercent != 100) && // not show sale percent if 0 or 100
            widget.item.type != 'variable')*/
        if (isSale)
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
              decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(12))),
              child: Text(
                /*'$salePercent%'*/ Provider.of<AppModel>(context,
                                listen: false)
                            .langCode ==
                        "en"
                    ? "Offer"
                    : "عرض",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )
                    .apply(fontSizeFactor: 0.7),
              ),
            ),
          ),

        /// Show On Sale label for variant product.
        if (isSale && widget.item!.type == 'variable')
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(8))),
              child: Text(
                S.of(context).onSale,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ),
      ],
    );

    Widget _productInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _productTitle,
        const SizedBox(height: 4),
        _productPricing,
        // priceProduct == '0.0'
        //     ? Text(
        //         S.of(context).loading,
        //         style: Theme.of(context)
        //             .textTheme
        //             .headline6
        //             .copyWith(
        //               color: theme.primaryColor,
        //               fontWeight: FontWeight.w600,
        //             )
        //             .apply(fontSizeFactor: 0.8),
        //       )
        //     : ProductTitleView(widget.item, ''),
        const SizedBox(height: 4),
        _productMeasurement,
        widget.fromHome != null && widget.fromHome!
            ? SizedBox(
                height: 4,
              )
            : SizedBox.shrink(),
        // const SizedBox(height: 4),
        // _productDeliverydate,
        // const SizedBox(height: 3),
        _productStockRating,
        // _soldByStore,
        if (_soldByStore != null) ...[
          const SizedBox(height: 4),
          _soldByStore,
        ],
      ],
    );

    return GestureDetector(
      onTap: () => _onTapProduct(context),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: <Widget>[
          Container(
            constraints: const BoxConstraints(
              maxHeight: double.infinity,
            ),
            //height: MediaQuery.of(context).size.height * .350,
            //  constraints: BoxConstraints(maxWidth: widget.maxWidth ?? widget.width),
            width: widget.width,
            //width: 185,
            // padding: const EdgeInsets.symmetric(horizontal: 4.0),
            // decoration: BoxDecoration(
            //   color: Theme.of(context).cardColor,
            //   borderRadius: BorderRadius.circular(3.0),
            // ),
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.all(2),
            // margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(
                color: Colors.black12,
                width: 0.4,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  // offset: Offset(
                  //   3.0,
                  //   3.0,
                  // ),
                  blurRadius: 5.0,
                  spreadRadius: 2.0,
                ), //BoxShadow
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(0.0, 0.0),
                  blurRadius: 0.0,
                  spreadRadius: 0.0,
                ), //BoxShadow
              ],
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              //color: Colors.grey[50]
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                widget.item!.type != "configurable"
                    ? _productImage
                    : _configurableproductImage,
                if (widget.item!.type != "configurable") _productInfo,
                if (widget.item!.type == "configurable")
                  ProductVariant(widget.item, true),
              ],
            ),
          ),
          if (widget.showHeart && !widget.item!.isEmptyProduct())
            Positioned(
              top: 10,
              right: 10,
              child: HeartButton(product: widget.item, size: 18),
            ),
        ],
      ),
    );
  }

  Future<bool> _addToCart(BuildContext context, CartModel cartModel, int offset,
      UserModel userModel, WishListModel wishListModel) async {
    try {
      setState(() {
        addProduct = true;
      });
      final addProductToCart =
          Provider.of<CartModel>(context, listen: false).addProductToCartNew;
      var key = "${widget.item!.id}";
      int total = !cartModel.productsInCart.containsKey(key)
          ? offset
          : (cartModel.productsInCart[key]! + offset);
      printLog("sudaugsudfgasj");
      printLog("Product Max Sale Qty: ${widget.item!.maxSaleQty}");
      printLog("Total Qty: $total");
      printLog(cartModel.productsInCart[key]);
      printLog("offset $offset");
      if (total <= widget.item!.maxSaleQty!) {
        MagentoApi()
            .addItemsToCart(
                Provider.of<AppModel>(context, listen: false).langCode,
                cartModel,
                widget.item!.id,
                userModel.user != null ? userModel.user!.cookie : null,
                widget.item!.sku,
                total)
            .then((value) async {
              if(value!= null && value) {}
        }).catchError((e) {
          printLog(' catcherror - $e');
          addProductToCart(
            product: widget.item,
            quantity: -offset,
            context: context,
          );
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
        });
        await Future.delayed(const Duration(milliseconds: 1100));
        String message = await addProductToCart(
            product: widget.item, quantity: offset, context: context);
        setState(() {
          qnty = 1;
        });
        _showFlashNotification(widget.item, message, context, false, offset);
        wishListModel.removeToWishlist(widget.item);
      } else {
        _showFlashNotification(
            widget.item,
            "The requested qty exceeds the maximum qty allowed in shopping cart",
            context,
            true,
            offset);
      }
    } catch (e) {
      printLog(e.toString());
    }
    finally {
      setState(() {
        addProduct = false;
      });
    }
    return true;
  }

  Widget _buildImageFeature(onTapProduct) {
    return GestureDetector(
      onTap: onTapProduct,
      child: Tools.image(
        url:widget.item!.imageFeature,
        width: widget.width,
        height: widget.width! * 0.9,
        size: kSize.medium,
        isResize: true,
        fit: BoxFit.contain, //cover,
        offset: widget.offset ?? 0.0,
      ),
    );
  }

  void _onTapProduct(context) {
    if (widget.item!.imageFeature == '') return;
    Provider.of<RecentModel>(context, listen: false)
        .addRecentProduct(widget.item);

    eventBus.fire('detail');
//  var cut = widget.item.imageFeature.split("/cache/");
//                  int cut2=cut[1].indexOf("/");

//                  String newImageFeature =cut[0]+cut[1].substring(cut2);
//                   print("dei");
//     print(newImageFeature);
//     print(widget.item.imageFeature);
//                  widget.item.imageFeature="https://up.ctown.jo/pub/media/catalog/product/5/0/5015000003796.jpg";
//                 //  newImageFeature;

//    print(widget.item.imageFeature);
    Navigator.of(
      context,
      //rootNavigator: !isBigScreen(context), // Push in tab for tablet (IPad)
    ).pushNamed(
      RouteList.productDetail,
      arguments: widget.item,
    );
  }

  void _showFlashNotification(
      Product? product, String message, context, bool isError, offset) {
    if (message.isNotEmpty) {
      showFlash(
        context: context,
        duration: const Duration(milliseconds: 2000),
        builder: (context, controller) {
          return Flash(
            // Theme.of(context).errorColor,
            controller: controller,
            dismissDirections: [FlashDismissDirection.startToEnd],
            child: FlashBar(
              controller: controller,
              position: FlashPosition.top,
              behavior: FlashBehavior.fixed,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(3))),
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
        duration: const Duration(milliseconds: 2000),
        builder: (context, controller) {
          return Flash(
            // Theme.of(context).primaryColor,
            controller: controller,
            dismissDirections: [FlashDismissDirection.startToEnd],
            child: FlashBar(
              controller: controller,
              position: FlashPosition.top,
              behavior: FlashBehavior.floating,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(3))),
              backgroundColor: Colors.white,
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

  Widget _buildStockStatus(BuildContext context) {
    if (widget.showProgressBar ?? false) {
      return SaleProgressBar(width: widget.width, product: widget.item);
    }

    return (kAdvanceConfig['showStockStatus'] as bool &&
            !widget.item!.isEmptyProduct())
        ? widget.item!.backOrdered != null && widget.item!.backOrdered
            ? widget.item!.status == true
                ? Container()
                : Text(
                    '${S.of(context).backOrder}',
                    style: const TextStyle(
                      color: kColorBackOrder,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  )
            // : widget.item!.status != null && (widget.item!.status == false)
        : widget.item!.status != null && widget.item!.status == false
                // widget.item.inStock != null
                ? Text(
                    S.of(context).outOfStock,
                    style: TextStyle(
                      color: widget.item!.status == true
                          //  widget.item.inStock
                          ? kColorInStock
                          : kColorOutOfStock,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  )
                : const SizedBox.shrink()
        : Container();
  }
}
