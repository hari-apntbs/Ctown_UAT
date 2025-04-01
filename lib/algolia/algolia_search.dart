import 'dart:convert';
import 'dart:io';

import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;

import '../common/constants/general.dart';
import '../common/constants/loading.dart';
import '../common/constants/route_list.dart';
import '../models/app_model.dart';
import '../models/product_model.dart';
import '../services/index.dart';
import '../widgets/home/search/search_results.dart';
import 'credentials.dart';

class AlgoliaSearch extends StatefulWidget {
  String? barcode;
  String? indexName;
  AlgoliaSearch({super.key, this.indexName,  this.barcode});

  @override
  State<AlgoliaSearch> createState() => _AlgoliaSearchState();
}

class _AlgoliaSearchState extends State<AlgoliaSearch> {
  // 1. Create a Hits Searcher
  // late HitsSearcher hitsSearcher;
  final TextEditingController _searchTextController = TextEditingController();
  late HitsSearcher hitsSearcher;
  List<Hit> searchHitList = [];
  SharedPreferences? search_prefs;
  List<String> searchHistory = [];
  List<SearchHist> recentSearches = [];


  @override
  void initState() {
    super.initState();
    sharedPrefs();
    hitsSearcher = HitsSearcher(
      applicationID: Credentials.applicationID,
      apiKey: Credentials.searchOnlyKey,
      indexName: widget.indexName ?? "",
    );
    _searchTextController.addListener(() {
      setState(() {});
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if(widget.barcode != null && widget.barcode != "") {
        if(mounted){
          setState(() {
            _searchTextController.text = widget.barcode!;
          });
          hitsSearcher.query(_searchTextController.text);
        }
      }
    });
    // getJson();
  }

  bool isRTL(String text) {
    return intl.Bidi.detectRtlDirectionality(text);
  }

  sharedPrefs() async {
    search_prefs = await SharedPreferences.getInstance();
    var data;
    if(Provider.of<AppModel>(context, listen: false).langCode == "en") {
      data = await search_prefs?.getString("recentSearch") ?? "";
    }
    else {
      data = await search_prefs?.getString("recentSearchAr") ?? "";
    }
    if(data != "") {
      var list = jsonDecode(data) as List;
      var lines = list.map((e) => SearchHist.fromJson(e)).toList();
      recentSearches.addAll(lines);
      if(lines.length > 0) {
        lines.forEach((element) {
          if(element.searchText != "") {
            searchHistory.add(element.searchText);
          }
        });
        searchHistory = searchHistory.reversed.toList();
        searchHistory = searchHistory.toSet().toList();
        print(searchHistory.length);
      }
    }
  }
  getJson() async {
    PermissionStatus status = await Permission.storage.status;
    if(!status.isGranted){
      await Permission.storage.request();
    }
    PermissionStatus status2 = await Permission.manageExternalStorage.status;
    if(!status2.isGranted){
      await Permission.manageExternalStorage.request();
    }
    Directory downloadFile = await Directory('/storage/emulated/0/Download');
    var file = File('${downloadFile.path}/response.json');
    final contents = await file.readAsString();
    var jsonList = json.decode(contents) as List;
    int count = 1;
    for(var item in jsonList){
      item["imageUrl"] = "https://picsum.photos/id/$count/200/300";
      count++;
    }
    file.writeAsStringSync(jsonEncode(jsonList));
    print(jsonList.length);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back,
            color: Colors.white,),
        ),
        title: Container(
          height: 40,
          child: TextField(
            controller: _searchTextController,
            textDirection: isRTL(_searchTextController.text) ? TextDirection.rtl : TextDirection.ltr,
            autofocus: true,
            onChanged: (value) {
              if(isRTL(_searchTextController.text)) {
                hitsSearcher = HitsSearcher(
                  applicationID: Credentials.applicationID,
                  apiKey: Credentials.searchOnlyKey,
                  indexName: "Ctown SM Tela Al-Ali_ar_76",
                );
                if(value != "") {
                  hitsSearcher.query(value);
                }
              }
              else {
                hitsSearcher = HitsSearcher(
                  applicationID: Credentials.applicationID,
                  apiKey: Credentials.searchOnlyKey,
                  indexName: "Ctown SM Tela Al-Ali_En_75",
                );
                if(value != "") {
                  hitsSearcher.query(value);
                }
              }
            },
            decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
                border: InputBorder.none,
                hintText: Provider.of<AppModel>(context, listen: false).langCode == "en" ? "Search...." :"يبحث....",
                hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14
                ),
                contentPadding:
                const EdgeInsets.only(left: 14.0, bottom: 15.0, top: 0.0),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.surface),
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.surface),
                  borderRadius: BorderRadius.circular(20),
                ),
                prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 15, color: Colors.grey,),
                suffixIcon: _searchTextController.text.isNotEmpty ?
                InkWell(
                    onTap: () {
                      _searchTextController.clear();
                      hitsSearcher.query("");
                      setState(() {});},
                    child: const Icon(
                      Icons.clear, size: 17,)
                ) : null
            ),
            onSubmitted: (value) async {
              String searchString = "";
              List<String> result = [];
              List<String> parts = value.split(" ");
              if(parts.length > 1) {
                for (String part in parts) {
                  if(part.length > 2) {
                    result.add(part);
                  }
                }

                // Combine the parts in pairs
                for (int i = 0; i < parts.length - 1; i++) {
                  result.add(parts[i] + parts[i + 1]);
                }

                // Add the full original string
                result.add(value);
                searchString = result.reversed.join(", ");
              }
              else {
                searchString = value;
              }
              if(searchHitList.length > 0) {
                String val = searchHitList[0]["_highlightResult"]["product_name"]["value"];
                if(val.contains("<")) {
                  String res = val.substring(val.indexOf("<"), val.lastIndexOf(">")+1);
                  String withoutTags = res.replaceAll(RegExp(r'<[^>]*>'), '');
                  String result = withoutTags.toLowerCase().trim();
                  SearchHist search = SearchHist(id: (searchHistory.length+1).toString(), searchText: result);
                  recentSearches.add(search);
                  var data = recentSearches.map((e) {
                    return e.toJson();
                  }).toList();
                  var saveSearch = jsonEncode(data);
                  if(Provider.of<AppModel>(context, listen: false).langCode == "en") {
                    search_prefs?.setString("recentSearch", saveSearch);
                  }
                  else {
                    search_prefs?.setString("recentSearchAr", saveSearch);
                  }
                  searchHistory.insert(0, result);
                  searchHistory = searchHistory.toSet().toList();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SearchResults(
                        name: searchString,
                        isBarcode: false,
                        cateId: searchHitList.length > 0 ?searchHitList[0]["category_id"] : "",
                        searchLang: isRTL(_searchTextController.text) ? "ar" :"en",
                        searchString: _searchTextController.text,

                      )));
                  setState(() {});
                }
                else if(val.isNotEmpty) {
                  searchHistory.insert(0, val);
                  searchHistory = searchHistory.toSet().toList();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SearchResults(
                        name: val,
                        isBarcode: false,
                        cateId: searchHitList.length > 0 ?searchHitList[0]["category_id"] : "",
                        searchLang: isRTL(_searchTextController.text) ? "ar" :"en",
                        searchString: _searchTextController.text,
                      )));
                  setState(() {});
                }
              }
              else {
                searchHistory.insert(0, _searchTextController.text);
                searchHistory = searchHistory.toSet().toList();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SearchResults(
                      name: _searchTextController.text,
                      isBarcode: false,
                      cateId: searchHitList.length > 0 ?searchHitList[0]["category_id"] : "",
                      searchLang: isRTL(_searchTextController.text) ? "ar" :"en",
                      searchString: _searchTextController.text,
                    )));
                setState(() {});
              }
            },
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildRecentSearches(),
          Expanded(
              child: StreamBuilder<SearchResponse>(
                stream: hitsSearcher.responses,
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    final response = snapshot.data;
                    final hits = response?.hits.toList() ?? [];
                    searchHitList = hits;
                    // 3.2 Display your search hits
                    return ListView.builder(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: hits.length,
                        itemBuilder: (_, i) {
                          final highlighted = hits[i].getProductHighlight(hits[i]['_highlightResult']['product_name']['value'] ?? "", inverted: true);
                          return Column(
                            children: [
                              ListTile(
                                onTap: () async {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: kLoadingWidget,
                                  );
                                  final _service = Services();
                                  var productData = await _service.searchProducts(
                                      name: hits[i]["sku"],
                                      categoryId: hits[i]["category_id"],
                                      tag: "",
                                      attribute: "",
                                      attributeId: "",
                                      page: 1,
                                      lang: Provider.of<AppModel>(context, listen: false).langCode,
                                      isBarcode: false);
                                  Navigator.of(context, rootNavigator: true).pop();
                                  if(productData.length > 0){
                                    Navigator.of(context).pushNamed(
                                      RouteList.productDetail,
                                      arguments: productData[0],
                                    );
                                  }
                                  else {
                                    // FocusScope.of(context).unfocus();
                                    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong")));
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: kLoadingWidget,
                                    );
                                    final _service = Services();
                                    var productData = await _service.searchProducts(
                                        name: hits[i]["product_name"].contains("-") ? hits[i]["product_name"].substring(0, hits[i]["product_name"].indexOf("-")) :
                                        hits[i]["product_name"],
                                        categoryId: hits[i]["category_id"],
                                        tag: "",
                                        attribute: "",
                                        attributeId: "",
                                        page: 1,
                                        lang: Provider.of<AppModel>(context, listen: false).langCode,
                                        isBarcode: false);
                                    printLog(productData.length);
                                    Navigator.of(context, rootNavigator: true).pop();
                                    if(productData.length == 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Product not found")));
                                    }
                                    else {
                                      var config = { "category": hits[i]["category_id"], "screens": "Bakery"};
                                      // printLog(await SearchRepository().brandFacets.first);
                                      ProductModel.showList(
                                        context: context,
                                        config: config,
                                        products: productData,
                                        showCountdown: false,
                                        countdownDuration: const Duration(milliseconds: 0),
                                      );
                                    }
                                  }
                                },
                                tileColor: Theme.of(context).scaffoldBackgroundColor,
                                dense: true,
                                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                                leading: const Icon(Icons.search, color: Colors.grey,),
                                trailing: IconButton(
                                  onPressed: () {
                                    _searchTextController.value = TextEditingValue(
                                      text: hits[i]["product_name"],
                                      selection: TextSelection.fromPosition(
                                        TextPosition(offset: hits[i]["product_name"].length),
                                      ),
                                    );
                                    hitsSearcher.query(_searchTextController.text);
                                  },
                                  icon: const Icon(Icons.north_west, color: Colors.grey,),
                                ),
                                title: RichText(
                                    text: TextSpan(
                                        style: GoogleFonts.poppins(
                                            color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white :Colors.black,
                                            fontSize: 15
                                        ),
                                        children: highlighted.toInlineSpans(
                                            regularTextStyle: TextStyle(
                                                color: Theme.of(context).primaryColor,
                                                fontWeight: FontWeight.bold
                                            ),
                                            highlightedTextStyle: TextStyle(
                                                color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white :Colors.black,
                                                fontWeight: FontWeight.bold
                                            )
                                        ))),
                                subtitle: Text(Provider.of<AppModel>(context, listen: false).langCode == "en" ? "In ${hits[i]["category_name"]}" :" في${hits[i]["category_name"]}",
                                  style: TextStyle(
                                      fontSize: 10,
                                    color: Colors.grey
                                  ),),
                                // leading: Image.network(hits[i]["imageUrl"],fit: BoxFit.cover,height: 60, width: 60,
                                //     loadingBuilder: (BuildContext context, Widget child,
                                //         ImageChunkEvent? loadingProgress) {
                                //       if (loadingProgress == null) return child;
                                //       return Center(
                                //         child: CircularProgressIndicator(
                                //           color: Theme.of(context).primaryColor,
                                //         ),
                                //       );
                                //     },
                                //     errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                //       return Center(
                                //         child: Text("error"),
                                //       );
                                //     }),
                              ),
                              Container(
                                  height: 1,
                                  width: MediaQuery.of(context).size.height,
                                  child: Divider(thickness: 0.4,color: Colors.grey,))
                            ],
                          );
                        }
                    );
                  } else {
                    if(snapshot.hasError || (snapshot.connectionState == ConnectionState.done && !snapshot.hasData)) {
                      return Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: const Center(
                          child: Text("Nothing found",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15
                            ),),
                        ),
                      );
                    }
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              )
          ),
        ],
      )
  );

  buildRecentSearches() {
    return searchHistory.length > 0 ?
    Container(
        padding: EdgeInsets.all(8),
        height: 50,
        width: double.infinity,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return FloatingActionButton.extended(
              label: Text(searchHistory[index],
                style: TextStyle(
                    fontWeight: FontWeight.w600
                ),),
              extendedPadding: EdgeInsets.only(right: 5, left: 5, top: 0,bottom: 0),
              backgroundColor: Colors.white,
              elevation: 0,
              icon: Icon(
                Icons.history,
                size: 17.0,
                color: Colors.grey,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                      color: Colors.grey.shade400
                  )
              ),
              onPressed: () {
                _searchTextController.text = searchHistory[index];
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SearchResults(
                      name: searchHistory[index],
                      isBarcode: false,
                      cateId: searchHitList.length > 0 ?searchHitList[0]["category_id"] : "",
                      searchLang: isRTL(_searchTextController.text) ? "ar" :"en",
                      searchString: _searchTextController.text,
                    )));
              },
            );
          },
          itemCount: searchHistory.length, separatorBuilder: (BuildContext context, int index) {
          return SizedBox(width: 10,);
        },)
    ) :SizedBox.shrink();
  }

  @override
  void dispose() {
    super.dispose();
    // 4. Release underling resources
    hitsSearcher.dispose();
  }
}

class SearchHist {
  final String id;
  final String searchText;

  SearchHist({required this.id,required this.searchText});

  factory SearchHist.fromJson(Map<String, dynamic> parsedJson) {
    return SearchHist(
        id: parsedJson['id'] ?? "",
        searchText: parsedJson['searchText'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "searchText": searchText
    };
  }
}