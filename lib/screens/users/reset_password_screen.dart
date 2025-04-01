import 'package:flutter/material.dart';

import '../../common/constants/general.dart';
import '../../common/constants/images.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../services/index.dart';
import '../../widgets/common/login_animation.dart';

class ResetPasswordScreen extends StatefulWidget {
  final customerId;

  const ResetPasswordScreen({
    Key? key,
    required this.customerId,
  }) : super(key: key);
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> with TickerProviderStateMixin {
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  late var parentContext;
  final confirmPasswordNode = FocusNode();
  late AnimationController _loginButtonController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loginButtonController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _loginButtonController.dispose();
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

  void _failMessage(message, context) {
    /// Showing Error messageSnackBarDemo
    /// Ability to close message
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 30),
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    // ignore: deprecated_member_use
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  _onSubmit(context) async {
    try {
      await _playAnimation();

      if (password.text.isEmpty || confirmPassword.text.isEmpty) {
        Tools.showSnackBar(ScaffoldMessenger.of(context), 'Please input all the fields');
      } else if (password.text != confirmPassword.text) {
        Tools.showSnackBar(ScaffoldMessenger.of(context), 'Passwords do not match!');
      } else {
        await Services().widget?.resetPasswordMobile(context, widget.customerId, password.text);
        //await _stopAnimation();
        // await Navigator.of(context).pushReplacement(MaterialPageRoute(
        //   builder: (context) => const HomeScreen(),
        // ));
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      await _stopAnimation();
    } catch (e) {
      await _stopAnimation();
      _failMessage(e.toString(), context);
    }

    // call function to reset password
    // start and stop animation
  }

  @override
  Widget build(BuildContext context) {
    parentContext = context;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                })
            : Container(),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Utils.hideKeyboard(context),
            child: Center(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Container(
                      alignment: Alignment.center,
                      width: 500,
                      height: 600,
                      child: Column(
                        children: <Widget>[
                          //const SizedBox(height: 0.0),
                          Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                      height: 100.0,
                                      child: Image.asset(
                                        kLogo,
                                        width: 250,
                                        fit: BoxFit.contain,
                                      )),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Reset Password",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                          TextField(
                              obscureText: true,
                              controller: password,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => FocusScope.of(context).requestFocus(confirmPasswordNode),
                              decoration: InputDecoration(
                                labelText: S.of(parentContext).newPassword,
                              )),
                          const SizedBox(height: 10.0),
                          Stack(children: <Widget>[
                            TextField(
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              controller: confirmPassword,
                              focusNode: confirmPasswordNode,
                              decoration: const InputDecoration(
                                labelText: 'Confirm password', //S.of(parentContext).confirmPassword,
                              ),
                            ),
                          ]),
                          const SizedBox(
                            height: 30.0,
                          ),
                          StaggerAnimation(
                            titleButton: S.of(context).resetPassword,
                            buttonController: _loginButtonController.view as AnimationController,
                            onTap: () {
                              if (!isLoading) {
                                _onSubmit(context);
                              }
                              // if (!isLoading) {
                              //   _login(context);
                              // }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
