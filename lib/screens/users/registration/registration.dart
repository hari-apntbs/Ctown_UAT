import 'dart:convert';

import 'package:ctown/models/cart/cart_base.dart';
import 'package:ctown/models/entities/user.dart';
import 'package:ctown/models/point_model.dart';
import 'package:ctown/screens/settings/check_deliverable.dart';
import 'package:ctown/screens/users/registration/verify_otp.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/index.dart' show AppModel, UserModel;
import '../../../widgets/custom_text_field.dart';
// ignore: unused_import
import '../login_sms/verify.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String? selectedCountryCode = '962';
  List<String?> countryCodes = [];
  // final _auth = firebase_auth.FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = TextEditingController();
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

  String? firstName,
      lastName,
      emailAddress,
      phoneNumber,
      password,
      loyalty_card_number,
      otp;
  bool? isVendor = false;
  bool isChecked = false;
  bool _isLoading = false;

  final bool showPhoneNumberWhenRegister =
      kLoginSetting['showPhoneNumberWhenRegister'] ?? true;
  final bool requirePhoneNumberWhenRegister =
      kLoginSetting['requirePhoneNumberWhenRegister'] ?? true;

  final firstNameNode = FocusNode();
  final lastNameNode = FocusNode();
  final phoneNumberNode = FocusNode();
  final passwordNode = FocusNode();
  //final otpNode = FocusNode();
  final loyaltyNode = FocusNode();
  final emailNode = FocusNode();
  //final passwordNode = FocusNode();

  // void _welcomeDiaLog(User user) {
  //   Provider.of<CartModel>(context, listen: false).setUser(user);
  //   Provider.of<PointModel>(context, listen: false).getMyPoint(user.cookie);
  //   var email = user.email;
  //   _snackBar(S.of(context).welcome + ' $email!');
  //   // if (kIsWeb) {
  //   //   Navigator.of(context).pushReplacementNamed('/home-screen');
  //   // } else {
  //   //   Navigator.of(context).pushReplacementNamed(RouteList.dashboard);
  //   // }
  //   Navigator.of(context, rootNavigator: true).pushReplacementNamed(RouteList.dashboard);
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCountryCodes();
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

  @override
  void dispose() {
    _emailController.dispose();
    firstNameNode.dispose();
    lastNameNode.dispose();
    emailNode.dispose();
    //passwordNode.dispose();
    phoneNumberNode.dispose();
    //otpNode.dispose();
    loyaltyNode.dispose();
    super.dispose();
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

  void _snackBar(String? text) {
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

  Future<void> _submitRegister({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? emailAddress,
    String? password,
    String? countryCode,
    String? loyalty_card_number,
    String? signature_code,
    bool? isVendor,
  }) async {
    setState(() {
      _isLoading = true;
    });
    if (firstName == null ||
        lastName == null ||
        emailAddress == null ||
        password == null ||
        phoneNumber == null ||
        (showPhoneNumberWhenRegister &&
            requirePhoneNumberWhenRegister &&
            phoneNumber == null)) {
      _snackBar(S.of(context).pleaseInputFillAllFields);
    } else if (isChecked == false) {
      _snackBar(S.of(context).pleaseAgreeTerms);
    } else {
      var uri = Uri.parse("https://up.ctown.jo/api/sms.php");
      print("body for sms.php");
      print({
        'country_code': selectedCountryCode,
        'phone_number': phoneNumber,
        'signature_code': signature_code,
      });
      var response = await http.post(uri, body: {
        'country_code': selectedCountryCode,
        'phone_number': phoneNumber,
        'signature_code': signature_code
      });
      print("Response body ${response.body}");
      var res = jsonDecode(response.body);
      if (response.statusCode != 200) {
        _snackBar("Could not request OTP at this time");
      }
      if (res["success"] == 1) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VerifyOtp(
              firstName: firstName,
              lastName: lastName,
              countryCode: countryCode,
              password: password,
              phoneNumber: phoneNumber,
              emailAddress: emailAddress,
              loyalty_card_number: loyalty_card_number,
              isVendor: isVendor,
            ),
          ),
        );
      } else {
        print("hdkghghdgd");
        _snackBar(res["message"]);
      }
      //

      try {
        print(jsonEncode({
          "customer": {
            "email": emailAddress,
            "firstname": firstName,
            "lastname": lastName,
            "store_id": 57,
            // "store_id": store['store_en']['id'],
            "extension_attributes": {"is_subscribed": false},
            "custom_attributes": [
              {"attribute_code": "phone_number", "value": phoneNumber},
              {
                "attribute_code": "loyalty_card_number",
                "value": loyalty_card_number
              }
            ]
          },
          "password": password,
          "otp": otp,
          "phone_number": countryCode! + phoneNumber,
          "loyalty_card_number": loyalty_card_number,
        }));
        //await Services().widget.verifyOTP(context, widget.verId, _smsCode);
        if (res["success"] == 1) {
          await Provider.of<UserModel>(context, listen: false).createUser(
            username: emailAddress,
            password: password,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            countryCode: countryCode,
            // otp: "",
            loyalty_card_number: loyalty_card_number,
            success: _welcomeDiaLog,
            fail: _snackBar,
            isVendor: isVendor,
          );
        }
        // await _stopAnimation();
        // await Navigator.of(context).pushReplacement(MaterialPageRoute(
        //     //builder: (context) => ResetPasswordScreen(customerId: widget.verId),
        //     ));
      } catch (e) {
        // await _stopAnimation();
        _failMessage(e.toString() + "dfgdfgdfgdf", context);
      }
      // /
      // Provider.of<UserModel>(context, listen: false).createUser(
      //   username: emailAddress,
      //   password: password,
      //   firstName: firstName,
      //   lastName: lastName,
      //   phoneNumber: phoneNumber,
      //   otp: otp,
      //   loyalty_card_number: loyalty_card_number,
      //   success: _welcomeDiaLog,
      //   fail: _snackBar,
      //   isVendor: isVendor,
      // );
    }
    setState(() {
      _isLoading = false;
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          S.of(context).newRegister,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else if (kLoginSetting['IsRequiredLogin']!) {
              Navigator.of(context).pushNamed('/login');
            } else {
              Navigator.of(context).pushNamed(RouteList.dashboard);
            }
          },
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => Utils.hideKeyboard(context),
          child: ListenableProvider.value(
            value: Provider.of<UserModel>(context),
            child: Consumer<UserModel>(
              builder: (context, value, child) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(height: 10.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 55, right: 55),
                          child: Container(
                            child: Image.asset("assets/images/logo.png"),
                            // decoration: BoxDecoration(
                            //   // color: Colors.red,
                            //   image: DecorationImage(
                            //       image: AssetImage(
                            //         "assets/images/logo.png",

                            //       ),
                            //       // scale: 1,

                            //       fit: BoxFit.cover),
                            // ),
                            // child: Image.asset(kLogo,
                            //     width: 300,
                            //     fit: BoxFit.fitHeight)
                          ),
                        ),
                        // const SizedBox(
                        //   height: 30.0,
                        // ),
                        CustomTextField(
                          onChanged: (value) => firstName = value,
                          textCapitalization: TextCapitalization.words,
                          nextNode: lastNameNode,
                          showCancelIcon: false,
                          decoration: InputDecoration(
                            labelText: S.of(context).firstName,
                          ),
                        ),
                        // const SizedBox(height: 20.0),
                        CustomTextField(
                          focusNode: lastNameNode,
                          // nextNode: emailNode,
                          nextNode: showPhoneNumberWhenRegister
                              ? emailNode
                              : emailNode,
                          showCancelIcon: false,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (value) => lastName = value,
                          decoration: InputDecoration(
                            labelText: S.of(context).lastName,
                          ),
                        ),
                        // const SizedBox(height: 20.0),
                        CustomTextField(
                          focusNode: emailNode,
                          nextNode: phoneNumberNode,
                          controller: _emailController,
                          onChanged: (value) => emailAddress = value,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              labelText: S.of(context).enterYourEmail),
                        ),

                        if (showPhoneNumberWhenRegister)
                          // const SizedBox(height: 20.0),

                          if (showPhoneNumberWhenRegister)
                            Row(children: [
                              //
                              //
                              // Container(
                              //   width: 150,
                              //   child: DropdownButton<String>(
                              //     focusColor: Colors.white,
                              //     value: selectedCountryCode,s
                              //     //elevation: 5,
                              //     style: TextStyle(color: Colors.white),
                              //     iconEnabledColor: Colors.black,
                              //     items: countryCodes.map<DropdownMenuItem<String>>(
                              //         (String value) {
                              //       return DropdownMenuItem<String>(
                              //         value: value,
                              //         child: Text(
                              //           value,
                              //           style: TextStyle(color: Colors.black),
                              //         ),
                              //       );
                              //     }).toList(),
                              //     hint: Text(
                              //       "Please choose a langauage",
                              //       style: TextStyle(
                              //           color: Colors.black,
                              //           fontSize: 14,
                              //           fontWeight: FontWeight.w500),
                              //     ),
                              //     onChanged: (String value) {
                              //       setState(() {
                              //         selectedCountryCode = value;
                              //       });
                              //     },
                              //   ),
                              // ),

////
                              Container(
                                width: 70.0,
                                height: 76.5,
                                padding: EdgeInsets.only(top: 20),
                                child: DropdownButton(
                                  // isExpanded: true,
                                  value: selectedCountryCode,
                                  items: countryCodes
                                      // ['844', '34443', '974']
                                      .map<DropdownMenuItem<String>>(
                                          (String? value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value!,
                                        style: TextStyle(
                                            color:
                                                //  Colors.black
                                                Theme.of(context).colorScheme.secondary),
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
                              // FutureBuilder(
                              //     future: getCountryCodes(),
                              //     builder: (context, snapshot) {
                              //       if (snapshot.hasData) {
                              //         List<String> countryCodes = [];
                              //         snapshot.data.forEach((element) {
                              //           countryCodes
                              //               .add(element['country_code']);
                              //         });

                              //         selectedCountryCode = countryCodes[0];
                              //         print(selectedCountryCode);
                              //         print(countryCodes);
                              //         // return Text(snapshot.data.toString());
                              //         return Container(
                              //           width: 70.0,
                              //           height: 76.5,
                              //           padding: EdgeInsets.only(top: 20),
                              //           child: DropdownButton(
                              //             isExpanded: true,
                              //             value: selectedCountryCode,
                              //             items: countryCodes
                              //                 .map<DropdownMenuItem<String>>(
                              //                     (String value) {
                              //               return DropdownMenuItem<String>(
                              //                 value: value,
                              //                 child: Text(
                              //                   value,
                              //                   style: TextStyle(
                              //                       color: Colors.black),
                              //                 ),
                              //               );
                              //             }).toList(),
                              //             onChanged: (String value) {
                              //               print(value);
                              //               selectedCountryCode = value;
                              //               // print(selectedCountryCode);
                              //               // print(value);
                              //               setState(() {
                              //                 selectedCountryCode = value;
                              //               });
                              //               print(selectedCountryCode);
                              //             },
                              //             style:
                              //                 Theme.of(context).textTheme.title,
                              //           ),
                              //         );
                              //       }
                              //       return Center(
                              //           child: CircularProgressIndicator());
                              //     }),
                              Expanded(
                                  child: Container(
                                height: 60,
                                width: 200,
                                child: CustomTextField(
                                  focusNode: phoneNumberNode,
                                  nextNode: passwordNode,
                                  showCancelIcon: false,
                                  onChanged: (value) => phoneNumber = value,
                                  decoration: InputDecoration(
                                    labelText: S.of(context).phoneNumber,
                                    // suffixIcon: FlatButton(
                                    //   shape: RoundedRectangleBorder(
                                    //       borderRadius: BorderRadius.circular(25.0), side: BorderSide(color: Colors.blue)),
                                    //   color: Colors.blue,
                                    //   height: 50,
                                    //   textColor: Colors.white,
                                    //   onPressed: () async {
                                    //     var uri = Uri.parse("https://online.ajmanmarkets.ae/api/sms.php");
                                    //     var response = await http.post(uri, body: {
                                    //       'phone_number': phoneNumber,
                                    //     });
                                    //     if (response.statusCode == 200) {
                                    //       print("image upload");
                                    //     } else {
                                    //       print("image failed");
                                    //     }
                                    //     _snackBar("Otp sent to your phone number");
                                    //   },
                                    //   child: Text(
                                    //     S.of(context).getotp,
                                    //     textAlign: TextAlign.center,
                                    //     style: TextStyle(
                                    //       color: Colors.white,
                                    //       fontFamily: "Poppins",
                                    //       fontWeight: FontWeight.w400,
                                    //       fontSize: 14,
                                    //     ),
                                    //   ),
                                    // ),
                                  ),
                                  keyboardType: TextInputType.phone,
                                ),
                              ))
                            ]),

                        CustomTextField(
                          focusNode: passwordNode,
                          nextNode: loyaltyNode,
                          // nextNode: showPhoneNumberWhenRegister
                          //     ? emailNode
                          //     : emailNode,
                          showCancelIcon: false,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (value) {
                            password = value;
                            print(password);
                          },
                          decoration: InputDecoration(
                            labelText: S.of(context).password,
                          ),
                        ),

                        /*
                        if (showPhoneNumberWhenRegister)
                          // const SizedBox(height: 20.0),
                          if (showPhoneNumberWhenRegister)
                            CustomTextField(
                              focusNode: phoneNumberNode,
                              nextNode: loyaltyNode,
                              showCancelIcon: false,
                              onChanged: (value) => phoneNumber = value,
                              decoration: InputDecoration(
                                labelText: S.of(context).phoneNumber,
                                // suffixIcon: FlatButton(
                                //   shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(25.0), side: BorderSide(color: Colors.blue)),
                                //   color: Colors.blue,
                                //   height: 50,
                                //   textColor: Colors.white,
                                //   onPressed: () async {
                                //     var uri = Uri.parse("https://online.ajmanmarkets.ae/api/sms.php");
                                //     var response = await http.post(uri, body: {
                                //       'phone_number': phoneNumber,
                                //     });
                                //     if (response.statusCode == 200) {
                                //       print("image upload");
                                //     } else {
                                //       print("image failed");
                                //     }
                                //     _snackBar("Otp sent to your phone number");
                                //   },
                                //   child: Text(
                                //     S.of(context).getotp,
                                //     textAlign: TextAlign.center,
                                //     style: TextStyle(
                                //       color: Colors.white,
                                //       fontFamily: "Poppins",
                                //       fontWeight: FontWeight.w400,
                                //       fontSize: 14,
                                //     ),
                                //   ),
                                // ),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                        // const SizedBox(height: 20.0),
                        // CustomTextField(
                        //   focusNode: otpNode,
                        //   nextNode: loyaltyNode,
                        //   showCancelIcon: false,
                        //   onChanged: (value) => otp = value,
                        //   decoration: InputDecoration(
                        //     labelText: S.of(context).otp,
                        //   ),
                        //   keyboardType: TextInputType.phone,
                        // ),
                        // const SizedBox(height: 20.0),

                        */
                        // CustomTextField(
                        //   focusNode: loyaltyNode,
                        //   //nextNode: passwordNode,
                        //   showCancelIcon: false,
                        //   onChanged: (value) => loyalty_card_number = value,
                        //   decoration: InputDecoration(
                        //     labelText: S.of(context).loyaltyno,
                        //   ),
                        //   keyboardType: TextInputType.phone,
                        // ),
                        // const SizedBox(height: 20.0),
                        // CustomTextField(
                        //   focusNode: passwordNode,
                        //   showEyeIcon: true,
                        //   obscureText: true,
                        //   onChanged: (value) => password = value,
                        //   decoration: InputDecoration(
                        //     labelText: S.of(context).enterYourPassword,
                        //   ),
                        // ),
                        // const SizedBox(height: 20.0),
                        if (kVendorConfig['VendorRegister'] == true &&
                            Provider.of<AppModel>(context, listen: false)
                                    .vendorType ==
                                VendorType.multi)
                          Row(
                            children: <Widget>[
                              Checkbox(
                                value: isVendor,
                                activeColor: Theme.of(context).primaryColor,
                                checkColor: Colors.white,
                                onChanged: (value) {
                                  setState(() {
                                    isVendor = value;
                                  });
                                },
                              ),
                              InkWell(
                                onTap: () {
                                  isVendor = !isVendor!;
                                  setState(() {});
                                },
                                child: Text(
                                  S.of(context).registerAsVendor,
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ),
                            ],
                          ),
                        // Row(
                        //   children: <Widget>[
                        //     Checkbox(
                        //       value: isChecked,
                        //       activeColor: Theme.of(context).primaryColor,
                        //       checkColor: Colors.white,
                        //       onChanged: (value) {
                        //         isChecked = !isChecked;
                        //         setState(() {});
                        //       },
                        //     ),
                        //     InkWell(
                        //       onTap: () {
                        //         isChecked = !isChecked;
                        //         setState(() {});
                        //       },
                        //       child: Text(
                        //         S.of(context).iwantToCreateAccount,
                        //         style: const TextStyle(fontSize: 16.0),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: isChecked,
                              activeColor: Theme.of(context).primaryColor,
                              checkColor: Colors.white,
                              onChanged: (value) {
                                isChecked = !isChecked;
                                setState(() {});
                              },
                            ),
                            InkWell(
                              onTap: () {
                                isChecked = !isChecked;
                                setState(() {});
                              },
                              child: Text(
                                S.of(context).iAgree,
                                style: const TextStyle(fontSize: 16.0),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => Navigator.of(context).pushNamed(
                                  '/terms_condition',
                                  arguments: '26'),
                              child: Text(
                                S.of(context).agreeWithPrivacy,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 16.0,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Material(
                            color: Colors.yellow,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(25.0)),
                            elevation: 0,
                            child: MaterialButton(
                              onPressed: _isLoading == true
                                  ? null
                                  // : () => Navigator.of(context).push(
                                  //       MaterialPageRoute(
                                  //         builder: (context) => VerifyOtp(),
                                  //       ),
                                  //     ),
                                  : () async {
                                      if (firstName == null ||
                                          firstName!.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text("Enter firstName"),
                                        ));
                                        return;
                                      }
                                      if (lastName == null ||
                                          lastName!.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text("Enter lastName"),
                                        ));
                                        return;
                                      }

                                      if (emailAddress == null ||
                                          emailAddress!.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text("Enter email"),
                                        ));
                                        return;
                                      }

                                      bool emailValid = RegExp(
                                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(emailAddress!);
                                      if (!emailValid) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text("Enter valid email"),
                                        ));
                                        return;
                                      }

                                      if (phoneNumber == null ||
                                          phoneNumber!.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text("Enter Mobile number"),
                                        ));
                                        return;
                                      }

                                      if (phoneNumber!.length < 6) {
                                        print(phoneNumber!.length);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text("Enter valid number"),
                                        ));
                                        return;
                                      }
                                      if (password == null ||
                                          password!.isEmpty) {
                                        print(phoneNumber!.length);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text("Enter  password"),
                                        ));
                                        return;
                                      }
                                      if (password!.length <= 1) {
                                        print(phoneNumber!.length);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text("Enter valid password"),
                                        ));
                                        return;
                                      }

                                      final signature =
                                          await SmsAutoFill().getAppSignature;
                                      print(signature);
                                      print("otp_verify");
                                      await _submitRegister(
                                        signature_code: signature,
                                        firstName: firstName,
                                        lastName: lastName,
                                        phoneNumber: phoneNumber,
                                        emailAddress: emailAddress,
                                        countryCode: selectedCountryCode,
                                        password: password,
                                        //otp: otp,
                                        loyalty_card_number:
                                            loyalty_card_number,
                                        isVendor: isVendor,
                                      );
                                    },
                              minWidth: 200.0,
                              elevation: 0.0,
                              height: 50.0,
                              child: Text(
                                _isLoading == true
                                    ? S.of(context).loading
                                    : S.of(context).newRegister,
                                // S.of(context).getOTP,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              // Text(
                              //   S.of(context).or + ' ',
                              //   style: const TextStyle(color: Colors.black45),
                              // ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  S.of(context).loginToYourAccount,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    //  decoration: TextDecoration.underline,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).agreeWithPrivacy,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            S.of(context).privacyTerms,
            style: const TextStyle(fontSize: 16.0, height: 1.4),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}
