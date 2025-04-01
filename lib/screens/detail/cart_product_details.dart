import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show AppModel, Product, ProductModel, ProductVariation;
import '../../screens/base.dart';
import '../../widgets/common/countdown_timer.dart';

class CartProductDetails extends StatefulWidget {
  final Product product;
  final String value;

  CartProductDetails(this.product, this.value);

  @override
  _CartProductDetailsState createState() => _CartProductDetailsState();
}

class _CartProductDetailsState extends BaseScreen<CartProductDetails> {
  var regularPrice;
  bool? onSale = false;
  int sale = 100;
  String? price;
  ProductVariation? productVariation;
  String? dateOnSaleTo;

  @override
  void afterFirstLayout(BuildContext context) async {
    getProductPrice();
  }

  getProductPrice() {
    try {
      regularPrice = productVariation != null
          ? productVariation!.regularPrice
          : widget.product.regularPrice;
      onSale = productVariation != null
          ? productVariation!.onSale
          : widget.product.onSale;
      price = productVariation != null
          ? productVariation!.price
          : isNotBlank(widget.product.price)
              ? widget.product.price
              : widget.product.regularPrice;

      /// update the Sale price
      if (onSale!) {
        price = productVariation != null
            ? productVariation!.salePrice
            : isNotBlank(widget.product.salePrice)
                ? widget.product.salePrice
                : widget.product.price;
        dateOnSaleTo = productVariation != null
            ? productVariation!.dateOnSaleTo
            : widget.product.dateOnSaleTo;
      }

      if (onSale! && regularPrice.isNotEmpty && double.parse(regularPrice) > 0) {
        sale = (100 - (double.parse(price!) / double.parse(regularPrice)) * 100)
            .toInt();
      }
    } catch (e, trace) {
      printLog(trace);
      printLog(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    productVariation = Provider.of<ProductModel>(context).productVariation;
    getProductPrice();

    final String? currency = Provider.of<AppModel>(context).currency;
    final Map<String, dynamic> currencyRate =
        Provider.of<AppModel>(context).currencyRate;
    final int? dateOnSaleTo = DateTime.tryParse(
            productVariation?.dateOnSaleTo ?? widget.product.dateOnSaleTo ?? "")
        ?.millisecondsSinceEpoch;
    final int countDown =
        (dateOnSaleTo ?? 0) - DateTime.now().millisecondsSinceEpoch;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.product.vendor != null)
          Row(
            children: <Widget>[
              Text(
                widget.product.vendor!,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.secondary,
                    ),
              ),
            ],
          ),
        // const SizedBox(height: 10),
        // Container(
        //   width: MediaQuery.of(context).size.width * 0.7,
        //   child: Text(
        //     widget.product.name,
        //     style: TextStyle(
        //       color: theme.accentColor,
        //       // fontFamily: 'raleway'
        //     ),
        //     maxLines: 2,
        //     overflow: TextOverflow.ellipsis,
        //   ),
        // ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            widget.product.type == 'configurable'
                ? Text(
                    "${Tools.getCurrencyFormatted(productVariation!.price ?? "0.0", currencyRate, currency: currency)! + "  " + "Per" + "  " + widget.value}",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                  )
                : Text(
                    widget.product.type != 'grouped'
                        ? Tools.getCurrencyFormatted(
                            price ?? "0.0", currencyRate,
                            currency: currency)!
                        : Provider.of<ProductModel>(context).detailPriceRange,
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      // fontFamily: 'raleway'
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

            /// For variable product, hide regular price when loading product variation.
            if ((onSale! &&
                    (sale > 0 && sale < 100) &&
                    widget.product.type != 'grouped' &&
                    widget.product.type != 'variable') ||
                (onSale! &&
                    widget.product.type == 'variable' &&
                    productVariation != null))
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(width: 5),
                    Text(
                      Tools.getCurrencyFormatted(
                        regularPrice,
                        currencyRate,
                        currency: currency,
                      )!,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontSize: 14,
                            color:
                                Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.lineThrough,
                          ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        S.of(context).sale('$sale'),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ),
                    if ((kSaleOffProduct["ShowCountDown"] as bool? ?? false) &&
                        dateOnSaleTo != null &&
                        countDown > 0) ...[
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          S.of(context).endsIn("").toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color: theme.colorScheme.secondary.withOpacity(0.9),
                              )
                              .apply(fontSizeFactor: 0.6),
                        ),
                      ),
                      CountDownTimer(
                        Duration(milliseconds: countDown),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
        // Container(
        //   width: MediaQuery.of(context).size.width * 0.7,
        //   child: Text(
        //     widget.product.unit_of_measurement,
        //     style: Theme.of(context).textTheme.subtitle2.copyWith(
        //       fontWeight: FontWeight.w600,
        //       fontFamily: 'raleway'
        //     ),
        //   ),
        // ),
        // Row(
        //   crossAxisAlignment: CrossAxisAlignment.baseline,
        //   children: [
        //     if (kAdvanceConfig['EnableRating'])
        //       Padding(
        //         padding: const EdgeInsets.only(top: 5.0),
        //         child: SmoothStarRating(
        //           allowHalfRating: true,
        //           starCount: 5,
        //           spacing: 0.0,
        //           rating: widget.product.averageRating,
        //           size: 17.0,
        //           label: Text(
        //             " (${widget.product.ratingCount})",
        //             style: Theme.of(context).textTheme.subtitle1.copyWith(
        //                   fontSize: 12,
        //                   color: Theme.of(context).accentColor.withOpacity(0.8),
        //                 ),
        //           ),
        //         ),
        //       ),
        //     const Spacer(),
        //     if (dateOnSaleTo != null && countDown > 0)
        //       Padding(
        //         padding: const EdgeInsets.only(left: 8.0),
        //         child: SaleProgressBar(
        //           product: widget.product,
        //           productVariation: productVariation,
        //           width: 160,
        //         ),
        //       ),
        //   ],
        // ),
      ],
    );
  }
}
