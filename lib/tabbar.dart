import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

import 'algolia/algolia_search.dart';
import 'algolia/credentials.dart';
import 'algolia/suggestion_repository.dart';
import 'app.dart';
import 'cache_manager_file.dart';
import 'common/config/general.dart';
import 'common/constants.dart';
import 'common/tools.dart';
import 'generated/l10n.dart';
import 'models/app_model.dart';
import 'models/cart/cart_model.dart';
import 'models/product_model.dart';
import 'models/search_model.dart';
import 'models/user_model.dart';
import 'route.dart';
import 'screens/base.dart';
import 'screens/categories/index.dart';
import 'screens/home/notification.dart';
import 'screens/index.dart'
    show CartScreen, CategoriesScreen, HomeScreen, NotificationScreen, StaticSite, UserScreen, WebViewScreen, WishListScreen;
import 'screens/settings/deals.dart';
import 'screens/settings/new_arrival.dart';
import 'screens/users/user_loyalty.dart';
import 'screens/users/user_update.dart';
import 'services/index.dart';
import 'widgets/common/auto_hide_keyboard.dart';
import 'widgets/icons/feather.dart';
import 'widgets/layout/adaptive.dart';
import 'widgets/layout/main_layout.dart';

const int tabCount = 3;
const int turnsToRotateRight = 1;
const int turnsToRotateLeft = 3;

class MainTabControlDelegate {
  int? index;
  late Function(String? nameTab) changeTab;
  late Function(int index) tabAnimateTo;

  static MainTabControlDelegate? _instance;

  static MainTabControlDelegate getInstance() {
    return _instance ??= MainTabControlDelegate._();
  }

  MainTabControlDelegate._();
}

class MainTabs extends StatefulWidget {
  final RemoteMessage? pushMessage;
  const MainTabs({super.key, this.pushMessage});

  @override
  MainTabsState createState() => MainTabsState();
}

class MainTabsState extends BaseScreen<MainTabs>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  QuickActions quickActions = const QuickActions();
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey(debugLabel: 'Dashboard');
  final List<Widget> _tabView = [];
  final navigators = Map<int, GlobalKey<NavigatorState>>();

  late var tabData;

  Map saveIndexTab = Map();

  firebase_auth.User? loggedInUser;

  TabController? tabController;

  bool isAdmin = false;
  bool isFirstLoad = false;
  bool isShowCustomDrawer = false;

  StreamSubscription? _subOpenNativeDrawer;
  StreamSubscription? _subCloseNativeDrawer;
  StreamSubscription? _subOpenCustomDrawer;
  StreamSubscription? _subCloseCustomDrawer;
  String currentStore = "";
  String searchIndex = "";

  bool get isDesktopDisplay => isDisplayDesktop(context);

  @override
  void afterFirstLayout(BuildContext context) {
    loadTabBar(context);
  }

  Widget tabView(Map<String, dynamic> data) {
    switch (data['layout']) {
      case 'category':
        return CategoriesScreen(
          key: const Key("category"),
          layout: data['categoryLayout'],
          categories: data['categories'],
          images: data['images'],
          showChat: data['showChat'],
          showSearch: data['showSearch'] ?? true,
        );
      case 'search':
        {
          return AutoHideKeyboard(
            child: ChangeNotifierProvider<SearchModel>(
              create: (context) => SearchModel(),
              child: Services().widget?.renderSearchScreen(
                context,
                showChat: data['showChat'],
              ),
            ),
          );
        }

      case 'cart':
        return CartScreen(showChat: data['showChat']);
      case 'profile':
        return UserScreen(
            settings: data['settings'],
            background: data['background'],
            showChat: data['showChat']);
    // case 'blog':
    //   return HorizontalSliderList(config: data);
      case 'wishlist':
        return WishListScreen(canPop: false, showChat: data['showChat']);
      case 'deals':
        return DealsScreen();
    // case 'page':
    //   return WebViewScreen(
    //       title: data['title'], url: data['url'], showChat: data['showChat']);
    // case 'html':
    //   return StaticSite(data: data['data'], showChat: data['showChat']);
    // case 'static':
    //   return StaticPage(data: data['data'], showChat: data['showChat']);
    // case 'postScreen':
    //   return PostScreen(
    //       pageId: data['pageId'],
    //       pageTitle: data['pageTitle'],
    //       isLocatedInTabbar: true,
    //       showChat: data['showChat']);

    /// Story Screen
    // case 'story':
    //   return StoryWidget(
    //     config: data,
    //     isFullScreen: true,
    //     onTapStoryText: (cfg) {
    //       Utils.onTapNavigateOptions(context: context, config: cfg);
    //     },
    //   );

    /// vendor screens
      case 'vendors':
        return Services().widget?.renderVendorCategoriesScreen(data) ?? const SizedBox.shrink();

      case 'map':
        return Services().widget?.renderMapScreen() ?? const SizedBox.shrink();

    /// Default Screen
      case 'dynamic':
      default:
        return HomeScreen(
          changeTabTo: changeTab,
        );
    }
  }

  void changeTab(String? nameTab) {
    printLog("name tab");
    printLog(nameTab);
    if (saveIndexTab[nameTab] != null) {
      tabController?.animateTo(saveIndexTab[nameTab]);
      setState(() {});
    } else {
      Navigator.of(context, rootNavigator: true).pushNamed("/$nameTab");
    }
  }

  void loadTabBar(context) {
    tabData = List.from(
        Provider.of<AppModel>(context, listen: false).appConfig!['TabBar']);

    for (var i = 0; i < tabData.length; i++) {
      Map<String, dynamic> _dataOfTab = Map.from(tabData[i]);
      saveIndexTab[_dataOfTab['layout']] = i;
      navigators[i] = GlobalKey<NavigatorState>();
      _tabView.add(
        Navigator(
          key: navigators[i],
          onGenerateRoute: (RouteSettings settings) {
            if (settings.name == Navigator.defaultRouteName) {
              return MaterialPageRoute(
                builder: (context) => tabView(_dataOfTab),
                fullscreenDialog: true,
                settings: settings,
              );
            }
            return Routes.getRouteGenerate(settings);
          },
        ),
      );
    }
    printLog("Tab length");
    _tabView.forEach((element) {
      printLog(element);
    });
    printLog(_tabView.length);

    setState(() {
      tabController = TabController(length: _tabView.length, vsync: this);
    });

    if (MainTabControlDelegate.getInstance().index != null) {
      tabController!.animateTo(MainTabControlDelegate.getInstance().index!);
    } else {
      MainTabControlDelegate.getInstance().index = 0;
    }

    tabController!.addListener(() {
      eventBus.fire('tab_${tabController!.index}');
      MainTabControlDelegate.getInstance().index = tabController!.index;
    });
  }

  Future<void> getCurrentUser() async {
    try {
      //Provider.of<UserModel>(context).getUser();
      final user = await _auth.currentUser;
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    } catch (e) {
      printLog("[tabbar] getCurrentUser error ${e.toString()}");
    }
  }

  @override
  void initState() {
    printLog("[Dashboard] init");
    if (!kIsWeb) {
      getCurrentUser();
    }
    setupListenEvent();
    MainTabControlDelegate.getInstance().changeTab = changeTab;
    MainTabControlDelegate.getInstance().tabAnimateTo = (int index) {
      tabController?.animateTo(index);
    };
    super.initState();
    const channel = MethodChannel('plugins.flutter.io/quick_actions');
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'launch':
          handleQuickAction(call.arguments);
          break;
        default:
          throw MissingPluginException('notImplemented');
      }
    });
    if(Platform.isAndroid) {
      quickActions.initialize((type) async {
        await Future.delayed(const Duration(milliseconds: 700));
        printLog("sucess shortcut21");
        if (type == 'NotificationScreen') {
          printLog("==================Notifications clicked");
          navigators[0]?.currentState?.push(
              MaterialPageRoute(builder: (context) => Notificationsceens()));
          printLog("sucess shortcut2");
        } else if (type == 'Deals') {
          printLog("===============Deals clicked");
          changeTab("deals");
        } else if (type == 'History') {
          printLog("Notificatoins clicked");
          UserModel userModel = Provider.of<UserModel>(context, listen: false);
          if (userModel.user != null && userModel.user!.cookie != null ) {
            navigators[4]?.currentState?.pushNamed(RouteList.orders);
            changeTab("profile");
          }
          else {
            Navigator.of(context).pushReplacementNamed(RouteList.login);
          }
        } else if (type == 'Search') {
          printLog("================search clicked");
          await getSavedStore();
          _presentAutoComplete(context, "");
        }
      });
    }
    quickActions.setShortcutItems([
      const ShortcutItem(
          type: 'NotificationScreen',
          localizedTitle: 'Notification',
          icon: 'notification'),
      const ShortcutItem(
          type: 'Deals', localizedTitle: 'Deals', icon: 'discount'),
      const ShortcutItem(
          type: 'Search', localizedTitle: 'Search', icon: 'search'),
      const ShortcutItem(
          type: 'History',
          localizedTitle: 'Order History',
          icon: 'history'),
    ]);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DynamicLinkService().retrieveDynamicLink(context);
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        _handleMessage(message);
      });
      getPushMessage();
    });
  }

  void handleQuickAction(String type) async  {
    printLog("sucess shortcut21");
    if (type == 'NotificationScreen') {
      printLog("==================Notifications clicked");
      tabController?.animateTo(0);
      await Future.delayed(const Duration(milliseconds: 700));
      navigators[0]?.currentState?.push(
          MaterialPageRoute(builder: (context) => Notificationsceens()));
      printLog("sucess shortcut2");
    } else if (type == 'Deals') {
      await Future.delayed(const Duration(milliseconds: 700));
      printLog("===============Deals clicked");
      changeTab("deals");
    } else if (type == 'History') {
      await Future.delayed(const Duration(milliseconds: 700));
      printLog("Notificatoins clicked");
      UserModel userModel = Provider.of<UserModel>(context, listen: false);
      if (userModel.user != null && userModel.user!.cookie != null ) {
        navigators[4]?.currentState?.pushNamed(RouteList.orders);
        changeTab("profile");
      }
      else {
        Navigator.of(context).pushReplacementNamed(RouteList.login);
      }
    } else if (type == 'Search') {
      tabController?.animateTo(0);
      await Future.delayed(const Duration(milliseconds: 700));
      printLog("================search clicked");
      await getSavedStore();
      _presentAutoComplete(context, "");
    }
  }

  void _presentAutoComplete(BuildContext context, String barcode) =>
      navigators[0]?.currentState?.push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => Provider<SuggestionRepository>(
            create: (_) => SuggestionRepository(initialIndexName: searchIndex),
            dispose: (_, value) => value.dispose(),
            child: AlgoliaSearch(barcode: barcode, indexName: searchIndex,)),
        fullscreenDialog: true,
      ));

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
  void didChangeDependencies() {
    isShowCustomDrawer = isDesktopDisplay;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    tabController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _subOpenNativeDrawer?.cancel();
    _subCloseNativeDrawer?.cancel();
    _subOpenCustomDrawer?.cancel();
    _subCloseCustomDrawer?.cancel();
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // went to Background
    }
    if (state == AppLifecycleState.resumed) {
      // came back to Foreground
      final appModel = Provider.of<AppModel>(context, listen: false);
      if (appModel.deeplink?.isNotEmpty ?? false) {
        if (appModel.deeplink?['screen'] == 'NotificationScreen') {
          appModel.deeplink = null;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationScreen()),
          );
        }
      }
    }

    super.didChangeAppLifecycleState(state);
  }

  void setupListenEvent() {
    _subOpenNativeDrawer = eventBus.on<EventOpenNativeDrawer>().listen((event) {
      if (!_scaffoldKey.currentState!.isDrawerOpen) {
        _scaffoldKey.currentState!.openDrawer();
      }
    });
    _subCloseNativeDrawer =
        eventBus.on<EventCloseNativeDrawer>().listen((event) {
      if (_scaffoldKey.currentState!.isDrawerOpen) {
        _scaffoldKey.currentState!.openEndDrawer();
      }
    });
    _subOpenCustomDrawer = eventBus.on<EventOpenCustomDrawer>().listen((event) {
      setState(() {
        isShowCustomDrawer = true;
      });
    });
    _subCloseCustomDrawer =
        eventBus.on<EventCloseCustomDrawer>().listen((event) {
      setState(() {
        isShowCustomDrawer = false;
      });
    });
  }

  Future<void> getPushMessage() async {
    if(!Provider.of<AppModel>(context, listen: false).messageServed) {
      RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }
    }
  }

  bool isLoggedIn = false;
  _handleMessage(RemoteMessage message) async {
    try {
      EasyLoading.instance
        ..loadingStyle = EasyLoadingStyle.custom
        ..backgroundColor = Colors.transparent
        ..indicatorColor = Colors.transparent
        ..dismissOnTap = false
        ..textColor = Colors.transparent
        ..boxShadow = []
        ..userInteractions = false;
      await EasyLoading.show(
          indicator: SpinKitCubeGrid(
              color: Theme.of(context).primaryColor,
              size: 30.0),
          maskType: EasyLoadingMaskType.black);
      Provider.of<AppModel>(context, listen: false).setPushMessageState(true);
      isLoggedIn = await checkLogin();
      if(message.data["product"]!=null){
        Map<String, dynamic> product = jsonDecode(message.data["product"]);
        // Product product = Product.fromJson(data);
        if(product["sku"] != null) {
          final _service = Services();
          var productData = await _service.searchProducts(
              name: product["sku"],
              categoryId: null,
              tag: "",
              attribute: "",
              attributeId: "",
              page: 1,
              lang: Provider.of<AppModel>((App.navigatorKey.currentState?.context)!, listen: false).langCode,
              isBarcode: false);
          if(productData.length > 0){
            navigators[0]?.currentState?.pushNamed(RouteList.productDetail, arguments: productData[0]);
          }
          else {
            ScaffoldMessenger.of((App.navigatorKey.currentState?.context)!).showSnackBar(SnackBar(content: Text("Something went wrong")));
          }
        }
      }
      else if(message.data["category"] != null){
        if(message.data["category"] != null) {
          Map<String, dynamic> category = jsonDecode(message.data["category"]);
          ProductModel.showList(
              context: navigators[1]?.currentState?.context ?? context,
              config: category);
          // Provider.of<ProductModel>(context, listen: false).setCurrentCat(category["category"]);
          // navigators[1]?.currentState?.push(
          //     MaterialPageRoute(builder: (context) => ProductModel.showList(
          //         context: context,
          //         config: category),)
          // );
        }
        changeTab("category");
      }
      else if(message.data["screen"] != null) {
        Map<String, dynamic> category = jsonDecode(message.data["screen"]);
        if(isLoggedIn){
          if(category["name"] == "profile"){
            navigators[4]?.currentState?.push(
                MaterialPageRoute(
                    builder: (context) => UserUpdate())
            );
            changeTab("profile");
          }
          else if(category["name"] == "loyalty"){
            navigators[4]?.currentState?.push(
                MaterialPageRoute(builder: (context) => JamaeytiWidget())
            );
            changeTab("profile");
          }
          else if(category["name"] == "orders"){
            navigators[4]?.currentState?.pushNamed(RouteList.orders);
            changeTab("profile");
          }
          else if(category["name"] == "deals"){
            if(category["subcategory"] != null && category["subcategory"] != "") {
              await Future.delayed(const Duration(milliseconds: 500));
              navigators[2]?.currentState?.push(
                  MaterialPageRoute(builder: (context) => DealsScreen(subCategory: category["subcategory"],)));
            }
            changeTab("deals");
          }
          else if(category["name"] == "new_arrival") {
            var data = Provider.of<AppModel>(context, listen: false).appConfig!["HorizonLayout"];
            var conf;
            data.forEach((map) {
              if(map["name"] == "New Arrival") {
                conf = map["category"][0]["product_id"];
                printLog(map["name"]);
              }
            });
            if(conf != null) {
              navigators[1]?.currentState?.push(
                  MaterialPageRoute(builder: (context) => NewArrival(config: conf))
              );
            }
            changeTab("category");
          }
        }
        else {
          if(category["name"] == "deals"){
            if(category["subcategory"] != null && category["subcategory"] != "") {
              navigators[2]?.currentState?.push(
                  MaterialPageRoute(builder: (context) => DealsScreen(subCategory: category["subcategory"],)));
            }
            changeTab("deals");
          }
          else if(category["name"] == "new_arrival") {
            var data = Provider.of<AppModel>(context, listen: false).appConfig!["HorizonLayout"];
            var conf;
            data.forEach((map) {
              if(map["name"] == "New Arrival") {
                conf = map["category"][0]["product_id"];
                printLog(map["name"]);
              }
            });
            if(conf != null) {
              navigators[1]?.currentState?.push(
                  MaterialPageRoute(builder: (context) => NewArrival(config: conf))
              );
            }
            changeTab("category");
          }
          else {
            Navigator.of(context).pushReplacementNamed(RouteList.login);
          }
        }
      }
    }
    catch(e) {
      printLog(e.toString());
    }
    finally {
      await EasyLoading.dismiss();
    }
  }

  Future<bool> checkOnceMainBanner() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    int? day =  await prefs.getInt('lastMessageTime');
    if(day == null || day == now.day){
      await prefs.setInt('lastMessageTime', now.day +1);
      return true;
    }
    else {
      return false;
    }
  }

  Future<bool> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggedIn') ?? false;
  }


  Future<bool> handleWillPopScopeRoot() {
    // Check pop navigator current tab
    final currentNavigator = navigators[tabController!.index]!;
    if (currentNavigator.currentState!.canPop()) {
      currentNavigator.currentState!.pop();
      return Future.value(false);
    }
    // Check pop root navigator
    if (Navigator.of(context).canPop()) {
      if(tabController!.index != 0) {
        tabController!.animateTo(0);
        return Future.value(false);
      }
      else {
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text(S.of(context).areYouSure),
            content: Text(S.of(context).doYouWantToExitApp),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  S.of(context).no,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () {
                  if(Platform.isAndroid){
                    SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
                  }
                  else {
                    Navigator.of(context).pop(true);
                  }
                },
                child: Text(
                  S.of(context).yes,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ).then((value) => value as bool) ??
            false as Future<bool>;
      }
    }
    if (tabController!.index != 0) {
      tabController!.animateTo(0);
      return Future.value(false);
    } else {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(S.of(context).areYouSure),
          content: Text(S.of(context).doYouWantToExitApp),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                S.of(context).no,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                S.of(context).yes,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ).then((value) => value as bool) ??
          false as Future<bool>;
    }
  }

  @override
  Widget build(BuildContext context) {
    printLog('[tabbar] ============== tabbar.dart DASHBOARD ==============');
    printLog(
        '[Resolution Screen]: ${MediaQuery.of(context).size.width} x ${MediaQuery.of(context).size.height}');

    if (_tabView.isEmpty) {
      return Container(
        color: Colors.white,
      );
    }
    return renderBody(context);
  }

  Widget renderBody(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final appSetting = Provider.of<AppModel>(context).appConfig!['Setting'];
    final colorTabbar = appSetting['ColorTabbar'] != null
        ? HexColor(appSetting['ColorTabbar'])
        : false;

    final tabBar = TabBar(
      controller: tabController,
        onTap: (index) {
          if (index == 0) {
            Provider.of<AppModel>(context, listen: false).setLangChange(false);
            Navigator.of(context).pushReplacementNamed(RouteList.dashboard).then((_) {
              CustomCacheManager.instance.emptyCache(); // Clear cache
            });
          }
          else if(Provider.of<AppModel>(context, listen: false).langChanged && index == 2) {
            Provider.of<AppModel>(context, listen: false).setLangChange(false);
            Navigator.of(context).pushReplacementNamed(RouteList.dashboard).then((_) {
              CustomCacheManager.instance.emptyCache(); // Clear cache
            });
          }
          else if(index == 3) {
            setState(() {});
            if(Provider.of<CartModel>(context, listen: false).totalCartQuantity > 0) {
              Provider.of<CartModel>(context, listen: false).refreshCart(true);
              Services().widget?.syncCartFromWebsite(
                  Provider.of<UserModel>(context, listen: false).user?.cookie,
                  Provider.of<CartModel>(context, listen: false),
                  context,
                  Provider.of<AppModel>(context, listen: false).langCode ?? "en").then((val) {
                Provider.of<CartModel>(context, listen: false).refreshCart(false);
              });
            }
          }
          else{
            printLog(index);
            setState(() {});
          }
        },
      tabs: renderTabbar(),
      isScrollable: false,
      labelStyle: Theme.of(context)
          .primaryTextTheme
          .bodySmall!
          .copyWith(fontSize: 12, fontWeight: FontWeight.bold),
      unselectedLabelStyle:
          Theme.of(context).primaryTextTheme.bodySmall!.copyWith(fontSize: 12),
      labelPadding: EdgeInsets.zero,
      labelColor: colorTabbar == false
          ? Theme.of(context).colorScheme.secondary
          : Colors.white,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorPadding: const EdgeInsets.all(0.0),
      indicatorColor: Colors.transparent,
      dividerColor: Colors.transparent,
      // colorTabbar == false ? Theme.of(context).primaryColor : Colors.white,
    );

    // TabBarView
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      resizeToAvoidBottomInset: false,
      body: WillPopScope(
        onWillPop: handleWillPopScopeRoot,
        child: MainLayout(
          content: ListenableProvider.value(
            value: tabController,
            child: Consumer(
              builder: (context, TabController controller, child) {
                printLog("MMMMMMMMMMMMMM");
                printLog(controller.length);
                printLog(controller.previousIndex);
                return IndexedStack(
                    index: controller.index, children: _tabView);
              },
            ),
          ),
        ),
      ),
      // drawer: isDesktopDisplay ? null : Drawer(child: MenuBar()),
      bottomNavigationBar: GestureDetector(
        child: Container(
          color: colorTabbar == false
              ? Theme.of(context).scaffoldBackgroundColor
              : colorTabbar as Color,
          child: SafeArea(
            top: false,
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOutQuint,
                height: isShowCustomDrawer ? 0 : null,
                constraints: const BoxConstraints(
                  maxHeight: 55,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.black12, width: 0.5),
                  ),
                ),
                width: screenSize.width,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: tabBar,
                )
            ),
          ),
        ),
      )
    );
  }

  List<Widget> renderTabbar() {
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    var totalCart = Provider.of<CartModel>(context).totalCartQuantity;
    final tabData = Provider.of<AppModel>(context, listen: false)
        .appConfig!['TabBar'] as List;

    final appSetting = Provider.of<AppModel>(context).appConfig!['Setting'];
    final colorIcon = appSetting['TabBarIconColor'] != null
        ? HexColor(appSetting['TabBarIconColor'])
        : Theme.of(context).colorScheme.secondary;

    final activeColorIcon = appSetting['ActiveTabBarIconColor'] != null
        ? HexColor(appSetting['ActiveTabBarIconColor'])
        : Theme.of(context).primaryColor;



    List<Widget> list = [];

    int index = 0;

    tabData.forEach((item) {
      final isActive = tabController!.index == index;
      var icon = !item["icon"].contains('/')
          ? Icon(
              featherIcons[item["icon"]],
              color: isActive ? activeColorIcon : colorIcon,
              size: 22,
            )
          : (item["icon"].contains('http')
              ? Image.network(
                  item["icon"],
                  color: isActive ? activeColorIcon : colorIcon,
                  width: 24,
                )
              : Image.asset(
                  item["icon"],
                  color: isActive ? activeColorIcon : colorIcon,
                  width: 24,
                ));

      if (item["layout"] == "cart") {
        icon = Stack(
          children: <Widget>[
            Container(
              width: 30,
              height: 25,
              padding: const EdgeInsets.only(right: 0.0, top: 0),
              child: icon,
            ),
            if (totalCart > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    totalCart.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isTablet ? 14 : 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
          ],
        );
      }

      if (item["label"] != null) {
        list.add(Tab(
          icon: icon,
          iconMargin: EdgeInsets.zero,
          text: item["label"],
        ));
      } else {
        list.add(Tab(icon: icon));
      }
      index++;
    });

    return list;
  }
}
