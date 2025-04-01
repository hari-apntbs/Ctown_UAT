// ignore: prefer_relative_imports
import 'package:ctown/frameworks/magento/services/magento.dart';
import 'package:ctown/models/app_model.dart';
import 'package:ctown/screens/users/forgot_password.dart';
// ignore: prefer_relative_imports
import 'package:ctown/screens/users/validate_otp.dart';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../../services/index.dart';

class ForgotPasswordWithPhoneNumber extends StatefulWidget {
  @override
  _ForgotPasswordWithPhoneNumberState createState() =>
      _ForgotPasswordWithPhoneNumberState();
}

class _ForgotPasswordWithPhoneNumberState
    extends State<ForgotPasswordWithPhoneNumber> {
  final TextEditingController forgotPasswordController =
      TextEditingController();
  String? selectedCountryCode = "962";
  List<String?> countryCodes = [];
  getCountryCodes() async {
    var data;
    var response = await http.get(Uri.parse('https://up.ctown.jo/api/countrycode.php'));
    data = json.decode(response.body)['data'];
    print(data.runtimeType);
    data.forEach((element) {
      countryCodes.add(element['country_code']);
    });

    setState(() {});
    // return data;
  }

  bool isSubmitting = false;
  //String phoneNumber;
  //String verId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCountryCodes();
  }

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
      print("forgot password phone number");
     var store1= MagentoApi().getSavedStore();
    var lang= Provider.of<AppModel>(context, listen: false).langCode;
   
    

      final verId = await Services()
          .widget?.forgotPasswordMobile(context, phoneNumber,selectedCountryCode,lang);
      print("id from response $verId");
      _validateOTP(context, phoneNumber, verId!);
      print("done");
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
                  // TextField(
                  //   controller: forgotPasswordController,
                  //   decoration: InputDecoration(
                  //     hintText: S.of(context).phoneNumber,
                  //   ),
                  // ),
                  Row(children: [
                    Container(
                      width: 70.0,
                      height: 76.5,
                      padding: EdgeInsets.only(top: 18,bottom: 12),
                      child: DropdownButton(
                        // isExpanded: true,
                        value: selectedCountryCode,
                        items: countryCodes
                            // ['844', '34443', '974']
                            .map<DropdownMenuItem<String>>((String? value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value!,
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          selectedCountryCode = value;

                          setState(() {
                            selectedCountryCode = value;
                          });
                          print(selectedCountryCode);
                        },
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                        child: Container(
                      height: 60,
                      width: 200,
                      child: TextField(
                        controller: forgotPasswordController,
                        decoration: InputDecoration(
                          hintText: S.of(context).phoneNumber,
                          
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      // CustomTextField(
                      //   focusNode: phoneNumberNode,
                      //   nextNode: loyaltyNode,
                      //   showCancelIcon: false,
                      //   onChanged: (value) => phoneNumber = value,
                      //   decoration: InputDecoration(
                      //     labelText: S.of(context).phoneNumber,

                      //   ),
                      //   keyboardType: TextInputType.phone,
                      // ),
                    ))
                  ]),
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
                      text: S.of(context).useemailinstead,
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
