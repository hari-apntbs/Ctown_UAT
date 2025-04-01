import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/tools.dart';
import '../../models/index.dart' show Product, ProductModel, ProductVariation;
import '../../widgets/common/image_galery.dart';

class ImageFeature extends StatelessWidget {
  final Product? product;

  ImageFeature(this.product);

  @override
  Widget build(BuildContext context) {
    ProductVariation? productVariation;
    productVariation = Provider.of<ProductModel>(context).productVariation;
    final imageFeature = productVariation != null
        ? productVariation.imageFeature2 ?? productVariation.imageFeature?? ""
        : product!.imageFeature2 ?? product!.imageFeature?? "";

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30.0),
                  Expanded(
                    child: Tools.image(
                      url: imageFeature,
                      fit: BoxFit.contain,
                      isResize: true,
                      size: kSize.small,
                      width: MediaQuery.of(context).size.width * 0.8,
                      hidePlaceHolder: true,
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
