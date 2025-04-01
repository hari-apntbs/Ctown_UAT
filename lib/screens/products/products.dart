import 'dart:async';

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
// import '../../widgets/asymmetric/asymmetric_view.dart';
import '../../widgets/backdrop/backdrop.dart';
import '../../widgets/backdrop/backdrop_menu.dart';
import '../../widgets/common/countdown_timer.dart';
import '../../widgets/product/product_bottom_sheet.dart';
import '../../widgets/product/product_list.dart';
import '../settings/deals.dart';
import 'products_backdrop.dart';

class ProductsPage extends StatefulWidget {
  final List<Product?>? products;
  final String? categoryId;
  final String? tagId;
  final Map<String, dynamic>? config;
  final bool? onSale;
  final bool showCountdown;
  final Duration countdownDuration;
  final String? title;
  final String? searchValue;
  final bool? appBarRequired;
  final bool? fromSearch;
  final bool? pushNotify;

  ProductsPage({
    this.products,
    this.categoryId,
    this.config,
    this.tagId,
    this.onSale,
    this.showCountdown = false,
    this.countdownDuration = Duration.zero,
    this.title,
    this.searchValue,
    this.appBarRequired,
    this.fromSearch,
    this.pushNotify
  });

  @override
  State<StatefulWidget> createState() {
    return ProductsPageState();
  }
}

class ProductsPageState extends State<ProductsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  String? newTagId;
  List<String?>? newCategoryIdList;
  // String newCategoryId;
  double? minPrice;
  double? maxPrice;
  String? orderBy;
  String? orDer;
  String? attribute;

//  int attributeTerm;
  bool? featured;
  bool? onSale;

  bool isFiltering = false;
  List<Product> products = [];
  String? errMsg;
  int _page = 1;
  String _mySelection = '';
  List data = [];
  bool isLoading = false;
  Timer? _loadingTimer;
  bool loadProducts = false;
  String subCategory = "";
  String selectCategory = "";

  @override
  void initState() {
    super.initState();
    //  brandfliter();
    setState(() {
      newCategoryIdList =
      widget.categoryId != null ? [widget.categoryId] : ['-1'];
      selectCategory = newCategoryIdList!.first ?? "";
      // newCategoryId = widget.categoryId ?? '-1';
      newTagId = widget.tagId;
      onSale = widget.onSale;
      subCategory = widget.categoryId != null ? widget.categoryId! : "-1";
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1.0,
    );

    if (widget.config != null) {
      onRefresh();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLoadingTimer();
    });
  }

  void _startLoadingTimer() {
    const interval = Duration(milliseconds: 1500); // Define the interval duration
    _loadingTimer = Timer.periodic(interval, (_) async {
      if(mounted) {
        if (!loadProducts && Provider.of<ProductModel>(context, listen: false).productsList!.isNotEmpty &&
            !Provider.of<ProductModel>(context, listen: false).isEnd!) {
          await onLoadMore();
        }
      }
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _page = 1;
    _controller.dispose();
    super.dispose();
  }

  Future loadCategoriesList(
      List categoryIdList, ProductModel productModel, tagId, terms) async {
    productModel.setCatIdListLen(categoryIdList.length);
    categoryIdList.forEach((catId) async {
      printLog('catId: $catId');
      await productModel.getProductsList(
          categoryId: catId,
          // categoryIdList: categoryIdList == -1 ? null : categoryIdList,
          minPrice: minPrice,
          maxPrice: maxPrice,
          page: 1,
          lang: Provider.of<AppModel>(context, listen: false).langCode,
          orderBy: orderBy,
          order: orDer,
          sort: "vengadesh",
          featured: featured,
          onSale: onSale,
          tagId: tagId,
          attribute: attribute,
          attributeTerm: terms.isEmpty ? null : terms);
    });
    return;
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

    final productModel = Provider.of<ProductModel>(context, listen: false);
    final filterAttr =
    Provider.of<FilterAttributeModel>(context, listen: false);
    // newCategoryIdList = widget.categoryId != null
    //     ? [widget.categoryId]
    //     : ['-1']; //commented to fix category selection on products page not getting highlighted
    // newCategoryId = categoryId;
    newTagId = tagId;
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;
    if (attribute != null && !attribute.isEmpty) this.attribute = attribute;
    String terms = '';

    if (currentSelectedTerms != null) {
      for (int i = 0; i < currentSelectedTerms.length; i++) {
        if (currentSelectedTerms[i]) {
          terms += '${filterAttr.lstCurrentAttr[i].id},';
        }
      }
    }

    productModel.setProductsList(<Product>[]);
    await loadCategoriesList(categoryIdList, productModel, tagId, terms);
    setState(() {
      isLoading = false;
    });

    // categoryIdList.forEach((catId) async {

    // });

    // productModel.getProductsList(
    //   categoryId: categoryId == -1 ? null : categoryId,
    //   minPrice: minPrice,
    //   maxPrice: maxPrice,
    //   page: 1,
    //   lang: Provider.of<AppModel>(context, listen: false).langCode,
    //   orderBy: orderBy,
    //   order: orDer,
    //   featured: featured,
    //   onSale: onSale,
    //   tagId: tagId,
    //   attribute: attribute,
    //   attributeTerm: terms.isEmpty ? null : terms,
    // );
  }

  void onSort(order) {
    if (order == "date") {
      featured = null;
      onSale = null;
    } else {
      featured = order == "featured";
      onSale = order == "on_sale";
    }

    final filterAttr =
    Provider.of<FilterAttributeModel>(context, listen: false);
    String terms = '';
    for (int i = 0; i < filterAttr.lstCurrentSelectedTerms.length; i++) {
      if (filterAttr.lstCurrentSelectedTerms[i]) {
        terms += '${filterAttr.lstCurrentAttr[i].id},';
      }
    }
    final productModelT = Provider.of<ProductModel>(context, listen: false);
    productModelT.setProductsList(<Product>[]);
    productModelT.setCatIdListLen(newCategoryIdList!.length);

    newCategoryIdList!.forEach((catId) async {
      await productModelT.getProductsList(
        categoryId: catId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        lang: Provider.of<AppModel>(context, listen: false).langCode,
        page: 1,
        orderBy: 'date',
        order: 'desc',
        featured: featured,
        onSale: onSale,
        sort: "vengadesh",
        attribute: attribute,
        attributeTerm: terms,
        tagId: newTagId,
      );
    });

    // Provider.of<ProductModel>(context, listen: false)
    //     .getProductsListWithCatList(
    //   categoryIdList: newCategoryIdList,
    // minPrice: minPrice,
    // maxPrice: maxPrice,
    // lang: Provider.of<AppModel>(context, listen: false).langCode,
    // page: 1,
    // orderBy: 'date',
    // order: 'desc',
    // featured: featured,
    // onSale: onSale,
    // attribute: attribute,
    // attributeTerm: terms,
    // tagId: newTagId,
    // );
  }

  Future<void> onRefresh() async {
    setState(() {
      _page = 1;
    });
    if (widget.config == null) {
      final filterAttr =
      Provider.of<FilterAttributeModel>(context, listen: false);
      String terms = '';
      for (int i = 0; i < filterAttr.lstCurrentSelectedTerms.length; i++) {
        if (filterAttr.lstCurrentSelectedTerms[i]) {
          terms += '${filterAttr.lstCurrentAttr[i].id},';
        }
      }
      final productModelT = Provider.of<ProductModel>(context, listen: false);
      productModelT.setProductsList(<Product>[]);
      productModelT.setCatIdListLen(newCategoryIdList!.length);
      if(newCategoryIdList![0] != "") {
        newCategoryIdList!.forEach((catId) async {
          await productModelT.getProductsList(
            categoryId: catId,
            minPrice: minPrice,
            maxPrice: maxPrice,
            lang: Provider.of<AppModel>(context, listen: false).langCode,
            page: 1,
            orderBy: orderBy,
            sort: "vengadesh",
            order: orDer,
            attribute: attribute,
            attributeTerm: terms,
            tagId: newTagId,
            featured: featured,
            onSale: onSale,
            isFromSearch: widget.fromSearch ?? false,
            products: widget.products,
          );
        });
      }
      else if(widget.searchValue != null && widget.searchValue != "") {
        await productModelT.getProductsBySearchValue(widget.searchValue ?? "", Provider.of<AppModel>(context, listen: false).langCode ?? "en", 1);
      }

      // await Provider.of<ProductModel>(context, listen: false)
      //     .getProductsListWithCatList(
      //   categoryIdList: newCategoryIdList,
      // minPrice: minPrice,
      // maxPrice: maxPrice,
      // lang: Provider.of<AppModel>(context, listen: false).langCode,
      // page: 1,
      // orderBy: orderBy,
      // order: orDer,
      // attribute: attribute,
      // attributeTerm: terms,
      // tagId: newTagId,
      // );
    } else if(widget.pushNotify == null) {
      try {
        var newProducts = await Services().fetchProductsLayout(
            config: widget.config,
            lang: Provider.of<AppModel>(context, listen: false).langCode);
        setState(() {
          products = newProducts;
        });
      } catch (err) {
        setState(() {
          isLoading = false;
          errMsg = err.toString();
        });
      }
    }
    else {
      try {
        final filterAttr =
        Provider.of<FilterAttributeModel>(context, listen: false);
        String terms = '';
        for (int i = 0; i < filterAttr.lstCurrentSelectedTerms.length; i++) {
          if (filterAttr.lstCurrentSelectedTerms[i]) {
            terms += '${filterAttr.lstCurrentAttr[i].id},';
          }
        }
        final productModelT = Provider.of<ProductModel>(context, listen: false);
        productModelT.setProductsList(<Product>[]);
        productModelT.setCatIdListLen(newCategoryIdList!.length);
        await productModelT.getProductsList(
          categoryId: widget.config!["category"],
          minPrice: minPrice,
          maxPrice: maxPrice,
          lang: Provider.of<AppModel>(context, listen: false).langCode,
          page: 1,
          orderBy: orderBy,
          sort: "vengadesh",
          order: orDer,
          attribute: attribute,
          attributeTerm: terms,
          tagId: newTagId,
          featured: featured,
          onSale: onSale,
          isFromSearch: widget.fromSearch ?? false,
          products: widget.products,
        );
      } catch (err) {
        setState(() {
          isLoading = false;
          errMsg = err.toString();
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget? renderCategoryAppbar() {
    final category = Provider.of<CategoryModel>(context);
    final langCode = Provider.of<AppModel>(context, listen: false).langCode ??  "en";
    String? parentCategory = newCategoryIdList!.first;
    if (category.categories != null && category.categories!.isNotEmpty) {
      parentCategory =
          getParentCategories(category.categories, parentCategory) ??
              parentCategory;
      final listSubCategory =
      getSubCategories(category.categories, parentCategory)!;

      if (listSubCategory.length < 2) return null;

      return ListenableProvider.value(
        value: category,
        child: Consumer<CategoryModel>(builder: (context, value, child) {
          if (value.isLoading) {
            return Center(child: kLoadingWidget(context));
          }

          if (value.categories != null) {
            print(parentCategory);
            List<Widget> _renderListCategory = [];
            _renderListCategory.add(const SizedBox(width: 10));
            if (parentCategory != "177") {
              _renderListCategory.add(_renderItemCategory(
                  categoryId: parentCategory,
                  categoryName: langCode == "en" ? "See All" : "اظهار الكل"));
            }

            List<Category> subCats = getSubCategories(value.categories, parentCategory)!;
            var matchingCategories = subCats.where((element) => element.id == selectCategory);
            if (matchingCategories.isNotEmpty) {
              Category categoryToMove = matchingCategories.first;
              subCats.remove(categoryToMove);
              subCats.insert(0, categoryToMove);
            }

            _renderListCategory.addAll([
              for (var category in subCats)
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
        }),
      );
    }
    return null;
  }

  List<Category>? getSubCategories(categories, id) {
    return categories.where((o) => o.parent == id).toList();
  }

  String? getParentCategories(categories, id) {
    for (var item in categories) {
      if (item.id == id) {
        return (item.parent == null || item.parent == '0') ? null : item.parent;
      }
    }
    return '0';
    // return categories.where((o) => ((o.id == id) ? o.parent : null));
  }

  Widget _renderItemCategory({String? categoryId, required String categoryName}) {
    return GestureDetector(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
            color: newCategoryIdList!.first == categoryId
                ? Colors.white24
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: newCategoryIdList!.first == categoryId ?
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
        print("running");
        _page = 1;
        if(!Provider.of<ProductModel>(context, listen: false).isFetching) {
          Provider.of<ProductModel>(context, listen: false).setProductsList(<Product>[]);
          Provider.of<ProductModel>(context, listen: false).setCurrentCat(categoryId ?? "");
          subCategory = categoryId ?? "";
          if(categoryId != "0") {
            setState(() {
              isLoading = true;
              loadProducts = false;
              newCategoryIdList!.first = categoryId;
              _page = 1;
              onFilter(
                minPrice: minPrice,
                maxPrice: maxPrice,
                categoryIdList: newCategoryIdList!,
                tagId: newTagId,
              );
            });
          }
          else {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => DealsScreen()));
          }
        }
      },
    );
  }

  Future<void> onLoadMore() async {
    // TODO: onLoadMore
    if(isLoading) return;
    setState(() {
      _page = _page + 1;
      loadProducts = true;
    });
    final filterAttr =
    Provider.of<FilterAttributeModel>(context, listen: false);
    String terms = '';
    for (int i = 0; i < filterAttr.lstCurrentSelectedTerms.length; i++) {
      if (filterAttr.lstCurrentSelectedTerms[i]) {
        terms += '${filterAttr.lstCurrentAttr[i].id},';
      }
    }
    // if (_page == 0 || _page == 1) {
    //   Provider.of<ProductModel>(context, listen: false)
    //       .setProductsList(List<Product>());
    // }
    if(isLoading) return;
    if(newCategoryIdList![0] != "") {
      newCategoryIdList!.forEach((catId) async {
        if(isLoading) return;
        await Provider.of<ProductModel>(context, listen: false).getMoreProducts(
          categoryId: catId,
          minPrice: minPrice,
          maxPrice: maxPrice,
          lang: Provider.of<AppModel>(context, listen: false).langCode,
          page: _page,
          orderBy: orderBy,
          order: orDer,
          featured: featured,
          onSale: onSale,
          sort: "vengadesh",
          attribute: attribute,
          attributeTerm: terms,
          tagId: widget.tagId,
          loadMore: true,
          currentCat: subCategory
        );
      });
    }
    else if(widget.searchValue != null && widget.searchValue != "") {
      if(isLoading) return;
      await Provider.of<ProductModel>(context, listen: false).getProductsBySearchValue(
          widget.searchValue ?? "", Provider.of<AppModel>(context, listen: false).langCode ?? "en",
          _page, loadMore: true);
    }
    // Provider.of<ProductModel>(context, listen: false)
    //     .getProductsListWithCatList(
    //   categoryIdList: newCategoryIdList,
    // minPrice: minPrice,
    // maxPrice: maxPrice,
    // lang: Provider.of<AppModel>(context, listen: false).langCode,
    // page: _page,
    // orderBy: orderBy,
    // order: orDer,
    // featured: featured,
    // onSale: onSale,
    // attribute: attribute,
    // attributeTerm: terms,
    // tagId: widget.tagId,
    // );
    setState(() {
      loadProducts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<ProductModel>(context, listen: false);
    final title = widget.title ?? S.of(context).products;
    final layout = widget.config != null && widget.config!["layout"] != null
        ? widget.config!["layout"]
        : Provider.of<AppModel>(context, listen: false).productListLayout;

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
          backdrop: Backdrop(
            pushNotify: widget.pushNotify,
              product: newCategoryIdList!.last,
              frontLayer:
              ListenableProvider.value(
                value: Provider.of<AppModel>(context),
                child: Consumer<AppModel>(
                  builder: (context, value, child) => ProductList(
                    products: products,
                    onRefresh: onRefresh,
                    onLoadMore: onLoadMore,
                    isFetching: isFetching, // !allLoaded,
                    errMsg: errMsg,
                    isEnd: isEnd,
                    layout: "list", //layout, //fix for changing product layout
                    ratioProductImage: ratioProductImage,
                    width: width,
                    showProgressBar: widget.showCountdown,
                  ),
                ),
              ),
              listViewWidget: ListenableProvider.value(
                value: Provider.of<AppModel>(context),
                child: Consumer<AppModel>(
                  builder: (context, value, child) => ProductList(
                    products: products,
                    onRefresh: onRefresh,
                    onLoadMore: onLoadMore,
                    isFetching: isFetching, // !allLoaded,
                    errMsg: errMsg,
                    isEnd: isEnd,
                    layout: "listTile", //layout, //fix for changing product layout
                    ratioProductImage: ratioProductImage,
                    width: width,
                    showProgressBar: widget.showCountdown,
                  ),
                ),
                //   )
                // : AsymmetricView(
                //     products: products,
                //     isFetching: isFetching, // !allLoaded,
                //     isEnd: isEnd,
                //     onLoadMore: onLoadMore,
                //     width: width,
              ),
              backLayer: BackdropMenu(
                onFilter: onFilter,
                categoryIdList: newCategoryIdList,
                tagId: newTagId,
              ),
              frontTitle: widget.showCountdown ? Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title),
                      CountDownTimer(
                        widget.countdownDuration,
                        color: Colors.blue,
                        textColor: Colors.white,
                      )
                    ],
                  ),
                ],
              )
                  : Text(title),
              backTitle: Text(
                S.of(context).filter,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              controller: _controller,
              onSort: onSort,
              appbarCategory: widget.appBarRequired ?? true ? renderCategoryAppbar() : null,),
          expandingBottomSheet: (!Config().isListingType())
              ? ExpandingBottomSheet(hideController: _controller)
              : null,
        );

    Widget buildMain = Container(
      child: LayoutBuilder(
        builder: (context, constraint) {
          return FractionallySizedBox(
            widthFactor: 1.0,
            child: ListenableProvider.value(
              value: product,
              child: Consumer<ProductModel>(builder: (context, value, child) {
                return backdrop(
                    allLoaded: value.allLoaded,
                    products: value.productsList,
                    isFetching: value.isFetching,
                    errMsg: value.errMsg,
                    isEnd: value.isEnd,
                    width: constraint.maxWidth);
              }),
            ),
          );
        },
      ),
    );
    return kIsWeb ? WillPopScope(
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
