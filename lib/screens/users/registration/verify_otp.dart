import 'dart:async';

import 'package:ctown/models/index.dart';
import 'package:ctown/screens/settings/check_deliverable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/user_model.dart';
import '../../../widgets/common/login_animation.dart';

class VerifyOtp extends StatefulWidget {
  final String? firstName;
  final String? lastName;
  final String? countryCode;
  final String? phoneNumber;
  final String? password;
  final String? emailAddress;
  final String? loyalty_card_number;
  final bool? isVendor;

  const VerifyOtp({
    Key? key,
    this.countryCode,
    this.password,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.emailAddress,
    this.loyalty_card_number,
    this.isVendor,
  }) : super(key: key);

  _VerifyOtpState createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp>
    with TickerProviderStateMixin, CodeAutoFill {
  late AnimationController _loginButtonController;
  bool isLoading = false;
  bool isSending = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _pinCodeController = TextEditingController();

  bool hasError = false;
  String currentText = "";
  var onTapRecognizer;
  var _smsCode = "", _password = "";

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
    _listOPT();

    //widget.verifySuccessStream?.listen(_verifySuccessStreamListener);

    //listenForCode();

    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        print("fdfdf");
        setState(() {
          isSending = true;
        });
        //Navigator.pop(context);
        var uri = Uri.parse("https://up.ctown.jo/api/sms.php");
        print("sms resend php body");
        print({
          'phone_number': widget.countryCode! + widget.phoneNumber!,
        });
        var response = await http.post(uri, body: {
          'phone_number': widget.countryCode! + widget.phoneNumber!,
        });
        setState(() {
          isSending = false;
        });
        if (response.statusCode != 200) {
          _snackBar("Could not request OTP at this time");
        } else {
          _snackBar("OTP resent to your phone number");
        }
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

  void _welcomeDiaLog(User user) async {
    Provider.of<CartModel>(context, listen: false).setUser(user);
    Provider.of<PointModel>(context, listen: false).getMyPoint(user.cookie);
    var email = user.email;
    print("user email $email");
    _snackBar(S.of(context).welcome + ' $email!');
    // if (kIsWeb) {
    //   Navigator.of(context).pushReplacementNamed('/home-screen');
    // } else {
    //   Navigator.of(context).pushReplacementNamed(RouteList.dashboard);
    // }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CheckIfDeliverable(isSkip: false),
      ),
    );
  }

  void _snackBar(String text) {
    if (mounted) {
      final snackBar = SnackBar(
        content: Text('$text'),
        duration: const Duration(seconds: 10),
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
  }

  _loginSMS(smsCode, context) async {
    await _playAnimation();
    print("printeeed");
    try {
      //await Services().widget.verifyOTP(context, widget.verId, _smsCode);
      await Provider.of<UserModel>(context, listen: false).createUser(
        username: widget.emailAddress!,
        password: widget.password!,
        firstName: widget.firstName,
        lastName: widget.lastName,
        phoneNumber: widget.phoneNumber,
        countryCode: widget.countryCode,
        otp: _smsCode,
        loyalty_card_number: widget.loyalty_card_number,
        success: _welcomeDiaLog,
        fail: _snackBar,
        isVendor: widget.isVendor,
      );
      await _stopAnimation();
      // await Navigator.of(context).pushReplacement(MaterialPageRoute(
      //     //builder: (context) => ResetPasswordScreen(customerId: widget.verId),
      //     ));
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
            const SizedBox(height: 30),
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Container(height: 40.0, child: Image.asset(kLogo)),

                    Container(
                      height: 100.0,
                      width: 200,
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
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                    text: S.of(context).enterSendedCode,
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
              child: PinFieldAutoFill(
                controller: _pinCodeController,
                currentCode: _pinCodeController.text,
                decoration: UnderlineDecoration(
                  textStyle: const TextStyle(fontSize: 20, color: Colors.black),
                  colorBuilder:
                      FixedColorBuilder(Colors.black.withOpacity(0.3)),
                ),
                codeLength: 4,
                onCodeSubmitted: (value) {
                  print("value$value");
                  if (value != null && value.length == 4) {
                    //_loginSMS(value, context);
                    _smsCode = value;
                  }
                },
                onCodeChanged: (value) {
                  if (value != null && value.length == 4) {
                    //_loginSMS(value, context);
                    _smsCode = value;
                    if (_smsCode.isNotEmpty) {
                      _loginSMS(_smsCode, context);
                    }
                  }
                },
              ),
            ),

            // PinCodeTextField(
            //   appContext: context,
            //   controller: _pinCodeController,
            //   keyboardType: TextInputType.number,
            //   pinTheme: PinTheme(
            //     shape: PinCodeFieldShape.box,
            //     borderRadius: BorderRadius.circular(9),
            //     fieldHeight: 50,
            //     fieldWidth: 40,
            //     activeFillColor: Theme.of(context).backgroundColor,
            //   ),
            //   length: 4,
            //   autoFocus: true,
            //   animationType: AnimationType.fade,
            //   animationDuration: const Duration(milliseconds: 300),
            //   onChanged: (value) {
            //     if (value != null && value.length == 4) {
            //       //_loginSMS(value, context);
            //       _smsCode = value;
            //     }
            //   },
            // )
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 30.0),
            //   // error showing widget
            //   child: Text(
            //     hasError ? S.of(context).pleasefillUpAllCellsProperly : "",
            //     style: TextStyle(color: Colors.red.shade300, fontSize: 15),
            //   ),
            // ),
            const SizedBox(height: 4),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: S.of(context).didntReceiveCode,
                  style: const TextStyle(color: Colors.black54, fontSize: 15),
                  children: [
                    TextSpan(
                        text: !isSending ? S.of(context).resend : "Sending...",
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
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 48.0),
            //   child: CustomTextField(
            //     // focusNode: loyaltyNode,
            //     // nextNode: passwordNode,
            //     showCancelIcon: false,
            //     onChanged: (value) => _password = value,
            //     decoration: InputDecoration(
            //       labelText: S.of(context).password,
            //     ),
            //     keyboardType: TextInputType.text,
            //     obscureText: true,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              // error showing widget
              child: Text(
                hasError ? S.of(context).pleasefillUpAllCellsProperly : "",
                style: TextStyle(color: Colors.red.shade300, fontSize: 15),
              ),
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
              child: StaggerAnimation(
                titleButton: S.of(context).signUp,
                buttonController: _loginButtonController.view as AnimationController,
                onTap: () {
                  if (!isLoading) {
                    hasError = false;
                    if (_smsCode.isEmpty) {
                      hasError = true;
                      setState(() {});
                      return;
                    }
                    print("suv");
                    _loginSMS(_smsCode, context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _listOPT() async {
    await SmsAutoFill().listenForCode;
  }
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
