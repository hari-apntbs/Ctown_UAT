import 'package:ctown/screens/users/forgot_password.dart';
import 'package:ctown/screens/users/validate_otp.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

class ResetPasswordWithPhoneNumber extends StatefulWidget {
  @override
  _ResetPasswordWithPhoneNumberState createState() =>
      _ResetPasswordWithPhoneNumberState();
}

class _ResetPasswordWithPhoneNumberState
    extends State<ResetPasswordWithPhoneNumber> {
  final TextEditingController forgotPasswordController =
      TextEditingController();

  bool isSubmitting = false;
  //String phoneNumber;
  //String verId;

  void onSubmitPassword(BuildContext context) async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    String phoneNumber = forgotPasswordController.text;
    if (phoneNumber.isEmpty) {
      final snackBar = SnackBar(
        content: Text(S.of(context).phoneIsRequired),
        duration: const Duration(seconds: 3),
      );
      // ignore: deprecated_member_use
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      return;
    }
    setState(() {
      isSubmitting = true;
    });

    try {
      //await Services().widget.resetPassword(context, userName);
      // TODO await the api call for phone number submission
      final verId = "1";
      _validateOTP(context, phoneNumber, verId);
      setState(() {
        isSubmitting = false;
      });
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });
      final snackBar = SnackBar(
        content: Text(e.toString()),
        duration: const Duration(seconds: 3),
      );
      // ignore: deprecated_member_use
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void dispose() {
    forgotPasswordController.dispose();
    super.dispose();
  }

  _validateOTP(context, String phoneNumber, String verId) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ValidateOTP(
          verId: verId,
          phoneNumber: phoneNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Builder(
        builder: (context) => SafeArea(
          child: Container(
            alignment: Alignment.center,
            width:
                screenSize.width / (2 / (screenSize.height / screenSize.width)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    S.of(context).resetYourPassword,
                    style: TextStyle(
                        fontSize: 30.0, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(
                    height: 40.0,
                  ),
                  const Icon(
                    Icons.vpn_key,
                    color: Colors.orangeAccent,
                    size: 70.0,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  TextField(
                    controller: forgotPasswordController,
                    decoration: InputDecoration(
                      hintText: S.of(context).phoneNumber,
                    ),
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  InkWell(
                    onTap: () =>
                        isSubmitting ? null : onSubmitPassword(context),
                    child: Container(
                      height: 50.0,
                      width: 200.0,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(25.0)),
                      ),
                      child: Center(
                        child: Text(
                          isSubmitting
                              ? S.of(context).loading
                              : S.of(context).getOTP,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Use Email instead',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                              builder: (context) => ForgotPassword(),
                            )),
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                  const SizedBox(
                    height: 50.0,
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
