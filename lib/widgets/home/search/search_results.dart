import 'dart:async';

import 'package:ctown/common/constants.dart';
import 'package:ctown/common/constants/general.dart';
import 'package:ctown/frameworks/magento/services/magento.dart';
import 'package:ctown/screens/products/products_backdrop.dart';
import 'package:ctown/widgets/backdrop/backdrop_work.dart';
import 'package:ctown/widgets/home/search/search_backdrop_menu.dart';
import 'package:ctown/widgets/product/product_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/constants/loading.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart'
    show
        AppModel,
        Category,
        CategoryModel,
        FilterAttributeModel,
        Product,
        SearchModel;
import '../../../services/index.dart';

class SearchResults extends StatefulWidget {
  final String? name;
  final bool? isBarcode;
  String? cateId;
  String? searchLang;
  String? searchString;
  String? from;
  // final List<Product> products;

  SearchResults(
      {required this.name, this.isBarcode, this.cateId, this.searchLang, this.searchString, this.from/*, this.products*/});

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults>
    with SingleTickerProviderStateMixin {
  //final _refreshController = RefreshController();
  final _service = Services();

  List<Product> _products = [];
  int _page = 0;
  //bool _isEnd = false;
  bool canLoad = true;
  bool isFetching = false;
  late AnimationController _controller;
  Future? categoryLists;
  late List<Category> categories;
  List<String?> newCategoryIdList = ["-1"];
  int? selectedCategory;
  bool initialLoad = true;
  Timer? _loadingTimer;

  Future<void> _loadProduct(bool? isBarcode) async {
    if (!canLoad) return;
    _page = _page + 1;
    setState(() {
      isFetching = true;
    });

    List newProducts = [];

    if (selectedCategory != null) {
      newProducts.addAll(await _service.searchProducts(
          name: widget.name,
          categoryId: selectedCategory,
          page: _page,
          lang: widget.searchLang ?? Provider.of<AppModel>(context, listen: false).langCode,
          isBarcode: isBarcode));
    } else {
      newProducts.addAll(await _service.searchProducts(
          name: widget.name,
          page: _page,
          lang: widget.searchLang ?? Provider.of<AppModel>(context, listen: false).langCode,
          isBarcode: isBarcode));
      if(newProducts.length == 0) {
        newProducts.addAll(await _service.searchProducts(
            name: widget.name,
            page: _page,
            categoryId: widget.cateId ?? "",
            lang: widget.searchLang ?? Provider.of<AppModel>(context, listen: false).langCode,
            isBarcode: isBarcode));
      }
    }

    if (newProducts.isEmpty || newProducts.length == 0) {
      if(!initialLoad && _page > 1) {
        setState(() {
          canLoad = false;
          _loadingTimer?.cancel();
        });
      }
    }
    setState(() {
      isFetching = false;
      if(!initialLoad && _page > 1) {
        _products = [..._products, ...newProducts];
      }
    });
  }


  Future<void> _initialLoad(bool? isBarcode) async {
    if (!canLoad) return;
    _page = _page + 1;
    if(_page == 1) {
      setState(() {
        isFetching = true;
      });
    }
    List newProducts = [];

    if (selectedCategory != null) {
      newProducts.addAll(await _service.searchProducts(
          name: widget.name,
          categoryId: selectedCategory,
          page: _page,
          lang: widget.searchLang ?? Provider.of<AppModel>(context, listen: false).langCode,
          isBarcode: isBarcode));
    } else {
      newProducts.addAll(await _service.searchProducts(
          name: widget.name,
          page: _page,
          lang: widget.searchLang ?? Provider.of<AppModel>(context, listen: false).langCode,
          isBarcode: isBarcode));
      if(newProducts.length == 0) {
        newProducts.addAll(await _service.searchProducts(
            name: widget.name,
            page: _page,
            categoryId: widget.cateId ?? "",
            lang: widget.searchLang ?? Provider.of<AppModel>(context, listen: false).langCode,
            isBarcode: isBarcode));
      }
    }

    if (newProducts.isEmpty || newProducts.length == 0) {
      setState(() {
        canLoad = false;
      });
    }
    setState(() {
      _products.clear();
      _products = [...newProducts];
      isFetching = false;
      initialLoad = false;
    });
    _startLoadingTimer();
  }

  _onRefresh2() {
    setState(() {
      _loadingTimer?.cancel();
      _page = 0;
      _products = [];
      canLoad = true;
      initialLoad = true;
    });
    _onRefresh();
  }

  Future<void> _onRefresh() async {
    await _initialLoad(widget.isBarcode);
  }

  // Future<void> _onLoading() async {
  //   if (_isEnd == false) {
  //     _page++;
  //     await _loadProduct(widget.isBarcode);
  //   }
  //   // _refreshController.loadComplete();
  // }

  Future<void> onFilter(
      {minPrice,
      maxPrice,
      List<String?>? categoryIdList,
      // categoryId,
      tagId,
      attribute,
      currentSelectedTerms}) async {
    printLog('categoryIdList: $categoryIdList');
    _controller.forward();

    //final productModel = Provider.of<ProductModel>(context, listen: false);
    final filterAttr =
        Provider.of<FilterAttributeModel>(context, listen: false);
    //newTagId = tagId;
    // this.minPrice = minPrice;
    // this.maxPrice = maxPrice;
    // if (attribute != null && !attribute.isEmpty) this.attribute = attribute;
    String terms = '';

    if (currentSelectedTerms != null) {
      for (int i = 0; i < currentSelectedTerms.length; i++) {
        if (currentSelectedTerms[i]) {
          terms += '${filterAttr.lstCurrentAttr[i].id},';
        }
      }
    }
    // selectedCategory.clear();
    // categoryIdList.forEach((element) {
    //   selectedCategory.add(int.parse(element));
    // });
    selectedCategory = categoryIdList != null && categoryIdList.isNotEmpty
        ? int.parse(categoryIdList[0]!)
        : null;
    await _initialLoad(widget.isBarcode);
    // productModel.setProductsList(List<Product>());
    // await loadCategoriesList(categoryIdList, productModel, tagId, terms);
  }

  @override
  void initState() {
    super.initState();
    _getCategoryList(widget.searchString);
    _initialLoad(widget.isBarcode);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1.0,
    );

    // _products = widget.products;
  }

  void _startLoadingTimer() {
    const interval = Duration(milliseconds: 1000); // Define the interval duration
    _loadingTimer = Timer.periodic(interval, (_) async {
      if (!isFetching) {
        _loadProduct(widget.isBarcode);
      }
    });
  }

  _getCategoryList(String? searchStr) async {
    categoryLists = MagentoApi().getSearchCategoryList(
        searchStr, widget.searchLang ?? Provider.of<AppModel>(context, listen: false).langCode);
    printLog("=========categories${categoryLists}");
  }

  @override
  void didUpdateWidget(SearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    // setState(() {
    //   _products = widget.products;
    // });
    if (oldWidget.name != widget.name) {
      _initialLoad(widget.isBarcode);
    }
  }

  void dispose() {
    //_refreshController.dispose();
    _controller.dispose();
    _loadingTimer?.cancel();
    super.dispose();
  }

  Widget renderCategoryAppbar() {
    final catModel = Provider.of<CategoryModel>(context);
    final langCode = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
    // newCategoryIdList.first = "-1";
    // String parentCategory = newCategoryIdList.first;
    // if (category.categories != null && category.categories.isNotEmpty) {
    //   parentCategory = getParentCategories(category.categories, parentCategory) ?? parentCategory;
    //   final listSubCategory = getSubCategories(category.categories, parentCategory);

    //   if (listSubCategory.length < 2) return null;

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

          List<Widget> _renderListCategory = [];
          _renderListCategory.add(const SizedBox(width: 10));

          _renderListCategory.add(_renderItemCategory(
              categoryId: "-1", categoryName: langCode == "en" ? "See All" : "اظهار الكل"));

          _renderListCategory.addAll([
            for (var category in categories)
              _renderItemCategory(
                  categoryId: category.id, categoryName: category.name!)
          ]);

          return Container(
            color: Theme.of(context).primaryColor,
            height: 40,
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _renderListCategory,
                ),
              ),
            ),
          );
        }

        return Container();
      },
    );
  }

  Widget _renderItemCategory({String? categoryId, required String categoryName}) {
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
                color: newCategoryIdList.first == categoryId ?
                Colors.yellow : Colors.transparent
            )
        ),
        child: Text(
          categoryName.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w500,
            color: Colors.white
          ),
        ),
      ),
      onTap: () {
        // Provider.of<ProductModel>(context, listen: false).getProductsList(
        //   categoryId: categoryId,
        //   page: _page,
        //   onSale: onSale,
        //   lang: Provider.of<AppModel>(context, listen: false).langCode,
        //   // tagId: newTagId,
        // );

        if(!initialLoad) {
          setState(() {
            _loadingTimer?.cancel();
            _page = 0;
            _products = [];
            canLoad = true;
            initialLoad = true;
            newCategoryIdList.first = categoryId;
            onFilter(
              // minPrice: minPrice,
              // maxPrice: maxPrice,
              // categoryIdList: newCategoryIdList.first == "-1" ? categories.map((e) => e.id).toList() : newCategoryIdList,
              categoryIdList:
              newCategoryIdList.first == "-1" ? null : newCategoryIdList,
              // tagId: newTagId,
            );
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout =
        Provider.of<AppModel>(context, listen: false).productListLayout;

    final ratioProductImage =
        Provider.of<AppModel>(context, listen: false).ratioProductImage;

    final isListView = layout != 'horizontal';

    /// load the product base on default 2 columns view or AsymmetricView
    /// please note that the AsymmetricView is not ready support for loading per page.
    final backdrop = ({
      allLoaded,
      products,
      isFetching,
      errMsg,
      isEnd,
      width,
    }) =>
        ProductBackdrop(
          backdrop: CustomBackdrop(
              frontLayer:
                  //  isListView
                  //     ?
              ListenableProvider.value(
                value: Provider.of<AppModel>(context),
                child: Consumer<AppModel>(
                  builder: (context, value, child) => ProductList(
                    products: products,
                    onRefresh: _onRefresh2,
                    onLoadMore: () => canLoad ? _loadProduct(widget.isBarcode) : null,
                    isFetching: isFetching, // !allLoaded,
                    errMsg: errMsg,
                    isEnd: isEnd,
                    layout: "list", //layout, //fix for changing product layout
                    ratioProductImage: ratioProductImage,
                    width: width,
                    startTimer: true,
                    //showProgressBar: widget.showCountdown,
                  ),
                ),
              ),
              // : AsymmetricView(
              //     products: products,
              //     isFetching: isFetching, // !allLoaded,
              //     isEnd: isEnd,
              //     onLoadMore: () => _loadProduct(widget.isBarcode),
              //     width: width,
              //   )
              listViewWidget: ListenableProvider.value(
                value: Provider.of<AppModel>(context),
                child: Consumer<AppModel>(
                  builder: (context, value, child) => ProductList(
                    products: products,
                    onRefresh: _onRefresh2,
                    onLoadMore: () => canLoad ? _loadProduct(widget.isBarcode) : null,
                    isFetching: isFetching, // !allLoaded,
                    errMsg: errMsg,
                    isEnd: isEnd,
                    layout: "listTile", //layout, //fix for changing product layout
                    ratioProductImage: ratioProductImage,
                    width: width,
                    startTimer: true,
                    //showProgressBar: widget.showCountdown,
                  ),
                ),
              ),
              backLayer: SearchBackdropMenu(
                onFilter: onFilter,
                searchStr: widget.name,
                // categoryIdList: newCategoryIdList,
                // tagId: newTagId,
              ),
              frontTitle: Text(Provider.of<AppModel>(context, listen: false).langCode== "en" ?
                  "Search results" : "نتائج البحث"),
              backTitle: Text(
                S.of(context).filter,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              controller: _controller,
              // onSort: onSort,
              appbarCategory: renderCategoryAppbar()),
        );

    Widget buildMain = Scaffold(
      body: Container(
        child: LayoutBuilder(
          builder: (context, constraint) {
            return FractionallySizedBox(
                widthFactor: 1.0,
                child: backdrop(
                    //allLoaded: value.allLoaded,
                    products: _products,
                    isFetching: initialLoad,
                    //errMsg: value.errMsg,
                    isEnd: !canLoad,
                    width: constraint.maxWidth));
          },
        ),
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
