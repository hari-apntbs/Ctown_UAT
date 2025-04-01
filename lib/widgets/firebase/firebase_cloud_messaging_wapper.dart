
import 'package:ctown/notification_service.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/constants.dart';

abstract class FirebaseCloudMessagagingAbs {
  init();
  FirebaseCloudMessagingDelegate? delegate;
}

abstract class FirebaseCloudMessagingDelegate {
  onMessage(Map<String, dynamic> message);
  onResume(Map<String, dynamic> message);
  onLaunch(Map<String, dynamic> message);
}

class FirebaseCloudMessagagingWapper extends FirebaseCloudMessagagingAbs {
  late FirebaseMessaging _firebaseMessaging;

  bool isLoggedIn = false;

  @override
  init() async {
    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.getToken().then((token) async {
      FirebaseMessaging.instance.subscribeToTopic('ctown_notify');
      printLog('[FCM]--> token: [ $token ]');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String id = await FirebaseInstallations.instance.getId();
      printLog("FID=======> $id");
      prefs.setString("fcmToken", token??"");
      prefs.setString("inAppToken", id??"");
    });
    firebaseCloudMessagingListeners();
  }

  void firebaseCloudMessagingListeners() {
    if (isIos) {
      iOSPermission();
    }
    printLog("inside firebase cloud messageing listeners");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      printLog(notification?.body);
      NotificationService.showNotification(message);
    });
  }

  Future<bool> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggedIn') ?? false;
  }

  void iOSPermission() {
    if (isIos) {
      _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }
  }
}
