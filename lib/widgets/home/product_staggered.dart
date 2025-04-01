import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../models/index.dart' show Product;
import '../../widgets/product/product_card_view.dart';

List<StaggeredGridTile> _staggeredTiles = const  <StaggeredGridTile>[
  StaggeredGridTile.count(crossAxisCellCount: 2, mainAxisCellCount: 1, child: SizedBox()),
  StaggeredGridTile.count(crossAxisCellCount: 1, mainAxisCellCount: 1,child: SizedBox()),
  StaggeredGridTile.count(crossAxisCellCount: 3, mainAxisCellCount: 2,child: SizedBox()),
  StaggeredGridTile.count(crossAxisCellCount: 1, mainAxisCellCount: 1,child: SizedBox()),
  StaggeredGridTile.count(crossAxisCellCount: 1, mainAxisCellCount: 1,child: SizedBox()),
  StaggeredGridTile.count(crossAxisCellCount: 1, mainAxisCellCount: 1,child: SizedBox()),
];


class ProductStaggered extends StatefulWidget {
  final List<Product?>? products;
  final width;

  ProductStaggered(this.products, this.width);

  @override
  _StateProductStaggered createState() => _StateProductStaggered();
}

class _StateProductStaggered extends State<ProductStaggered> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double? _size = widget.width / 3;
    final screenSize = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.only(left: 15.0),
      height: screenSize.height * 0.8 / (screenSize.height / widget.width),
      child: StaggeredGrid.count(
        crossAxisCount: 3,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        axisDirection: AxisDirection.right,
        children: List.generate(
          widget.products!.length,
              (index) => StaggeredGridTile.count(
            crossAxisCellCount: (_staggeredTiles[index % 6].mainAxisCellCount ?? 1).toInt(),
            mainAxisCellCount: (_staggeredTiles[index % 6].crossAxisCellCount ?? 1).toInt(),
            child: Center(
              child: ProductCard(
                width: _size! * (_staggeredTiles[index % 6].mainAxisCellCount ?? 1),
                height: _size * (_staggeredTiles[index % 6].crossAxisCellCount ?? 1) - 20,
                item: widget.products![index],
                hideDetail: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
