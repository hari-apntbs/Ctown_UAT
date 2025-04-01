import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../services/index.dart';
import 'forgot_password_with_phone_number.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController forgotPasswordController =
      TextEditingController();

  bool isSubmitting = false;

  void onSubmitPassword(BuildContext context) async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    String userName = forgotPasswordController.text;
    if (userName.isEmpty) {
      final snackBar = SnackBar(
        content: Text(S.of(context).emptyUsername),
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
      await Services().widget?.forgotPasswordEmail(context, userName);
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          S.of(context).resetPassword,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        leading: GestureDetector(
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onTap: () => Navigator.pop(context),
        ),
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
                        fontSize: 20.0, color: Theme.of(context).primaryColor),
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
                      hintText: S.of(context).yourUsernameEmail,
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
                              : S.of(context).getPasswordLink,
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
                      text: S.of(context).usephonenumberinstead,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) =>
                                    ForgotPasswordWithPhoneNumber())),
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
