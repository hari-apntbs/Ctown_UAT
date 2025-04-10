import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/constants.dart';
import '../../../models/index.dart' show CategoryModel, Category, ProductModel;
import '../../../screens/index.dart' show SearchBox;
import '../../../widgets/common/auto_hide_keyboard.dart';

class CategorySearch extends StatefulWidget {
  CategorySearch();
  @override
  State<StatefulWidget> createState() => _CategorySearchState();
}

class _CategorySearchState<T> extends State<CategorySearch> {
  final _searchFieldNode = FocusNode();
  final _searchFieldController = TextEditingController();

  List<Category> categories = [];

  @override
  void dispose() {
    _searchFieldNode.dispose();
    _searchFieldController.dispose();
    super.dispose();
  }

  void _onSearchTextChange(String value) {
    if (value.isEmpty) {
      setState(() {
        categories = [];
      });
      return;
    }

    if (_searchFieldNode.hasFocus) {
      final categoryModel = Provider.of<CategoryModel>(context, listen: false);
      categories = categoryModel.categories!
          .where((e) => e.name!.toLowerCase().contains(value.toLowerCase()))
          .toList();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    var theme = Theme.of(context);
    theme = Theme.of(context).copyWith(
      primaryColor: Colors.white,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      // primaryColorBrightness: Brightness.light,
      primaryTextTheme: theme.textTheme,
    );
    final String searchFieldLabel =
        MaterialLocalizations.of(context).searchFieldLabel;
    String routeName = isIos ? '' : searchFieldLabel;

    return Semantics(
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: true,
      label: routeName,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          iconTheme: theme.primaryIconTheme,
          // textTheme: theme.primaryTextTheme,
          // brightness: theme.primaryColorBrightness,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: close,
          ),
          title: SearchBox(
            showSearchIcon: false,
            showCancelButton: false,
            autoFocus: true,
            controller: _searchFieldController,
            focusNode: _searchFieldNode,
            onChanged: _onSearchTextChange,
          ),
        ),
        body: AutoHideKeyboard(
          child: Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    reverseDuration: const Duration(milliseconds: 300),
                    child: buildResult()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildResult() {
    return ListView.separated(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        Category item = categories[index];
        return SearchCategoryItem(category: item);
      },
      separatorBuilder: (context, index) => Divider(
        color: Colors.black.withOpacity(0.05),
      ),
    );
  }

  void close() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    Navigator.of(context).pop();
  }
}

class SearchCategoryItem extends StatelessWidget {
  final Category? category;
  SearchCategoryItem({this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ProductModel.showList(
          context: context, cateId: category!.id, cateName: category!.name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
        child: Row(
          children: <Widget>[
            Container(
              width: 100,
              height: 80,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(category!.image!), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(category!.name!,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
