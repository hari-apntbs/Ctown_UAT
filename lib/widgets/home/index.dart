import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scrolls_to_top/scrolls_to_top.dart';

import '../../models/index.dart' show AppModel, User, UserModel, WishListModel;
import 'dynamic_layout.dart';
import 'vertical.dart';

Future<Album> fetchAlbum() async {
  final response = await http.get(Uri.parse('https://up.ctown.jo/api/getloyalty.php'));
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final jsonresponse = json.decode(response.body);
    return Album.fromJson(jsonresponse);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  final int? userId;
  final String? loylatyCardNumber;
  final String? firstName;
  final String? programname;
  final availablePoints;
  // final String availableAmount;

  Album({
    this.userId,
    this.loylatyCardNumber,
    this.firstName,
    this.programname,
    this.availablePoints,
    //this.availableAmount
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      loylatyCardNumber: json['loylatyCardNumber'],
      firstName: json['firstName'],
      programname: json['programName'],
      availablePoints: json['availablePoints'],
      // availableAmount: json['availableAmount'],
    );
  }
}

class HomeLayout extends StatefulWidget {
  final configs;
  final bool isPinAppBar;
  final bool isShowAppbar;
  final Album? album;
  final User? user;
  final Function? changeTabTo;
  HomeLayout({
    this.configs,
    this.isPinAppBar = false,
    this.isShowAppbar = true,
    this.album,
    this.user,
    this.changeTabTo,
    Key? key,
  }) : super(key: key);

  @override
  _HomeLayoutState createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  late List widgetData;
  ScrollController? _scrollController;
  List<dynamic> widgetList = [];
  @override
  void initState() {
    /// init config data
    ///
    _scrollController = ScrollController();
    widgetData =
        List<Map<String, dynamic>>.from(widget.configs["HorizonLayout"]) ?? [];
    if (widgetData.isNotEmpty && widget.isShowAppbar) {
      widgetData.removeAt(0);
    }

    /// init single vertical layout
    if (widget.configs["VerticalLayout"] != null) {
      Map verticalData =
      Map<String, dynamic>.from(widget.configs["VerticalLayout"]);
      verticalData['type'] = 'vertical';
      widgetData.add(verticalData);
    }

    /// init multi vertical layout
    if (widget.configs["VerticalLayouts"] != null) {
      List verticalLayouts = widget.configs["VerticalLayouts"];
      for (int i = 0; i < verticalLayouts.length; i++) {
        Map verticalData = verticalLayouts[i];
        verticalData['type'] = 'vertical';
        widgetData.add(verticalData);
      }
      ;
    }
    super.initState();
  }

  @override
  void didUpdateWidget(HomeLayout oldWidget) {
    if (oldWidget.configs != widget.configs) {
      /// init config data
      List data =
          List<Map<String, dynamic>>.from(widget.configs["HorizonLayout"]);
      if (data.isNotEmpty && widget.isShowAppbar) {
        data.removeAt(0);
      }

      /// init vertical layout
      if (widget.configs["VerticalLayout"] != null) {
        Map verticalData =
            Map<String, dynamic>.from(widget.configs["VerticalLayout"]);
        verticalData['type'] = 'vertical';
        data.add(verticalData);
      }
      setState(() {
        widgetData = data;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  Future<void> _onScrollsToTop(ScrollsToTopEvent event) async {
    if (mounted) {
      await _scrollController?.animateTo(0,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    }
  }


  double getCacheExtent(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (screenHeight < 700) {
      return 1000.0;
    } else if (screenHeight < 1200) {
      return 2000.0;
    } else {
      return 5000.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.configs == null) return Container();

    List<dynamic> horizonLayout = widget.configs["HorizonLayout"] ?? [];

    // ignore: unused_local_variable
    Map config = horizonLayout
        .firstWhere((element) => element['layout'] == 'logo', orElse: () => {});

    return Platform.isIOS ? ScrollsToTop(
      onScrollsToTop: _onScrollsToTop,
      child: CustomScrollView(
        controller: _scrollController,
        cacheExtent: 13000.0,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                var config = widgetData[index];

                if (config['type'] != null && config['type'] == 'vertical') {
                  return VerticalLayout(config: config);
                }

                return DynamicLayout(
                  config,
                  widget.configs['Setting'],
                  widget.album,
                  widget.user,
                  widget.changeTabTo,
                );
              },
              childCount: widgetData.length,
            ),
          ),
        ],
      ),
    ) : CustomScrollView(
      cacheExtent: 15000.0,
      controller: _scrollController,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              var config = widgetData[index];

              if (config['type'] != null && config['type'] == 'vertical') {
                return VerticalLayout(config: config);
              }

              return DynamicLayout(
                config,
                widget.configs['Setting'],
                widget.album,
                widget.user,
                widget.changeTabTo,
              );
            },
            childCount: widgetData.length,
          ),
        ),
      ],
    );

  }
}
