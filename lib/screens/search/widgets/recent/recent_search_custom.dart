import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/search_model.dart';
import 'recent_products_custom.dart';
import 'package:ctown/widgets/home/search/search_results.dart';

class RecentSearchesCustom extends StatefulWidget {
  final Function? onTap;

  RecentSearchesCustom({this.onTap});

  @override
  _RecentSearchesCustomState createState() => _RecentSearchesCustomState();
}

class _RecentSearchesCustomState extends State<RecentSearchesCustom> {
  List<String> searchTexts = [];

  TextEditingController searchTextController = TextEditingController(text: "");
  getNames() {
    String text = "";

    for (int i = 0; i < searchTexts.length; i++) {
      text = text + searchTexts[i];
      if (i < searchTexts.length - 1) {
        text = text + ",";
      }
    }
    print(text);
    // searchTexts.forEach((element) {
    //   text = text + element + ",";
    // });
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final widthContent = (screenSize.width / 2) - 4;

    return Consumer<SearchModel>(
      builder: (context, model, child) {
        return (model.keywords.isEmpty)
            ? renderEmpty(context)
            : renderKeywords(model, widthContent, context);
      },
    );
  }

  Widget renderEmpty(context) {
    return SingleChildScrollView(
      child: Container(
        // color: Colors.blue,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 30, right: 10),
                      // width: 250,
                      child: Row(children: [
                        Expanded(
                          child: TextField( 
                            // obscureText: true,
                            controller: searchTextController,
                            decoration: InputDecoration(),
                            onSubmitted: (e) {
                              if (searchTextController.text.isNotEmpty)
                                setState(() {
                                  searchTexts.add(e);
                                  searchTextController.clear();
                                });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            if (searchTextController.text.isNotEmpty)
                              setState(() {
                                searchTexts.add(searchTextController.text);
                                searchTextController.clear();
                              });
                          },
                        )
                      ]),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20, left: 30),
                      //  right: 100),
                      // height: 150,
                      // color: Colors.red,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Products:",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Column(
                              children: List.generate(
                                searchTexts.length,
                                (index) => Container(
                                    height: 30,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            searchTexts[index],
                                            style: TextStyle(fontSize: 14.5),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.close,
                                              size: 15,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                searchTexts.removeAt(index);
                                              });
                                            },
                                          ),
                                        ])),
                              ),
                            ),
                          ]),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        child: Text(
                          "Search",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SearchResults(
                                    name: getNames(),
                                    isBarcode: false,
                                  )));
                        },
                      ),
                    ),
                  ]),
            ),
            SizedBox(
              height: 100,
            ),
            Image.asset(
              kEmptySearch,
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 10),
            Container(
              width: 250,
              child: Text(
                S.of(context).searchForItems,
                style: const TextStyle(color: kGrey400),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget renderKeywords(
      SearchModel model, double widthContent, BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
          Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 30, right: 10),
                      // width: 250,
                      child: Row(children: [
                        Expanded(
                          child: TextField(
                            // obscureText: true,
                            controller: searchTextController,
                            decoration: InputDecoration(),
                            onSubmitted: (e) {
                              if (searchTextController.text.isNotEmpty)
                                setState(() {
                                  searchTexts.add(e);
                                  searchTextController.clear();
                                });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            if (searchTextController.text.isNotEmpty)
                              setState(() {
                                searchTexts.add(searchTextController.text);
                                searchTextController.clear();
                              });
                          },
                        )
                      ]),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20, left: 30),
                      //  right: 100),
                      // height: 150,
                      // color: Colors.red,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Products:",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Column(
                              children: List.generate(
                                searchTexts.length,
                                (index) => Container(
                                    height: 30,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            searchTexts[index],
                                            style: TextStyle(fontSize: 14.5),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.close,
                                              size: 15,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                searchTexts.removeAt(index);
                                              });
                                            },
                                          ),
                                        ])),
                              ),
                            ),
                          ]),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        child: Text(
                          "Search",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SearchResults(
                                    name: getNames(),
                                    isBarcode: false,
                                  )));
                        },
                      ),
                    ),
                  ]),
            ),
        Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                S.of(context).recentSearches,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (model.keywords.isNotEmpty)
                InkWell(
                  onTap: model.clearKeywords,
                  child: Text(  
                    S.of(context).clear,
                    style: const TextStyle(color: Colors.yellow, fontSize: 13),
                  ), 
                )
            ],
          ),
        ),
        Card(
          elevation: 0,
          color: Theme.of(context).primaryColorLight,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: model.keywords
                .take(5)
                .map((e) => ListTile(
                      title: Text(e,
                          style: const TextStyle(
                            fontSize: 14,
                          )),
                      onTap: () {
                        widget.onTap?.call(e);
                      },
                    ))
                .toList(),
          ),
        ),
        RecentProductsCustom(),
      ],
    );
  }
}

/*
class RecentSearchesCustom extends StatefulWidget {
  final Function onTap;

  RecentSearchesCustom({this.onTap});

  @override
  _RecentSearchesCustomState createState() => _RecentSearchesCustomState();
}

class _RecentSearchesCustomState extends State<RecentSearchesCustom> {
  List<String> searchTexts = [];

  TextEditingController searchTextController = TextEditingController(text: "");
  getNames() {
    String text = "";

    for (int i = 0; i < searchTexts.length; i++) {
      text = text + searchTexts[i];
      if (i < searchTexts.length - 1) {
        text = text + ",";
      }
    }
    print(text);
    // searchTexts.forEach((element) {
    //   text = text + element + ",";
    // });
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final widthContent = (screenSize.width / 2) - 4;

    return Consumer<SearchModel>(
      builder: (context, model, child) {
        return (model.keywords?.isEmpty ?? true)
            ? renderEmpty(context)
            : renderKeywords(model, widthContent, context);
      },
    );
  }

  Widget renderEmpty(context) {
    return SingleChildScrollView(
      child: Container(
        // color: Colors.blue,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      // width: 250,
                      child: Row(children: [
                        Expanded(
                          child: TextField(
                            // obscureText: true,
                            controller: searchTextController,
                            decoration: InputDecoration(),
                            onSubmitted: (e) {
                              setState(() {
                                searchTexts.add(e);
                                searchTextController.clear();
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              searchTexts.add(searchTextController.text);
                              searchTextController.clear();
                            });
                          },
                        )
                      ]),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20, left: 30),
                      //  right: 100),
                      // height: 150,
                      // color: Colors.red,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Products:",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Column(
                              children: List.generate(
                                searchTexts.length,
                                (index) => Container(
                                    height: 30,
                                    child: Row(children: [
                                      Text(
                                        searchTexts[index],
                                        style: TextStyle(fontSize: 14.5),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          size: 15,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            searchTexts.removeAt(index);
                                          });
                                        },
                                      ),
                                    ])),
                              ),
                            ),
                          ]),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.only(left: 20),
                      child: RaisedButton(
                        child: Text("Search"),
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SearchResults(
                                    name: getNames(),
                                    isBarcode: false,
                                  )));
                        },
                      ),
                    ),
                  ]),
            ),
            SizedBox(
              height: 100,
            ),
            Image.asset(
              kEmptySearch,
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 10),
            Container(
              width: 250,
              child: Text(
                S.of(context).searchForItems,
                style: const TextStyle(color: kGrey400),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget renderKeywords(
      SearchModel model, double widthContent, BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                S.of(context).recentSearches,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (model.keywords.isNotEmpty)
                InkWell(
                  onTap: model.clearKeywords,
                  child: Text(
                    S.of(context).clear,
                    style: const TextStyle(color: Colors.yellow, fontSize: 13),
                  ),
                )
            ],
          ),
        ),
        Card(
          elevation: 0,
          color: Theme.of(context).primaryColorLight,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: model.keywords
                .take(5)
                .map((e) => ListTile(
                      title: Text(e,
                          style: const TextStyle(
                            fontSize: 14,
                          )),
                      onTap: () {
                        widget.onTap?.call(e);
                      },
                    ))
                .toList(),
          ),
        ),
        RecentProductsCustom(),
      ],
    );
  }
}
*/