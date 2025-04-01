import 'dart:convert';
import 'dart:io' show Platform;

import 'package:ctown/models/cart/cart_model.dart';
import 'package:ctown/screens/settings/address_book.dart';
import 'package:ctown/screens/settings/settings_provider.dart';
import 'package:ctown/screens/settings/shopping_list.dart';
import 'package:ctown/screens/users/about.dart';
import 'package:ctown/screens/users/feedback_widget/feedback_widget.dart';
import 'package:ctown/screens/users/help_center_widget/help_center_widget.dart';
import 'package:ctown/screens/users/legal_widget/legal_widget.dart';
import 'package:ctown/screens/users/my_coupons_widget/my_coupons_widget.dart';
import 'package:ctown/screens/users/my_vouchers_widget/my_vouchers_widget.dart';
import 'package:ctown/screens/users/user_loyalty.dart';
import 'package:ctown/widgets/appbar.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:scrolls_to_top/scrolls_to_top.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/config.dart';
import '../../common/config.dart' as config;
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/index.dart' show AppModel, User, UserModel, WishListModel;
import '../../services/index.dart';
import '../../widgets/common/webview.dart';
import '../index.dart';
import '../users/user_update.dart';
import 'language.dart';
import 'notification.dart';

class SettingScreen extends StatefulWidget {
  final List<dynamic>? settings;
  final String? background;
  final User? user;
  final VoidCallback? onLogout;
  final bool? showChat;
  final String? notifyScreen;

  SettingScreen({
    this.user,
    this.onLogout,
    this.settings,
    this.background,
    this.showChat,
    this.notifyScreen
  });

  @override
  State<StatefulWidget> createState() {
    return SettingScreenState();
  }
}

class SettingScreenState extends State<SettingScreen>
    with
        TickerProviderStateMixin,
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin<SettingScreen> {
  @override
  bool get wantKeepAlive => false;

  final bannerHigh = 150.0;
  bool enabledNotification = true;
  String appVersion = "";
  final ScrollController _scrollController = ScrollController();
  final RateMyApp _rateMyApp = RateMyApp(
      // rate app on store
      minDays: 7,
      minLaunches: 10,
      remindDays: 7,
      remindLaunches: 10,
      googlePlayIdentifier: kStoreIdentifier['android'],
      appStoreIdentifier: kStoreIdentifier['ios']);

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration.zero, () async {
    //   await checkNotificationPermission();
    // });
    _rateMyApp.init().then((_) {
      // state of rating the app
      if (_rateMyApp.shouldOpenDialog) {
        _rateMyApp.showRateDialog(
          context,
          title: S.of(context).rateTheApp,
          // The dialog title.
          message: S.of(context).rateThisAppDescription,
          // The dialog message.
          rateButton: S.of(context).rate.toUpperCase(),
          // The dialog "rate" button text.
          noButton: S.of(context).noThanks.toUpperCase(),
          // The dialog "no" button text.
          laterButton: S.of(context).maybeLater.toUpperCase(),
          // The dialog "later" button text.
          listener: (button) {
            // The button click listener (useful if you want to cancel the click event).
            switch (button) {
              case RateMyAppDialogButton.rate:
                break;
              case RateMyAppDialogButton.later:
                break;
              case RateMyAppDialogButton.no:
                break;
            }

            return true; // Return false if you want to cancel the click event.
          },
          // Set to false if you want to show the native Apple app rating dialog on iOS.
          dialogStyle: const DialogStyle(),
          // Custom dialog styles.
          // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
          // actionsBuilder: (_) => [], // This one allows you to use your own buttons.
        );
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(mounted) {
        if(widget.notifyScreen != null && widget.notifyScreen != "") {
          if(widget.notifyScreen == "loyalty") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JamaeytiWidget(),
              ),
            );
          }
          else if(widget.notifyScreen == "orders") {
            Navigator.pushNamed(context, "/orders");
          }
        }
      }
    });
  }

  getVouchers() async {
    UserModel userModel = Provider.of<UserModel>(context, listen: false);
    List<dynamic>? data;
    try {
      if(userModel.user != null) {
        var url = "https://up.ctown.jo/api/myvoucher.php?id=${userModel.user?.id}";
        printLog("Voucher Url: $url");

        var res = await http.get(Uri.parse(url));

        final response = jsonDecode(res.body);
        if (response["success"] == 1) {
          printLog("userid");
          printLog(response['data']);
          data =  response['data'];
        } else if (response["success"] == 0) {
          printLog("failed");
          data = null;
        }
      }
    }
    catch(e) {
      printLog(e.toString());
    }
    return data;
  }

  @override
  void dispose() {
    // Utils.setStatusBarWhiteForeground(false);
    _scrollController.dispose();
    super.dispose();
  }

  Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    return appVersion;
  }

  // Future<void> checkNotificationPermission() async {
  //   if (!isAndroid || isIos) {
  //     return;
  //   }
  //
  //   try {
  //     await NotificationPermissions.getNotificationPermissionStatus()
  //         .then((status) {
  //       if (mounted) {
  //         setState(() {
  //           enabledNotification = status == PermissionStatus.granted;
  //         });
  //       }
  //     });
  //   } catch (err) {
  //     printLog('[Settings Screen] : ${err.toString()}');
  //   }
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // checkNotificationPermission();
    }
  }

  /// Render the Admin Vendor Menu
  Widget renderVendorAdmin() {
    if (!(widget.user != null ? widget.user!.isVender ?? false : false)) {
      return Container();
    }

    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 2.0),
      elevation: 0,
      child: ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InAppWebView(
                    url:
                    Services().widget?.getAdminVendorUrl(widget.user!.cookie),
                    title: S.of(context).vendorAdmin,
                    appBarRequire: true),
              ));
        },
        leading: Icon(
          Icons.dashboard,
          size: 24,
          color: Theme.of(context).colorScheme.secondary,
        ),
        title: Text(
          S.of(context).vendorAdmin,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  /// Render the custom profile link via Webview
  /// Example show some special profile on the woocommerce site: wallet, wishlist...
  Widget renderWebViewProfile() {
    if (widget.user == null) {
      return Container();
    }
// TODO :: change we made  here at 4-01-2021
    // var base64Str = Utils.encodeCookie(widget.user.cookie);
    // print("jaydip +${widget.user.cookie}");
    var profileURL = '${serverConfig["url"]}/my-account?cookie=';

    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 2.0),
      elevation: 0,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InAppWebView(
                  url: profileURL,
                  appBarRequire: true,
                  title: S.of(context).updateUserInfor),
            ),
          );
        },
        leading: Icon(
          CupertinoIcons.profile_circled,
          size: 24,
          color: Theme.of(context).colorScheme.secondary,
        ),
        title: Text(
          S.of(context).updateUserInfor,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Widget renderItem(value) {
    IconData icon;
    String title;
    Widget? trailing;
    Function() onTap;
    switch (value) {
      case 'products':
        {
          if (!(widget.user != null ? widget.user!.isVender ?? false : false)) {
            return Container();
          }
          trailing = const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: kGrey600,
          );
          title = S.of(context).myProducts;
          icon = CupertinoIcons.cube_box;
          onTap = () => Navigator.pushNamed(context, RouteList.productSell);
          break;
        }
      case 'wishlist':
        {
          trailing = Consumer<WishListModel>(
              builder: (context, provider, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (provider.products.length > 0)
                      Text(
                        "${provider.products.length} ${S.of(context).items}",
                        style: TextStyle(
                            fontSize: 14, color: Theme.of(context).primaryColor),
                      ),
                    const SizedBox(width: 5),
                    const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600)
                  ],
                );
              }
          );

          title = S.of(context).myWishList;
          icon = CupertinoIcons.heart;
          onTap = () => Navigator.pushNamed(context, "/wishlist");
          break;
        }
      case 'shoppinglist':
        {
          if (widget.user == null) {
            return Container();
          }

          trailing = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600)
            ],
          );
          title = S.of(context).myShoppingList;
          icon = Icons.shopping_bag;
          onTap = () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => ShoppingList()));
          break;
        }
      case 'notifications':
        {
          return Column(
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 2.0),
                elevation: 0,
                child: SwitchListTile(
                  secondary: Icon(
                    CupertinoIcons.bell,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 24,
                  ),
                  value: enabledNotification,
                  activeColor: const Color(0xFF0066B4),
                  onChanged: (bool value) {
                    if (value) {
                      // NotificationPermissions.requestNotificationPermissions(
                      //   iosSettings: const NotificationSettingsIos(
                      //       sound: true, badge: true, alert: true),
                      // ).then((_) {
                      //   checkNotificationPermission();
                      // });
                    }
                    setState(() {
                      enabledNotification = value;
                    });
                  },
                  title: Text(
                    S.of(context).getNotification,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              Divider(
                color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.black12 : Theme.of(context).colorScheme.surface,
                height: 0.5,
                indent: 75,
                //endIndent: 20,
              ),
              if (enabledNotification)
                Card(
                  margin: const EdgeInsets.only(bottom: 2.0),
                  elevation: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationScreen()),
                      );
                    },
                    child: ListTile(
                      leading: Icon(
                        CupertinoIcons.list_bullet,
                        size: 22,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      title: Text(S.of(context).listMessages,
                          style: const TextStyle(
                            fontSize: 14,
                          )),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: kGrey600,
                      ),
                    ),
                  ),
                ),
              if (enabledNotification)
                Divider(
                  color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.black12 : Theme.of(context).colorScheme.surface,
                  height: 0.5,
                  indent: 75,
                  //endIndent: 20,
                ),
            ],
          );
        }
      case 'language':
        {
          icon = CupertinoIcons.globe;
          title = S.of(context).language;
          trailing = const Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: kGrey600,
          );
          onTap = () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Language()),
              );
          break;
        }
      case 'darkTheme':
        {
          return Column(
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 2.0),
                elevation: 0,
                child: SwitchListTile(
                  secondary: Icon(
                    Provider.of<AppModel>(context).darkTheme
                        ? CupertinoIcons.sun_min
                        : CupertinoIcons.moon,
                    color: kGrey600,
                    size: 24,
                  ),
                  value: Provider.of<AppModel>(context).darkTheme,
                  activeColor: const Color(0xFF0066B4),
                  onChanged: (bool value) {
                    if (value) {
                      Provider.of<AppModel>(context, listen: false)
                          .updateTheme(true);
                    } else {
                      Provider.of<AppModel>(context, listen: false)
                          .updateTheme(false);
                    }
                  },
                  title: Text(
                    S.of(context).darkTheme,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              Divider(
                color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.black12 : Theme.of(context).colorScheme.surface,
                height: 0.5,
                indent: 75,
                //endIndent: 20,
              ),
            ],
          );
        }
      case 'order':
        {
          if (widget.user == null) {
            return Container();
          }
          icon = CupertinoIcons.time;
          title = S.of(context).orderHistory;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () => Navigator.pushNamed(context, "/orders");
          break;
        }
      case 'point':
        {
          if (!(config.kAdvanceConfig['EnablePointReward'] == true &&
              widget.user != null)) {
            return Container();
          }
          icon = CupertinoIcons.bag_badge_plus;
          title = S.of(context).jamaeyati;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JamaeytiWidget(),
                ),
              );
          break;
        }
      case 'coupon':
        {
          if (!(config.kAdvanceConfig['EnableVoucher'] == true &&
              widget.user != null)) {
            return Container();
          }
          icon = CupertinoIcons.cart_fill_badge_plus;
          title = S.of(context).mycoupons;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyCouponsWidget(),
                ),
              );
          break;
        }
      case 'voucher':
        {
          if (!(config.kAdvanceConfig['EnableCoupon'] == true &&
              widget.user != null)) {
            return Container();
          }
          icon = CupertinoIcons.creditcard;
          title = S.of(context).myvoucher;
          trailing = FutureBuilder(
            future: getVouchers(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a loading indicator while waiting for the future
                return const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                );
              } else if (snapshot.hasData && snapshot.data != null && snapshot.data.isNotEmpty) {
                // If data is available, show the arrow icon
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (snapshot.data.length > 0)
                      Text(
                        "${snapshot.data.length} Voucher(s)",
                        style: TextStyle(
                            fontSize: 14, color: Theme.of(context).primaryColor),
                      ),
                    const SizedBox(width: 5),
                    const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600)
                  ],
                );
              } else {
                // If no data, show nothing
                return const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
              }
            },
          );
          onTap = () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyVouchersWidget(),
                ),
              );
          break;
        }
      case 'rating':
        {
          if (!(config.kAdvanceConfig["EnableRating"] as bool)) {
            return Container();
          }
          icon = CupertinoIcons.star;
          title = S.of(context).rateTheApp;
          // trailing =
          //     const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () async {
            final String playStoreUrl =
                "https://play.google.com/store/apps/details?id=jo.ctown.ecom";
            final String appStoreUrl =
                "https://apps.apple.com/in/app/ctown-jordan/id1602258988";

            if (await canLaunch(playStoreUrl) && Platform.isAndroid) {
              await launch(playStoreUrl);
            }
            if (await canLaunch(appStoreUrl) && Platform.isIOS) {
              await launch(appStoreUrl, forceSafariVC: false);
            }

            // else {
            //   throw "Couldn't launch URL";
            // }
          };
          // onTap = () =>
          //     _rateMyApp.showRateDialog(context).then((v) => setState(() {}));
          break;
        }
      // case 'legal':
      //   {
      //     icon = CupertinoIcons.doc_text;
      //     title = S.of(context).agreeWithPrivacy;
      //     trailing =
      //         const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
      //     onTap = () => Navigator.push(
      //         context,
      //
      //           MaterialPageRoute(
      //             builder: (context) => PrivacyScreen(),
      //           ),
      //
      //         // MaterialPageRoute(
      //         //   builder: (context) => PostScreen(
      //         //       //enter your pageId here
      //         //       pageId: 9937,
      //         //       pageTitle: "${S.of(context).agreeWithPrivacy}"),
      //         // ),
      //     );
      //     break;
      //   }

      case 'legal':
        {
          icon = CupertinoIcons.doc_text;
          title = S.of(context).legalterms;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () => Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) => LegalWidget(),
                ),

                // MaterialPageRoute(
                //   builder: (context) => PostScreen(
                //       //enter your pageId here
                //       pageId: 9937,
                //       pageTitle: "${S.of(context).agreeWithPrivacy}"),
                // ),
              );
          break;
        }
      case 'helpsupport':
        {
          icon = CupertinoIcons.phone_badge_plus;
          title = S.of(context).helpSupport;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () => Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) => HelpCenterWidget(),
                ),

                // MaterialPageRoute(
                //   builder: (context) => PostScreen(
                //       //enter your pageId here
                //       pageId: 9937,
                //       pageTitle: "${S.of(context).agreeWithPrivacy}"),
                // ),
              );
          break;
        }
      case 'feedback':
        {
          icon = CupertinoIcons.chat_bubble_text;
          title = S.of(context).feedback;
          trailing =
              const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
          onTap = () => Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (context) => FeedbackWidget(),
                ),

                // MaterialPageRoute(
                //   builder: (context) => PostScreen(
                //       //enter your pageId here
                //       pageId: 9937,
                //       pageTitle: "${S.of(context).agreeWithPrivacy}"),
                // ),
              );
          break;
        }
      // case 'about':
      //   {
      //     icon = CupertinoIcons.info;
      //     title = S.of(context).aboutUs;
      //     trailing =
      //         const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
      //     onTap = () => Navigator.push(
      //           context,
      //           // MaterialPageRoute(
      //           //   builder: (context) => WebView(
      //           //       url:
      //           //           "https://online.ajmanmarkets.ae/index.php/en/about-us-en",
      //           //       title: S.of(context).aboutUs),
      //           // )
      //           MaterialPageRoute(
      //             builder: (context) => AboutScreen('22'),
      //           ),
      //         );
      //     break;
      //   }
      // case 'help':
      //   {
      //     icon = CupertinoIcons.info;
      //     title = S.of(context).help;
      //     trailing =
      //         const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
      //     // onTap = () => Navigator.push(
      //     //   context,
      //     //   // MaterialPageRoute(
      //     //   //   builder: (context) => WebView(
      //     //   //       url:
      //     //   //           "https://online.ajmanmarkets.ae/index.php/en/about-us-en",
      //     //   //       title: S.of(context).aboutUs),
      //     //   // )
      //     //   MaterialPageRoute(
      //     //     builder: (context) => AboutScreen(),
      //     //   ),
      //     // );
      //     break;
      //   }
      default:
        {
          {
            icon = CupertinoIcons.info;
            title = S.of(context).aboutUs;
            trailing =
                const Icon(Icons.arrow_forward_ios, size: 18, color: kGrey600);
            onTap = () => Navigator.push(
                  context,
                  // MaterialPageRoute(
                  //   builder: (context) => WebView(
                  //       url:
                  //           "https://online.ajmanmarkets.ae/index.php/en/about-us-en",
                  //       title: S.of(context).aboutUs),
                  // )
                  MaterialPageRoute(
                    builder: (context) => AboutScreen('22'),
                  ),
                );
            break;
          }
          break;
        }
    }

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 2.0),
          elevation: 0,
          child: ListTile(
            leading: Icon(
              icon,
              color: kGrey600,
              size: 24,
            ),
            title: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
            trailing: trailing,
            onTap: onTap,
          ),
        ),
        Divider(
          color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.black12 : Theme.of(context).colorScheme.surface,
          height: 0.5,
          indent: 75,
          //endIndent: 20,
        ),
      ],
    );
  }

  deletecustomeraccount() async {
    try {
      var user_id = Provider.of<UserModel>(context, listen: false).user!;
      String _url = "https://up.ctown.jo/api/deleteCustomerAccount.php";

      Map body = {
        "user_name": user_id.name,
        "email": user_id.email,
        "phone": user_id.mobile_no,
        "customer_id": user_id.id
      };
      printLog(body);

      var responseBody;
      var response = await http.post(Uri.parse(_url), body: jsonEncode(body));
      printLog(response.statusCode);
      printLog("vengadesh");
      if (response.statusCode == 200) {
        printLog(response.body);
        responseBody = await jsonDecode(response.body);
        printLog(response.body);
        printLog(responseBody);

        if (responseBody["success"] == 0 &&
            responseBody["additionalMessage"].toString().isNotEmpty) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 8,
              title: Text(
                  Provider.of<AppModel>(context, listen: false).langCode == "en"
                      ? "Account Delete request"
                      : "طلب حذف الحساب"),
              content: Text(responseBody["additionalMessage"].toString()),

              // Text(Provider.of<AppModel>(context, listen: false)
              //             .langCode ==
              //         "en"
              //     ? "Your account deletion has been initiated as per your request; Kindly visit our Customer Service Helpdesk for any further assistance"
              //     : "تم بدء حذف حسابك بناءً على طلبك ؛ يرجى زيارة مكتب مساعدة خدمة العملاء للحصول على أي مساعدة إضافية"),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black38,
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(S.of(context).close),
                ),
              ],
            ),
          );
        } else {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 8,
              title: Text(
                  Provider.of<AppModel>(context, listen: false).langCode == "en"
                      ? "Account Delete request"
                      : "طلب حذف الحساب"),
              content: Text(Provider.of<AppModel>(context, listen: false)
                          .langCode ==
                      "en"
                  ? "Your account deletion has been initiated as per your request; Kindly visit our Customer Service Helpdesk for any further assistance"
                  : "تم بدء حذف حسابك بناءً على طلبك ؛ يرجى زيارة مكتب مساعدة خدمة العملاء للحصول على أي مساعدة إضافية"),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black38,
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(S.of(context).close),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _onScrollsToTop(ScrollsToTopEvent event) async {
    _scrollController.animateTo(0, duration: Duration(milliseconds: 1000), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    // Utils.setStatusBarWhiteForeground(false);
    super.build(context);

    bool loggedIn = Provider.of<UserModel>(context).loggedIn;
    final screenSize = MediaQuery.of(context).size;
    List<dynamic> settings = widget.settings ?? kDefaultSettings;
    // String background = widget.background ?? kProfileBackground;
    // final bool showChat = widget.showChat ?? false;
    final textStyle = TextStyle(fontSize: 14,
    color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white : Colors.black,);

    return Platform.isIOS ? ScrollsToTop(
      onScrollsToTop: _onScrollsToTop,
      child: Scaffold(
        // backgroundColor: Theme.of(context).backgroundColor,
        // floatingActionButton: showChat
        //     ? SmartChat(
        //         margin: EdgeInsets.only(
        //           right: Provider.of<AppModel>(context, listen: false).langCode ==
        //                   'ar'
        //               ? 30.0
        //               : 0.0,
        //         ),
        //       )
        //     : Container(),

        appBar: Platform.isAndroid
            ? AppBar(
                //  Colors.white,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: AppLocal(
                  scanBarcode: "Search",
                ),
              )
            : AppBar(
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: Container(
                  padding: const EdgeInsets.only(top: 4),
                  height: 55,
                  width: double.infinity,
                  color: Theme.of(context).primaryColor,
                  child: AppLocal2(
                    scanBarcode: "Search",
                  ),
                ),
              ),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            // SliverAppBar(
            //   pinned: true,
            //   snap: true,

            //   floating: true,
            //   titleSpacing: 0,
            //   title: Logo(
            //     config: logoConfigs['HorizonLayout'],
            //   ),
            // ),
            // SliverAppBar(
            //   backgroundColor: Theme.of(context).primaryColor,
            //   // leading: IconButton(
            //   //   icon: const Icon(
            //   //     Icons.blur_on,
            //   //     color: Colors.white70,
            //   //   ),
            //   //   onPressed: () {
            //   //     eventBus.fire('drawer');
            //   //     Scaffold.of(context).openDrawer();
            //   //   },
            //   // ),
            //   // expandedHeight: bannerHigh,
            //   floating: true,
            //   pinned: true,
            //   flexibleSpace: FlexibleSpaceBar(
            //     title: Text(S.of(context).settings,f
            //         style: const TextStyle(
            //             fontSize: 18,
            //             color: Colors.white,
            //             fontWeight: FontWeight.w600)),
            //     // background: Image.network(
            //     //   background,
            //     //   fit: BoxFit.cover,
            //     // ),
            //   ),
            // ),
            SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  Container(
                    width: screenSize.width,
                    child: Container(
                      width: screenSize.width /
                          (2 / (screenSize.height / screenSize.width)),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(height: 10.0),
                            if (widget.user != null && widget.user!.name != null)
                              ListTile(
                                leading:
                                    (widget.user!.picture?.isNotEmpty ?? false)
                                        ? CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(widget.user!.picture!),
                                          )
                                        : Icon(Icons.face, color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white : Colors.black,),
                                title: Text(
                                  widget.user!.firstName!.replaceAll("Ajman", "") +
                                      "  " +
                                      widget.user!.lastName!
                                          .replaceAll("Ajman", ""),
                                  style: textStyle,
                                ),
                              ),
                            if (widget.user != null && widget.user!.email != null)
                              ListTile(
                                leading: Icon(Icons.email, color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white : Colors.black, ),
                                title: Text(
                                  widget.user!.email!,
                                  style: textStyle,
                                ),
                              ),
                            if (widget.user != null)
                              Card(
                                margin: const EdgeInsets.only(bottom: 2.0),
                                elevation: 0,
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.portrait,
                                    color: kGrey600,
                                    size: 25,
                                  ),
                                  title: Text(
                                    S.of(context).updateUserInfor,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: kGrey600,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UserUpdate()),
                                    );
                                  },
                                ),
                              ),
                            if (widget.user != null)
                              Card(
                                margin: const EdgeInsets.only(bottom: 2.0),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.menu_book,
                                    color: kGrey600,
                                    size: 25,
                                  ),
                                  title: Text(
                                    S.of(context).addressBook,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: kGrey600,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddressBook(),
                                        ));
                                  },
                                ),
                              ),
                            if (widget.user == null)
                              Card(
                                margin: const EdgeInsets.only(bottom: 2.0),
                                elevation: 0,
                                child: ListTile(
                                  onTap: () {
                                    if (!loggedIn) {
                                      Navigator.of(context, rootNavigator: true).push(
                                          MaterialPageRoute(builder: (context) => LoginScreen(reLogin: true))
                                      );
                                      return;
                                    }
                                    Provider.of<WishListModel>(context,
                                            listen: false)
                                        .clearWishList();
                                    Provider.of<CartModel>(context, listen: false)
                                        .clearCart();
                                    Provider.of<UserModel>(context, listen: false)
                                        .logout();
                                    if (kLoginSetting['IsRequiredLogin'] ??
                                        false) {
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pushNamedAndRemoveUntil(
                                        RouteList.login,
                                        (route) => false,
                                      );
                                    }
                                  },
                                  leading: const Icon(Icons.person, color: kGrey600,),
                                  title: Text(
                                    loggedIn
                                        ? S.of(context).logout
                                        : S.of(context).login,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios,
                                      size: 18, color: kGrey600),
                                ),
                              ),
                            if (widget.user != null)
                              Card(
                                margin: const EdgeInsets.only(bottom: 2.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)
                                ),
                                elevation: 0,
                                child: ListTile(
                                  // onTap: () {
                                  //   Provider.of<WishListModel>(context, listen: false).clearWishList();
                                  //   Provider.of<UserModel>(context, listen: false).logout();
                                  //   if (kLoginSetting['IsRequiredLogin'] ?? false) {
                                  //     Navigator.of(
                                  //       context,
                                  //       rootNavigator: true,
                                  //     ).pushNamedAndRemoveUntil(
                                  //       RouteList.login,
                                  //       (route) => false,
                                  //     );
                                  //   }
                                  // },
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                        content: Text(
                                            S.of(context).are_you_sure_logout),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: kGrey200,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(25.0),
                                                  side: const BorderSide(
                                                    color: kGrey200)),
                                            ),
                                            child: Text(S.of(context).no,
                                            style: const TextStyle(
                                              color: Colors.black87
                                            ),),
                                          ),
                                          ElevatedButton(
                                            //onPressed: () => Navigator.of(context).pop(),
                                            onPressed: () async {
                                              Provider.of<WishListModel>(context,
                                                      listen: false)
                                                  .clearWishList();
                                              Provider.of<CartModel>(context,
                                                      listen: false)
                                                  .clearCart();
                                              await Provider.of<UserModel>(context,
                                                      listen: false)
                                                  .logout();
                                              if (kLoginSetting[
                                                      'IsRequiredLogin'] ??
                                                  false) {
                                                Navigator.of(
                                                  context,
                                                  rootNavigator: true,
                                                ).pushNamedAndRemoveUntil(
                                                  RouteList.login,
                                                  (route) => false,
                                                );
                                              }
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(S.of(context).yes,
                                            style: TextStyle(
                                              color: Colors.white
                                            ),),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(25.0),
                                                  side: const BorderSide(
                                                      color: Colors.red)),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                  leading: const Icon(
                                    Icons.logout,
                                    size: 20,
                                    color: kGrey600,
                                  ),

                                  // Image.asset(
                                  //   'assets/icons/profile/icon-logout.png',
                                  //   width: 24,
                                  //   color: Theme.of(context).accentColor,
                                  // ),
                                  title: Text(
                                    S.of(context).logout,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios,
                                      size: 18, color: kGrey600),
                                ),
                              ),
                            const SizedBox(height: 30.0),
                            Text(
                              S.of(context).generalSetting,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10.0),

                            /// render some extra menu for Vendor
                            if (widget.user != null &&
                                widget.user!.isVender == true) ...[
                              renderVendorAdmin(),
                              Services().widget?.renderVendorOrder(context) ?? const SizedBox.shrink(),
                            ],

                            /// Render custom Wallet feature
                            // renderWebViewProfile(),

                            /// render some extra menu for Listing
                            if (widget.user != null &&
                                Config().isListingType()) ...[
                              Services().widget?.renderNewListing(context) ?? const SizedBox.shrink(),
                              Services().widget?.renderBookingHistory(context) ?? const SizedBox.shrink(),
                            ],
                            const SizedBox(height: 10.0),
                            if (widget.user != null)
                              Divider(
                                color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.black12 : Theme.of(context).colorScheme.surface,
                                height: 0.5,
                                indent: 75,
                                //endIndent: 20,
                              ),
                            /// render list of dynamic menu

                            ...List.generate(
                              settings.length,
                              (index) {
                                return renderItem(settings[index]);
                              },
                            ),

                            if (widget.user != null)
                              Card(
                                margin: const EdgeInsets.only(bottom: 2.0),
                                elevation: 0,
                                child: ListTile(
                                  leading: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                  title: Text(
                                    S.of(context).deleteAccount,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Icon(Icons.arrow_forward_ios,
                                      size: 18, color: kGrey600),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                        elevation: 8,
                                        title: Text(Provider.of<AppModel>(context,
                                                        listen: false)
                                                    .langCode ==
                                                "en"
                                            ? "Account Delete request"
                                            : "طلب حذف الحساب"),
                                        // title: Text(
                                        //     Provider.of<AppModel>(context, listen: false).langCode ==
                                        //             "en"
                                        //         ? "Ajman Feedback"
                                        //         : "ملاحظات عجمان"),
                                        content: Text(Provider.of<AppModel>(
                                                        context,
                                                        listen: false)
                                                    .langCode ==
                                                "en"
                                            ? "Do you want to delete this account"
                                            : "هل تريد حذف هذا الحساب"),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.of(context).pop(false);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: kGrey200,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(25.0),
                                                  side: const BorderSide(
                                                      color: kGrey200)),
                                            ),
                                            child: Text(S.of(context).no),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await deletecustomeraccount();

                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text(
                                              S.of(context).yes,
                                            ),
                                            style: TextButton.styleFrom(
                                              backgroundColor: Theme.of(context).primaryColor,
                                              foregroundColor: Colors.white
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),

                            // const SizedBox(height: 100)
                            const SizedBox(height: 50),
                            Center(
                                child: Text(
                                    "version : ${Provider.of<SettingsProvider>(context, listen: false).version}")),
                            const SizedBox(height: 40)
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    ) :Scaffold(
      appBar: Platform.isAndroid ? AppBar(
        //  Colors.white,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Container(
          height: 45,
          child: AppLocal(
            scanBarcode: "Search",
          ),
        ),
      ) : AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Container(
          padding: const EdgeInsets.only(top: 2),
          height: 55,
          width: double.infinity,
          color: Theme.of(context).colorScheme.surface,
          child: AppLocal2(
            scanBarcode: "Search",
          ),
        ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                Container(
                  width: screenSize.width,
                  child: Container(
                    width: screenSize.width /
                        (2 / (screenSize.height / screenSize.width)),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 10.0),
                          if (widget.user != null && widget.user!.name != null)
                            ListTile(
                              leading:
                              (widget.user!.picture?.isNotEmpty ?? false)
                                  ? CircleAvatar(
                                backgroundImage:
                                NetworkImage(widget.user!.picture!),
                              )
                                  : Icon(Icons.face, color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white : Colors.black),
                              title: Text(
                                widget.user!.firstName!.replaceAll("Ajman", "") +
                                    "  " +
                                    widget.user!.lastName!
                                        .replaceAll("Ajman", ""),
                                style: textStyle,
                              ),
                            ),
                          if (widget.user != null && widget.user!.email != null)
                            ListTile(
                              leading: Icon(Icons.email, color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.white : Colors.black,),
                              title: Text(
                                widget.user!.email!,
                                style: textStyle,
                              ),
                            ),
                          if (widget.user != null)
                            Card(
                              margin: const EdgeInsets.only(bottom: 2.0),
                              elevation: 0,
                              child: ListTile(
                                leading: const Icon(
                                  Icons.portrait,
                                  color: kGrey600,
                                  size: 25,
                                ),
                                title: Text(
                                  S.of(context).updateUserInfor,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: kGrey600,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UserUpdate()),
                                  );
                                },
                              ),
                            ),
                          if (widget.user != null)
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              margin: const EdgeInsets.only(bottom: 2.0),
                              elevation: 0,
                              child: ListTile(
                                leading: const Icon(
                                  Icons.menu_book,
                                  color: kGrey600,
                                  size: 25,
                                ),
                                title: Text(
                                  S.of(context).addressBook,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: kGrey600,
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddressBook(),
                                      ));
                                },
                              ),
                            ),
                          if (widget.user == null)
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              margin: const EdgeInsets.only(bottom: 2.0),
                              elevation: 0,
                              child: ListTile(
                                onTap: () {
                                  if (!loggedIn) {
                                    Navigator.of(context, rootNavigator: true).push(
                                        MaterialPageRoute(builder: (context) => LoginScreen(reLogin: true))
                                    );
                                    return;
                                  }
                                  Provider.of<WishListModel>(context,
                                      listen: false)
                                      .clearWishList();
                                  Provider.of<CartModel>(context, listen: false)
                                      .clearCart();
                                  Provider.of<UserModel>(context, listen: false)
                                      .logout();
                                  if (kLoginSetting['IsRequiredLogin'] ??
                                      false) {
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pushNamedAndRemoveUntil(
                                      RouteList.login,
                                          (route) => false,
                                    );
                                  }
                                },
                                leading: const Icon(Icons.person),
                                title: Text(
                                  loggedIn
                                      ? S.of(context).logout
                                      : S.of(context).login,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 18, color: kGrey600),
                              ),
                            ),
                          if (widget.user != null)
                            Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              margin: const EdgeInsets.only(bottom: 2.0),
                              elevation: 0,
                              child: ListTile(
                                // onTap: () {
                                //   Provider.of<WishListModel>(context, listen: false).clearWishList();
                                //   Provider.of<UserModel>(context, listen: false).logout();
                                //   if (kLoginSetting['IsRequiredLogin'] ?? false) {
                                //     Navigator.of(
                                //       context,
                                //       rootNavigator: true,
                                //     ).pushNamedAndRemoveUntil(
                                //       RouteList.login,
                                //       (route) => false,
                                //     );
                                //   }
                                // },
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                      content: Text(
                                          S.of(context).are_you_sure_logout),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text(S.of(context).no,
                                            style: const TextStyle(
                                                color: Colors.black87
                                            ),),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kGrey200,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(25.0),
                                                side: const BorderSide(
                                                    color: kGrey200)),
                                          ),
                                        ),
                                        ElevatedButton(
                                          //onPressed: () => Navigator.of(context).pop(),
                                          onPressed: () {
                                            Provider.of<WishListModel>(context,
                                                listen: false)
                                                .clearWishList();
                                            Provider.of<CartModel>(context,
                                                listen: false)
                                                .clearCart();
                                            Provider.of<UserModel>(context,
                                                listen: false)
                                                .logout();
                                            if (kLoginSetting[
                                            'IsRequiredLogin'] ??
                                                false) {
                                              Navigator.of(
                                                context,
                                                rootNavigator: true,
                                              ).pushNamedAndRemoveUntil(
                                                RouteList.login,
                                                    (route) => false,
                                              );
                                            }
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(S.of(context).yes,
                                            style: const TextStyle(
                                                color: Colors.white
                                            ),),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(25.0),
                                                side: const BorderSide(
                                                    color: Colors.red)),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                                leading: const Icon(
                                  Icons.logout,
                                  size: 20,
                                  color: kGrey600,
                                ),

                                // Image.asset(
                                //   'assets/icons/profile/icon-logout.png',
                                //   width: 24,
                                //   color: Theme.of(context).accentColor,
                                // ),
                                title: Text(
                                  S.of(context).logout,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 18, color: kGrey600),
                              ),
                            ),
                          const SizedBox(height: 30.0),
                          Text(
                            S.of(context).generalSetting,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10.0),

                          /// render some extra menu for Vendor
                          if (widget.user != null &&
                              widget.user!.isVender == true) ...[
                            renderVendorAdmin(),
                            Services().widget?.renderVendorOrder(context) ?? const SizedBox.shrink(),
                          ],

                          /// Render custom Wallet feature
                          // renderWebViewProfile(),

                          /// render some extra menu for Listing
                          if (widget.user != null &&
                              Config().isListingType()) ...[
                            Services().widget?.renderNewListing(context) ?? const SizedBox.shrink(),
                            Services().widget?.renderBookingHistory(context) ?? const SizedBox.shrink(),
                          ],
                          const SizedBox(height: 10.0),
                          if (widget.user != null)
                            Divider(
                              color: Provider.of<AppModel>(context, listen: false).darkTheme ? Colors.black12 : Theme.of(context).colorScheme.surface,
                              height: 0.5,
                              indent: 75,
                              //endIndent: 20,
                            ),

                          /// render list of dynamic menu

                          ...List.generate(
                            settings.length,
                                (index) {
                              return renderItem(settings[index]);
                            },
                          ),

                          if (widget.user != null)
                            Card(
                              margin: const EdgeInsets.only(bottom: 2.0),
                              elevation: 0,
                              child: ListTile(
                                leading: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 24,
                                ),
                                title: Text(
                                  S.of(context).deleteAccount,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios,
                                    size: 18, color: kGrey600),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                      elevation: 8,
                                      title: Text(Provider.of<AppModel>(context,
                                          listen: false)
                                          .langCode ==
                                          "en"
                                          ? "Account Delete request"
                                          : "طلب حذف الحساب"),
                                      // title: Text(
                                      //     Provider.of<AppModel>(context, listen: false).langCode ==
                                      //             "en"
                                      //         ? "Ajman Feedback"
                                      //         : "ملاحظات عجمان"),
                                      content: Text(Provider.of<AppModel>(
                                          context,
                                          listen: false)
                                          .langCode ==
                                          "en"
                                          ? "Do you want to delete this account"
                                          : "هل تريد حذف هذا الحساب"),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop(false);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kGrey200,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(25.0),
                                                side: const BorderSide(
                                                    color: kGrey200)),
                                          ),
                                          child: Text(S.of(context).no),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await deletecustomeraccount();

                                            Navigator.of(context).pop(false);
                                          },
                                          child: Text(
                                            S.of(context).yes,
                                          ),
                                          style: TextButton.styleFrom(
                                            backgroundColor: Theme.of(context).primaryColor,
                                            foregroundColor: Colors.white
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),

                          // const SizedBox(height: 100)
                          const SizedBox(height: 50),
                          Center(
                              child: Text(
                                  "version : ${Provider.of<SettingsProvider>(context, listen: false).version}")),
                          const SizedBox(height: 40)
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
