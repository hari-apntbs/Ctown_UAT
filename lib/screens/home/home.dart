import 'dart:async';
import 'dart:io';


import 'package:app_links/app_links.dart';
import 'package:ctown/widgets/appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../common/constants.dart';
import '../../models/app_model.dart';
import '../../models/point_model.dart';
import '../../models/user_model.dart';
import '../../screens/base.dart';
import '../../widgets/home/background.dart';
import '../../widgets/home/index.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({this.changeTabTo});
  final Function? changeTabTo;

  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends BaseScreen<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  @override
  bool get wantKeepAlive => false;

  Uri? _latestUri;
  StreamSubscription? _sub;
  int? itemId;
  final appLinks = AppLinks();

  @override
  void dispose() {
    printLog("[Home] dispose");
    _sub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    printLog("[Home] initState");
    initPlatformState();
    super.initState();
  }

  Future<void> initPlatformState() async {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      await initPlatformStateForStringUniLinks();
    }
  }

  Future<void> initPlatformStateForStringUniLinks() async {
    _sub = appLinks.uriLinkStream.listen((link) {
      if (!mounted) return;
      setState(() {
        _latestUri = null;
        try {
          _latestUri = link;
          setState(() {
            itemId = int.parse(_latestUri!.path.split('/')[1]);
          });
        } on FormatException {
          printLog('[initPlatformStateForStringUniLinks] error');
        }
      });
    }, onError: (err) {
      if (!mounted) return;
      setState(() {
        _latestUri = null;
      });
    });

    appLinks.uriLinkStream.listen((link) {
      printLog('got link: $link');
    }, onError: (err) {
      printLog('got err: $err');
    });
  }

  @override
  void afterFirstLayout(BuildContext context) {
    printLog("[Home] afterFirstLayout");
    final userModel = Provider.of<UserModel>(context, listen: false);

    if (userModel.user != null && userModel.user!.cookie != null) {
      Provider.of<PointModel>(context, listen: false).getMyPoint(
          Provider.of<UserModel>(context, listen: false).user!.cookie);
    }
    DynamicLinkService();
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    printLog("[Home] build");
    return Consumer<AppModel>(
      builder: (context, value, child) {
        if (value.appConfig == null) {
          return kLoadingWidget(context);
        }

        bool isStickyHeader = value.appConfig!["Setting"] != null
            ? (value.appConfig!["Setting"]["StickyHeader"] ?? false)
            : false;

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(57.0), // Desired app bar height
            child: Platform.isAndroid
                ? AppBar(
                    automaticallyImplyLeading: false,
                    titleSpacing: 0,
                    title: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: AppLocal(scanBarcode: "Search"),
                    ),
                  )
                : AppBar(
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Container(
                padding: const EdgeInsets.only(top: 4),
                height: 57,
                width: double.infinity,
                color: Theme.of(context).primaryColor,
                child: AppLocal2(
                  scanBarcode: "Search",
                ),
              ),
            ),
          ),
          body: Stack(
            children: <Widget>[
              if (value.appConfig!['Background'] != null)
                isStickyHeader
                    ? SafeArea(
                  child: HomeBackground(
                    config: value.appConfig!['Background'],
                  ),
                )
                    : HomeBackground(config: value.appConfig!['Background']),
              HomeLayout(
                isPinAppBar: isStickyHeader,
                isShowAppbar:
                value.appConfig!['HorizonLayout'][0]['layout'] == 'logo',
                configs: value.appConfig,
                key: Key(value.langCode!),
                changeTabTo: widget.changeTabTo,
              ),
            ],
          )
        );
      },
    );
  }
}
