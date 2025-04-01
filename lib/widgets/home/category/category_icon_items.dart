import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/constants/general.dart';
import '../../../common/tools.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';

/// The category icon circle list
class CategoryItem extends StatelessWidget {
  final config;
  final item;
  final products;
  final width;

  CategoryItem({
    this.config,
    this.item,
    this.products,
    this.width = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final _defaultColumn = kIsWeb ? 8 : 6;
    final id = item['category'].toString();
    final size = config['size'] ?? 1;
    final columns = config['columns'] ?? _defaultColumn;
    final itemWidth = size * width / _defaultColumn;
    final containerWidth =
        config['wrap'] == false ? itemWidth : width / columns - 20;

    Widget getImageCategory = item['image'].indexOf('http') != -1
        ? Image.network(
            item['image'],
            color: HexColor(item["colors"][0]),
            width: itemWidth * 0.4 * size,
            height: itemWidth * 0.4 * size,
          )
        : Image.asset(
            item["image"],
            color: HexColor(item["colors"][0]),
            width: itemWidth * 0.4 * size,
            height: itemWidth * 0.4 * size,
          );

    Widget getOriginalImage = item['image'].indexOf('http') != -1
        ? Image.network(
            item['image'],
            width: itemWidth * 0.4 * size,
            height: itemWidth * 0.4 * size,
          )
        : Image.asset(
            item["image"],
            width: itemWidth * 0.4 * size,
            height: itemWidth * 0.4 * size,
          );

    List<Color> colors = [];
    for (var item in item["colors"]) {
      colors.add(HexColor(item).withAlpha(30));
    }

    return Consumer<CategoryModel>(builder: (context, model, child) {
      final name =
          model.categoryList[id] != null ? model.categoryList[id]!.name : '';

      return GestureDetector(
          onTap: () {
            /// Show blog list.
            if (item['blog_category'] != null) {
              Utils.onTapNavigateOptions(context: context, config: item);
              return;
            }

            /// Default show product list.
            ProductModel.showList(
              config: item,
              context: context,
              products: item['data'] ?? [],
            );
          },
          child: Container(
            width: containerWidth,
            margin: EdgeInsets.only(
                left: Tools.formatDouble(config['wrap'] == false ? 10 : 0.0)!),
            padding: const EdgeInsets.only(top: 15.0),
            decoration: config['border'] != null
                ? BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: Tools.formatDouble(config['border'])!,
                        color: Colors.black.withOpacity(0.05),
                      ),
                      right: BorderSide(
                        width: Tools.formatDouble(config['border'])!,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  decoration: (config['noBackground'] == true ||
                          item['noBackground'] == true ||
                          (item['originalColor'] ?? false))
                      ? (item["backgroundColor"] != true &&
                              item["backgroundColor"] != null
                          ? BoxDecoration(
                              color: HexColor(item["backgroundColor"]),
                              borderRadius: BorderRadius.circular(
                                Tools.formatDouble(
                                    config['radius'] ?? itemWidth / 2)!,
                              ))
                          : null)
                      : BoxDecoration(
                          color: colors.length == 1 ? colors.first : null,
                          gradient: colors.length >= 2
                              ? LinearGradient(
                                  colors: colors,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(
                            Tools.formatDouble(
                                config['radius'] ?? itemWidth / 2)!,
                          ),
                        ),
                  child: Padding(
                    padding: EdgeInsets.all(10.0 * size),
                    child: (item['originalColor'] ?? false)
                        ? getOriginalImage
                        : getImageCategory,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['name'] ?? name!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .apply(fontSizeFactor: 0.9),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ));
    });
  }
}

/// List of Category Items
class CategoryIcons extends StatelessWidget {
  final config;

  CategoryIcons({this.config, Key? key}) : super(key: key);

  List getItemLayout({width}) {
    List<Widget> items = [];
    for (var item in config['items']) {
      items.add(CategoryItem(
        item: item,
        config: config,
        width: width,
      ));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    // final screenSize = MediaQuery.of(context).size;
    // final screenWidth =
    //     screenSize.width / (2 / (screenSize.height / screenSize.width));

    // final itemWidth = screenWidth / 10;
    // final heightList = kIsWeb ? itemWidth + 50 : itemWidth + 20;
    final column = config['column'] ?? 4;
    var row = (config['items'].length / column).toInt();
    if (row * column < config['items'].length) row += 1;

    return LayoutBuilder(
      builder: (context, constraint) {
        if (config['wrap'] == false) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: getItemLayout(width: constraint.maxWidth) as List<Widget>,
            ),
          );
        }

        return Container(
          color: Theme.of(context).colorScheme.surface,
          child: Container(
            margin: const EdgeInsets.all(10.0),
            padding: const EdgeInsets.only(bottom: 15.0),
            width: MediaQuery.of(context).size.width - 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.0),
              boxShadow: [
                if (config['shadow'] != null)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: Tools.formatDouble(config['shadow'] ?? 15.0)!,
                    offset:
                        Offset(0, Tools.formatDouble(config['shadow'] ?? 10.0)!),
                  )
              ],
            ),
            child: Column(
              children: List.generate(row, (index) {
                return Row(
                  children: List.generate(column, (item) {
                    return Expanded(
                      child: column * index + item >= config['items'].length
                          ? Container()
                          : FittedBox(
                              child: CategoryItem(
                                  item: config['items'][column * index + item],
                                  config: config,
                                  width: constraint.maxWidth),
                            ),
                    );
                  }),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
