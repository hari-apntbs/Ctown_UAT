import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/config.dart';
import 'common/constants.dart';
import 'common/packages.dart' show ScreenUtil;
import 'models/index.dart'
    show
        AppModel,
        BlogModel,
        CartModel,
        CategoryModel,
        FilterAttributeModel,
        FilterTagModel,
        TagModel,
        UserModel;
import 'screens/animation.dart';
import 'screens/base.dart';
import 'screens/index.dart' show LoginScreen;
import 'screens/settings/check_deliverable.dart';
import 'screens/settings/settings_provider.dart';
import 'services/index.dart';
import 'update_app.dart';

class AppInit extends StatefulWidget {
  final Function? onNext;

  AppInit({this.onNext});

  @override
  _AppInitState createState() => _AppInitState();
}

class _AppInitState extends BaseScreen<AppInit> {
  final StreamController<bool> _streamInit = StreamController<bool>();

  bool isFirstSeen = false;
  bool isLoggedIn = false;
  bool isLoading = true;
  bool isWaitingToNext = true;


  Map? appConfig;

  /// check if the screen is already seen At the first time
  Future<bool> checkFirstSeen() async {
    /// Ignore if OnBoardOnlyShowFirstTime is set to true.
    if (kAdvanceConfig['OnBoardOnlyShowFirstTime'] == false) {
      return false;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = prefs.getBool('seen') ?? false;
    return _seen;
  }

  Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version;
    Provider.of<SettingsProvider>(context, listen: false)
        .setAppVersion(appVersion);
    return appVersion;
  }

  /// Check if the App is Login
  Future<bool> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggedIn') ?? false;
  }

  getSavedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore');
    if (result != null) {
      return true;
    }
    return false;
  }

  Future loadInitData() async {
    try {
      printLog("[AppState] Inital Data");

      isFirstSeen = await checkFirstSeen();
      isLoggedIn = await checkLogin();

      /// Load App model config
      Services().setAppConfig(serverConfig);
      appConfig =
          await Provider.of<AppModel>(context, listen: false).loadAppConfig();

      Future.delayed(Duration.zero, () async {
        /// Load more Category/Blog/Attribute Model beforehand
        if (mounted) {
          final lang = Provider.of<AppModel>(context, listen: false).langCode;

          Provider.of<CategoryModel>(context, listen: false).getCategories(
            lang: lang,
            sortingList:
                Provider.of<AppModel>(context, listen: false).categories,
          );

          Provider.of<AppModel>(context, listen: false).loadCurrency();

          Provider.of<TagModel>(context, listen: false).getTags();

          //Provider.of<BlogModel>(context, listen: false).getBlogs();

          Provider.of<FilterTagModel>(context, listen: false).getFilterTags();

          Provider.of<FilterAttributeModel>(context, listen: false)
              .getFilterAttributes();

          Provider.of<CartModel>(context, listen: false).changeCurrencyRates(
              Provider.of<AppModel>(context, listen: false).currencyRate);
          getAppVersion();
          Provider.of<CartModel>(context, listen: false)
              .setUser(Provider.of<UserModel>(context, listen: false).user);
          if (Provider.of<UserModel>(context, listen: false).user != null) {
            /// Preload address.
            Provider.of<CartModel>(context, listen: false).getAddress(Provider.of<AppModel>(context, listen: false).langCode ?? "en");
          }
          UserModel userModel = Provider.of<UserModel>(context, listen: false);
          if (userModel.user != null &&
              userModel.user!.cookie != null &&
              kAdvanceConfig["EnableSyncCartFromWebsite"] as bool) {
            Services().widget?.syncCartFromWebsite(userModel.user?.cookie ?? "",
                Provider.of<CartModel>(context, listen: false), context, lang ?? "en");
          }

          setState(() {
            isLoading = false;
          });
          if (isWaitingToNext) {
            printLog("dgdfhfgkhjdfg");
            goToNextScreen();
          }
        }
      });

      /// Firebase Dynamic Link Init
      // if (firebaseDynamicLinkConfig['isEnabled'] as bool && isMobile) {
      //   printLog("[dynamic_link] Firebase Dynamic Link Init$isMobile");
      //   DynamicLinkService dynamicLinkService = DynamicLinkService();
      //   dynamicLinkService.generateFirebaseDynamicLink(context);
      // }

      /// Facebook Ads init
      // if (kAdConfig['enable']) {
      //   debugPrint("[AppState] Init Facebook Audience Network");
      //   await FacebookAudienceNetwork.init();
      // }

      printLog("[AppState] Init Data Finish");
    } catch (e, trace) {
      printLog(e.toString());
      printLog(trace.toString());
      setState(() {
        isLoading = false;
      });
      if (isWaitingToNext) {
        goToNextScreen();
      }
    }
  }


  letMeGiveWidget() async {
    printLog("let me give widget");
    var storeAlreadySaved = await getSavedStore();
    return storeAlreadySaved;
  }

  Widget onNextScreen(bool isFirstSeen) {
    if (!isLoggedIn) {
      return LoginScreen(
        onLoginSuccess: (context) async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CheckIfDeliverable(isSkip: false),
            ),
          );
        },
      );
    }
    return FutureBuilder(
      future: letMeGiveWidget(),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.data != null) {
          printLog("print ${snapshot.data}   s");
          return !snapshot.data
              ? const CheckIfDeliverable(isSkip: false)
              : widget.onNext!();
        }
        return Container();
      },
    );

    /*return widget.onNext();*/
  }

  void goToNextScreen() {
    printLog("fgdgfghdfsd");
    Navigator.of(context).pushReplacement(CupertinoPageRoute(
        builder: (BuildContext context) =>
            UpdateApp(child: onNextScreen(isFirstSeen))));
  }

  void checkToShowNextScreen() {
    isWaitingToNext = isLoading;
    if (!isLoading) {
      goToNextScreen();
    }
  }

  @override
  void dispose() {
    _streamInit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? splashScreenType = kSplashScreenType;
    dynamic splashScreenData = kSplashScreen;

    /// showing this blank page will impact to the UX
    // if (appConfig == null) {
    //   return Center(child: Container(color: Theme.of(context).backgroundColor));
    // }

    if (appConfig != null && appConfig!['SplashScreen'] != null) {
      splashScreenType = appConfig!['SplashScreen']['type'];
      splashScreenData = appConfig!['SplashScreen']['data'];
    }

    // if (splashScreenType == 'flare') {
    //   return SplashScreen.navigate(
    //     name: splashScreenData,
    //     startAnimation: 'A&H Market',
    //     backgroundColor: Colors.white,
    //     next: checkToShowNextScreen,
    //     until: () => Future.delayed(const Duration(seconds: 2)),
    //   );
    // }

    // if (splashScreenType == 'animated') {
    //   debugPrint('[FLARESCREEN] Animated');
    //   return AnimatedSplash(
    //     imagePath: splashScreenData,
    //     next: checkFirstSeen,
    //     duration: 2500,
    //     type: AnimatedSplashType.StaticDuration,
    //     isPushNext: true,
    //   );
    // }
    // if (splashScreenType == 'zoomIn') {
    //   return CustomSplash(
    //     imagePath: splashScreenData,
    //     backGroundColor: Colors.white,
    //     animationEffect: 'zoom-in',
    //     logoSize: 50,
    //     next: checkToShowNextScreen,
    //     duration: 2500,
    //   );
    // }
    if (splashScreenType == 'static') {
      return GiphySplashScreen();
      // StaticSplashScreen(
      //   imagePath: splashScreenData,
      //   onNextScreen: checkToShowNextScreen,
      // );
    }
    return Container();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    ScreenUtil.init(context);

    loadInitData();
  }
}
