import 'dart:async';

import 'package:ctown/frameworks/magento/services/magento.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
//import 'vertical_simple_list.dart';
import '../../generated/l10n.dart';
//import 'package:provider/provider.dart';

import '../../models/index.dart'
    show
        AppModel,
        Category,
        CategoryModel,
        FilterAttributeModel,
        Product,
        ProductModel;
import '../../services/index.dart';
// import '../../widgets/asymmetric/asymmetric_view.dart';
import '../../widgets/backdrop/backdrop_work.dart';
import '../../widgets/backdrop/deals_backdrop_menu.dart';
import '../../widgets/product/product_list.dart';
import '../products/products_backdrop.dart';

class NewArrival extends StatefulWidget {
  final config;

  NewArrival({Key? key, this.config}) : super(key: key);

  @override
  _NewArrivalState createState() => _NewArrivalState();
}

class _NewArrivalState extends State<NewArrival>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List data = ['weekly', 'monthly'];

  final Services _service = Services();
  List<Product> _products = [];
  bool canLoad = true;
  int _page = 0;
  bool isFetching = false;
  List<int> selectedCategory = [];
  bool? featured;
  bool? onSale;
  Future? categoryLists;
  List<String?> newCategoryIdList = ["-1"];
  late List<Category> categories;
  Timer? _loadingTimer;
  @override
  void initState() {
    super.initState();
    _getCategoryList(Provider.of<AppModel>(context, listen: false).langCode);
    _loadProduct();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    if (_loadingTimer != null && _loadingTimer!.isActive) {
      _loadingTimer!.cancel();
    }
    _controller.dispose();
    super.dispose();
  }

  void _startLoadingTimer() {
    const interval =
        Duration(milliseconds: 1500); // Define the interval duration
    _loadingTimer = Timer.periodic(interval, (_) async {
      if (mounted) {
        if (!isFetching) {
          await _loadMore();
        }
      }
    });
  }

  _getCategoryList(lang) async {
    categoryLists = MagentoApi().getDealsCategoryList(lang);
  }

  _loadProduct() async {
    //var config = widget.config;
    _page = _page + 1;
    // config['page'] = _page;
    setState(() {
      isFetching = true;
    });
    if (!canLoad) return;
    List newProducts = [];
    if (selectedCategory.isNotEmpty) {
      for (var catergory in selectedCategory) {
        newProducts.addAll(await MagentoApi().newArrival(
            config: widget.config,
            page: _page,
            lang: Provider.of<AppModel>(context, listen: false).langCode));
      }
    } else {
      newProducts.addAll(await MagentoApi().newArrival(
          config: widget.config,
          page: _page,
          lang: Provider.of<AppModel>(context, listen: false).langCode));
    }
    if (newProducts.isEmpty) {
      setState(() {
        canLoad = false;
      });
      if (_loadingTimer != null && _loadingTimer!.isActive) {
        _loadingTimer?.cancel();
      }
    }
    else {
      _startLoadingTimer();
    }
    setState(() {
      isFetching = false;
      _products = [..._products, ...newProducts];
    });
  }

  _loadMore() async {
    //var config = widget.config;
    _page = _page + 1;
    // config['page'] = _page;
    if (!canLoad) return;
    List newProducts = [];
    if (selectedCategory.isNotEmpty) {
      for (var catergory in selectedCategory) {
        newProducts.addAll(await MagentoApi().newArrival(
            config: widget.config,
            page: _page,
            lang: Provider.of<AppModel>(context, listen: false).langCode));
      }
    } else {
      newProducts.addAll(await MagentoApi().newArrival(
          config: widget.config,
          page: _page,
          lang: Provider.of<AppModel>(context, listen: false).langCode));
    }
    if (newProducts.isEmpty) {
      if (_loadingTimer != null && _loadingTimer!.isActive) {
        _loadingTimer?.cancel();
      }
      setState(() {
        canLoad = false;
      });
    }
    setState(() {
      isFetching = false;
      _products = [..._products, ...newProducts];
    });
  }

  _onRefresh() async {
    _page = 1;
    setState(() {
      isFetching = true;
      canLoad = true;
      _products.clear();
    });
    if (_loadingTimer != null && _loadingTimer!.isActive) {
      _loadingTimer?.cancel();
    }
    List newProducts = [];
    if (selectedCategory.isNotEmpty) {
      for (var catergory in selectedCategory) {
        newProducts.addAll(await MagentoApi().newArrival(
            config: widget.config,
            page: _page,
            lang: Provider.of<AppModel>(context, listen: false).langCode));
      }
    } else {
      newProducts.addAll(await MagentoApi().newArrival(
          config: widget.config,
          page: _page,
          lang: Provider.of<AppModel>(context, listen: false).langCode));
    }
    if (newProducts.isEmpty) {
      setState(() {
        canLoad = false;
      });
    }
    else {
      _startLoadingTimer();
    }
    setState(() {
      isFetching = false;
      _products = [/*..._products,*/ ...newProducts];
    });
  }

  Future<void> onFilter(
      {minPrice,
      maxPrice,
      required List<String?> categoryIdList,
      // categoryId,
      tagId,
      attribute,
      currentSelectedTerms}) async {
    printLog('categoryIdList: $categoryIdList');
    _controller.forward();
    final filterAttr =
        Provider.of<FilterAttributeModel>(context, listen: false);
    String terms = '';

    if (currentSelectedTerms != null) {
      for (int i = 0; i < currentSelectedTerms.length; i++) {
        if (currentSelectedTerms[i]) {
          terms += '${filterAttr.lstCurrentAttr[i].id},';
        }
      }
    }
    selectedCategory.clear();
    categoryIdList.forEach((element) {
      selectedCategory.add(int.parse(element!));
    });
    _onRefresh();
  }

  void onSort(order) async {
    List<Product> productList = [];
    if (order == "date") {
      featured = null;
      onSale = null;
    } else {
      featured = order == "featured";
      onSale = order == "on_sale";
    }
    _page = 1;
    setState(() {
      isFetching = true;
      _products.clear();
    });
    List newProducts = [];
    if (selectedCategory.isNotEmpty) {
      for (var catergory in selectedCategory) {
        productList = [];
        productList = await MagentoApi().newArrival(
            config: widget.config,
            page: _page,
            lang: Provider.of<AppModel>(context, listen: false).langCode);
        newProducts.addAll(productList);
      }
    } else {
      productList = [];
      productList = await MagentoApi().newArrival(
          config: widget.config,
          page: _page,
          lang: Provider.of<AppModel>(context, listen: false).langCode);
      newProducts.addAll(productList);
    }
    if (newProducts.isEmpty || productList.isEmpty) {
      setState(() {
        canLoad = false;
      });
    }
    setState(() {
      isFetching = false;
      _products = [/*..._products,*/ ...newProducts];
    });
  }

  Widget renderCategoryAppbar() {
    final catModel = Provider.of<CategoryModel>(context);

    return FutureBuilder(
      future: categoryLists,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: kLoadingWidget(context));
        }

        if (snapshot.data != null && catModel.categories != null) {
          categories = catModel.categories!
              .where((item) =>
                  item.parent == '0' && snapshot.data.contains(item.id))
              .toList();
          return Container(
            color: Theme.of(context).primaryColor,
            height: 50,
            child: const Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // children: _renderListCategory,
                ),
              ),
            ),
          );
        }

        return Container();
      },
    );
  }

  Widget _renderItemCategory(
      {String? categoryId, required String categoryName}) {
    return GestureDetector(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
            color: newCategoryIdList.first == categoryId
                ? Colors.white24
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: newCategoryIdList.first == categoryId
                    ? Colors.yellow
                    : Colors.transparent)),
        child: Text(
          categoryName.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      onTap: () {
        _page = 1;
        if (categoryName == S.of(context).seeAll) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => super.widget));
          return;
        }
        setState(() {
          newCategoryIdList.first = categoryId;
          onFilter(
            categoryIdList: newCategoryIdList.first == "-1"
                ? categories.map((e) => e.id).toList()
                : newCategoryIdList,
            // tagId: newTagId,
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = S.of(context).products;
    final layout =
        Provider.of<AppModel>(context, listen: false).productListLayout;

    final ratioProductImage =
        Provider.of<AppModel>(context, listen: false).ratioProductImage;

    final isListView = layout != 'horizontal';

    /// load the product base on default 2 columns view or AsymmetricView
    /// please note that the AsymmetricView is not ready support for loading per page.
    backdrop({
      allLoaded,
      products,
      isFetching,
      errMsg,
      isEnd,
      width,
    }) =>
        ProductBackdrop(
          backdrop: CustomBackdrop2(
            frontLayer:
            ListenableProvider.value(
              value: Provider.of<AppModel>(context),
              child: Consumer<AppModel>(
                builder: (context, value, child) => ProductList(
                  products: products,
                  onRefresh: _onRefresh,
                  onLoadMore: _loadMore,
                  isFetching: isFetching, // !allLoaded,
                  errMsg: errMsg,
                  isEnd: isEnd,
                  layout: "list", //layout, //fix for changing product layout
                  ratioProductImage: ratioProductImage,
                  width: width,
                ),
              ),
            ),
            listViewWidget: ListenableProvider.value(
              value: Provider.of<AppModel>(context),
              child: Consumer<AppModel>(
                builder: (context, value, child) => ProductList(
                  products: products,
                  onRefresh: _onRefresh,
                  onLoadMore: _loadMore,
                  isFetching: isFetching, // !allLoaded,
                  errMsg: errMsg,
                  isEnd: isEnd,
                  layout: "listTile", //layout, //fix for changing product layout
                  ratioProductImage: ratioProductImage,
                  width: width,
                ),
              ),
            ),
            backLayer: DealsBackdropMenu(
              onFilter: onFilter,
            ),
            frontTitle: Text(title),
            backTitle: Text(
              S.of(context).filter,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            controller: _controller,
            onSort: onSort,
          ),
        );

    Widget buildMain = Scaffold(
      body: LayoutBuilder(
        builder: (context, constraint) {
          return FractionallySizedBox(
              widthFactor: 1.0,
              child: backdrop(
                  //allLoaded: value.allLoaded,
                  products: _products,
                  isFetching: isFetching,
                  //errMsg: value.errMsg,
                  isEnd: !canLoad,
                  width: constraint.maxWidth));
        },
      ),
    );

    return kIsWeb
        ? WillPopScope(
            onWillPop: () async {
              eventBus.fire(const EventOpenCustomDrawer());
              // LayoutWebCustom.changeStateMenu(true);
              Navigator.of(context).pop();
              return false;
            },
            child: buildMain,
          )
        : buildMain;
  }
}
