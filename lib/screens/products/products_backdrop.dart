import 'package:flutter/material.dart';

import '../../widgets/product/product_bottom_sheet.dart';

class ProductBackdrop extends StatelessWidget {
  final ExpandingBottomSheet? expandingBottomSheet;
  final Widget? backdrop;

  const ProductBackdrop({Key? key, this.expandingBottomSheet, this.backdrop})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        backdrop!,
        Align(alignment: Alignment.bottomRight, child: expandingBottomSheet)
      ],
    );
  }
}
