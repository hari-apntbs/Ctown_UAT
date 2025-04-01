import 'package:ctown/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/constants/route_list.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart' show AppModel, Product;

enum SimpleListType { BackgroundColor, PriceOnTheRight }

class SimpleListView extends StatelessWidget {
  final Product? item;
  final SimpleListType? type;

  SimpleListView({this.item, this.type});

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<AppModel>(context).currency;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    var screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize = 15;
    double imageWidth = 60;
    double imageHeight = 60;
    double? regularPrice = 0.0;
    var salePercent = 0;

    final ThemeData theme = Theme.of(context);

    // bool isSale = (item.onSale ?? false) &&
    //     double.parse(Tools.getPriceProductValue(item, currency, onSale: true)) <
    //         double.parse(Tools.getPriceProductValue(item, currency, onSale: false));
    bool isSale = (item!.onSale ?? false);

    if (item!.regularPrice != null &&
        item!.regularPrice!.isNotEmpty &&
        item!.regularPrice != '0.0') {
      regularPrice = double.tryParse(item!.regularPrice.toString())!;
    }

    printLog("Is Sale: $isSale");
    printLog("Item Sale Price: ${item!.salePrice}");
    printLog("Regular Price: $regularPrice");

    if (isSale && regularPrice != 0.0) {
      salePercent = (100 -
              (double.parse(item!.salePrice ?? "$regularPrice") / regularPrice) *
                  100)
          .toInt();
      printLog("Sale Percent: $salePercent");
    }

    if (item!.type == 'variable') {
      isSale = item!.onSale ?? false;
    }

    var priceProduct = Tools.getPriceProductValue(
      item,
      currency,
      onSale: isSale,
    );

    void onTapProduct() {
      if (item!.imageFeature == '') return;
      Navigator.of(context).pushNamed(
        RouteList.productDetail,
        arguments: item,
      );
    }

    /// Product Pricing
    Widget _productPricing = Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: <Widget>[
        item!.type == 'configurable'
            ? Text(
                item!.type == 'grouped'
                    ? '${S.of(context).from} ${Tools.getPriceProduct(item, currencyRate, currency, onSale: isSale)}'
                    : priceProduct == '0.0'
                        ? S.of(context).loading
                        : "${Tools.getPriceProduct(item, currencyRate, currency, onSale: true)}  Per 0.25 Kg",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 15,
                      color: theme.colorScheme.secondary,
                    ),
              )
            : Text(
                item!.type == 'grouped'
                    ? '${S.of(context).from} ${Tools.getPriceProduct(item, currencyRate, currency, onSale: isSale)}'
                    : priceProduct == '0.0'
                        ? S.of(context).loading
                        : Tools.getPriceProduct(item, currencyRate, currency,
                            onSale: item!.onSale)!,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 15,
                      color: theme.colorScheme.secondary,
                    ),
              ),
        /*if (isSale && (salePercent > 0 && salePercent < 100)) ...[
          const SizedBox(width: 5),
          Text(
            item.type == 'grouped'
                ? ''
                : Tools.getCurrencyFormatted(
                    regularPrice,
                    currencyRate,
                    currency: currency,
                  ),
            style: Theme.of(context).textTheme.headline6.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).accentColor.withOpacity(0.6),
                  decoration: TextDecoration.lineThrough,
                ),
          ),
        ]*/
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: GestureDetector(
        onTap: onTapProduct,
        child: Container(
          width: screenWidth,
          decoration: BoxDecoration(
            color: type == SimpleListType.BackgroundColor
                ? Theme.of(context).primaryColorLight
                : null,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  child: Tools.image(
                    url: item!.imageFeature,
                    width: imageWidth,
                    size: kSize.medium,
                    isResize: true,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  width: 20.0,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        item!.name!,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      (type != SimpleListType.PriceOnTheRight)
                          ? _productPricing
                          : Container(),
                    ],
                  ),
                ),
                (type == SimpleListType.PriceOnTheRight)
                    ? Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: _productPricing,
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
