import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';

import '../../generated/l10n.dart';
import '../../models/app_model.dart';

Future<Pages> PagesData(langcode) async {
  final response = await http
      .get(Uri.parse('https://up.ctown.jo/api/pages.php?id=28&lang_code=$langcode'));

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
}

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

class DeliverypolicyScreen extends StatefulWidget {
  //PrivacyScreen({Key key}) : super(key: key);
  final arguments;
  DeliverypolicyScreen(this.arguments);
  @override
  _PrivacyState createState() => _PrivacyState();
}

//PrivacyScreen({Key key, this.pages,this.arguments}) : super(key: key);
@override
class _PrivacyState extends State<DeliverypolicyScreen> {
  Future<Pages>? pages;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    var langCode = Provider.of<AppModel>(context, listen: false).langCode;
    pages = PagesData(langCode);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onScrollsToTop(ScrollsToTopEvent event) async {
    _scrollController.animateTo(0, duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
  }


  Widget build(BuildContext context) {
    return ScrollsToTop(
      onScrollsToTop: _onScrollsToTop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            S.of(context).DeliveryPolicy,
            // 'Delivery Policy',
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
                // return Text(snapshot.data.content,
                //     style: const TextStyle(fontSize: 15.0, height: 1.4),
                //     textAlign: TextAlign.justify,);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              } else {
                return Container(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      //hild: CircularProgressIndicator()
                      child: SpinKitCubeGrid(
                        color: Theme.of(context).primaryColor,
                        size: 30.0,
                      ),
                    ));
              }
              // By default, show a loading spinner.
              //return CircularProgressIndicator();
            },
          ),

          // padding: const EdgeInsets.all(20.0),
          // child: Text(S.of(context).privacyTerms,
          //   style: const TextStyle(fontSize: 15.0, height: 1.4),
          //   textAlign: TextAlign.justify,
        ),
      ),
    );
  }
}
