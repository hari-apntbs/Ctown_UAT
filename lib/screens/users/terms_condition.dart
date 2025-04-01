import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

import '../../generated/l10n.dart';
import '../../models/app_model.dart';

class Pages {
  final String? page_id;
  final String? content;
  final String? title;
  Pages({this.page_id, this.content, this.title});

  factory Pages.fromJson(Map<String, dynamic> json) {
    return Pages(
      page_id: json['page_id'],
      content: json['content'],
      title: json['title'],
    );
  }
}

class TermsScreen extends StatefulWidget {
  //PrivacyScreen({Key key}) : super(key: key);
  final String arguments;
  TermsScreen(this.arguments);
  @override
  State<StatefulWidget> createState() {
    return _PrivacyState(arguments);
  }
  //_PrivacyState createState() => _PrivacyState();
}

Future<Pages> PagesData(langcode) async {
  //if (kAdvanceConfig['DefaultLanguage'] == "en") {
  final response = await http
      .get(Uri.parse('https://up.ctown.jo/api/pages.php?id=26&lang_code=$langcode'));
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final jsonresponse = json.decode(response.body);
    return Pages.fromJson(jsonresponse[0]);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load pages');
  }
  //}
}

//PrivacyScreen({Key key, this.pages,this.arguments}) : super(key: key);
@override
class _PrivacyState extends State<TermsScreen> {
  String arguments;
  _PrivacyState(this.arguments);
  Future<Pages>? pages;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    var langcode = Provider.of<AppModel>(context, listen: false).langCode;
    pages = PagesData(langcode);
  }

  Future<void> _onScrollsToTop(ScrollsToTopEvent event) async {
    _scrollController.animateTo(0, duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
  }

  Widget build(BuildContext context) {
    return Platform.isIOS ? ScrollsToTop(
      onScrollsToTop: _onScrollsToTop,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            S.of(context).PrivacyAndTerm,
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
          leading: GestureDetector(
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20.0),
          child: FutureBuilder<Pages>(
            future: pages,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Html(data: snapshot.data!.content);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              } else {
                return Container(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: SpinKitCubeGrid(
                        color: Theme.of(context).primaryColor,
                        size: 30.0,
                      ),
                    ));
              }
            },
          ),
        ),
      ),
    ) : Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          S.of(context).PrivacyAndTerm,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        leading: GestureDetector(
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<Pages>(
          future: pages,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Html(data: snapshot.data!.content);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            } else {
              return Container(
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: SpinKitCubeGrid(
                      color: Theme.of(context).primaryColor,
                      size: 30.0,
                    ),
                  ));
            }
          },
        ),
      ),
    );
  }
}
