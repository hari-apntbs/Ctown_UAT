import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../common/constants.dart';
import '../../../models/index.dart'
    show
        AppModel,
        CategoryModel,
        FilterAttributeModel,
        FilterTagModel,
        SearchModel;
import '../../../screens/index.dart'
    // ignore: unused_shown_name
    show
        FilterSearch,
        RecentSearchesCustom,
        SearchBox,
        SearchResultsCustom;
import '../../common/auto_hide_keyboard.dart';
import 'search_results.dart';

class HomeSearchPage extends StatefulWidget {
  final _barcodedata;
  HomeSearchPage(this._barcodedata);
  @override
  State<StatefulWidget> createState() => _HomeSearchPageState();
}

class _HomeSearchPageState<T> extends State<HomeSearchPage> {
  // This node is owned, but not hosted by, the search page. Hosting is done by
  // the text field.
  final _searchFieldNode = FocusNode();
  final _searchFieldController = TextEditingController();

  bool isVisibleSearch = true;
  bool _showResult = false;
  List<String>? _suggestSearch;
  // ignore: unused_field
  String _scanBarcode = 'Search';
  bool isBarcode = false;

  SearchModel get _searchModel =>
      Provider.of<SearchModel>(context, listen: false);

  String get _searchKeyword => _searchFieldController.text;

//
  List<String> get suggestSearch =>
      _suggestSearch
          ?.where((s) => s.toLowerCase().contains(_searchKeyword.toLowerCase()))
          .toList() ??
      <String>[];

  @override
  void initState() {
    super.initState();
    _searchFieldController.text = widget._barcodedata;
    if (widget._barcodedata != null && widget._barcodedata != "") {
      isBarcode = true;
    }

    _searchFieldNode.addListener(() {
      if (_searchKeyword.isEmpty && !_searchFieldNode.hasFocus) {
        _showResult = false;
      } else {
        _showResult = !_searchFieldNode.hasFocus;
      }
    });
  }

  @override
  void dispose() {
    _searchFieldNode.dispose();
    _searchFieldController.dispose();
//    _searchModel.dispose();
    super.dispose();
  }

  void _onSearchTextChange(String value) {
    if (value.isEmpty) {
      _showResult = false;
      setState(() {});
      return;
    }

    if (_searchFieldNode.hasFocus) {
      if (suggestSearch.isEmpty) {
        setState(() {
          _showResult = true;

          /// added for barcode scan change
          _searchModel.loadProduct(name: value, isBarcode: isBarcode);
          isBarcode = false;
        });
      } else {
        setState(() {
          _showResult = false;
        });
      }
    }
  }

  Future<void> onBarcodePressed(BuildContext context) async {
    var barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await BarcodeScanner.scan();
      if (barcodeScanRes != "-1") {
        _searchFieldController.text = barcodeScanRes.rawContent;
        isBarcode = true;
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      if (barcodeScanRes.rawContent != '-1') _scanBarcode = barcodeScanRes.rawContent;
    });
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
    final List<String> suggestSearch = List<String>.from(
        Provider.of<AppModel>(context).appConfig!['searchSuggestion'] ?? ['']);

    String routeName = isIos ? '' : searchFieldLabel;

    _suggestSearch = List<String>.from(
        Provider.of<AppModel>(context).appConfig!['searchSuggestion'] ?? ['']);

    return Semantics(
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: true,
      label: routeName,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          iconTheme: theme.primaryIconTheme,
          // textTheme: theme.primaryTextTheme,
          // brightness: theme.primaryColorBrightness,
          titleSpacing: 0,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
            onPressed: close,
          ),
          title: SearchBox(
            showSearchIcon: false,
            showCancelButton: false,
            autoFocus: true,
            controller: _searchFieldController,
            focusNode: _searchFieldNode,
            onChanged: _onSearchTextChange,
            // onSubmitted: _onSubmit,
            onSubmitted: (searchStr) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SearchResults(
                        name: searchStr,
                        isBarcode: isBarcode,
                      )));
            },
          ),
          // actions: _buildActions(),
        ),
        body: AutoHideKeyboard(
          child: Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  reverseDuration: const Duration(milliseconds: 300),
                  child: _showResult
                      ? buildResult()
                      : Align(
                          alignment: Alignment.topCenter,
                          child: Consumer<FilterTagModel>(
                            builder: (context, tagModel, child) {
                              return Consumer<CategoryModel>(
                                builder: (context, categoryModel, child) {
                                  return Consumer<FilterAttributeModel>(
                                    builder: (context, attributeModel, child) {
                                      if (tagModel.isLoading ||
                                          categoryModel.isLoading ||
                                          attributeModel.isLoading) {
                                        return kLoadingWidget(context);
                                      }
                                      var child = _buildRecentSearch();

                                      if (_searchFieldNode.hasFocus &&
                                          suggestSearch.isNotEmpty) {
                                        child = isVisibleSearch
                                            ? _buildSuggestions()
                                            : Container();
                                      }

                                      return isVisibleSearch
                                          ? child
                                          : Container();
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearch() {
    return RecentSearchesCustom(onTap: _onSubmit);
  }

  Widget _buildSuggestions() {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).primaryColorLight,
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        itemCount: suggestSearch.length,
        itemBuilder: (_, index) {
          final keyword = suggestSearch[index];
          return GestureDetector(
            onTap: () => _onSubmit(keyword),
            child: ListTile(
              title: Text(keyword),
            ),
          );
        },
      ),
    );
  }

  Widget buildResult() {
    return SearchResultsCustom(
      name: _searchKeyword,
      isBarcode: isBarcode,
    );
  }

  // List<Widget> _buildActions() {
  //   return <Widget>[
  //     IconButton(icon: Image.asset(
  //         "assets/images/barcode.png",
  //         ), onPressed: () => this.onBarcodePressed(context),),
  //
  //     _searchFieldController.text.isEmpty
  //         ? IconButton(
  //             tooltip: 'Search',
  //             icon: const Icon(Icons.search),
  //             onPressed: () {},
  //           )
  //         : IconButton(
  //             tooltip: 'Clear',
  //             icon: const Icon(Icons.clear),
  //             onPressed: () {
  //               _searchFieldController.clear();
  //               _searchFieldNode.requestFocus();
  //             },
  //           ),
  //
  //
  //   ];
  // }

  void _onSubmit(String name) {
    _searchFieldController.text = name;
    setState(() {
      _showResult = true;
      isVisibleSearch = true;
      isBarcode = false;
      _searchModel.loadProduct(name: name);
    });

    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void close() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    Navigator.of(context).pop();
  }
}
