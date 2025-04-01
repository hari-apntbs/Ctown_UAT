import 'package:ctown/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../../common/constants/loading.dart';
import '../../../generated/l10n.dart';
import '../../../models/search_model.dart';
import '../../../widgets/home/vertical/vertical_simple_list.dart';

class SearchResultsCustom extends StatefulWidget {
  final String name;
  final bool? isBarcode;

  const SearchResultsCustom({required this.name, this.isBarcode});

  @override
  _SearchResultsCustomState createState() => _SearchResultsCustomState();
}

class _SearchResultsCustomState extends State<SearchResultsCustom> {
  final _refreshController = RefreshController();

  SearchModel get _searchModel =>
      Provider.of<SearchModel>(context, listen: false);

  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchModel>(
      builder: (_, model, __) {
        final _products = model.products;

        if (_products == null) {
          return kLoadingWidget(context);
        }

        if (_products.isEmpty) {
          return Center(
            child: Text(S.of(context).noProduct),
          );
        }

        return SmartRefresher(
          header: MaterialClassicHeader(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          controller: _refreshController,
          enablePullUp: !model.isEnd,
          enablePullDown: false,
          onRefresh: _searchModel.refresh,
          onLoading: () async {
            await _searchModel.loadProduct(
                name: widget.name, isBarcode: widget.isBarcode);
            _refreshController.loadComplete();
          },
          footer: kCustomFooter(context),
          child: ListView.builder(
            itemCount: _products.length,
            itemBuilder: (context, index) {
              printLog("Products Length: ${_products.length}");
              printLog("Index: $index");
              printLog("Product: ${_products[index]}");
              final product = _products[index];
              return SimpleListView(item: product);
            },
          ),
        );
      },
    );
  }
}
