import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart'
    show AppModel, Category, CategoryModel, Product;
import '../../../services/index.dart';

class MenuLayout extends StatefulWidget {
  final config;

  MenuLayout({this.config});

  @override
  _StateSelectLayout createState() => _StateSelectLayout();
}

class _StateSelectLayout extends State<MenuLayout> {
  int position = 0;
  bool loading = false;
  List<List<Product>?> products = [];
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  Future<bool> getAllListProducts({
    minPrice,
    maxPrice,
    sort,
    orderBy,
    order,
    lang,
    page = 1,
    categories,
  }) async {
    if (this.products.isNotEmpty) return true;
    List<List<Product>?> products = [];
    Services _service = Services();
    for (var category in categories) {
      try {
        List<dynamic>? productList = [];
        if (category.products != null && page == 1) {
          productList = category.products;
        } else {
          productList = await _service.fetchProductsByCategory(
            categoryId: category.id,
            minPrice: minPrice,
            maxPrice: maxPrice,
            orderBy: orderBy,
            order: order,
            lang: lang,
            page: page,
            sort:sort,
          );
        }

        products.add(productList as List<Product>?);
        setState(() {
          this.products = products;
        });
      } catch (e) {
        products.add([]);
        setState(() {
          this.products = products;
        });
      }
    }
    return true;
  }

  List<Category>? getAllCategory() {
    final categories =
        Provider.of<CategoryModel>(context, listen: true).categories;
    if (categories == null) return null;
    var listCategories =
        categories.where((item) => item.parent == '0').toList();
    List<Category> _categories = [];

    for (var category in listCategories) {
      var children = categories.where((o) => o.parent == category.id).toList();
      if (children.isNotEmpty) {
        _categories = [..._categories, ...children];
      } else {
        _categories = [..._categories, category];
      }
    }
    return _categories;
  }

  @override
  Widget build(BuildContext context) {
    List<Category>? categories = getAllCategory();
    if (categories == null) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: kLoadingWidget(context),
        ),
      );
    }

    return Column(
      children: <Widget>[
        Container(
          height: 70,
          padding: const EdgeInsets.only(top: 15),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: List.generate(categories.length, (index) {
              bool check = (products.length > index)
                  ? (products[index]!.isEmpty ? false : true)
                  : true;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    position = index;
                  });
                },
                child: !check
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              child: Text(
                                categories[index].name!.toUpperCase(),
                                style: TextStyle(
                                    color: index == position
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w600),
                              ),
                              padding: const EdgeInsets.only(bottom: 8),
                            ),
                            index == position
                                ? Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Theme.of(context).primaryColor),
                                    width: 20,
                                  )
                                : Container()
                          ],
                        ),
                      ),
              );
            }),
          ),
        ),
        FutureBuilder<bool>(
          future: getAllListProducts(
            categories: categories,
            lang: Provider.of<AppModel>(context, listen: false).langCode,
          ),
          builder: (context, check) {
            if (products.isEmpty) {
              return StaggeredGrid.count(
                  crossAxisCount: 4,
                  key: Key(categories[position].id.toString()),
                  children: List.generate(4, (value) {
                    return StaggeredGridTile.fit(
                        crossAxisCellCount: 2,
                        child: Services().widget?.renderProductCardView(
                          item: Product.empty(value.toString()),
                          width: MediaQuery.of(context).size.width / 2,
                        ) ?? const SizedBox.shrink()
                    );
                  })
              );
            }
            if (products[position] == null || products[position]!.isEmpty) {
              return Container(
                height: MediaQuery.of(context).size.width / 2,
                child: Center(
                  child: Text(S.of(context).noProduct),
                ),
              );
            }
            return MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return StaggeredGrid.count(
                      crossAxisCount: 4,
                      key: Key(categories[position].id.toString()),
                      children: List.generate(products[position]!.length, (value) {
                        return StaggeredGridTile.fit(
                            crossAxisCellCount: 2,
                            child: Services().widget?.renderProductCardView(
                              item: products[position]![value],
                              showCart: true,
                              showHeart: true,
                              width: constraints.maxWidth / 2,
                            ) ?? const SizedBox.shrink()
                        );
                      })
                  );
                },
              ),
            );
          },
        )
      ],
    );
  }
}
