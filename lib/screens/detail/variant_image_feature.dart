import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show Product, ProductModel, ProductVariation;
import '../../widgets/common/image_galery.dart';

class VariantImageFeature extends StatelessWidget {
  final Product? product;

  VariantImageFeature(this.product);

  @override
  Widget build(BuildContext context) {
    final bool isLoading =
        Provider.of<ProductModel>(context).isProductVariationLoading;
    ProductVariation? productVariation;
    productVariation = Provider.of<ProductModel>(context).productVariation;
    final imageFeature = productVariation != null
        ? productVariation.imageFeature
        : product!.imageFeature;

    _onShowGallery(context, [index = 0]) {
      Navigator.push(
        context,
        PageRouteBuilder(pageBuilder: (context, __, ___) {
          return ImageGalery(images: product!.images, index: index);
        }),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return FlexibleSpaceBar(
          background: GestureDetector(
            onTap: () => _onShowGallery(context),
            child: Container(
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: double.parse(kProductDetail['marginTop'].toString()),
                    child: Tools.image(
                      url: imageFeature,
                      fit: BoxFit.contain,
                      isResize: true,
                      size: kSize.medium,
                      width: constraints.maxWidth,
                      hidePlaceHolder: true,
                    ),
                  ),
                  Positioned(
                    top: double.parse(kProductDetail['marginTop'].toString()),
                    child: Tools.image(
                      url: imageFeature,
                      fit: BoxFit.contain,
                      width: constraints.maxWidth,
                      size: kSize.large,
                      hidePlaceHolder: true,
                    ),
                  ),
                  if (productVariation == null && isLoading)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 1,
                          bottom: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          S.of(context).loading,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
