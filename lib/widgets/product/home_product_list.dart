import 'dart:async';
import 'dart:io';

import 'package:ctown/models/app_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../common/packages.dart' show StringExtensions;
import '../../common/tools.dart';
import '../../models/index.dart' show Product;
import '../../services/index.dart';
import "../backdrop/backdrop_constants.dart";
import '../common/no_internet_connection.dart';
import '../common/skeleton.dart';
import "../home/vertical/pinterest_card.dart";
import '../layout/adaptive.dart';
import 'product_list_tile.dart';

class HomeProductList extends StatefulWidget {
  final List<Product>? products;
  final bool? isFetching;
  final bool? isEnd;
  final String? errMsg;
  final width;
  final padding;
  final String? layout;
  final Function? onRefresh;
  final Function? onLoadMore;
  final double? ratioProductImage;
  final bool showProgressBar;
  final bool startTimer;

  HomeProductList({
    this.isFetching = false,
    this.isEnd = true,
    this.errMsg,
    this.products,
    this.width,
    this.padding = 8.0,
    this.onRefresh,
    this.onLoadMore,
    this.layout = "list",
    this.ratioProductImage,
    this.showProgressBar = false,
    this.startTimer = false,
  });

  @override
  _HomeProductListState createState() => _HomeProductListState();
}

class _HomeProductListState extends State<HomeProductList> {
  late RefreshController _refreshController;
  final _scrollController = ScrollController();
  final _listScrollController = ScrollController();

  List<Product> emptyList = [
    Product.empty('1'),
  ];

  @override
  initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
  }

  _onRefresh() async {
    if (!widget.isFetching!) {
      widget.onRefresh!();
    }
  }

  _onLoading() async {
    if (!widget.isFetching!) {
      widget.onLoadMore!();
    }
  }

  Future<void> _onScrollsToTop(ScrollsToTopEvent event) async {
    if(widget.layout == "listTile") {
      _listScrollController.animateTo(0, duration: const Duration(milliseconds: 1000), curve: Curves.easeInOut);
    }
    else {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 1000), curve: Curves.easeInOut);
    }
  }

  @override
  void didUpdateWidget(HomeProductList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isFetching == false && oldWidget.isFetching == true) {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = Tools.isTablet(MediaQuery.of(context));

    var widthScreen = widget.width != null ? widget.width : screenSize.width;
    double? widthContent = screenSize.width;
    var crossAxisCount = 1;
    var childAspectRatio = 0.8;

    if (isDisplayDesktop(context)) {
      widthScreen -= BackdropConstants.drawerWidth;
    }
    if (widget.layout == "card") {
      crossAxisCount = isTablet ? 2 : 1;
      widthContent = isTablet ? widthScreen / 2 : widthScreen; //one column
    } else if (widget.layout == "columns") {
      crossAxisCount = isTablet ? 4 : 3;
      widthContent =
      isTablet ? widthScreen / 4 : (widthScreen / 3); //three columns
    } else if (widget.layout == "listTile") {
      crossAxisCount = isTablet ? 2 : 1;
      widthContent = widthScreen; // one column
    } else {
      /// 2 columns on mobile, 3 columns on ipad
      crossAxisCount = isTablet ? 3 : 2;
      //layout is list
      widthContent =
      isTablet ? widthScreen / 3 : (widthScreen / 2); //two columns
    }
    childAspectRatio = (isTablet ? 0.94 : 1) *
        widthContent! /
        (widthContent * (widget.ratioProductImage ?? 1.2) + 119);

    final hasNoProduct = widget.products == null || widget.products!.isEmpty;

    final productsList =
    hasNoProduct && widget.isFetching! ? emptyList : widget.products;

    if (hasNoProduct &&
        widget.errMsg != null &&
        widget.errMsg!.isNoInternetError) {
      return NoInternetConnection(onRefresh: _onRefresh);
    }

    if(widget.isFetching!) {
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          height: 300,
          width: 220,
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.all(2),
          // margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(
              color: Colors.black12,
              width: 0.4,
            ),
            boxShadow: [
              const BoxShadow(
                color: Colors.black12,
                // offset: Offset(
                //   3.0,
                //   3.0,
                // ),
                blurRadius: 5.0,
                spreadRadius: 2.0,
              ), //BoxShadow
              const BoxShadow(
                color: Colors.white,
                offset: Offset(0.0, 0.0),
                blurRadius: 0.0,
                spreadRadius: 0.0,
              ), //BoxShadow
            ],
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            //color: Colors.grey[50]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(
                height: 200,
                width: 220,
              ),
              const SizedBox(height: 30,),
              Text(Provider.of<AppModel>(context, listen: false).langCode == "en"
                  ?"Loading..." : "تحميل",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                )
                    .apply(fontSizeFactor: 0.8),)
            ],
          ),
        ),
      );
    }

    if (productsList == null || productsList.isEmpty) {
      return Center(
        child:

        /*  Column(
          children: [
            const SizedBox(height: 80),
            Image.asset(
              // 'assets/images/default-store-banner.png',
              'assets/images/empty_product.png',
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.width * 0.9 * 0.6,
            ),
            const SizedBox(height: 20),*/
        Text(
          // S.of(context).noProduct,
          Provider.of<AppModel>(context, listen: false).langCode == "en"
              ? "Oops! No product found..."
              : "لم يتم العثور على منتج",
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        // ],
        // ),
      );
    }

    Widget typeList = const SizedBox();

    if (widget.layout != 'pinterest') {
      if (widget.layout == 'listTile') {
        typeList = buildListView(products: productsList);
      } else {
        //          try{
        //   Comparator<Product> qtyComparator = (a, b) => b.qty.compareTo(a.qty);

        // productsList.sort(qtyComparator);
        //       }catch(e){
        //         print(e);
        //       }
        typeList = buildGridViewProduct(
          childAspectRatio: childAspectRatio,
          crossAxisCount: crossAxisCount,
          products: productsList,
          widthContent: widthContent,
        );
      }
    } else {
      typeList = buildStaggeredGridView(products: productsList);
    }

    return Platform.isIOS ? ScrollsToTop(
      onScrollsToTop: _onScrollsToTop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SmartRefresher(
          header: MaterialClassicHeader(
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          enablePullDown: true,
          enablePullUp: !widget.isEnd!,
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: typeList,
        ),
      ),
    ) : SmartRefresher(
      header: MaterialClassicHeader(
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      enablePullDown: true,
      enablePullUp: !widget.isEnd!,
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: typeList,
    );
  }

  Widget buildGridViewProduct({
    required int crossAxisCount,
    required double childAspectRatio,
    double? widthContent,
    required List<Product> products,
  }) {
    return WaterfallFlow.builder(
      gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        // childAspectRatio: childAspectRatio,
      ),
      controller: _scrollController,
      cacheExtent: 500.0,
      itemCount: products.length,
      itemBuilder: (context, i) {
        return Services().widget?.renderProductCardView(
          item: products[i],
          showCart: widget.layout != "columns",
          showHeart: true,
          width: widthContent,
          ratioProductImage: widget.ratioProductImage,
          marginRight: widget.layout == "card" ? 0.0 : 10.0,
          showProgressBar: widget.showProgressBar,
        ) ?? const SizedBox.shrink();
      },
    );
  }

  Widget buildStaggeredGridView({
    required List<Product> products,
  }) {
    return StaggeredGrid.count(
        crossAxisCount: 4,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: List.generate(products.length, (index) {
          return StaggeredGridTile.fit(
              crossAxisCellCount: 2,
              child: PinterestCard(
                item: products[index],
                showOnlyImage: false,
                width: MediaQuery.of(context).size.width / 2,
                showCart: widget.layout != "columns",
              )
          );
        })
    );
  }
  Widget buildListView({
    required List<Product> products,
  }) {
    return ListView.builder(
      controller: _listScrollController,
      itemCount: products.length,
      cacheExtent: 500,
      itemBuilder: (_, index) => ProductItemTileView(
        item: products[index],
        padding: const EdgeInsets.only(),
        showProgressBar: widget.showProgressBar,
      ),
    );
  }
}
