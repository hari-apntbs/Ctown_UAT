// import 'package:onesignal_flutter/onesignal_flutter.dart';

// import '../../common/config.dart';
// import '../../common/constants.dart';
// import '../../common/constants/general.dart';
// import '../../models/index.dart' show storeNotification;

// class OneSignalWapper {
//   init() {
//     if (kOneSignalKey['appID'] != '' && kOneSignalKey['enable'] == true) {
//       Future.delayed(Duration.zero, () async {
//         bool allowed =
//             await OneSignal.shared.promptUserForPushNotificationPermission();
//         if (isIos && allowed != null || !isIos) {
//           OneSignal.shared.setNotificationOpenedHandler(
//               (OSNotificationOpenedResult result) {
//             printLog(result.notification
//                 .jsonRepresentation()
//                 .replaceAll("\\n", "\n"));
//           });
//           await OneSignal.shared.init(
//             kOneSignalKey['appID'],
//             iOSSettings: {
//               OSiOSSettings.autoPrompt: false,
//               OSiOSSettings.inAppLaunchUrl: true
//             },
//           );
//           await OneSignal.shared
//               .setInFocusDisplayType(OSNotificationDisplayType.notification);

//           OneSignal.shared
//               .setNotificationReceivedHandler((OSNotification osNotification) {
//             // print(osNotification.payload.body.toString());
//             // print(osNotification.payload.notificationId);
//             storeNotification a =
//                 storeNotification.fromOneSignal(osNotification);
//             a.saveToLocal(
//               osNotification.payload.notificationId != null
//                   ? osNotification.payload.notificationId
//                   : DateTime.now().toString(),
//             );
//           });
//         }
//       });
//     }
//   }
// }
