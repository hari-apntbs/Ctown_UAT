import 'dart:io'
    show HttpClient, HttpOverrides, SecurityContext, X509Certificate;


import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as inapp;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'common/constants.dart' as constant;
import 'firebase_options.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  NotificationService.initialize();
  constant.printLog('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  GestureBinding.instance.resamplingEnabled = true;

  Provider.debugCheckInvalidValueType = null;
  constant.printLog('[main] ============== main.dart START ==============');
  if (!kIsWeb) {
    try {
      /// enable network traffic logging
      // HttpClient.enableTimelineLogging = true;
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark
            .copyWith(statusBarColor: const Color(0xffda0c15)),
      );
      /// grant notification permission in android 13 and above
      PermissionStatus status = await Permission.notification.status;
      if (!status.isGranted) {
        status = await Permission.notification.request();
        constant.printLog(status.name);
      }
    }
    catch(e) {
      constant.printLog(e.toString());
    }
  }
  if (!constant.isWindow) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    constant.printLog('[main] Initialize Firebase successfully');
  }
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await inapp.InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  runApp(App());
}
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}