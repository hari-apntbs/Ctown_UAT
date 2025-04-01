import 'package:app_settings/app_settings.dart';
import 'package:ctown/models/app_model.dart';
import 'package:ctown/screens/settings/check_deliverable.dart';
import 'package:ctown/services/service_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app.dart';
import '../../common/config.dart';
import '../../common/config.dart' as config;
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/cart/cart_base.dart';
import '../../models/cart/cart_model.dart';
import '../../models/point_model.dart';
import '../../models/user_model.dart';
import '../../screens/base.dart';
import '../../services/index.dart';
import '../../services/service_config.dart';
import '../../widgets/common/login_animation.dart';
import '../../widgets/common/webview.dart';
import 'forgot_password.dart';
import 'registration/registration.dart';

class LoginScreen extends StatefulWidget {
  final bool fromCart;
  final Function? onLoginSuccess;
  final bool reLogin;

  LoginScreen({this.fromCart = false, this.onLoginSuccess, this.reLogin = false});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends BaseScreen<LoginScreen>
    with TickerProviderStateMixin {
  final isRequiredLogin = config.kLoginSetting['IsRequiredLogin'];
  late AnimationController _loginButtonController;
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final usernameNode = FocusNode();
  final passwordNode = FocusNode();

  late var parentContext;
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;
  bool isAvailableApple = false;

  Position? location;
  LocationPermission? hasPermission;
  bool serviceEnabled = false;
  late Position locationData;
  LatLng? target;

  @override
  void initState() {
    super.initState();
    _loginButtonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      hasPermission = await Geolocator.checkPermission();
      if (hasPermission == LocationPermission.denied) {
        hasPermission = await Geolocator.requestPermission();
        if(hasPermission != LocationPermission.denied && hasPermission != LocationPermission.deniedForever) {
          locationData = await Geolocator.getCurrentPosition();
          target = LatLng(locationData.latitude, locationData.longitude);
        }
      }
      setState(() {});
    } catch (e) {
      printLog('[Login] afterFirstLayout error');
    }
  }

  @override
  void dispose() {
    _loginButtonController.dispose();
    username.dispose();
    password.dispose();
    usernameNode.dispose();
    passwordNode.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      setState(() {
        isLoading = true;
      });
      await _loginButtonController.forward();
    } on TickerCanceled {
      printLog('[_playAnimation] error');
    }
  }

  Future<Null> _stopAnimation() async {
    try {
      await _loginButtonController.reverse();
      setState(() {
        isLoading = false;
      });
    } on TickerCanceled {
      printLog('[_stopAnimation] error');
    }
  }

  void _preloadAddress(BuildContext context) {
    Provider.of<CartModel?>(context, listen: false)?.address = null;
    Provider.of<CartModel?>(context, listen: false)?.getAddress(Provider.of<AppModel>(context, listen: false).langCode ?? "en");
  }

  Future _welcomeMessage(user, context) async {
    Provider.of<CartModel?>(context, listen: false)?.setUser(user);
    if (user != null &&
        (kAdvanceConfig["EnableSyncCartFromWebsite"] as bool? ?? true)) {
      await Services().widget?.syncCartFromWebsite(
          user.cookie, Provider.of<CartModel>(context, listen: false), context, Provider.of<AppModel>(context, listen: false)
          .langCode ?? "en");
      Provider.of<PointModel>(context, listen: false)
          .getMyPoint(user.cookie);
    }

    _preloadAddress(context);

    if (widget.onLoginSuccess != null) {
      widget.onLoginSuccess!(context);
    } else {
      if (widget.fromCart || widget.reLogin) {
        Navigator.of(context).pop(user);
      } else {
        if (user.name != null) {
          Tools.showSnackBar(
              ScaffoldMessenger.of(context), '${S.of(context).welcome} ${user.name} !');
          // ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(
          //     SnackBar(content: Text(S.of(context).welcome + ' ${user.name} !'))
          // );
        }
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const CheckIfDeliverable(isSkip: false),
          ),
        );
      }
    }
  }

  getSavedStore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var result = await prefs.getString('savedStore');
    if (result != null) {
      return true;
    }
    return false;
  }

  void _failMessage(message, context) {
    /// Showing Error messageSnackBarDemo
    /// Ability so close message
    final snackBar = SnackBar(
      content: Text(S.of(context).warning(message)),
      duration: const Duration(seconds: 30),
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    ScaffoldMessenger.of(context)
      // ignore: deprecated_member_use
      ..removeCurrentSnackBar()
      // ignore: deprecated_member_use
      ..showSnackBar(snackBar);
  }

  // _loginFacebook(context) async {
  //   //showLoading();
  //   await _playAnimation();
  //   await Provider.of<UserModel>(context, listen: false).loginFB(
  //       success: (user) {
  //         //hideLoading();
  //         _stopAnimation();
  //         _welcomeMessage(user, context);
  //       },
  //       fail: (message) {
  //         //hideLoading();
  //         _stopAnimation();
  //         _failMessage(message, context);
  //       },
  //       context: context);
  // }

  _loginApple(context) async {
    await _playAnimation();
    await Provider.of<UserModel>(context, listen: false).loginApple(
        success: (user) {
          _stopAnimation();
          _welcomeMessage(user, context);
        },
        fail: (message) {
          _stopAnimation();
          _failMessage(message, context);
        },
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    List<Map<String, dynamic>> languages = Utils.getLanguagesList(context);
    for (var i = 0; i < languages.length; i++) {
      if (languages[i]["code"] != Provider.of<AppModel>(context, listen: false).langCode) {
        list.add(InkWell(
          onTap: () async {
            await Provider.of<AppModel>(context, listen: false)
                .changeLanguage(languages[i]["code"], context);
          },
          child: Container(
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //  SizedBox(width:30),
                // Icon(Icons.translate),

                // Icon(Icons.translate),
                const SizedBox(width: 10),
                Provider.of<AppModel>(context, listen: false).langCode == 'en'
                    ? const Text("EN-AR", style: TextStyle(color: Colors.white))
                    : const Text("AR-EN",
                        style: TextStyle(color: Colors.white)),
                const SizedBox(width: 10),

                //  Provider.of<AppModel>(context, listen: false).langCode=='en'?
                // Text("Change Language to EN - AR?",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),):
                // Text("تغيير اللغة إلى AR- EN?",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),)
              ],
            ),
          ),
        )

            // IconButton(
            //   icon:Icon(
            //   Icons.language_rounded),
            //   // leading: Image.asset(
            //   //   languages[i]["icon"],
            //   //   width: 30,
            //   //   height: 20,
            //   //   fit: BoxFit.cover,
            //   // ),
            //   // title: Text(languages[i]["name"]),
            //   onPressed: () async {
            //     await Provider.of<AppModel>(context, listen: false)
            //         .changeLanguage(languages[i]["code"], context);
            //   //   setState(() {});
            //   //   _showLoading(languages[i]["text"]);
            //   },
            // ),
            );
        if (i < languages.length - 1) {
          list.add(
            const Divider(
              color: Colors.black12,
              height: 1.0,
              indent: 75,
              //endIndent: 20,
            ),
          );
        }
      }
    }
    parentContext = context;

    String? forgetPasswordUrl = Config().forgetPassword;

    Future launchForgetPassworddWebView(String url) async {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              InAppWebView(url: url, appBarRequire: true, title: S.of(context).resetPassword),
          fullscreenDialog: true,
        ),
      );
    }

    void launchForgetPasswordURL(String? url) async {
      if (url != null && url != '') {
        /// show as webview
        await launchForgetPassworddWebView(url);
      } else {
        /// show as native
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ForgotPassword()),
        );
      }
    }

    _login(context) async {
      if (username.text.isEmpty || password.text.isEmpty) {
        Tools.showSnackBar(ScaffoldMessenger.of(context), S.of(context).pleaseInput);
      } else {
        await _playAnimation();
        await Provider.of<UserModel>(context, listen: false).login(
          username: username.text.startsWith("0")
              ? username.text.substring(1)
              : username.text.trim(),
          password: password.text.trim(),
          success: (user) async {
            await _welcomeMessage(user, context);
            await _stopAnimation();
            await _auth.signInWithEmailAndPassword(
              email: username.text,
              password: username.text,
            ).catchError(
                  (onError) {
                if (onError.code == 'ERROR_USER_NOT_FOUND') {
                  _auth.createUserWithEmailAndPassword(
                    email: username.text,
                    password: username.text,
                  ).then((_) {
                    _auth.signInWithEmailAndPassword(
                      email: username.text,
                      password: username.text,
                    );
                  });
                }
                return onError;
              },
            );
          },
          fail: (message) {
            _stopAnimation();
            _failMessage(message, context);
          },
        );
      }
    }

    // _loginSMS(context) async {
    //   await Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => LoginSMS()),
    //   );
    // }

    _loginGoogle(context) async {
      await _playAnimation();
      await Provider.of<UserModel>(context, listen: false).loginGoogle(
        Provider.of<AppModel>(context, listen: false).langCode ?? "en",
          success: (user) {
            //hideLoading();
            _stopAnimation();
            _welcomeMessage(user, context);
          },
          fail: (message) {
            //hideLoading();
            _stopAnimation();
            _failMessage(message, context);
          },
          context: context);
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(
          child: Text(
            S.of(context).login,
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
        ),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.of(context).pop();
                })
            : Container(),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
        actions: [
          ...list,
          // LoginLanguage(),
          // IconButton( icon: const Icon(Icons.language_rounded),
          //       onPressed: () {
          //         Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginLanguage()));
          //       }
          //         )
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Utils.hideKeyboard(context),
            child: Center(
              child: Stack(
                children: [
                  ListenableProvider.value(
                    value: Provider.of<UserModel>(context),
                    child:
                        Consumer<UserModel>(builder: (context, model, child) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Container(
                          alignment: Alignment.center,
                          width: 500,
                          // height: 600,
                          child: Column(
                            children: <Widget>[
                              //const SizedBox(height: 0.0),
                              Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        height: 130.0,
                                        width: 230,
                                        decoration: const BoxDecoration(
                                          // color: Colors.red,
                                          image: DecorationImage(
                                              image: AssetImage(
                                                "assets/images/logo.png",
                                              ),
                                              fit: BoxFit.cover),
                                        ),
                                        // child: Image.asset(kLogo,
                                        //     width: 300,
                                        //     fit: BoxFit.fitHeight)
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 30.0,
                              ),
                              Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      // Text(S.of(context).forgot),
                                      // GestureDetector(
                                      //   onTap: () {
                                      //     launchForgetPasswordURL(
                                      //         forgetPasswordUrl);
                                      //   },
                                      Text(
                                        S.of(context).login_desc,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              TextField(
                                  controller: username,
                                  textInputAction: TextInputAction.next,
                                  onSubmitted: (_) => FocusScope.of(context)
                                      .requestFocus(passwordNode),
                                  decoration: InputDecoration(
                                    labelText: S.of(parentContext).username,
                                    labelStyle:
                                        GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                                  )),
                              const SizedBox(height: 10.0),
                              Stack(children: <Widget>[
                                TextField(
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  controller: password,
                                  focusNode: passwordNode,
                                  decoration: InputDecoration(
                                    labelText: S.of(parentContext).password,
                                    labelStyle:
                                        GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                                  ),
                                ),
                                // Positioned(
                                //   right: appModel.langCode == "ar" ? null : 4,
                                //   left: appModel.langCode == "ar" ? 4 : null,
                                //   bottom: 20,
                                //   child: GestureDetector(
                                //     child: Text(
                                //       " " + S.of(context).reset,
                                //       style: TextStyle(
                                //           color:
                                //               Theme.of(context).primaryColor),
                                //     ),
                                //     onTap: () {
                                //       launchForgetPasswordURL(
                                //           forgetPasswordUrl);
                                //     },
                                //   ),
                                // )
                              ]),
                              const SizedBox(
                                height: 30.0,
                              ),
                              Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          launchForgetPasswordURL(
                                              forgetPasswordUrl);
                                        },
                                        child: Text(
                                          " ${S.of(context).forgot}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 30.0,
                              ),
                              StaggerAnimation(
                                titleButton: S.of(context).signIn,
                                buttonController: _loginButtonController.view as AnimationController,
                                onTap: () {
                                  if (!isLoading) {
                                    _login(context);
                                  }
                                },
                              ),
                              Stack(
                                alignment: AlignmentDirectional.center,
                                children: <Widget>[
                                  SizedBox(
                                      height: 50.0,
                                      width: 200.0,
                                      child:
                                          Divider(color: Colors.grey.shade300)),
                                  Container(
                                      height: 30,
                                      width: 40,
                                      color: Theme.of(context).colorScheme.surface),
                                  if (kLoginSetting['showFacebook']! ||
                                      kLoginSetting['showSMSLogin']! ||
                                      kLoginSetting['showGoogleLogin']! ||
                                      kLoginSetting['showAppleLogin']!)
                                    Text(
                                      S.of(context).or,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade400),
                                    )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  if (kLoginSetting['showAppleLogin']! &&
                                      isAvailableApple)
                                    InkWell(
                                      onTap: () => _loginApple(context),
                                      child: Container(
                                        child: const Icon(
                                          FontAwesomeIcons.apple,
                                          color: Colors.white,
                                          size: 24.0,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  if (kLoginSetting['showFacebook']!)
                                    InkWell(
                                      //onTap: () => _loginFacebook(context),
                                      child: Container(
                                        child: const Icon(
                                          FontAwesomeIcons.facebookF,
                                          color: Colors.white,
                                          size: 24.0,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          color: const Color(0xFF4267B2),
                                        ),
                                      ),
                                    ),
                                  if (kLoginSetting['showGoogleLogin']!)
                                    InkWell(
                                      onTap: () => _loginGoogle(context),
                                      child: Container(
                                        child: const Icon(
                                          FontAwesomeIcons.google,
                                          color: Colors.white,
                                          size: 24.0,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          color: const Color(0xFFEA4336),
                                        ),
                                      ),
                                    ),
                                  // if (kLoginSetting['showSMSLogin'])
                                  //   InkWell(
                                  //     onTap: () => _loginSMS(context),
                                  //     child: Container(
                                  //       child: const Icon(
                                  //         FontAwesomeIcons.sms,
                                  //         color: Colors.white,
                                  //         size: 24.0,
                                  //       ),
                                  //       padding: const EdgeInsets.all(12),
                                  //       decoration: BoxDecoration(
                                  //         borderRadius:
                                  //             BorderRadius.circular(40),
                                  //         color: Colors.lightBlue,
                                  //       ),
                                  //     ),
                                  //   ),
                                ],
                              ),
                              const SizedBox(
                                height: 30.0,
                              ),
                              Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(S.of(context).dontHaveAccount),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  RegistrationScreen(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          " ${S.of(context).signup}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap:
                                            () async {
                                          bool checkIfStoreSaved =
                                              await getSavedStore();
                                          printLog(
                                              "in login $checkIfStoreSaved");
                                          if (checkIfStoreSaved) {
                                            Navigator.of(
                                              context,
                                              rootNavigator: true,
                                            ).pushNamedAndRemoveUntil(
                                              RouteList.dashboard,
                                                  (route) => false,
                                            );
                                          } else {
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const CheckIfDeliverable(
                                                        isSkip: true),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          " ${S.of(context).skip}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  showPermissionAlertDialog(BuildContext context) {
    // set up the buttons
    Widget okayButton = TextButton(
      child: const Text("OK",
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            fontFamily: "PoppinsBold",
            color: Colors.red,
          )),
      onPressed: () async {
        hasPermission = await Geolocator.checkPermission();
        if (hasPermission == false) {
          await AppSettings.openAppSettings().then((value) async {
            hasPermission = await Geolocator.checkPermission();
            setState(() {});
          });
        } else {
          Navigator.of(context).pop();
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      titlePadding: const EdgeInsets.only(
          left: 10.0, right: 10.0, top: 10.0, bottom: 5.0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: StatefulBuilder(builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Alert",
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: "PoppinsBold",
                  color: Colors.red,
                )),
            const SizedBox(height: 10.0),
            const Text(
              "Location permission is needed. Please turn on.",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 15.0,
                color: Colors.black,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                okayButton,
              ],
            ),
          ],
        );
      }),
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(child: alert, onWillPop: () async => false);
      },
    );
  }

  showGpsAlertDialog(BuildContext context) {
    // set up the buttons
    Widget okayButton = TextButton(
      child: const Text("OK",
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            fontFamily: "PoppinsBold",
            color: Colors.red,
          )),
      onPressed: () async {
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled == false) {
          await AppSettings.openAppSettings().then((value) async {
            hasPermission = await Geolocator.checkPermission();
            setState(() {});
          });
        } else {
          Navigator.of(context).pop();
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      titlePadding: const EdgeInsets.only(
          left: 10.0, right: 10.0, top: 10.0, bottom: 5.0),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: StatefulBuilder(builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Alert",
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: "PoppinsBold",
                  color: Colors.red,
                )),
            const SizedBox(height: 10.0),
            const Text(
              "GPS location permission is needed. Please turn on.",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 15.0,
                color: Colors.black,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                okayButton,
              ],
            ),
          ],
        );
      }),
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(child: alert, onWillPop: () async => false);
      },
    );
  }
}
