import 'package:async/async.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../frameworks/magento/services/magento.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show AppModel, CartModel, Product, ProductModel, UserModel;
import '../../screens/detail/product_title.dart';

class GroupedProduct extends StatefulWidget {
  final Product? product;

  GroupedProduct(this.product);

  @override
  _GroupedProductState createState() => _GroupedProductState();
}

class _GroupedProductState extends State<GroupedProduct> {
  final _memoizer = AsyncMemoizer<List<Product>?>();

  // prevent FutureBuilder from being triggered again at
  // the time build method triggers, which possibly cause duplicate data.
  Future<List<Product>?> getGroupProduct(context) => _memoizer.runOnce(() {
        return Provider.of<ProductModel>(context, listen: false)
            .fetchGroupedProducts(product: widget.product!);
      });

  List<int?> productCounts = [];
  List<Product> lstGroupedProducts = [];

  void addToCart(int index, int? productCount) async {
    try{
      final cartModel = Provider.of<CartModel>(context, listen: false);

      // try {
      var userModel = Provider.of<UserModel>(context, listen: false);
      await MagentoApi()
          .addItemsToCart(
          Provider.of<AppModel>(context, listen: false).langCode,
          cartModel,
          lstGroupedProducts[index].id,
          userModel.user != null ? userModel.user!.cookie : null,
          lstGroupedProducts[index].sku,
          productCount)
          .then((value) => null)
          .catchError((e) {
        cartModel.addProductToCart(
          product: lstGroupedProducts[index],
          quantity: -productCount!,
          // success: false
        );
      });
      // } catch (e) {
      //   throw Exception(e.toString());
      // }
      String message = cartModel.addProductToCart(
          product: lstGroupedProducts[index], quantity: productCount!);

      if (message.isNotEmpty) {
        Tools.showSnackBar(ScaffoldMessenger.of(context), message);
      } else {
        await showFlash(
            context: context,
            duration: const Duration(milliseconds: 1200),
            builder: (context, controller) {
              return Flash(
                controller: controller,
                dismissDirections: [FlashDismissDirection.startToEnd],
                child: FlashBar(
                  controller: controller,
                  position: FlashPosition.top,
                  backgroundColor: const Color(0xFF80FF72).withOpacity(0.5),
                  behavior: FlashBehavior.fixed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  icon: const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  content: Center(
                    child: Text(
                      S.of(context).addedSuccessfully,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              );
            });
      }
    }
    catch(e) {
      printLog(e.toString());
    }
  }

  void onUpdate({required int index, int? productCount}) {
    productCounts[index] = productCount;
  }

  Widget availableWidget() {
    return Row(
      children: <Widget>[
        Text(
          "${S.of(context).availability}: ",
          style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.secondary),
        ),
        Text(
          S.of(context).inStock,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget addToCartWidget() {
    final ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        for (int i = 0; i < lstGroupedProducts.length; i++) {
          if (productCounts[i]! > 0) addToCart(i, productCounts[i]);
        }
      },
      child: Container(
        height: 44,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.primaryColor,
        ),
        child: Center(
          child: Text(
            S.of(context).addToCart.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

//  Widget groupedProductList() {
//    List<Widget> lstWidget = [];
//    int i = 0;
//    for (var product in Provider.of<ProductModel>(context).lstGroupedProduct) {
//      lstGroupedProducts.add(product);
//      productCounts.add(0);
//      lstWidget.add(GroupProductRow(product, i, onUpdate));
//      i++;
//    }
//    return Column(
//      crossAxisAlignment: CrossAxisAlignment.stretch,
//      children: lstWidget,
//    );
//  }

  Widget groupedProductBuilder() {
    final currency = Provider.of<AppModel>(context, listen: false).currency;
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;
    return FutureBuilder(
//      future: Provider.of<ProductModel>(context)
//          .fetchGroupedProducts(product: widget.product),
      future: getGroupProduct(context),
      builder: (BuildContext context, AsyncSnapshot<List<Product>?> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return kLoadingWidget(context);
          case ConnectionState.done:
          default:
            if (snapshot.hasData) {
              Provider.of<ProductModel>(context, listen: false)
                  .changeDetailPriceRange(currency, currencyRate);
              List<Widget> lstWidget = [];

              int i = 0;
              for (var product in snapshot.data!) {
                lstGroupedProducts.add(product);
                productCounts.add(0);
                lstWidget.add(GroupProductRow(product, i, onUpdate));
                i++;
              }

              return Column(
                children: <Widget>[
                  ProductTitle(widget.product, '', '', '', '', [], true),
                  const SizedBox(height: 10.0),
                  availableWidget(),
                  const SizedBox(height: 10.0),
                  Column(
                    children: lstWidget,
                  ),
                  const SizedBox(height: 10.0),
                  addToCartWidget(),
                ],
              );
            }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 30,
              width: 200,
              color: Theme.of(context).primaryColorLight,
            ),
            const SizedBox(height: 10.0),
            Container(
              height: 30,
              width: 150,
              color: Theme.of(context).primaryColorLight,
            ),
            const SizedBox(height: 10.0),
            Container(
              height: 20,
              width: 130,
              color: Theme.of(context).primaryColorLight,
            ),
            const SizedBox(height: 10.0),
            Container(
              height: 20,
              width: 140,
              color: Theme.of(context).primaryColorLight,
            ),
            const SizedBox(height: 10.0),
            Container(
              height: 44,
              width: double.infinity,
              color: Theme.of(context).primaryColorLight,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return groupedProductBuilder();
  }
}

class GroupProductRow extends StatefulWidget {
  final Product product;
  final int index;
  final Function onUpdate;

  GroupProductRow(this.product, this.index, this.onUpdate);

  @override
  _GroupProductRowState createState() => _GroupProductRowState();
}

class _GroupProductRowState extends State<GroupProductRow> {
  int productCount = 0;

  void onUpdate() {
    widget.onUpdate(index: widget.index, productCount: productCount);
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<AppModel>(context, listen: false).currency;
    final currencyRate =
        Provider.of<AppModel>(context, listen: false).currencyRate;
    var price = Tools.getCurrencyFormatted(widget.product.price, currencyRate,
        currency: currency);
    return Container(
      color: const Color(0xFFF4F4F4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: const Color(0xFFFFFFFF),
              ),
              height: 35.0,
              child: Row(
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    child: IconButton(
                      splashColor: Colors.transparent,
                      icon: const Icon(
                        Icons.remove,
                        color: Colors.black,
                      ),
                      iconSize: 16.0,
                      onPressed: () {
                        setState(() {
                          if (productCount > 0) productCount--;
                          onUpdate();
                        });
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      '$productCount',
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: IconButton(
                      splashColor: Colors.transparent,
                      icon: const Icon(
                        Icons.add,
                        color: Colors.black,
                      ),
                      iconSize: 16.0,
                      onPressed: () {
                        setState(() {
                          productCount++;
                          onUpdate();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              '${widget.product.name}',
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            '$price',
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8.0),
        ],
      ),
    );
  }
}
