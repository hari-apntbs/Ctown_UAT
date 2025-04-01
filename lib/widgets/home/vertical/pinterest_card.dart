import 'package:ctown/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../frameworks/magento/services/magento.dart';
import '../../../models/index.dart' show CartModel, Product, ProductVariation, UserModel;
import '../../common/start_rating.dart';

class PinterestCard extends StatelessWidget {
  final Product? item;
  final width;
  final marginRight;
  final kSize size;
  final bool showCart;
  final bool showHeart;
  final bool? showOnlyImage;

  PinterestCard({
    this.item,
    this.width,
    this.size = kSize.medium,
    this.showHeart = true,
    this.showCart = false,
    this.showOnlyImage = false,
    this.marginRight = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String Function({dynamic context, dynamic isSaveLocal, Function notify, Map<String, dynamic> options, Product? product, int quantity, ProductVariation variation}) addProductToCart = Provider.of<CartModel>(context).addProductToCart;
    final currency = Provider.of<CartModel>(context).currency;
    final currencyRates = Provider.of<CartModel>(context).currencyRates;
    final isTablet = Tools.isTablet(MediaQuery.of(context));

    double titleFontSize = isTablet ? 24.0 : 14.0;
    double iconSize = isTablet ? 24.0 : 18.0;
    double starSize = isTablet ? 20.0 : 10.0;

    void onTapProduct() {
      if (item!.imageFeature == '') return;

      Navigator.of(context).pushNamed(
        RouteList.productDetail,
        arguments: item,
      );
    }

    return GestureDetector(
      onTap: onTapProduct,
      child: Container(
        color: Theme.of(context).cardColor,
        margin: const EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            Tools.image(
              url: item!.imageFeature,
              width: width,
              size: kSize.medium,
              isResize: true,
              fit: BoxFit.fill,
            ),
            if (showOnlyImage == null || !showOnlyImage!)
              Container(
                width: width,
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(
                    top: 10, left: 8, right: 8, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item!.name!,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1),
                    const SizedBox(height: 6),
                    Text(Tools.getPriceProduct(item, currencyRates!, currency)!,
                        style: TextStyle(color: theme.colorScheme.secondary)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        if (kAdvanceConfig['EnableRating'] as bool)
                          Expanded(
                            child: SmoothStarRating(
                                allowHalfRating: true,
                                starCount: 5,
                                label: Text(
                                  '${item!.ratingCount}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                rating: item!.averageRating ?? 0.0,
                                size: starSize,
                                color: theme.primaryColor,
                                borderColor: theme.primaryColor,
                                spacing: 0.0),
                          ),
                        if (showCart && !item!.isEmptyProduct())
                          IconButton(
                              padding: const EdgeInsets.all(2.0),
                              icon:
                                  Icon(Icons.add_shopping_cart, size: iconSize),
                              onPressed: () async {
                                addProductToCart(product: item);
                                // try {
                                var cartModel = Provider.of<CartModel>(context,
                                    listen: false);
                                var userModel = Provider.of<UserModel>(context,
                                    listen: false);
                                // await
                                await MagentoApi()
                                    .addItemsToCart(
                                    Provider.of<AppModel>(context,
                                        listen: false)
                                        .langCode,
                                    cartModel,
                                    item!.id,
                                    userModel.user != null
                                        ? userModel.user!.cookie
                                        : null,
                                    item!.sku, 1)
                                    .then((value) => null)
                                    .catchError((e) {
                                  addProductToCart(
                                    product: item,
                                    quantity: -1,
                                    // success: false
                                  );
                                });
                                // } catch (e) {
                                //   throw Exception(e.toString());
                                // }
                              }),
                      ],
                    )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
