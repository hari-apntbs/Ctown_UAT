import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/packages.dart' show FlashHelper;
import '../../generated/l10n.dart' show S;
import '../../models/index.dart'
    show
        AppModel,
        CartModel,
        Product,
        ProductAttribute,
        ProductModel,
        ProductVariation;
import '../../services/index.dart';
import '../../widgets/common/webview.dart';

class ProductVariant extends StatefulWidget {
  final Product? product;
  final bool isProductCard;

  ProductVariant(this.product, this.isProductCard);

  @override
  StateProductVariant createState() => StateProductVariant(product);
}

class StateProductVariant extends State<ProductVariant> {
  Product? product;
  ProductVariation? productVariation;

  StateProductVariant(this.product);

  final services = Services();
  Map<String, String>? mapAttribute = {};
  List<ProductVariation>? variations = [];

  int? quantity = 1;

  /// Get product variants
  Future<void> getProductVariations() async {
    await services.widget?.getProductVariations(
        lang: Provider.of<AppModel>(context, listen: false).langCode,
        context: context,
        product: product,
        onLoad: (
            {Product? productInfo,
              List<ProductVariation>? variations,
              Map<String, String>? mapAttribute,
              ProductVariation? variation}) {
          setState(() {
            if (productInfo != null) {
              product = productInfo;
            }
            this.variations = variations;
            this.mapAttribute = mapAttribute;
            if (variation != null) {
              productVariation = variation;
              Provider.of<ProductModel>(context, listen: false)
                  .changeProductVariation(productVariation);
            }
          });
          return;
        });
  }

  @override
  void initState() {
    super.initState();
    getProductVariations();

    // added to show quantity as in cart instead of 1 always
    var productsInCart =
        Provider.of<CartModel>(context, listen: false).productsInCart;
    if (productsInCart.keys.contains(product!.id)) {
      quantity = productsInCart[product!.id];
    }
  }


  @override
  void dispose() {
    FlashHelper.dispose();
    super.dispose();
  }

  /// Support Affiliate product
  void openWebView() {
    if (product!.affiliateUrl == null || product!.affiliateUrl!.isEmpty) {
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
          body: Center(
            child: Text(S.of(context).notFound),
          ),
        );
      }));
      return;
    }

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => InAppWebView(
              url: product!.affiliateUrl,
              title: product!.name,
              appBarRequire: true,
            )));
  }

  /// check limit select quality by maximum available stock
  int getMaxQuantity() {
    int limitSelectQuantity = kCartDetail['maxAllowQuantity'] ?? 100;
    if (productVariation != null) {
      if (productVariation!.stockQuantity != null) {
        limitSelectQuantity = math.min(
            productVariation!.stockQuantity!, kCartDetail['maxAllowQuantity']!);
      }
    } else if (product!.stockQuantity != null) {
      limitSelectQuantity =
          math.min(product!.stockQuantity!, kCartDetail['maxAllowQuantity']!);
    }
    return limitSelectQuantity;
  }

  /// Check The product is valid for purchase
  bool? couldBePurchased() {
    return services.widget?.couldBePurchased(variations, productVariation, product, mapAttribute);
  }

  void onSelectProductVariant({
    ProductAttribute? attr,
    String? val,
    List<ProductVariation>? variations,
    Map<String, String>? mapAttribute,
    Function? onFinish,
  }) {
    services.widget?.onSelectProductVariant(
      attr: attr,
      val: val,
      variations: variations == null ? this.variations : variations,
      mapAttribute: mapAttribute,
      onFinish: (Map<String, String> mapAttribute, ProductVariation variation) {
        setState(() {
          print(this.mapAttribute);
          print(val);
          this.mapAttribute = mapAttribute;
        });
        productVariation = variation;
        Provider.of<ProductModel>(context, listen: false)
            .changeProductVariation(variation);
      },
    );
  }

  List<Widget> getProductAttributeWidget() {
    final lang = Provider.of<AppModel>(context, listen: false).langCode ?? 'en';
    return services.widget?.getProductAttributeWidget(lang, product,
        mapAttribute, onSelectProductVariant, variations, widget.isProductCard) ?? [];
  }

  List<Widget> getBuyButtonWidget() {
    return services.widget?.getBuyButtonWidget(context, productVariation ?? ProductVariation(),
        product, mapAttribute, getMaxQuantity(), quantity, (val) {
          setState(() {
            quantity = val;
          });
        }, variations, widget.isProductCard) ?? [];
  }

  List<Widget>? getProductTitleWidget() {
    return services.widget?.getProductTitleWidget(context, productVariation ?? ProductVariation(), product);
  }

  @override
  Widget build(BuildContext context) {
    FlashHelper.init(context);

    return Column(
      children: <Widget>[
        if (widget.product!.type != 'configurable') ...?getProductTitleWidget(),
        ...getProductAttributeWidget(),
        ...getBuyButtonWidget(),
      ],
    );
  }
}
