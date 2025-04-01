import 'dart:collection';

import 'package:ctown/models/app_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../models/index.dart'
    show Product, ProductAttribute, ProductModel, ProductVariation;
import '../../services/index.dart';
import '../../widgets/product/product_variant.dart';
import '../product_variant_mixin.dart';

mixin MagentoVariantMixin on ProductVariantMixin {
  Future<void> getProductVariations({
    BuildContext? context,
    Product? product,
    String? lang,
    Function? onLoad({
      Product? productInfo,
      List<ProductVariation>? variations,
      Map<String, String>? mapAttribute,
      ProductVariation? variation,
    })?,
  }) async {
    if ((product?.attributes?.isEmpty)!) {
      return;
    }

    Map<String, String> mapAttribute = HashMap();
    List<ProductVariation> variations = [];
    Product? productInfo;

    await Services()
        .getProductVariations(
        product!, Provider.of<AppModel>(context!, listen: false).langCode)
        .then((value) {
      variations = value?.toList() ?? [];
      // if(variations.length > 0) {
      //   Provider.of<ProductModel>(context, listen: false).saveProductVariations(product, variations);
      // }
    });

    if (variations.isEmpty) {
      for (var attr in product.attributes!) {
        mapAttribute.update(attr.name!, (value) => attr.options![0],
            ifAbsent: () => attr.options![0]);
      }
    } else {
      // await Services().getProduct(product.id).then((onValue) {
      //   if (onValue != null) {
      //     productInfo = onValue;
      //   }
      // });
      for (var variant in variations) {
        if (variant.price == product.price) {
          for (var attribute in variant.attributes) {
            for (var attr in product.attributes!) {
              mapAttribute.update(attr.name!, (value) => attr.options![0],
                  ifAbsent: () => attr.options![0]);
            }
            mapAttribute.update(attribute.name!, (value) => attribute.option!,
                ifAbsent: () => attribute.option!);
          }
          break;
        }
        if (mapAttribute.isEmpty) {
          for (var attribute in product.attributes!) {
            mapAttribute.update(attribute.name!, (value) => value, ifAbsent: () {
              return attribute.options![0]["value"];
            });
          }
        }
      }
    }
    final productVariantion = await updateVariation(variations, mapAttribute);
    if (productVariantion.id != null) {
      await Provider.of<ProductModel>(context, listen: false)
          .changeProductVariation(productVariantion);
    }
    onLoad!(
        productInfo: productInfo,
        variations: variations,
        mapAttribute: mapAttribute,
        variation: productVariantion);
    return;
  }

  bool couldBePurchased(
      List<ProductVariation>? variations,
      ProductVariation? productVariation,
      Product? product,
      Map<String, String>? mapAttribute,
      ) {
    final isAvailable =
    productVariation != null ? productVariation.sku != null : true;
    return isPurchased(productVariation!, product!, mapAttribute!, isAvailable);
  }

  Future<void> onSelectProductVariant({
    ProductAttribute? attr,
    String? val,
    List<ProductVariation>? variations,
    Map<String, String>? mapAttribute,
    Function? onFinish,
  }) async {
    mapAttribute?.update((attr?.name)!, (value) {
      final option = (attr?.options)!
          .firstWhere((o) => o["label"] == val.toString(), orElse: () => null);
      if (option != null) {
        return option["value"].toString();
      }
      return val.toString();
    }, ifAbsent: () => val.toString());
    int variationLength = variations?.length ?? 0;
    if(variationLength > 0) {
      variations?.forEach((element) {
        if(element.attributes.length > 1) {
          element.attributes[0] = element.attributes[1];
        }
      });
    }
    final productVariation = await updateVariation(variations!, mapAttribute!);
    onFinish!(mapAttribute, productVariation);
  }

  List<Widget> getProductAttributeWidget(
      String lang,
      Product? product,
      Map<String, String>? mapAttribute,
      Function onSelectProductVariant,
      List<ProductVariation>? variations,
      bool isProductCard,
      ) {
    List<Widget> listWidget = [];

    final checkProductAttribute =
        product?.attributes != null && (product?.attributes?.isNotEmpty)!;
    if (checkProductAttribute) {
      for (var attr in (product?.attributes)!) {
        // print(product.attributes);
        if (attr.name != null && attr.name!.isNotEmpty) {
          List options = [];
          List salePrice = [];
          List options1 = [];
          List option = [];
          List option1 = [];
          List prices = [];
          List onSale = [];
          List label = [];

          for (var i = 0; i < attr.options!.length; i++) {
            options.add(attr.options![i]["label"]);
            Map map = {
              'label': attr.options![i]["label"],
              'value': attr.options![i]["value"],
            };
            option1.add(map);
            // print(option1);
            // print("option1");
          }
          for (var i = 0; i < (variations?.length)!; i++) {
            options1.add(variations![i].price);
            for (var j = 0; j < variations[i].attributes.length; j++) {
              if (variations[i].attributes[j].name == 'product_weight') {
                Map map = {
                  'price': variations[i].price,
                  'value': variations[i].attributes[j].option,
                };

                option.add(map);
                // print(option);
                // print("option");
              }
            }
          }
          for (var i = 0; i < (variations?.length)!; i++) {
            salePrice.add(variations![i].salePrice);
            onSale.add(variations[i].onSale);
          }

          for (var lp = 0; lp < option.length; lp++) {
            var dataVal = option[lp]["value"];
            var indexCount =
            option1.indexWhere((item) => item["value"] == dataVal);
            var finalVal = option1[indexCount]["value"];
            if (finalVal == dataVal) {
              // print(option[lp]["price"]);
              // print(option1[indexCount]["label"]);
              prices.add(option[lp]["price"]);
              label.add(option1[indexCount]["label"]);
              // print(prices);
            }
          }

          String? selectedValue =
          mapAttribute![attr.name] != null ? mapAttribute[attr.name] : "";

          final o = attr.options!.firstWhere((f) => f["value"] == selectedValue,
              orElse: () => null);
          if (o != null) {
            selectedValue = o["label"];
          }
          listWidget.add(
            BasicSelection(
              onSale: onSale,
              salePrice: salePrice,
              isProductCard: isProductCard,
              product: product,
              options1: prices,
              options: label,
              title: (kProductVariantLanguage[lang] != null &&
                  kProductVariantLanguage[lang]![attr.name!.toLowerCase()] !=
                      null)
                  ? kProductVariantLanguage[lang]![attr.name!.toLowerCase()]
                  : attr.name!.toLowerCase(),
              type: ProductVariantLayout[attr.name!.toLowerCase()] ?? 'box',
              value: selectedValue,
              onChanged: (val) => onSelectProductVariant(
                  attr: attr,
                  val: val,
                  mapAttribute: mapAttribute,
                  variations: variations),
            ),
          );
          listWidget.add(
            const SizedBox(height: 10.0),
          );
        }
      }
    }

    return listWidget;
  }

  List<Widget> getProductTitleWidget(BuildContext context,
      ProductVariation productVariation, Product? product) {
    final isAvailable =
    productVariation.id != null ? productVariation.sku != null : true;
    return makeProductTitleWidget(
        context, productVariation, product!, isAvailable);
  }

  List<Widget> getBuyButtonWidget(
      BuildContext context,
      ProductVariation productVariation,
      Product? product,
      Map<String, String>? mapAttribute,
      int? maxQuantity,
      int? quantity,
      Function onChangeQuantity,
      List<ProductVariation>? variations,
      bool isProductCard
      ) {
    final isAvailable =
    productVariation.id != null ? productVariation.sku != null : true;
    return makeBuyButtonWidget(context, productVariation, product!, mapAttribute!,
        maxQuantity!, quantity!, onChangeQuantity, isAvailable, isProductCard);
  }
}
