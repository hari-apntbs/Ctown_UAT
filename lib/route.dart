// ignore: prefer_relative_imports
import 'package:ctown/screens/categories/index.dart';
import 'package:ctown/screens/categories/index1.dart';
import 'package:ctown/screens/users/delivery_policy.dart';
// ignore: prefer_relative_imports
import 'package:ctown/screens/users/payment_policy.dart';
// ignore: prefer_relative_imports
import 'package:ctown/screens/users/privacy_policy.dart';
// ignore: prefer_relative_imports
import 'package:ctown/screens/users/return_cancellation_policy.dart';
// ignore: prefer_relative_imports
import 'package:ctown/screens/users/terms_condition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/constants.dart';
import 'common/constants/route_list.dart';
import 'models/index.dart' show Product, SearchModel;
import 'screens/index.dart'
    show
        BlogScreen,
        CartScreen,
        CategorySearch,
        CategoriesScreen,
        Checkout,
        HomeScreen,
        LoginScreen,
        MyOrders,
        NotificationScreen,
        ProductDetailScreen,
        ProductsPage,
        RegistrationScreen,
        SearchScreen,
        UserScreen,
        // ignore: undefined_shown_name
        DealsScreen,
        WishListScreen;
import 'screens/settings/deals.dart';
import 'tabbar.dart';
import 'widgets/home/search/home_search_page.dart';

class Routes {
  static Map<String, WidgetBuilder> getAll() => _routes;

  static Route getRouteGenerate(RouteSettings settings) =>
      _routeGenerate(settings);

  static final Map<String, WidgetBuilder> _routes = {
    RouteList.home: (context) => HomeScreen(),
    RouteList.dashboard: (context) => MainTabs(),
    RouteList.login: (context) => LoginScreen(),
    RouteList.register: (context) => RegistrationScreen(),
    RouteList.products: (context) => ProductsPage(),
    RouteList.wishlist: (context) => WishListScreen(),
    RouteList.deals: (context) => DealsScreen(),
    RouteList.checkout: (context) => Checkout(),
    RouteList.orders: (context) => MyOrders(),
    // RouteList.blogs: (context) => BlogScreen(),
    RouteList.notify: (context) => NotificationScreen(),
    RouteList.category: (context) => CategoriesScreen1(),
    RouteList.category1: (context) => CategoriesScreen(),
    RouteList.cart: (context) => CartScreen(),
    RouteList.terms_condition: (context) => TermsScreen('26'),
    RouteList.privacy_policy: (context) => PrivacypolicyScreen('24'),
    RouteList.delivery_policy: (context) => DeliverypolicyScreen('28'),
    RouteList.payment_policy: (context) => PaymentpolicyScreen('32'),
    RouteList.return_policy: (context) => ReturncancelScreen('30'),
    RouteList.search: (context) => ChangeNotifierProvider(
          create: (_) => SearchModel(),
          child: SearchScreen(),
        ),
    RouteList.profile: (context) => UserScreen(),
  };

  static Route _routeGenerate(RouteSettings settings) {
    switch (settings.name) {
      case RouteList.homeSearch:
        return _buildRouteFade(
          settings,
          ChangeNotifierProvider(
            create: (context) => SearchModel(),
            child: HomeSearchPage(settings.arguments),
          ),
        );
      case RouteList.productDetail:
        Product? product;
        if (settings.arguments is Product) {
          product = settings.arguments as Product?;
          return _buildRoute(
            settings,
            ProductDetailScreen(
              product: product,
            ),
          );
        }
        return _errorRoute();

      case RouteList.categorySearch:
        return _buildRouteFade(
          settings,
          CategorySearch(),
        );
      default:
        return MaterialPageRoute(
          builder: getRouteByName(settings.name)!,
          maintainState: false,
          fullscreenDialog: true,
        );
    }
  }

  static WidgetBuilder? getRouteByName(String? name) {
    if (_routes.containsKey(name) == false) {
      return _routes[RouteList.home];
    }
    return _routes[name];
  }

  static Route _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Page not found'),
        ),
      );
    });
  }

  static PageRouteBuilder _buildRouteFade(
    RouteSettings settings,
    Widget builder,
  ) {
    return _FadedTransitionRoute(
      settings: settings,
      widget: builder,
    );
  }

  static MaterialPageRoute _buildRoute(
    RouteSettings settings,
    Widget builder,
  ) {
    return MaterialPageRoute(
      settings: settings,
      builder: (BuildContext context) => builder,
    );
  }
}

class _FadedTransitionRoute extends PageRouteBuilder {
  final Widget? widget;
  final RouteSettings settings;

  _FadedTransitionRoute({this.widget, required this.settings})
      : super(
            settings: settings,
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return widget!;
            },
            transitionDuration: const Duration(milliseconds: 100),
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                ),
                child: child,
              );
            });
}
