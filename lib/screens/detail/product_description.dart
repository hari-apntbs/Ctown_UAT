import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show Product;
import '../../services/index.dart';
import '../../widgets/common/expansion_info.dart';
import 'additional_information.dart';
import 'review.dart';

class ProductDescription extends StatelessWidget {
  final Product? product;

  ProductDescription(this.product);

  @override
  Widget build(BuildContext context) {
    bool enableReview = (Services().widget?.enableProductReview)! && kProductDetail['enableReview'] as bool;

    return Column(
      children: <Widget>[
        const SizedBox(height: 15),
        if (product!.description != null)
          ExpansionInfo(
            title: S.of(context).description,
            children: <Widget>[
              HtmlWidget(
                product!.description!.replaceAll('src="//', 'src="https://'),
                textStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(height: 20),
            ],
            expand: true,
          ),
        Container(height: 1, decoration: const BoxDecoration(color: kGrey200)),
        //if (product.infors?.isNotEmpty ?? false)
        ExpansionInfo(
          title: S.of(context).additionalInformation,
          children: <Widget>[
            AdditionalInformation(
              productId: product!.id,
              //listInfo: product.infors,
            ),
          ], 
        ),
       
        if (enableReview) ...[
          Container(
            height: 1,
            decoration: const BoxDecoration(color: kGrey200),
          ),
          ExpansionInfo(
            title: S.of(context).readReviews,
            children: <Widget>[
              Reviews(product!.id),
            ],
          ),
        ],
      ],
    );
  }
}
