import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

import '../../common/config/general.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show AppModel, CartModel, Product, UserModel, WishListModel;
import '../../services/service_config.dart';
import '../../tabbar.dart';
import '../../widgets/product/product_bottom_sheet.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/product/product_list.dart';

class WishListScreen extends StatefulWidget {
  final bool canPop;
  final bool? showChat;

  WishListScreen({this.canPop = true, this.showChat});

  @override
  State<StatefulWidget> createState() {
    return WishListState();
  }
}

class WishListState extends State<WishListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _hideController;
  final ScrollController _scrollController = ScrollController();

  getSavedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore')!;

    return jsonDecode(result);
  }

  @override
  void initState() {
    super.initState();
    _hideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _hideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool showChat = widget.showChat ?? false;

    getText(WishListModel model) {
      bool show = false;
      model.products.forEach((e) {
        if (!e!.status!) {
          show = true;
        }
      });
      return show
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Text(
                  Provider.of<AppModel>(context, listen: false).langCode == "en"
                      ? "Click the notify me button to let you know once the out of stock products in your wishlist are available"
                      : "انقر فوق زر إعلامي لإعلامك بمجرد توفر المنتجات غير المتوفرة في قائمة الرغبات الخاصة بك",
                  style: const TextStyle(fontSize: 14, color: kGrey400)),
            )
          : Container();
    }

    getAction(model) {
      bool show = false;
      model.products.forEach((e) {
        if (!e.status) {
          show = true;
        }
      });
      return !show
          ? Container()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () async {
                        final LocalStorage storage = LocalStorage('store');
                        final userJson = await storage.getItem(kLocalKey["userInfo"]!);
                        List<Product?> outOfStockProdducts = [];
                        List<String?> ids = [];
                        Provider.of<WishListModel>(context, listen: false)
                            .products
                            .forEach((element) {
                          if (!element!.status!) {
                            outOfStockProdducts.add(element);
                            outOfStockProdducts.toSet().toList();
                          }
                        });

                        if (outOfStockProdducts.isNotEmpty) {
                          outOfStockProdducts.forEach((element) {
                            ids.add(element!.id);
                          });
                        }

                        var savedStore = await getSavedStore();
                        String? storeId =
                            Provider.of<AppModel>(context, listen: false)
                                        .langCode ==
                                    "en"
                                ? savedStore["store_en"]["id"]
                                : savedStore["store_ar"]["id"] ?? "";
                        ids.add("2081");
                        String apiUrl =
                            "https://up.ctown.jo/api/instock_notify.php";
                        Map body = {
                          "customer_id": userJson["id"],
                          "customer_email": userJson["email"],
                          "product_id": ids
                              .toString()
                              .replaceAll("[", "")
                              .toString()
                              .replaceAll("]", ""),
                          "store_id": storeId
                        };
                        print(jsonEncode(body));
                        var response =
                            await http.post(Uri.parse(apiUrl), body: jsonEncode(body));
                        if (response.statusCode == 200) {
                          print(response.body);
                          var responseBody = jsonDecode(response.body);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(responseBody["message"]),
                          ));
                          // Scaffold.of(context).showSnackBar(SnackBar(
                          //   content: Text("Success"),
                          // ));
                        }
                      },
                      child: Text(
                        Provider.of<AppModel>(context, listen: false)
                                    .langCode ==
                                "en"
                            ? "Notify Me"
                            : "أشعرني، أعلمني، بلغني",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ))
              ],
            );
    }

    return Stack(children: [
      Platform.isIOS ? ScrollsToTop(
        onScrollsToTop: _onScrollsToTop,
        child: Scaffold(
          // floatingActionButton: showChat
          //     ? SmartChat(
          //         margin: EdgeInsets.only(
          //           right:
          //               Provider.of<AppModel>(context, listen: false).langCode ==
          //                       'ar'
          //                   ? 30.0
          //                   : 0.0,
          //         ),
          //       )
          //     : Container(),\
          appBar: AppBar(
            title: Text(
              S.of(context).myWishList,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
            leading: GestureDetector(
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onTap: ()
                  // {
                  //   print(Provider.of<WishListModel>(context, listen: false)
                  //       .showTextAndButtonInWishList);
                  // }
                  =>
                  Navigator.pop(context),
            ),
            // actions: [getAction(Provider.of<WishListModel>(context))]
          ),
          // appBar: AppBar(
          //     elevation: 0.5,
          //     leading: widget.canPop
          //         ? IconButton(
          //             icon: const Icon(
          //               Icons.arrow_back_ios,
          //               size: 22,
          //
          //             ),
          //             onPressed: () {
          //               Navigator.pop(context);
          //             },
          //           )
          //         : Container(),
          //     title: Text(
          //       S.of(context).myWishList,
          //       style: TextStyle(color: Colors.white),
          //     ),
          //     backgroundColor: Theme.of(context).primaryColor),
          body: ListenableProvider.value(
              value: Provider.of<WishListModel>(context, listen: false),
              child: Consumer<WishListModel>(builder: (context, model, child) {
                if (model.products.isEmpty) {
                  return EmptyWishlist(
                    canPop: widget.canPop,
                    onShowHome: () {
                      MainTabControlDelegate.getInstance().changeTab("home");
                      if (widget.canPop) {
                        Navigator.of(context).pop();
                      }
                    },
                  );
                } else {
                  List<Product> wishListProduct = [];
                  for(var item in model.products) {
                    wishListProduct.add(item!);
                  }
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "${model.products.length} " +
                                          S.of(context).items,
                                      style: const TextStyle(
                                          fontSize: 14, color: kGrey400)),
                                  getAction(model)
                                ])),
                        getText(model),
                        const Divider(height: 1, color: kGrey200),
                        const SizedBox(height: 15),
                        Expanded(
                          child: ProductList(
                            products: wishListProduct,
                            onRefresh: () {},
                            onLoadMore: (){},
                            isFetching: false, // !allLoaded,
                            errMsg: "",
                            isEnd: true,
                            layout: "listTile", //layout, //fix for changing product layout
                            ratioProductImage: Provider.of<AppModel>(context, listen: false).ratioProductImage,
                            width: double.infinity,
                            showProgressBar: false,
                          )
                        )
                      ]);
                }
              })),
        ),
      ) : Scaffold(
        // floatingActionButton: showChat
        //     ? SmartChat(
        //         margin: EdgeInsets.only(
        //           right:
        //               Provider.of<AppModel>(context, listen: false).langCode ==
        //                       'ar'
        //                   ? 30.0
        //                   : 0.0,
        //         ),
        //       )
        //     : Container(),
        appBar: AppBar(
          title: Text(
            S.of(context).myWishList,
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
          leading: GestureDetector(
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onTap: ()
            // {
            //   print(Provider.of<WishListModel>(context, listen: false)
            //       .showTextAndButtonInWishList);
            // }
            =>
                Navigator.pop(context),
          ),
          // actions: [getAction(Provider.of<WishListModel>(context))]
        ),
        // appBar: AppBar(
        //     elevation: 0.5,
        //     leading: widget.canPop
        //         ? IconButton(
        //             icon: const Icon(
        //               Icons.arrow_back_ios,
        //               size: 22,
        //
        //             ),
        //             onPressed: () {
        //               Navigator.pop(context);
        //             },
        //           )
        //         : Container(),
        //     title: Text(
        //       S.of(context).myWishList,
        //       style: TextStyle(color: Colors.white),
        //     ),
        //     backgroundColor: Theme.of(context).primaryColor),
        body: ListenableProvider.value(
            value: Provider.of<WishListModel>(context, listen: false),
            child: Consumer<WishListModel>(builder: (context, model, child) {

              if (model.products.isEmpty) {
                return EmptyWishlist(
                  canPop: widget.canPop,
                  onShowHome: () {
                    MainTabControlDelegate.getInstance().changeTab("home");
                    if (widget.canPop) {
                      Navigator.of(context).pop();
                    }
                  },
                );
              } else {
                List<Product> wishListProduct = [];
                for(var item in model.products) {
                  wishListProduct.add(item!);
                }
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "${model.products.length} " +
                                        S.of(context).items,
                                    style: const TextStyle(
                                        fontSize: 14, color: kGrey400)),
                                getAction(model)
                              ])),
                      getText(model),
                      const Divider(height: 1, color: kGrey200),
                      const SizedBox(height: 15),
                      Expanded(
                        child: ProductList(
                          products: wishListProduct,
                          onRefresh: () {},
                          onLoadMore: (){},
                          isFetching: false, // !allLoaded,
                          errMsg: "",
                          isEnd: true,
                          layout: "listTile", //layout, //fix for changing product layout
                          ratioProductImage: Provider.of<AppModel>(context, listen: false).ratioProductImage,
                          width: double.infinity,
                          showProgressBar: false,
                        ),
                      )
                    ]);
              }
            })),
      ),
      if (kAdvanceConfig['EnableShoppingCart'] as bool)
        Align(
            child: ExpandingBottomSheet(hideController: _hideController),
            alignment: Alignment.bottomRight)
    ]);
  }
  Future<void> _onScrollsToTop(ScrollsToTopEvent event) async {
    _scrollController.animateTo(0, duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
  }
}

class EmptyWishlist extends StatelessWidget {
  final Function? onShowHome;
  final bool canPop;

  EmptyWishlist({this.onShowHome, this.canPop = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 80),
          Image.asset(
            'assets/images/empty_wishlist.png',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 20),
          Text(S.of(context).noFavoritesYet,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600
                  //color: Colors.black
                  ),
              textAlign: TextAlign.center),
          const SizedBox(height: 15),
          Text(S.of(context).emptyWishlistSubtitle,
              style: const TextStyle(
                fontSize: 14,
                // color: kGrey900
              ),
              textAlign: TextAlign.center),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: ButtonTheme(
                  height: 50,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  child: ElevatedButton(
                      child: Text(
                        S.of(context).startShopping.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: onShowHome as void Function()?),
                ),
              )
            ],
          ),
          // const SizedBox(height: 10),
          // Row(
          //   children: [
          //     Expanded(
          //       child: ButtonTheme(
          //         height: 50,
          //         shape: new RoundedRectangleBorder(
          //             borderRadius: new BorderRadius.circular(25.0)),
          //         child: RaisedButton(
          //           child: Text(S.of(context).searchForItems.toUpperCase()),
          //           color: kGrey200,
          //           textColor: kGrey400,
          //           onPressed: () {
          //             if (canPop) {
          //               Navigator.of(context).popAndPushNamed('/search');
          //             } else {
          //               MainTabControlDelegate.getInstance()
          //                   .changeTab("search");
          //             }
          //           },
          //         ),
          //       ),
          //     )
          //   ],
          // )
        ],
      ),
    );
  }
}

class WishlistItem extends StatelessWidget {
  WishlistItem({required this.product, this.onAddToCart, this.onRemove});

  final Product? product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final localTheme = Theme.of(context);
    final currency = Provider.of<CartModel>(context).currency;
    final currencyRate = Provider.of<AppModel>(context).currencyRate;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                RouteList.productDetail,
                arguments: product,
              );
            },
            child: Row(
              key: ValueKey(product!.id),
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: onRemove,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: constraints.maxWidth * 0.25,
                              height: constraints.maxWidth * 0.3,
                              child: Tools.image(
                                  url: product!.imageFeature,
                                  size: kSize.medium),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product!.name ?? '',
                                    style: localTheme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                      Tools.getPriceProduct(
                                          product, currencyRate, currency)!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              color: kGrey400, fontSize: 14)),
                                  const SizedBox(height: 10),
                                  if (!Config().isListingType())
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(25.0),
                                              side: BorderSide(
                                                // color: Colors.blue
                                                  color:
                                                  localTheme.primaryColor)),
                                          foregroundColor: Colors.white,
                                          backgroundColor: localTheme.primaryColor,
                                        ),
                                        child: Text(product!.status!
                                            ? S
                                                .of(context)
                                                .addToCart
                                                .toUpperCase()
                                            : S
                                                .of(context)
                                                .outOfStock
                                                .toUpperCase()),
                                        onPressed: product!.status!?onAddToCart:(){})
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          const Divider(color: kGrey200, height: 1),
          const SizedBox(height: 10.0),
        ]);
      },
    );
  }
}
