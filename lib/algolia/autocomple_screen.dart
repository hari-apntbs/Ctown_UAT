import 'dart:convert';

import 'package:ctown/algolia/query_suggestion.dart';
import 'package:ctown/algolia/search_repository.dart';
import 'package:ctown/algolia/suggestion_row_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants.dart';
import '../models/app_model.dart';
import '../models/product_model.dart';
import '../screens/search/widgets/search_box.dart';
import '../services/index.dart';
import 'credentials.dart';
import 'history_row_view.dart';
import 'suggestion_repository.dart';

class AutocompleteScreen extends StatefulWidget {
  String? barcode;
  AutocompleteScreen({Key? key, this.barcode}) : super(key: key);

  @override
  State<AutocompleteScreen> createState() => _AutocompleteScreenState();
}

class _AutocompleteScreenState extends State<AutocompleteScreen> {
  final _searchTextController = TextEditingController();
  String currentStore = "";
  String searchIndex = "";
  final _searchFieldNode = FocusNode();
  var hitsSearcher;

  @override
  void initState() {
    super.initState();
    getSavedStore();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if(widget.barcode != null && widget.barcode != "") {
        if(mounted){
          setState(() {
            _searchTextController.text = widget.barcode!;
          });
        }
      }
    });
  }

  getSavedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore') ?? "";
    var jsonData = jsonDecode(result);
    if(jsonData.length > 0){
      if(Provider.of<AppModel>(context, listen: false).langCode == "en") {
        currentStore = jsonData['store_en']['code'] ?? "";
      }
      else {
        currentStore = jsonData['store_ar']['code'] ?? "";
      }
      if(currentStore != "") {
        searchIndex = await Credentials.getSearchIndex(currentStore);
        printLog("==========search index $searchIndex");
      }
    }
    printLog(jsonData);
  }



  @override
  Widget build(BuildContext context) {
    final suggestionRepository = context.read<SuggestionRepository>();
    return Scaffold(
        body: CustomScrollView(slivers: [
          SliverAppBar(
            leading: IconButton(
                onPressed: () {
                  // Navigator.of(context, rootNavigator: true)
                  //     .pushReplacementNamed(RouteList.dashboard);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back)),
            backgroundColor: Theme.of(context).primaryColor,
            pinned: true,
            titleSpacing: 0,
            elevation: 0,
            title: SearchBox(
              showSearchIcon: false,
              showCancelButton: false,
              autoFocus: true,
              controller: _searchTextController,
              focusNode: _searchFieldNode,
              onChanged: suggestionRepository.query,
              onSubmitted: (value) async {
                try {
                  suggestionRepository.saveKeywords([value]);
                  suggestionRepository.getKeywords(value);
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: kLoadingWidget,
                  );
                  final _service = Services();
                  var productData = await _service.searchProducts(
                      name: value,
                      categoryId: null,
                      tag: "",
                      attribute: "",
                      attributeId: "",
                      page: 1,
                      lang: Provider.of<AppModel>(context, listen: false).langCode,
                      isBarcode: false);
                  printLog(productData.length);
                  var config = { "category": "", "screens": ""};
                  // printLog(await SearchRepository().brandFacets.first);
                  ProductModel.showList(
                      context: context,
                      config: config,
                      products: productData,
                      showCountdown: false,
                      countdownDuration: const Duration(milliseconds: 0),
                      searchValue: value,
                      isAppBarRequired: false,
                      isFromSearch: true
                  );
                }
                catch(e) {
                  printLog(e.toString());
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nothing found")));
                }
                finally {
                  Navigator.of(context, rootNavigator: true).pop();
                }

              },
              // onSubmitted: _onSubmit,
              // onSubmitted: (query) => _onSubmitSearch(query, context),
            ),
          ),
          const SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
              )),
          _sectionHeader(
            suggestionRepository.history,
            Row(
              children: [
                Text(
                  _searchTextController.text.isEmpty ?
                  "Your searches" :"",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                    onPressed: suggestionRepository.clearHistory,
                    child: Text(_searchTextController.text.isEmpty ?"Clear" :"",
                        style: TextStyle(color: Theme.of(context).primaryColor)))
              ],
            ),
          ),
          _sectionBody(
              context,
              suggestionRepository.history,
                  (String item) => HistoryRowView(
                  suggestion: item,
                  onRemove: suggestionRepository.removeFromHistory)),
          _sectionBody(
              context,
              suggestionRepository.suggestions,
                  (QuerySuggestion item) => SuggestionRowView(
                  suggestion: item,
                  onComplete: (suggestion) =>
                  _searchTextController.value = TextEditingValue(
                    text: suggestion,
                    selection: TextSelection.fromPosition(
                      TextPosition(offset: suggestion.length),
                    ),
                  ))),
        ]));
  }

  Widget _sectionHeader<Item>(Stream<List<Item>> itemsStream, Widget title) =>
      StreamBuilder<List<Item>>(
          stream: itemsStream,
          builder: (context, snapshot) {
            final suggestions = snapshot.data ?? [];
            return SliverSafeArea(
                top: false,
                bottom: false,
                sliver: SliverPadding(
                    padding: const EdgeInsets.only(left: 15),
                    sliver: SliverToBoxAdapter(
                      child:
                      suggestions.isEmpty ? const SizedBox.shrink() : title,
                    )));
          });

  Widget _sectionBody<Item>(
      BuildContext context,
      Stream<List<Item>> itemsStream,
      Function(Item) rowBuilder,
      ) =>
      StreamBuilder<List<Item>>(
          stream: itemsStream,
          builder: (context, AsyncSnapshot snapshot) {
            if(snapshot.hasData) {
              final suggestions = snapshot.data ?? [];
              return SliverSafeArea(
                  top: false,
                  sliver: SliverPadding(
                      padding: const EdgeInsets.only(left: 15),
                      sliver: SliverFixedExtentList(
                          itemExtent: 44,
                          delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                              final item = suggestions[index];
                              return InkWell(
                                  onTap: () async {
                                    printLog(item);
                                  },
                                  child: rowBuilder(item));
                            },
                            childCount: suggestions.length,
                          ))));
            }
            else if(snapshot.hasError) {
              return const SliverSafeArea(
                  top: false,
                  bottom: false,
                  sliver: SliverPadding(
                      padding: EdgeInsets.only(left: 5),
                      sliver: SliverToBoxAdapter(
                          child: Center(
                            child: Text("Nothing found",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15
                              ),),
                          )
                      )));
            }
            else if(snapshot.connectionState == ConnectionState.done && !snapshot.hasData) {
              return const SliverSafeArea(
                  top: false,
                  bottom: false,
                  sliver: SliverPadding(
                      padding: EdgeInsets.only(left: 5),
                      sliver: SliverToBoxAdapter(
                          child: Center(
                            child: Text("Nothing found",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15
                              ),),
                          )
                      )));
            }
            return const SliverSafeArea(
                sliver: SliverPadding(padding:EdgeInsets.zero,
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),)
            );
          });

  void _onSubmitSearch(String query, BuildContext context) {
    context.read<SuggestionRepository>().addToHistory(query);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => Provider<SearchRepository>(
              create: (_) => SearchRepository(),
              dispose: (_, value) => value.dispose(),
              child: SizedBox.shrink()),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _searchTextController.dispose();
  }
}