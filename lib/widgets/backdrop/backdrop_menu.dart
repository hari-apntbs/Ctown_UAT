import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart'
    show
        AppModel,
        Category,
        TagModel,
        CategoryModel,
        FilterAttributeModel,
        ProductModel;
import '../common/tree_view.dart';
import '../layout/adaptive.dart';
import 'category_item.dart';
import 'filter_option_item.dart';

class BackdropMenu extends StatefulWidget {
  final Function? onFilter;
  final List<String?>? categoryIdList;
  final String? tagId;

  const BackdropMenu({
    Key? key,
    this.onFilter,
    this.categoryIdList,
    this.tagId,
  }) : super(key: key);

  @override
  _BackdropMenuState createState() => _BackdropMenuState();
}

class _BackdropMenuState extends State<BackdropMenu> {
  double mixPrice = 0.0;
  double maxPrice = kMaxPriceFilter / 2;
  List<String?>? categoryIdList = ['-1'];
  String? tagId = '-1';
  String? currentSlug;
  int currentSelectedAttr = -1;
  List<String> selectedCatIdList = [];
  static const double leftMarginAmount = 30.0;

  @override
  void initState() {
    super.initState();
    categoryIdList = widget.categoryIdList;
    tagId = widget.tagId;
  }

  @override
  Widget build(BuildContext context) {
    final category = Provider.of<CategoryModel>(context);
    final tag = Provider.of<TagModel>(context);
    final selectLayout = Provider.of<AppModel>(context).productListLayout;
    // ignore: unused_local_variable
    final currency = Provider.of<AppModel>(context).currency;
    // ignore: unused_local_variable
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final filterAttr = Provider.of<FilterAttributeModel>(context);

    categoryIdList = [Provider.of<ProductModel>(context).categoryId];

    Function _onFilter = (categoryIdList, tagId) => widget.onFilter!(
          minPrice: mixPrice,
          maxPrice: maxPrice,
          categoryIdList: categoryIdList,
          tagId: tagId,
          attribute: currentSlug,
          currentSelectedTerms: filterAttr.lstCurrentSelectedTerms,
        );

    return ListenableProvider.value(
      value: category,
      child: Consumer<CategoryModel>(
        builder: (context, catModel, _) {
          if (catModel.isLoading) {
            printLog('Loading');
            return Center(child: Container(child: kLoadingWidget(context)));
          }

          if (catModel.categories != null) {
            final categories = catModel.categories!
                .where((item) => item.parent == '0')
                .toList();
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //   children: [],
                  // ),
                  const SizedBox(height: 10),
                  isDisplayDesktop(context)
                      ? SizedBox(
                          height: 100,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const SizedBox(width: 20),
                              GestureDetector(
                                child: const Icon(Icons.arrow_back_ios,
                                    size: 22, color: Colors.white70),
                                onTap: () {
                                  if (isDisplayDesktop(context)) {
                                    eventBus
                                        .fire(const EventOpenCustomDrawer());
                                  }
                                  Navigator.of(context).pop();
                                },
                              ),
                              const SizedBox(width: 20),
                              Text(
                                S.of(context).products,
                                style: const TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                  // const SizedBox(height: 10),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 15),
                  //   child: Text(
                  //     S.of(context).layout.toUpperCase(),
                  //     style: const TextStyle(
                  //       fontSize: 15,
                  //       fontWeight: FontWeight.w600,
                  //       color: Colors.white70,
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 10.0),
                  // Wrap(
                  //   children: <Widget>[
                  //     for (var item in kProductListLayout)
                  //       GestureDetector(
                  //         onTap: () =>
                  //             Provider.of<AppModel>(context, listen: false).updateProductListLayout(item['layout']),
                  //         child: Container(
                  //           width: 40,
                  //           height: 40,
                  //           margin: const EdgeInsets.all(10.0),
                  //           child: Padding(
                  //             padding: const EdgeInsets.all(10.0),
                  //             child: Image.asset(
                  //               item['image'],
                  //               color: selectLayout == item['layout'] ? Colors.white : Colors.black.withOpacity(0.2),
                  //             ),
                  //           ),
                  //           decoration: BoxDecoration(
                  //               color: selectLayout == item['layout']
                  //                   ? Colors.black.withOpacity(0.15)
                  //                   : Colors.black.withOpacity(0.05),
                  //               borderRadius: BorderRadius.circular(9.0)),
                  //         ),
                  //       )
                  //   ],
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 0),
                    child: Row(
                      children: [
                        Text(
                          S.of(context).byCategory.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            //color: Colors.white70,
                          ),
                        ),
                        const Spacer(),
                        ApplyButton(
                          selectedCatIdList: selectedCatIdList.isNotEmpty
                              ? selectedCatIdList
                              : categories.map((e) => e.id).toList(),
                          onFilter: _onFilter,
                          tagId: tagId,
                          topPadding: 0,
                        ),
                        ClearButton(
                          selectedCatIdList: selectedCatIdList,
                          onPressed: () =>
                              setState(() => selectedCatIdList.clear()),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20),
                    child: Container(
                      padding: const EdgeInsets.only(top: 15.0),
                      decoration: BoxDecoration(
                        //color: Theme.of(context).primaryColorLight,
                        // color: Colors.white,
                        color: Theme.of(context).scaffoldBackgroundColor,
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        //color: Colors.grey[50]
                      ),
                      // decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(3.0)),
                      child: _buildTreeView(categories, catModel),
                    ),
                  ),
                ]
                  ..add(
                    ListenableProvider.value(
                      value: tag,
                      child: Consumer<TagModel>(
                        builder: (context, TagModel tagModel, _) {
                          if (tagModel.tagList?.isEmpty ?? true) {
                            return const SizedBox();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: tagModel.isLoading
                                ? [
                                    Center(
                                      child: Container(
                                        child: kLoadingWidget(context),
                                      ),
                                    )
                                  ]
                                : [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 15,
                                        top: 30,
                                      ),
                                      child: Text(
                                        S.of(context).byTag.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 15,
                                      ),
                                      child: Wrap(
                                        children: []..addAll(
                                            List.generate(
                                              tagModel.tagList?.length ?? 0,
                                              (index) {
                                                final bool selected = tagId ==
                                                    tagModel.tagList![index].id
                                                        .toString();
                                                return FilterOptionItem(
                                                  enabled: !tagModel.isLoading,
                                                  selected: selected,
                                                  isValid: tagId != '-1',
                                                  title: tagModel
                                                      .tagList![index].name!
                                                      .toUpperCase(),
                                                  onTap: () {
                                                    setState(() {
                                                      if (selected) {
                                                        tagId = null;
                                                      } else {
                                                        tagId = tagModel
                                                            .tagList![index].id
                                                            .toString();
                                                      }
                                                    });
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                      ),
                                    ),
                                  ],
                          );
                        },
                      ),
                    ),
                  )
                  ..addAll(
                    [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ApplyButton(
                            selectedCatIdList: selectedCatIdList.isNotEmpty
                                ? selectedCatIdList
                                : categories.map((e) => e.id).toList(),
                            onFilter: _onFilter,
                            tagId: tagId,
                          ),
                          ClearButton(
                            selectedCatIdList: selectedCatIdList,
                            onPressed: () =>
                                setState(() => selectedCatIdList.clear()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 70),
                    ],
                  ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  TreeView _buildTreeView(List<Category> categories, CategoryModel catModel) {
    return TreeView(
      parentList: [
        for (var item in categories) _buildCategory(item, catModel, 0),
      ],
    );
  }

  Parent _buildExpandableCategory(
      Category item, CategoryModel catModel, int level) {
    return Parent(
      parent: CategoryItem(
        item,
        leftMargin: level * leftMarginAmount,
        hasChild: true,
        isSelected: selectedCatIdList.contains(item.id),
        // onTap: (category) => setState(() {
        //   if (selectedCatIdList.contains(category)) {
        //     selectedCatIdList.remove(category);
        //   } else {
        //     selectedCatIdList.add(category);
        //   }
        // }),
      ),
      childList: ChildList(
        children: [
          Parent(
            parent: CategoryItem(
              item,
              leftMargin: (level + 1) * leftMarginAmount,
              isLast: true,
              isParent: true,
              isSelected: selectedCatIdList.contains(item.id),
              onTap: (category) => setState(() {
                if (selectedCatIdList.contains(category)) {
                  selectedCatIdList.remove(category);
                } else {
                  selectedCatIdList.add(category);
                }
              }),
            ),
            childList: ChildList(
              children: const [],
            ),
          ),
          for (var category in getSubCategories(catModel.categories, item.id)!)
            _buildCategory(category, catModel, level + 1)
        ],
      ),
    );
  }

  Parent _buildUnexpandableCategory(
      Category item, CategoryModel catModel, int level) {
    return Parent(
      parent: CategoryItem(
        item,
        leftMargin: level * leftMarginAmount,
        isLast: true,
        isSelected: selectedCatIdList.contains(item.id),
        onTap: (category) => setState(() {
          if (selectedCatIdList.contains(category)) {
            selectedCatIdList.remove(category);
          } else {
            selectedCatIdList.add(category);
          }
        }),
      ),
      childList: ChildList(
        children: const [],
      ),
    );
  }

  Parent _buildCategory(Category item, CategoryModel catModel, int level) {
    if (hasChildren(catModel.categories, item.id)!) {
      return _buildExpandableCategory(item, catModel, level);
    } else {
      return _buildUnexpandableCategory(item, catModel, level);
    }
  }

  bool? hasChildren(categories, id) {
    return categories.where((o) => o.parent == id).toList().length > 0;
  }

  List<Category>? getSubCategories(categories, id) {
    return categories.where((o) => o.parent == id).toList();
  }
}

class ClearButton extends StatelessWidget {
  const ClearButton({
    Key? key,
    required this.onPressed,
    required this.selectedCatIdList,
  }) : super(key: key);
  final Function onPressed;
  final List<String> selectedCatIdList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 0,
        right: 15,
        // top: 5,
      ),
      child: ButtonTheme(
        height: 40,
        minWidth: 90,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0.0,
            backgroundColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.0),
            ),
          ),
          onPressed: () {
            onPressed();
            Tools.showSnackBar(ScaffoldMessenger.of(context), S.of(context).filterclear);
          },
          child: Text(S.of(context).clear),
        ),
      ),
    );
  }
}

class ApplyButton extends StatelessWidget {
  const ApplyButton({
    Key? key,
    this.onPressed,
    required this.selectedCatIdList,
    required Function onFilter,
    required this.tagId,
    this.topPadding = 0,
  })  : _onFilter = onFilter,
        super(key: key);
  final Function? onPressed;
  final List<String?> selectedCatIdList;
  final Function _onFilter;
  final String? tagId;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 5,
        right: 10,
        top: topPadding,
      ),
      child: ButtonTheme(
        height: 40,
        minWidth: 90,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0.0,
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.0),
            ),
          ),
          onPressed: () {
            // if (selectedCatIdList == null || selectedCatIdList.isEmpty) {
            //   Tools.showSnackBar(Scaffold.of(context), S.of(context).noFiltersSelected);
            //   return;
            // }
            _onFilter(selectedCatIdList, tagId);
          },
          child: Text(
            S.of(context).apply,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
