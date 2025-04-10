import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, Product, ProductModel, ProductVariation, WishListModel;
import '../../services/index.dart';
import '../../widgets/common/image_galery.dart';

export 'themes/full_size_image_type.dart';
export 'themes/half_size_image_type.dart';
export 'themes/simple_type.dart';

class ProductDetailScreen extends StatefulWidget {
  bool isChecked = false;
  final Product? product;
  static showMenu(context, product) {
    final Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                  title:
                  Text(S.of(context).myCart, textAlign: TextAlign.center),
                  onTap: () {
                    Navigator.of(context).pop();
                  }),
              ListTile(
                  title: Text(S.of(context).showGallery,
                      textAlign: TextAlign.center),
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return ImageGalery(images: product.images, index: 0);
                        });
                  }),
              ListTile(
                  title: Text(S.of(context).saveToWishList,
                      textAlign: TextAlign.center),
                  onTap: () {
                    Provider.of<WishListModel>(context, listen: false)
                        .addToWishlist(product);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                  title: Text(S.of(context).share, textAlign: TextAlign.center),
                  onTap: () {
                    Navigator.of(context).pop();
                    Share.share(
                      product.permalink,
                      sharePositionOrigin:
                      Rect.fromLTWH(0, 0, size.width, size.height / 2),
                    );
                  }),
              Container(
                height: 1,
                decoration: const BoxDecoration(color: kGrey200),
              ),
              ListTile(
                title: Text(
                  S.of(context).cancel,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        });
  }

  ProductDetailScreen({this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailScreen> {
  Product? product;
  List<ProductVariation> proVariations = [];
  @override
  void initState() {
    product = widget.product;
    Future.delayed(Duration.zero, () async {
      product = await Services().widget?.getProductDetail(context, product);
      setState(() {});
    });
    proVariations = Provider.of<ProductModel>(context, listen: false).getProVariations(product!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var productDetail =
    Provider.of<AppModel>(context).appConfig!['Setting']['ProductDetail'];

    var layoutType =
        productDetail ?? (kProductDetail['layout'] ?? 'simpleType');

    Widget layout =
        Services().widget?.renderDetailScreen(context, product, layoutType, variations: proVariations) ?? const SizedBox.shrink();
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: layout,
    );
  }
}
