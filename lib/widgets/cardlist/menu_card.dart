import 'package:flutter/material.dart';

import '../../common/constants/general.dart';
import '../../models/index.dart' show Category, Product;
import '../../services/index.dart';
import '../../widgets/product/product_card_view.dart';
import 'list_card.dart';

class MenuCard extends StatefulWidget {
  final List<Category> categories;
  final Category category;

  MenuCard(this.categories, this.category);

  @override
  _StateMenuCard createState() => _StateMenuCard();
}

class _StateMenuCard extends State<MenuCard> {
  int position = 0;
  int pColor = 0;
  List<List<Product>> products = [];
  double _width = 0.0;
  int durations = 0;

  Future<List<Product>> getProductFromCategory(
      {categoryId, minPrice, maxPrice, orderBy, order, lang, page,sort}) async {
    Services _service = Services();
    final product = await _service.fetchProductsByCategory(
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        orderBy: orderBy,
        order: order,
        sort:sort,
        lang: lang,
        page: page);
    return product;
  }

  Future<List<List<Product>>> getAllListProducts(
      {minPrice, maxPrice, orderBy, order, lang,sort, page = 1}) async {
    List<List<Product>> products = [];
    Services _service = Services();
    for (var category in widget.categories) {
      var product = await _service.fetchProductsByCategory(
          categoryId: category.id,
          minPrice: minPrice,
          maxPrice: maxPrice,
          orderBy: orderBy,
          order: order,
          lang: lang,
          page: page,
          sort:sort);
      products.add(product);
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double productHeight = kIsWeb
            ? constraints.maxWidth * 0.4
            : constraints.maxWidth * 0.4 + 120;

        return Padding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                child: Text(
                  widget.category.name!.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900),
                ),
                padding: const EdgeInsets.only(bottom: 10),
              ),
              widget.categories.isEmpty
                  ? Container()
                  : Container(
                      height: 26,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: ClipRRect(
                                    child: Container(
                                      child: Padding(
                                        child: Center(
                                          child: index == pColor
                                              ? Text(
                                                  widget.categories[index].name!,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black),
                                                )
                                              : Text(
                                                  widget.categories[index].name!,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 3),
                                      ),
                                      decoration: BoxDecoration(
                                        color: index == pColor
                                            ? Theme.of(context).primaryColor
                                            : Colors.transparent,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                Container(
                                  width: 10,
                                )
                              ],
                            ),
                            onTap: () async {
                              if (position == index) return;
                              setState(() {
                                _width = constraints.maxWidth - 50;
                                durations = 0;
                                pColor = index;
                              });
                              await Future.delayed(
                                  const Duration(milliseconds: 50));
                              setState(() {
                                position = index;
                                durations = 200;
                                _width = 0.0;
                              });
                            },
                          );
                        },
                        itemCount: widget.categories.length,
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
              widget.categories.isEmpty
                  ? Container()
                  : Container(
                      height: 20,
                    ),
              FutureBuilder<List<List<Product>>>(
                future: getAllListProducts(),
                builder: (context, snaphost) {
                  if (!snaphost.hasData) {
                    return Container(
                      height: productHeight,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: List.generate(3, (index) {
                          return ProductCard(
                            item: Product.empty(index.toString()),
                            width: productHeight * 0.5,
                          );
                        }),
                      ),
                    );
                  }
                  if (snaphost.data!.isEmpty) {
                    return FutureBuilder<List<Product>>(
                      future: getProductFromCategory(
                          categoryId: widget.category.id, page: 1),
                      builder: (context, product) {
                        if (!product.hasData) {
                          return Container(
                            height: productHeight,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: List.generate(3, (index) {
                                return ProductCard(
                                  item: Product.empty(index.toString()),
                                  width: productHeight * 0.5,
                                );
                              }),
                            ),
                          );
                        }
                        return Container(
                          height: productHeight,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: product.data!.length,
                            itemBuilder: (context, index) {
                              return ProductCard(
                                item: product.data![index],
                                width: productHeight * 0.5,
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                  return Container(
                    height: productHeight,
                    child: SingleChildScrollView(
                      child: Row(
                        children: <Widget>[
                          AnimatedContainer(
                            width: _width,
                            duration: Duration(milliseconds: durations),
                            decoration: const BoxDecoration(),
                          ),
                          Expanded(
                            child: ListCard(
                              data: snaphost.data![position],
                              width: constraints.maxWidth,
                              id: widget.categories[position].id,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
        );
      },
    );
  }
}
