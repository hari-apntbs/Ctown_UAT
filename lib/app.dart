import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_init.dart';
import 'common/constants.dart';
import 'common/styles.dart';
import 'common/tools.dart';
import 'generated/l10n.dart';
import 'models/address_model.dart';
import 'models/home_product_model.dart';
import 'models/index.dart';
import 'route.dart';
import 'routes/route_observer.dart';
import 'screens/cart/cartProvider.dart';
import 'screens/cart/refresh_controller.dart';
import 'screens/home/notification.dart';
import 'screens/orders/suggested_product_provider.dart';
import 'screens/settings/settings_provider.dart';
import 'screens/settings/store_provider.dart';
import 'screens/users/login.dart';
import 'services/index.dart';
import 'tabbar.dart';
import 'widgets/common/internet_connectivity.dart';
import 'widgets/firebase/firebase_analytics_wapper.dart';
import 'widgets/firebase/firebase_cloud_messaging_wapper.dart';
import "widgets/home/clickandcollect_provider.dart";
import 'widgets/home/scrollProvider.dart';

class App extends StatefulWidget {
  App();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();


  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
}

class AppState extends State<App>
    implements FirebaseCloudMessagingDelegate, UserModelDelegate {
  final globalScaffoldKey = GlobalKey<ScaffoldState>();
  final _app = AppModel();
  final _product = ProductModel();
  final _wishlist = WishListModel();
  final _shippingMethod = ShippingMethodModel();
  final _paymentMethod = PaymentMethodModel();
  //final _advertisementModel = Ads();
  final _order = OrderModel();
  final _recent = RecentModel();
  final _blog = BlogModel();
  final _user = UserModel();
  final _filterModel = FilterAttributeModel();
  final _filterTagModel = FilterTagModel();
  final _categoryModel = CategoryModel();
  final _tagModel = TagModel();
  final _taxModel = TaxModel();
  final _pointModel = PointModel();
  final _addressModel = AddressModel();
  final _homeProduct = HomeProductModel();
  StoreModel? _storeModel;
  VendorShippingMethodModel? _vendorShippingMethodModel;

  CartInject cartModel = CartInject();
  bool isFirstSeen = false;
  bool isLoggedIn = false;

  late FirebaseAnalyticsAbs firebaseAnalyticsAbs;

  void checkInternetConnection() {
    if (kIsWeb || isMacOS || isWindow) {
      return;
    }
    MyConnectivity.instance.initialise();
    MyConnectivity.instance.myStream.listen((onData) {
      printLog("[App] internet issue change: $onData");
    });
  }

  @override
  void initState() {
    printLog("[AppState] initState");
    if (kIsWeb) {
      printLog("[AppState] init WEB");
      firebaseAnalyticsAbs = FirebaseAnalyticsWeb();
    } else {
      firebaseAnalyticsAbs = FirebaseAnalyticsWapper()..init();

      Future.delayed(
        const Duration(milliseconds: 300),
        () async {
          printLog("[AppState] init mobile modules ..");
          checkInternetConnection();

          _user.delegate = this;

          if (isMobile) {
            FirebaseCloudMessagagingWapper()
              ..init()
              ..delegate = this;
          }
//////one signal commented
          // OneSignalWapper()..init();
          printLog("[AppState] register modules .. DONE");
        },
      );
    }

    super.initState();
  }

  void _saveMessage(Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      _app.deeplink = message['data'];
    }

    storeNotification a = storeNotification.fromJsonFirebase(message);
    final id = message['notification'] != null
        ? message['notification']['tag']
        : message['data']['google.message_id'];

    a.saveToLocal(id);
  }

  @override
  void onLaunch(Map<String, dynamic> message) async {
    printLog('[app.dart] onLaunch Pushnotification: $message');
    isLoggedIn = await checkLogin();
    _saveMessage(message);
    if (isLoggedIn == true) {
      Future.delayed(const Duration(milliseconds: 2500), () {
        Navigator.push(
            App.navigatorKey.currentState!.context,
            MaterialPageRoute(
                builder: (context) => Notificationsceens(
                    screen: message["data"]["screen"] != null
                        ? message["data"]["screen"]
                        : '')));
      });
    } else if (isLoggedIn == false) {
      await Navigator.push(App.navigatorKey.currentState!.context,
          MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  void onMessage(Map<String, dynamic> message) {
    printLog('[app.dart] onMessage Pushnotification: $message');
    //  Navigator.push(App.navigatorKey.currentState.context,
    //     MaterialPageRoute(builder: (context) => Notificationsceens()));

    _saveMessage(message);
  }

  Future checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggedIn') ?? false;
  }

  @override
  void onResume(Map<String, dynamic> message) async {
    printLog('[app.dart] onResume Pushnotification: $message');
    isLoggedIn = await checkLogin();
    printLog(isLoggedIn);
    // print(await Provider.of<UserModel>(context, listen: false).loggedIn);

    if ((isLoggedIn == true)) {
      printLog("screenmess");
      printLog(message["data"]["screen"]);
      await Navigator.push(
          App.navigatorKey.currentState!.context,
          MaterialPageRoute(
              builder: (context) => Notificationsceens(
                  screen: message["data"]["screen"] != null
                      ? message["data"]["screen"]
                      : '')));
    } else if (isLoggedIn == false) {
      await Navigator.push(App.navigatorKey.currentState!.context,
          MaterialPageRoute(builder: (context) => LoginScreen()));
    }

    _saveMessage(message);
  }

  void updateDeviceToken(User? user) {
    FirebaseMessaging.instance.getToken().then((token) async {
      try {
        await Services().updateUserInfo({"deviceToken": token}, user);
      } catch (e) {
        printLog(e);
      }
    });
  }

  @override
  onLoaded(User? user) {
    updateDeviceToken(user);
  }

  @override
  onLoggedIn(User user) {
    updateDeviceToken(user);
  }

  @override
  onLogout(User? user) async {
    try {
      await Services().updateUserInfo({"deviceToken": ""}, user);
    } catch (e) {
      printLog(e);
    }
  }

  /// Build the App Theme
  ThemeData getTheme(context) {
    printLog("[AppState] build Theme");

    var appModel = Provider.of<AppModel>(context);
    var isDarkTheme = appModel.darkTheme;

    if (appModel.appConfig == null) {
      /// This case is loaded first time without config file
      return buildLightTheme(appModel.langCode);
    }

    // if (isDarkTheme) {
    //   return buildDarkTheme(appModel.langCode)
    //       .copyWith(primaryColor: Color(0xffda0c15));
    // }
    // return buildLightTheme(appModel.langCode)
    //     .copyWith(primaryColor: Color(0xffda0c15));
    if (isDarkTheme) {
      return buildDarkTheme(appModel.langCode).copyWith(
        primaryColor: HexColor(
          appModel.appConfig!["Setting"]["MainColor"],
        ),
      );
    }
    return buildLightTheme(appModel.langCode).copyWith(
      primaryColor: HexColor(appModel.appConfig!["Setting"]["MainColor"]),
    );
  }

  @override
  Widget build(BuildContext context) {
    printLog("[AppState] build");
    return ChangeNotifierProvider<AppModel>(
      create: (context) => _app,
      child: Consumer<AppModel>(
        builder: (context, value, child) {
          if (value.vendorType == VendorType.multi &&
              _storeModel == null &&
              _vendorShippingMethodModel == null) {
            _storeModel = StoreModel();
            _vendorShippingMethodModel = VendorShippingMethodModel();
          }
          return MultiProvider(
            providers: [
              Provider<ProductModel>.value(value: _product),
              Provider<HomeProductModel>.value(value: _homeProduct),
              Provider<WishListModel>.value(value: _wishlist),
              Provider<ShippingMethodModel>.value(value: _shippingMethod),
              Provider<PaymentMethodModel>.value(value: _paymentMethod),
              Provider<OrderModel>.value(value: _order),
              Provider<RecentModel>.value(value: _recent),
              Provider<UserModel>.value(value: _user),
              ChangeNotifierProvider<FilterAttributeModel>(
                  create: (_) => _filterModel),
              ChangeNotifierProvider<FilterTagModel>(
                  create: (_) => _filterTagModel),
              ChangeNotifierProvider<CategoryModel>(
                  create: (_) => _categoryModel),
              ChangeNotifierProvider(create: (_) => _tagModel),
              ChangeNotifierProvider(create: (_) => cartModel.model),
              ChangeNotifierProvider(create: (_) => BlogModel()),
              ChangeNotifierProvider(create: (_) => SettingsProvider()),
              ChangeNotifierProvider(create: (_) => CartProvider()),
              ChangeNotifierProvider(create: (_) => ClickNCollectProvider()),
              ChangeNotifierProvider(create: (_) => SuggestedProductProvider()),
              ChangeNotifierProvider(create: (_) => ScrollProvider()),
              ChangeNotifierProvider(create: (_) => StoreProvider()),
              ChangeNotifierProvider(create: (_) => RefreshControllerProvider()),

              ChangeNotifierProvider(create: (_) => _blog),
              //ChangeNotifierProvider(create: (_) => _advertisementModel),
              Provider<TaxModel>.value(value: _taxModel),
              if (value.vendorType == VendorType.multi) ...[
                ChangeNotifierProvider<StoreModel?>(create: (_) => _storeModel),
                Provider<VendorShippingMethodModel?>.value(
                    value: _vendorShippingMethodModel),
              ],
              Provider<PointModel>.value(value: _pointModel),
              Provider<AddressModel>.value(value: _addressModel),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              builder: EasyLoading.init(),
              navigatorKey: App.navigatorKey,
              locale: Locale(value.langCode!, ""),
              navigatorObservers: [
                MyRouteObserver(),
                ...firebaseAnalyticsAbs.getMNavigatorObservers()
              ],
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                DefaultCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              home: Scaffold(
                key: globalScaffoldKey,
                body: AppInit(
                  // this place to check stores selected
                  onNext: () => const MainTabs(),
                ),
              ),
              routes: Routes.getAll(),
              onGenerateRoute: Routes.getRouteGenerate,
              theme: buildLightTheme(value.langCode),
              themeMode: value.darkTheme ? ThemeMode.dark : ThemeMode.light,
              darkTheme: buildDarkTheme(value.langCode).copyWith(
                  primaryColor: kTeal100
              ),
            ),
          );
        },
      ),
    );
  }
}
