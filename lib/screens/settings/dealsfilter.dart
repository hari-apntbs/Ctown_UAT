/*
*  deals_widget.dart
*  AMCS-Supernova
*
*  Created by InstaSoft Inc.
*  Copyright © 2018 InstaSoft Inc. All rights reserved.
    */

/*
*  deals_widget.dart
*  AMCS-Supernova
*
*  Created by InstaSoft Inc.
*  Copyright © 2018 InstaSoft Inc. All rights reserved.
    */
/*
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
import '../../widgets/appbar.dart';
// import '../../widgets/asymmetric/asymmetric_view.dart';
import '../../widgets/backdrop/backdrop_work.dart';
import '../../widgets/backdrop/deals_backdrop_menu.dart';
import '../../widgets/product/product_list.dart';
import '../products/products_backdrop.dart';

class DealsScreen extends StatefulWidget {
  //final config;

  DealsScreen({Key key}) : super(key: key);

  @override
  _DealsScreenState createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  final Services _service = Services();
  List<Product> _products = [];
  bool canLoad = true;
  int _page = 0;
  bool isFetching = false;
  List<int> selectedCategory = List();
  bool featured;
  bool onSale;
  Future categoryLists;
  List<String> newCategoryIdList = ["-1"];
  List<Category> categories;
  @override
  void initState() {
    super.initState();
    _getCategoryList();
    _loadProduct();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1.0,
    );
  }

  _getCategoryList() async {
    categoryLists = MagentoApi().getDealsCategoryList();
  }

  _loadProduct() async {
    //var config = widget.config;
    _page = _page + 1;
    // config['page'] = _page;
    setState(() {
      isFetching = true;
    });
    if (!canLoad) return;
    List newProducts = List();
    if (selectedCategory.isNotEmpty) {
      for (var catergory in selectedCategory) {
        newProducts.addAll(await _service.getProductsonDeal2(
          page: _page,
          categoryId: catergory,
        ));
      }
    } else {
      newProducts.addAll(await _service.getProductsonDeal2(
        page: _page,
      ));
    }
    if (newProducts.isEmpty || newProducts.length < ApiPageSize) {
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
    //var config = widget.config;
    _page = 1;
    // config['page'] = _page;
    setState(() {
      isFetching = true;
      _products.clear();
    });
    //if (!canLoad) return;
    List newProducts = List();
    if (selectedCategory.isNotEmpty) {
      for (var catergory in selectedCategory) {
        newProducts.addAll(await _service.getProductsonDeal2(
          page: _page,
          categoryId: catergory,
        ));
      }
    } else {
      newProducts.addAll(await _service.getProductsonDeal2(
        page: _page,
      ));
    }
    if (newProducts.isEmpty || newProducts.length < ApiPageSize) {
      setState(() {
        canLoad = false;
      });
    }
    setState(() {
      isFetching = false;
      _products = [/*..._products,*/ ...newProducts];
    });
  }

  Future<void> onFilter(
      {minPrice,
      maxPrice,
      List<String> categoryIdList,
      // categoryId,
      tagId,
      attribute,
      currentSelectedTerms}) async {
    // printLog('categoryIdList: $categoryIdList');
    _controller.forward();

    //final productModel = Provider.of<ProductModel>(context, listen: false);
    final filterAttr =
        Provider.of<FilterAttributeModel>(context, listen: false);
    //newTagId = tagId;
    // this.minPrice = minPrice;
    // this.maxPrice = maxPrice;
    // if (attribute != null && !attribute.isEmpty) this.attribute = attribute;
    String terms = '';

    print("categoryList iid ${categoryIdList}");
    if (currentSelectedTerms != null) {
      for (int i = 0; i < currentSelectedTerms.length; i++) {
        if (currentSelectedTerms[i]) {
          terms += '${filterAttr.lstCurrentAttr[i].id},';
        }
      }
    }

    selectedCategory.clear();
    categoryIdList.forEach((element) {
      selectedCategory.add(int.parse(element));
    });
    //selectedCategory = categoryIdList.isNotEmpty ? int.parse(categoryIdList[0]) : null;

    _onRefresh();
    // productModel.setProductsList(List<Product>());
    // await loadCategoriesList(categoryIdList, productModel, tagId, terms);
  }

  // Future loadCategoriesList(List categoryIdList, ProductModel productModel, tagId, terms) async {
  //   productModel.setCatIdListLen(categoryIdList.length);
  //   categoryIdList.forEach((catId) async {
  //     printLog('catId: $catId');
  //     await productModel.getProductsList(
  //         categoryId: catId,
  //         // categoryIdList: categoryIdList == -1 ? null : categoryIdList,
  //         // minPrice: minPrice,
  //         // maxPrice: maxPrice,
  //         page: 1,
  //         lang: Provider.of<AppModel>(context, listen: false).langCode,
  //         // orderBy: orderBy,
  //         // order: orDer,
  //         // featured: featured,
  //         // onSale: onSale,
  //         // tagId: tagId,
  //         // attribute: attribute,
  //         attributeTerm: terms.isEmpty ? null : terms);
  //   });
  //   return;
  // }

  void onSort(order) async {
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
    List newProducts = List();
    if (selectedCategory.isNotEmpty) {
      for (var catergory in selectedCategory) {
        newProducts.addAll(await _service.getProductsonDeal2(
          page: _page,
          categoryId: catergory,
          orderBy: 'date',
          order: 'desc',
          featured: featured,
          onSale: onSale,
        ));
      }
    } else {
      newProducts.addAll(await _service.getProductsonDeal2(
        page: _page,
        orderBy: 'date',
        order: 'desc',
        featured: featured,
        onSale: onSale,
      ));
    }
    if (newProducts.isEmpty || newProducts.length < ApiPageSize) {
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
    // newCategoryIdList.first = "-1";
    // String parentCategory = newCategoryIdList.first;
    // if (category.categories != null && category.categories.isNotEmpty) {
    //   parentCategory = getParentCategories(category.categories, parentCategory) ?? parentCategory;
    //   final listSubCategory = getSubCategories(category.categories, parentCategory);

    //   if (listSubCategory.length < 2) return null;

    return FutureBuilder(
      future: categoryLists,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: kLoadingWidget(context));
        }

        if (snapshot.data != null && catModel.categories != null) {
          categories = catModel.categories
              .where((item) =>
                  item.parent == '0' && snapshot.data.contains(item.id))
              .toList();

          List<Widget> _renderListCategory = List();
          _renderListCategory.add(const SizedBox(width: 10));

          _renderListCategory.add(_renderItemCategory(
              categoryId: "-1", categoryName: S.of(context).seeAll));

          _renderListCategory.addAll([
            for (var category in categories)
              _renderItemCategory(
                  categoryId: category.id, categoryName: category.name)
          ]);

          return Container(
            color: Theme.of(context).primaryColor,
            height: 50,
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

  Widget _renderItemCategory({String categoryId, String categoryName}) {
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
        ),
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
        // Provider.of<ProductModel>(context, listen: false).getProductsList(
        //   categoryId: categoryId,
        //   page: _page,
        //   onSale: onSale,
        //   lang: Provider.of<AppModel>(context, listen: false).langCode,
        //   // tagId: newTagId,
        // );
        if (categoryName == S.of(context).seeAll) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => super.widget));
          return;
        }
        setState(() {
          newCategoryIdList.first = categoryId;

          //
          //
          //
          onFilter(
            // minPrice: minPrice,
            // maxPrice: maxPrice,

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
    //final product = Provider.of<ProductModel>(context, listen: false);
    final title = S.of(context).products;
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
    }) {
      // print("body scaffold");
      return ProductBackdrop(
        backdrop: CustomBackdrop(
            frontLayer:
                // isListView
                //     ?
                ListenableProvider.value(
              value: Provider.of<AppModel>(context),
              child: Consumer<AppModel>(builder: (context, value, child) {
                return ProductList(
                  products: products,
                  onRefresh: _onRefresh,
                  onLoadMore: _loadProduct,
                  isFetching: isFetching, // !allLoaded,
                  errMsg: errMsg,
                  isEnd: isEnd,
                  layout: value
                      .productListLayout, //layout, //fix for changing product layout
                  ratioProductImage: ratioProductImage,
                  width: width,
                  //showProgressBar: widget.showCountdown,
                );
              }),
            ),
            // : AsymmetricView(
            //     products: products,
            //     isFetching: isFetching, // !allLoaded,
            //     isEnd: isEnd,
            //     onLoadMore: _loadProduct,
            //     width: width,
            //   ),
            backLayer: DealsBackdropMenu(
              onFilter: onFilter,
              // categoryIdList: newCategoryIdList,
              // tagId: newTagId,
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
            appbarCategory: renderCategoryAppbar()),
      );
    };

    Widget buildMain = Scaffold(
      // appBar: AppBar(
      //   title: AppLocal(
      //     scanBarcode: "Search",
      //   ),
      // ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Image.asset(
      //     "assets/images/filter.png",
      //   ),
      // ),
      body: Container(
        child: LayoutBuilder(
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
      ),
    );

    // Container(
    //   child: LayoutBuilder(
    //     builder: (context, constraint) {
    //       return FractionallySizedBox(
    //           widthFactor: 1.0,
    //           child: backdrop(
    //               //allLoaded: value.allLoaded,
    //               products: _products,
    //               isFetching: isFetching,
    //               //errMsg: value.errMsg,
    //               isEnd: !canLoad,
    //               width: constraint.maxWidth));
    //     },
    //   ),
    // );
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

*/

//

import 'package:ctown/frameworks/magento/services/magento.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';

import '../../models/index.dart'
    show
        AppModel,
        Category,
        CategoryModel,
        FilterAttributeModel,
        Product,
        ProductModel;
import '../../services/index.dart';
import '../../widgets/backdrop/backdrop_work.dart';
import '../../widgets/backdrop/deals_backdrop_menu.dart';
import '../../widgets/product/product_list.dart';
import '../products/products_backdrop.dart';

class DealsScreen1 extends StatefulWidget {
  final config;

  DealsScreen1({Key? key, this.config}) : super(key: key);

  @override
  _DealsScreen1State createState() => _DealsScreen1State();
}

class _DealsScreen1State extends State<DealsScreen1>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _mySelection = '';
  List data = ["All", 'weekly', 'monthly'];

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
  @override
  void initState() {
    super.initState();
    print("**********************************************");
    print(widget.config);
    _getCategoryList(Provider.of<AppModel>(context, listen: false).langCode);
    _loadProduct();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1.0,
    );
  }

  _getCategoryList(lang) async {
    categoryLists = MagentoApi().getDealsCategoryList(lang);
  }

  _loadProduct() async {
    List<Product> productList = [];
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
        productList = [];
        productList = await MagentoApi().getProductsonDeal2(
          page: _page,
          filter: widget.config,
          categoryId: catergory,
          lang: Provider.of<AppModel>(context, listen: false).langCode,
        );
        newProducts.addAll(productList);
      }
    } else {
      productList = [];
      productList = await MagentoApi().getProductsonDeal2(
        filter: widget.config,
        page: _page,
        lang: Provider.of<AppModel>(context, listen: false).langCode,
      );
      newProducts.addAll(productList);
    }
    if (newProducts.isEmpty || productList.isEmpty) {
      setState(() {
        canLoad = false;
      });
    }
    setState(() {
      isFetching = false;
      _products = [..._products, ...newProducts ];
    });
  }

  _onRefresh() async {
    //var config = widget.config;
    List<Product> productList = [];
    _page = 1;
    // config['page'] = _page;
    setState(() {
      isFetching = true;
      _products.clear();
    });
    //if (!canLoad) return;
    List newProducts = [];
    if (selectedCategory.isNotEmpty) {
      for (var catergory in selectedCategory) {
        productList = [];
        productList = await MagentoApi().getProductsonDeal2(
          page: _page,
          filter: widget.config,
          categoryId: catergory,
          lang: Provider.of<AppModel>(context, listen: false).langCode,
        );
        newProducts.addAll(productList);

      }
    } else {
      productList = [];
      productList = await MagentoApi().getProductsonDeal2(
        page: _page,
        filter: widget.config,
        lang: Provider.of<AppModel>(context, listen: false).langCode,
      );
      newProducts.addAll(productList);
    }
    if (newProducts.isEmpty || productList.isEmpty) {
      setState(() {
        canLoad = false;
      });
    }
    setState(() {
      isFetching = false;
      _products = [/*..._products,*/ ...newProducts ];
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
    selectedCategory.clear();
    categoryIdList.forEach((element) {
      selectedCategory.add(int.parse(element!));
    });
    //selectedCategory = categoryIdList.isNotEmpty ? int.parse(categoryIdList[0]) : null;
    _onRefresh();
    // productModel.setProductsList(List<Product>());
    // await loadCategoriesList(categoryIdList, productModel, tagId, terms);
  }

  // Future loadCategoriesList(List categoryIdList, ProductModel productModel, tagId, terms) async {
  //   productModel.setCatIdListLen(categoryIdList.length);
  //   categoryIdList.forEach((catId) async {
  //     printLog('catId: $catId');
  //     await productModel.getProductsList(
  //         categoryId: catId,
  //         // categoryIdList: categoryIdList == -1 ? null : categoryIdList,
  //         // minPrice: minPrice,
  //         // maxPrice: maxPrice,
  //         page: 1,
  //         lang: Provider.of<AppModel>(context, listen: false).langCode,
  //         // orderBy: orderBy,
  //         // order: orDer,
  //         // featured: featured,
  //         // onSale: onSale,
  //         // tagId: tagId,
  //         // attribute: attribute,
  //         attributeTerm: terms.isEmpty ? null : terms);
  //   });
  //   return;
  // }

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
    List newProducts =[];
    if (selectedCategory.isNotEmpty) {
      for (var catergory in selectedCategory) {
        productList = [];
        productList = await MagentoApi().getProductsonDeal2(
          page: _page,
          categoryId: catergory,
          orderBy: 'date',
          order: 'desc',
          featured: featured,
          onSale: onSale,
          filter: widget.config,
          lang: Provider.of<AppModel>(context, listen: false).langCode,
        );
        newProducts.addAll(productList);
      }
    } else {
      productList = [];
      productList = await MagentoApi().getProductsonDeal2(
          page: _page,
          orderBy: 'date',
          order: 'desc',
          featured: featured,
          onSale: onSale,
          filter: widget.config,
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
      _products = [/*..._products,*/ ...newProducts ];
    });
  }

  Widget renderCategoryAppbar() {
    final catModel = Provider.of<CategoryModel>(context);
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
              categoryId: "-1", categoryName: S.of(context).seeAll));

          _renderListCategory.addAll([
            for (var category in categories)
              _renderItemCategory(
                  categoryId: category.id, categoryName: category.name!)
          ]);

          return Container(
            color: Theme.of(context).primaryColor,
            height: 50,
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
            color: Colors.white,
          ),
        ),
      ),
      onTap: () {
        _page = 1;
        // Provider.of<ProductModel>(context, listen: false).getProductsList(
        //   categoryId: categoryId,
        //   page: _page,
        //   onSale: onSale,
        //   lang: Provider.of<AppModel>(context, listen: false).langCode,
        //   // tagId: newTagId,
        // );
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
            // minPrice: minPrice,
            // maxPrice: maxPrice,
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
    //final product = Provider.of<ProductModel>(context, listen: false);
    final title = S.of(context).products;
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
                  // isListView
                  //     ?
                  ListenableProvider.value(
                value: Provider.of<AppModel>(context),
                child: Consumer<AppModel>(
                  builder: (context, value, child) => ProductList(
                    products: products,
                    onRefresh: _onRefresh,
                    onLoadMore: _loadProduct,
                    isFetching: isFetching, // !allLoaded,
                    errMsg: errMsg,
                    isEnd: isEnd,
                    layout: "list", //layout, //fix for changing product layout
                    ratioProductImage: ratioProductImage,
                    width: width,
                    //showProgressBar: widget.showCountdown,
                  ),
                ),
                // )
                // : AsymmetricView(
                //     products: products,
                //     isFetching: isFetching, // !allLoaded,
                //     isEnd: isEnd,
                //     onLoadMore: _loadProduct,
                //     width: width,
              ),
              listViewWidget: ListenableProvider.value(
                value: Provider.of<AppModel>(context),
                child: Consumer<AppModel>(
                  builder: (context, value, child) => ProductList(
                    products: products,
                    onRefresh: _onRefresh,
                    onLoadMore: _loadProduct,
                    isFetching: isFetching, // !allLoaded,
                    errMsg: errMsg,
                    isEnd: isEnd,
                    layout: "listTile", //layout, //fix for changing product layout
                    ratioProductImage: ratioProductImage,
                    width: width,
                    //showProgressBar: widget.showCountdown,
                  ),
                ),
                // )
                // : AsymmetricView(
                //     products: products,
                //     isFetching: isFetching, // !allLoaded,
                //     isEnd: isEnd,
                //     onLoadMore: _loadProduct,
                //     width: width,
              ),
              backLayer: DealsBackdropMenu(
                onFilter: onFilter,
                // categoryIdList: newCategoryIdList,
                // tagId: newTagId,
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
              // appbarCategory: renderCategoryAppbar()
              ),
        );

    Widget buildMain = Scaffold(
      // appBar: AppBar(
      //   title: AppLocal(
      //     scanBarcode: "Search",
      //   ),
      // ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Image.asset(
      //     "assets/images/filter.png",
      //   ),
      // ),
      body: Container(
        child: LayoutBuilder(
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
      ),
    );

    // Container(
    //   child: LayoutBuilder(
    //     builder: (context, constraint) {
    //       return FractionallySizedBox(
    //           widthFactor: 1.0,
    //           child: backdrop(
    //               //allLoaded: value.allLoaded,
    //               products: _products,
    //               isFetching: isFetching,
    //               //errMsg: value.errMsg,
    //               isEnd: !canLoad,
    //               width: constraint.maxWidth));
    //     },
    //   ),
    // );
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
