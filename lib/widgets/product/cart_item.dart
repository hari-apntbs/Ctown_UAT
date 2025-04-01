import 'package:ctown/models/cart/cart_model.dart';
import 'package:ctown/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config/products.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../frameworks/magento/services/magento.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, Product, ProductVariation;
import '../../services/index.dart';
import '../common/image_galery.dart';
import 'product_variant.dart';

class ShoppingCartRow extends StatelessWidget {
  ShoppingCartRow({
    required this.product,
    required this.quantity,
    this.onRemove,
    this.onChangeQuantity,
    this.variation,
    this.options,
    this.data,
    required this.lang,
  });
  final data;
  final Product product;
  final ProductVariation? variation;
  final Map<String, dynamic>? options;
  final int? quantity;
  final Function? onChangeQuantity;
  final VoidCallback? onRemove;
  TextEditingController note = TextEditingController();
  final String lang;

  Future<String> getProductImage() async {
    String image = product.imageFeature ?? "";
    String name = product.name ?? "";
    if (image != "" && image.contains("CTOWN-LOGO") && name != "") {
      product.imageFeature =
          await MagentoApi().getConfigImage(lang, product.sku ?? "");
    }
    return product.imageFeature ?? "";
  }

  @override
  Widget build(BuildContext context) {
    note.text = product.note;
    CartModel cartModel = Provider.of<CartModel>(context);
    String? currency = Provider.of<AppModel>(context).currency;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final price = Services()
        .widget
        ?.getPriceItemInCart(product, variation, currencyRate, currency);
    final imageFeature = variation != null &&
            variation!.imageFeature != null &&
            variation!.imageFeature != ""
        ? variation!.imageFeature
        : product.imageFeature;

    ThemeData theme = Theme.of(context);

    return product.type != "configurable"
        ? LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Row(
                    key: ValueKey(product.id),
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (onRemove != null)
                        IconButton(
                            icon: Icon(Icons.remove_circle_outline,
                                color: product.qty == null || product.qty == 0
                                    ? Colors.red
                                    : theme.colorScheme.secondary),
                            onPressed: () {
                              print(imageFeature);
                              // print(int.parse(data["qty"]));
                              print(product.id);
                              print(product.price);
                              print(product.qty);
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                        title: Text(Provider.of<AppModel>(
                                                        context,
                                                        listen: false)
                                                    .langCode ==
                                                'en'
                                            ? "Are You Sure "
                                            : 'هل أنت متأكد '),
                                        content: Text(Provider.of<AppModel>(
                                                        context,
                                                        listen: false)
                                                    .langCode ==
                                                'en'
                                            ? "Do you want to remove the product"
                                            : 'هل تريد إزالة المنتج'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text(S.of(context).no),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              onRemove!(); // Navigator.of(context1).push(MaterialPageRoute(builder:(context1)=>

                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text(S.of(context).yes),
                                          ),
                                        ],
                                      ));
                            }),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            FutureBuilder<String>(
                              future: getProductImage(),
                              builder: (context, snapshot) {
                                if(snapshot.data != null) {
                                  return InkWell(
                                    onTap: () {
                                      printLog(imageFeature);
                                      showDialog<void>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ImageGalery(
                                              images: [snapshot.data],
                                              index: 0,
                                            );
                                          });
                                    },
                                    child: Container(
                                      width: constraints.maxWidth * 0.25,
                                      height: constraints.maxWidth * 0.3,
                                      child: Tools.image(
                                          url: imageFeature == null || imageFeature == ""
                                              ? 'https://up.ctown.jo/pub/media/catalog/product/placeholder/default/CTOWN-LOGO_1_2.png'
                                              : snapshot.data),
                                    ),
                                  );
                                }
                                else if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(
                                    width: constraints.maxWidth * 0.25,
                                    height: constraints.maxWidth * 0.3,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name!,
                                      style: TextStyle(
                                        color: theme.colorScheme.secondary,
                                        fontSize: 14,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      price!,
                                      style: TextStyle(
                                        color: theme.colorScheme.secondary,
                                        fontSize: 14,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // const SizedBox(height: 5),
                                    // InkWell(
                                    //   onTap: () {
                                    //     print(product.imageFeature);
                                    //   },
                                    //   child: CartProductDetails(product, ''),
                                    // ),

                                    const SizedBox(height: 7),
                                    // Text(
                                    //   S.of(context).delivery +
                                    //       product.delivery_date!,
                                    //   // 'Delivery: within 30 mints',
                                    //   style: TextStyle(
                                    //     color: theme.accentColor,
                                    //     // fontFamily: 'raleway'
                                    //   ),
                                    //   maxLines: 2,
                                    //   overflow: TextOverflow.ellipsis,
                                    // ),
                                    // const SizedBox(height: 7),
                                    if (product.package_info!.isNotEmpty)
                                      Text(
                                        // 'Units: 6',
                                        S.of(context).units +
                                            product.package_info!,
                                        style: TextStyle(
                                          color: theme.colorScheme.secondary,
                                          // fontFamily: 'raleway'
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    // const SizedBox(height: 7),

                                    // const SizedBox(height: 7),
                                    product.qty != null && product.qty! <= 0
                                        ? Text(
                                            S.of(context).outOfStock,
                                            style: TextStyle(
                                              color: theme.primaryColor,
                                              fontSize: 14,
                                              // fontFamily: 'raleway',
                                            ),
                                          )
                                        : cartModel.outOfStockItems
                                                .containsKey(product.id!)
                                            ? Text(
                                                S.of(context).outOfStock,
                                                style: TextStyle(
                                                  color: theme.primaryColor,
                                                  fontSize: 14,
                                                  // fontFamily: 'raleway',
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                    onChangeQuantity == null
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white :Colors.black,
                                                width: 0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: TextField(
                                              // maxLines: 2,
                                              controller: note,
                                              onChanged: (value) {
                                                product.note = note.text;
                                                print(product.note);
                                              },
                                              style:
                                                  const TextStyle(fontSize: 13),
                                              decoration: InputDecoration(
                                                  hintText: S
                                                      .of(context)
                                                      .writeYourNote,
                                                  hintStyle: TextStyle(
                                                      fontSize: 14,
                                                      color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white :Colors.black),
                                                  border: InputBorder.none),
                                            ))
                                        : const SizedBox(height: 10),
                                    const SizedBox(height: 10),
                                    variation?.id != null || options != null
                                        ? Services()
                                                .widget
                                                ?.renderVariantCartItem(
                                                    variation, options) ??
                                            const SizedBox.shrink()
                                        : Container(),
                                    (product.package_info?.contains("KG"))!
                                        ? SizedBox.shrink()
                                        : QuantitySelection(
                                            enabled: onChangeQuantity != null,
                                            width: 60,
                                            height: 32,
                                            color:
                                                Theme.of(context).colorScheme.secondary,
                                            limitSelectQuantity:
                                                // product.qty!=null?
                                                /* product.qty,*/
                                                product.qty != null
                                                    ? product.qty! > 300
                                                        ? 300
                                                        : product.qty
                                                    : 0,
                                            value: quantity,
                                            onChanged: onChangeQuantity,
                                            useNewDesign: false,
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16.0),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  const Divider(color: kGrey200, height: 1),
                  const SizedBox(height: 10.0),
                ],
              );
            },
          )
        : LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Row(
                    key: ValueKey(variation!.id),
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (onRemove != null)
                        IconButton(
                            icon: Icon(Icons.remove_circle_outline,
                                color: data != null
                                    ? quantity! > int.parse(data["qty"]) ||
                                            int.parse(data["qty"]) < 1
                                        ? Colors.red
                                        : theme.colorScheme.secondary
                                    : theme.colorScheme.secondary),
                            onPressed: () {
                              print(product.type);
                              print(product.qty);
                              print(variation!.sku);
                              print(product.sku);
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                        title: Text(Provider.of<AppModel>(
                                                        context,
                                                        listen: false)
                                                    .langCode ==
                                                'en'
                                            ? "Are You Sure "
                                            : 'هل أنت متأكد '),
                                        content: Text(Provider.of<AppModel>(
                                                        context,
                                                        listen: false)
                                                    .langCode ==
                                                'en'
                                            ? "Do you want to remove the product"
                                            : 'هل تريد إزالة المنتج'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text(S.of(context).no),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              onRemove!(); // Navigator.of(context1).push(MaterialPageRoute(builder:(context1)=>

                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text(S.of(context).yes),
                                          ),
                                        ],
                                      ));
                            }),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                showDialog<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ImageGalery(
                                        images: [imageFeature],
                                        index: 0,
                                      );
                                    });
                              },
                              child: Container(
                                width: constraints.maxWidth * 0.25,
                                height: constraints.maxWidth * 0.3,
                                child: Tools.image(url: imageFeature),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      variation!.name ?? "",
                                      style: TextStyle(
                                        color: theme.colorScheme.secondary,
                                        fontSize: 14,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // const SizedBox(height: 7),
                                    // Text(
                                    //   S.of(context).delivery +
                                    //       product.delivery_date!,
                                    //   // 'Delivery: within 30 mints',
                                    //   style: TextStyle(
                                    //     color: theme.accentColor,
                                    //     // fontFamily: 'raleway'
                                    //   ),
                                    //   maxLines: 2,
                                    //   overflow: TextOverflow.ellipsis,
                                    // ),
                                    const SizedBox(height: 7),
                                    Text(
                                      // 'Units: 6',
                                      S.of(context).units +
                                          product.package_info!,
                                      style: TextStyle(
                                        color: theme.colorScheme.secondary,
                                        // fontFamily: 'raleway'
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      price!,
                                      style: TextStyle(
                                        color: theme.colorScheme.secondary,
                                        fontSize: 14,
                                        // fontFamily: 'raleway',
                                      ),
                                    ),
                                    data != null
                                        ? quantity! > int.parse(data["qty"]) ||
                                                int.parse(data["qty"]) < 1
                                            ? Text(
                                                S.of(context).outOfStock,
                                                style: TextStyle(
                                                  color: theme.primaryColor,
                                                  fontSize: 14,
                                                  // fontFamily: 'raleway',
                                                ),
                                              )
                                            : cartModel.outOfStockItems
                                                    .containsKey(product.id!)
                                                ? Text(
                                                    S.of(context).outOfStock,
                                                    style: TextStyle(
                                                      color: theme.primaryColor,
                                                      fontSize: 14,
                                                      // fontFamily: 'raleway',
                                                    ),
                                                  )
                                                : const SizedBox.shrink()
                                        : const Text(""),
                                    onChangeQuantity == null
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white :Colors.black,
                                                width: 0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: TextField(
                                              // maxLines: 2,
                                              controller: note,
                                              onChanged: (value) {
                                                product.note = note.text;
                                                print(product.note);
                                              },
                                              style:
                                                  const TextStyle(fontSize: 13),
                                              decoration: InputDecoration(
                                                  hintText: S
                                                      .of(context)
                                                      .writeYourNote,
                                                  hintStyle: TextStyle(
                                                      fontSize: 14,
                                                      color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white :Colors.black),
                                                  border: InputBorder.none),
                                            ))
                                        : const SizedBox(height: 10),
                                    const SizedBox(height: 10),
                                    variation != null || options != null
                                        ? Services()
                                                .widget
                                                ?.renderVariantCartItem(
                                                    variation, options) ??
                                            const SizedBox.shrink()
                                        : Container(),
                                    // InkWell(
                                    //     onTap: () async {
                                    //       // await Services()
                                    //       //     .widget
                                    //       //     .syncCartFromWebsite(
                                    //       //         cookie, cartModel, context);
                                    //       print("running");
                                    //
                                    //       // showDialog(
                                    //       //     barrierDismissible: true,
                                    //       //     context: context,
                                    //       //     builder: (context) {
                                    //       //       return AlertDialog(
                                    //       //         title: Text("jhfdjdh"),
                                    //       //       );
                                    //       //     });
                                    //     },
                                    //     child: Container(
                                    //         margin: const EdgeInsets.symmetric(
                                    //             horizontal: 4.0),
                                    //         width: 60,
                                    //         height: 32,
                                    //         decoration: BoxDecoration(
                                    //           border: Border.all(
                                    //               width: 1.0, color: kGrey200),
                                    //           borderRadius:
                                    //               BorderRadius.circular(3),
                                    //         ),
                                    //         alignment: Alignment.center,
                                    //         child: Center(
                                    //           child: Text(quantity.toString()),
                                    //         ))
                                    //
                                    //     //  QuantitySelection(
                                    //     //   enabled: false,
                                    //     //   width: 60,
                                    //     //   height: 32,
                                    //     //   color: Theme.of(context).accentColor,
                                    //     //   limitSelectQuantity:
                                    //     //       variation.stockQuantity != null
                                    //     //           ? variation.stockQuantity > 300
                                    //     //               ? 300
                                    //     //               : variation.stockQuantity
                                    //     //           : 0,
                                    //     //   value: quantity,
                                    //     //   onChanged: () {},
                                    //     //   useNewDesign: false,
                                    //     // ),
                                    //     ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16.0),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  const Divider(color: kGrey200, height: 1),
                  const SizedBox(height: 10.0),
                ],
              );
            },
          );
  }
}
