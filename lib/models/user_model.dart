//import 'package:A&H Market/screens/users/login.dart';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart' as apple;
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:localstorage/localstorage.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../generated/l10n.dart';
import '../services/index.dart';
import 'entities/user.dart';

abstract class UserModelDelegate {
  onLoaded(User? user);
  onLoggedIn(User user);
  onLogout(User? user);
}

class UserModel with ChangeNotifier {
  UserModel() {
    getUser();
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final Services _service = Services();
  User? user;
  bool loggedIn = false;
  bool loading = false;
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();
  UserModelDelegate? delegate;

  void updateUser(Map<String, dynamic> json) {
    user!.name = json['display_name'] ?? json['displayname'];
    user!.email = json['user_email'] ?? json['email'];
    user!.userUrl = json['user_url'] ?? json['url'];
    user!.nicename = json['user_nicename'] ?? json['nicename'];
    // user.telephone = json['user_telephone'] ?? json['telephone'];
    notifyListeners();
  }

  Future<String?> submitForgotPassword(
      {String? forgotPwLink, Map<String, dynamic>? data}) async {
    return await _service.submitForgotPassword(
        forgotPwLink: forgotPwLink, data: data);
  }

  /// Login by apple, This function only test on iPhone
  Future<void> loginApple({Function? success, Function? fail, context}) async {
    try {
      final AuthorizationResult result = await TheAppleSignIn.performRequests([
        const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      switch (result.status) {
        case apple.AuthorizationStatus.authorized:
          {
            final userId = result.credential!.user!.replaceAll(".", "");
            if (kAdvanceConfig["EnableFirebase"] as bool) {
              if (result.credential!.email != null) {
                final fullName = result.credential!.fullName!.givenName! +
                    " " +
                    result.credential!.fullName!.familyName!;
                await _database.child(userId).set(
                    {"email": result.credential!.email, "fullName": fullName});
                user = await _service.loginApple(
                    email: result.credential!.email, fullName: fullName);

                final AuthCredential credential =
                    OAuthProvider('apple.com').credential(
                  accessToken:
                      String.fromCharCodes(result.credential!.authorizationCode!),
                  idToken:
                      String.fromCharCodes(result.credential!.identityToken!),
                );
                await _auth.signInWithCredential(credential);
              } else {
                DataSnapshot snapshot = await _database.child(userId).once().then((value) {
                  return value.snapshot;
                });
                Map? item = snapshot.value as Map<dynamic, dynamic>?;
                if (item != null && item["email"] != null) {
                  user = await _service.loginApple(
                      email: item["email"], fullName: item["fullName"]);
                } else {
                  return fail!(
                      "Please enable realtime database in firebase. Then open up the Setting app in your iPhone and tap on your name at the top. Then press Password & Security, then Apps using Apple ID They listed all the apps there and you can delete your app to revoke access and try to run app again.");
                }
              }
            } else {
              if (result.credential!.email != null) {
                final fullName = result.credential!.fullName!.givenName! +
                    " " +
                    result.credential!.fullName!.familyName!;
                user = await _service.loginApple(
                    email: result.credential!.email, fullName: fullName);
              } else {
                Map<String, dynamic> decodedToken = JwtDecoder.decode(
                    String.fromCharCodes(result.credential!.identityToken!));
                if (decodedToken != null &&
                    decodedToken["payload"] != null &&
                    decodedToken["payload"]["email"] != null) {
                  user = await _service.loginApple(
                      email: decodedToken["payload"]["email"],
                      fullName: decodedToken["payload"]["email"]
                          .toString()
                          .split("@")[0]);
                } else {
                  return fail!(
                      "Please enable realtime database in firebase. Then open up the Setting app in your iPhone and tap on your name at the top. Then press Password & Security, then Apps using Apple ID They listed all the apps there and you can delete your app to revoke access and try to run app again.");
                }
              }
            }

            loggedIn = true;
            await saveUser(user);
            success!(user);

            notifyListeners();
          }
          break;

        case apple.AuthorizationStatus.error:
          fail!(S.of(context).error(result.error!));
          break;
        case apple.AuthorizationStatus.cancelled:
          fail!(S.of(context).loginCanceled);
          break;
      }
    } catch (err) {
      fail!(S.of(context).loginErrorServiceProvider(err.toString()));
    }
  }

  /// Login by Firebase phone
  Future<void> loginFirebaseSMS(
      {String? phoneNumber, required Function success, Function? fail, context}) async {
    try {
      user = await _service.loginSMS(token: phoneNumber);
      loggedIn = true;
      await saveUser(user);
      success(user);

      notifyListeners();
    } catch (err) {
      fail!(S.of(context).loginErrorServiceProvider(err.toString()));
    }
  }

  /// Login by Facebook
  // Future<void> loginFB({Function success, Function fail, context}) async {
  //   try {
  //     final FacebookLoginResult result =
  //         await FacebookLogin().logIn(['email', 'public_profile']);
  //
  //     switch (result.status) {
  //       case FacebookLoginStatus.loggedIn:
  //         final FacebookAccessToken accessToken = result.accessToken;
  //         if (kAdvanceConfig["EnableFirebase"]) {
  //           AuthCredential credential =
  //               FacebookAuthProvider.credential(accessToken.token);
  //           await _auth.signInWithCredential(credential);
  //         }
  //
  //         user = await _service.loginFacebook(token: accessToken.token);
  //
  //         loggedIn = true;
  //
  //         await saveUser(user);
  //
  //         success(user);
  //         break;
  //       case FacebookLoginStatus.cancelledByUser:
  //         fail(S.of(context).loginCanceled);
  //         break;
  //       case FacebookLoginStatus.error:
  //         fail(S.of(context).error(result.errorMessage));
  //         break;
  //     }
  //
  //     notifyListeners();
  //   } catch (err) {
  //     fail(S.of(context).loginErrorServiceProvider(err.toString()));
  //   }
  // }

  Future<void> loginGoogle(String lang, {Function? success, Function? fail, context}) async {
    try {
      GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
      GoogleSignInAccount? res = await _googleSignIn.signIn();

      if (res == null) {
        fail!(S.of(context).loginCanceled);
      } else {
        GoogleSignInAuthentication auth = await res.authentication;
        if (kAdvanceConfig["EnableFirebase"] as bool) {
          AuthCredential credential =
              GoogleAuthProvider.credential(accessToken: auth.accessToken);
          await _auth.signInWithCredential(credential);
        }
        user = await _service.loginGoogle(token: auth.accessToken);
        loggedIn = true;
        await saveUser(user);
        success!(user);
        notifyListeners();
      }
    } catch (err, trace) {
      printLog(trace);
      printLog(err);
      fail!(S.of(context).loginErrorServiceProvider(err.toString()));
    }
  }

  Future saveUserToFirestore() async {
    try {
      final token = await _firebaseMessaging.getToken();
      printLog('token: $token');
      await FirebaseFirestore.instance.collection('users').doc(user!.email).set(
          {'deviceToken': token, "isOnline": true}, SetOptions(merge: true));
    } catch (e) {
      printLog(e);
    }
  }

  Future<void> saveUser(User? user) async {
    final LocalStorage storage = LocalStorage("store");
    try {
      // ignore: unawaited_futures
      if (kAdvanceConfig["EnableFirebase"] as bool) {
        await saveUserToFirestore();
      }

      // save to Preference
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loggedIn', true);

      // save the user Info as local storage
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey["userInfo"]!, user);
        delegate?.onLoaded(user);
      }
    } catch (err) {
      printLog(err);
    }
  }

  Future<void> getUser() async {
    final LocalStorage storage = LocalStorage("store");
    try {
      final ready = await storage.ready;

      if (ready) {
        final json = await storage.getItem(kLocalKey["userInfo"]!);
        if (json != null) {
          user = User.fromLocalJson(json);
          loggedIn = true;
          if(user?.cookie != null) {
            final userInfo = await _service.getUserInfo(user?.cookie);
            if (userInfo != null) {
              userInfo.isSocial = user?.isSocial;
              user = userInfo;
            } else {
              await logout();
            }
          }
          delegate?.onLoaded(user);
          notifyListeners();
        }
      }
    } catch (err) {
      printLog(err);
    }
  }

  void setLoading(bool isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  Future<void> createUser({
    required String username,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? countryCode,
    String? otp,
    String? loyalty_card_number,
    bool? isVendor,
    required Function success,
    Function? fail,
  }) async {
    try {
      loading = true;
      notifyListeners();
      printLog("--------------");
      printLog(username + " v   " + password);
      printLog("--------------");
      if (kAdvanceConfig["EnableFirebase"] as bool) {
        await _auth.createUserWithEmailAndPassword(
            email: username, password: password);
      }
      // print("user user");
      // print(firstName +
      //     lastName +
      //     countryCode +
      //     username +
      //     password +
      //     countryCode +
      //     phoneNumber +
      //     otp +
      //     loyalty_card_number);
      user = await _service.createUser(
        firstName: firstName,
        lastName: lastName,
        countryCode: countryCode,
        username: username,
        password: password,
        phoneNumber: phoneNumber,
        otp: otp,
        loyalty_card_number: loyalty_card_number,
        isVendor: isVendor ?? false,
      );
      printLog("us $user");

      loggedIn = true;
      await saveUser(user);
      success(user);

      loading = false;
      notifyListeners();
    } catch (err) {
      printLog("errminer $err");
      fail!(err.toString());
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (kAdvanceConfig["EnableFirebase"] as bool) {
      await FirebaseAuth.instance.signOut();
    }

    // await FacebookLogin().logOut();
    delegate?.onLogout(user);
    user = null;
    loggedIn = false;
    //final LocalStorage storage = LocalStorage("ahmarket");
    final LocalStorage storage = LocalStorage("store");
    try {
      final ready = await storage.ready;
      if (ready) {
        storage.deleteItem(kLocalKey["userInfo"]!);
        storage.deleteItem(kLocalKey["shippingAddress"]!);
        storage.deleteItem(kLocalKey["recentSearches"]!);
        storage.deleteItem(kLocalKey["opencart_cookie"]!);
        storage.setItem(kLocalKey["userInfo"]!, null);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('loggedIn', false);
        // await storage.deleteItem(kLocalKey["userInfo"]);
        // await storage.deleteItem(kLocalKey["shippingAddress"]);
        // await storage.deleteItem(kLocalKey["recentSearches"]);
        // await storage.deleteItem(kLocalKey["opencart_cookie"]);
        // await storage.setItem(kLocalKey["userInfo"], null);
      }
      await _service.logout();
    } catch (err) {
      printLog(err);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loggedIn', false);
    }
    notifyListeners();
    // LoginScreen();
  }

  Future<void> login(
      {username, password, lang,required Function success, Function? fail}) async {
    try {
      loading = true;
      notifyListeners();
      user = await _service.login(
        username: username,
        password: password,
        lang: lang
      );

      loggedIn = true;
      await saveUser(user);
      success(user);
      loading = false;
      notifyListeners();
    } catch (err) {
      loading = false;
      fail!(err.toString());
      notifyListeners();
    }
  }

  Future<bool> isLogin() async {
    final LocalStorage storage = LocalStorage("store");
    try {
      final ready = await storage.ready;
      if (ready) {
        final json = await storage.getItem(kLocalKey["userInfo"]!);
        return json != null;
      }
      return false;
    } catch (err) {
      return false;
    }
  }
}
