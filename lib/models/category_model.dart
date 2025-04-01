import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';

import '../common/constants.dart';
import '../services/index.dart';
import 'entities/category.dart';

class CategoryModel with ChangeNotifier {
  final Services _service = Services();
  List<Category>? categories;
  Map<String?, Category> categoryList = {};

  bool isLoading = false;
  String? message;

  /// Format the Category List and assign the List by Category ID
  void sortCategoryList({List<Category>? categoryList, dynamic sortingList}) {
    Map<String?, Category> _categoryList = {};
    List<Category>? result = categoryList;

    if (sortingList != null) {
      List<Category> _categories = [];
      List<Category> _subCategories = [];
      bool isParent = true;
      for (var category in sortingList) {
        Category? item = categoryList!.firstWhereOrNull(
            (Category cat) => cat.id.toString() == category.toString());
        if (item != null) {
          if (item.parent != '0') {
            isParent = false;
          }
          _categories.add(item);
        }
      }

      for (var category in categoryList!) {
        Category? item = _categories.firstWhereOrNull((cat) => cat.id == category.id);
        if (item == null && isParent && category.parent != '0') {
          _subCategories.add(category);
        }
      }
      result = [..._categories, ..._subCategories];
    }

    for (Category cat in result!) {
      _categoryList[cat.id] = cat;
    }
    this.categoryList = _categoryList;
    categories = result;
    notifyListeners();
  }

  Future<void> getCategories({lang, sortingList}) async {
    try {
      printLog("[Category] getCategories");
      isLoading = true;
      notifyListeners();
      categories = await _service.getCategories(lang: lang);
      message = null;

      ///----store LISTING----///
      if (Config().isListingType()) {
        for (Category cat in categories!) {
          categoryList[cat.id] = cat;
        }
        isLoading = false;
        notifyListeners();

        ///----store LISTING----///
      } else {
        sortCategoryList(categoryList: categories, sortingList: sortingList);
        isLoading = false;
        notifyListeners();
      }
    } catch (err, _) {
      isLoading = false;
      message = "There is an issue with the app during request the data, "
              "please contact admin for fixing the issues " +
          err.toString();
      //notifyListeners();
    }
  }
}
