import 'dart:async';

import 'package:ctown/screens/users/reset_password_screen.dart';
import 'package:ctown/services/index.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../widgets/common/login_animation.dart';

class ValidateOTP extends StatefulWidget {
  final String? phoneNumber;
  final String? verId;
  //final Stream<firebase_auth.PhoneAuthCredential> verifySuccessStream;

  ValidateOTP({this.verId, this.phoneNumber
      // ,
      // this.verifySuccessStream
      });

  @override
  _ValidateOTPState createState() => _ValidateOTPState();
}

class _ValidateOTPState extends State<ValidateOTP>
    with TickerProviderStateMixin, CodeAutoFill {
  late AnimationController _loginButtonController;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _pinCodeController = TextEditingController();

  bool hasError = false;
  String currentText = "";
  var onTapRecognizer;

  @override
  void codeUpdated() {
    if (mounted) {
      setState(() {
        _pinCodeController.text = code!;
      });
    }
  }

  // Future<void> _verifySuccessStreamListener(
  //     firebase_auth.PhoneAuthCredential credential) async {
  //   if (credential != null && mounted) {
  //     await _playAnimation();
  //     //await _signInWithCredential(credential);
  //   }
  // }

  @override
  void initState() {
    super.initState();

    //widget.verifySuccessStream?.listen(_verifySuccessStreamListener);

    listenForCode();

    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pop(context);
      };

    _loginButtonController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    //widget.verifySuccessStream?.listen(null);
    _loginButtonController.dispose();
    cancel();
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

  // void _welcomeMessage(user, context) {
  //   if (widget.fromCart) {
  //     Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
  //         RouteList.dashboard, (Route<dynamic> route) => false);
  //   } else {
  //     Tools.showSnackBar(
  //         Scaffold.of(context), S.of(context).welcome + ' ${user.name} !');

  //     Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
  //         RouteList.dashboard, (Route<dynamic> route) => false);
  //   }
  // }

  void _failMessage(message, context) {
    /// Showing Error messageSnackBarDemo
    /// Ability so close message
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

  _loginSMS(smsCode, context) async {
    await _playAnimation();
    try {
      // final firebase_auth.AuthCredential credential =
      //     firebase_auth.PhoneAuthProvider.credential(
      //   verificationId: widget.verId,
      //   smsCode: smsCode,
      // );

      // await _signInWithCredential(credential);
      await Services().widget?.verifyOTP(context, widget.verId, smsCode);
      _stopAnimation();
      await Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ResetPasswordScreen(customerId: widget.verId),
      ));
    } catch (e) {
      await _stopAnimation();
      _failMessage(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          S.of(context).verifySMSCode,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 40),
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Container(
                    //     height: 40.0,
                    //     child: Image.asset(
                    //       // kLogo
                    //       "assets/images/logo.png",
                    //     )),
                    Padding(
                      padding: EdgeInsets.only(left: 55, right: 55),
                      child: Container(
                        height: 80.0,

                        width: 150,
                        decoration: BoxDecoration(
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
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                S.of(context).phoneNumberVerification,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
              child: RichText(
                text: TextSpan(
                    text: S.of(context).enterSendedCode + "  ",
                    children: [
                      TextSpan(
                          text: widget.phoneNumber,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ],
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 15)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 50),
                child: PinCodeTextField(
                  appContext: context,
                  controller: _pinCodeController,
                  keyboardType: TextInputType.number,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(9),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: Theme.of(context).colorScheme.surface,
                  ),
                  length: 4,
                  autoFocus: true,
                  animationType: AnimationType.fade,
                  animationDuration: const Duration(milliseconds: 300),
                  onChanged: (value) {
                    if (value != null && value.length == 4) {
                      _loginSMS(value, context);
                    }
                  },
                )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              // error showing widget
              child: Text(
                hasError ? S.of(context).pleasefillUpAllCellsProperly : "",
                style: TextStyle(color: Colors.red.shade300, fontSize: 15),
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: S.of(context).didntReceiveCode,
                  style: const TextStyle(color: Colors.black54, fontSize: 15),
                  children: [
                    TextSpan(
                        text: S.of(context).resend,
                        recognizer: onTapRecognizer,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16))
                  ]),
            ),
            const SizedBox(
              height: 14,
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
              child: StaggerAnimation(
                titleButton: S.of(context).verifySMSCode,
                buttonController: _loginButtonController.view as AnimationController,
                onTap: () {
                  if (!isLoading) {
                    // changeNotifier.add(Functions.submit);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _signInWithCredential(
  //     firebase_auth.PhoneAuthCredential credential) async {
  //   final firebase_auth.User user = (await firebase_auth.FirebaseAuth.instance
  //           .signInWithCredential(credential))
  //       .user;
  //   if (user != null) {
  //     await Provider.of<UserModel>(context, listen: false).loginFirebaseSMS(
  //       phoneNumber: user.phoneNumber,
  //       success: (user) {
  //         _stopAnimation();
  //         _welcomeMessage(user, context);
  //       },
  //       fail: (message) {
  //         _stopAnimation();
  //         _failMessage(message, context);
  //       },
  //     );
  //   } else {
  //     await _stopAnimation();
  //     _failMessage(S.of(context).invalidSMSCode, context);
  //   }
  // }
}

class PrimaryColorOverride extends StatelessWidget {
  const PrimaryColorOverride({Key? key, this.color, this.child})
      : super(key: key);

  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child!,
      data: Theme.of(context).copyWith(primaryColor: color),
    );
  }
}
