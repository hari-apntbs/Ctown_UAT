import UIKit
import GoogleMaps
import Firebase
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    var shortcutItem: UIApplicationShortcutItem?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 10.0, *) {
          UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        // TODO: SETUP4 - update your own Google API Key
        GMSServices.provideAPIKey("AIzaSyD3aB7FcaMNt6sx_-P6DqK32vYgO6QA4n4")
        GeneratedPluginRegistrant.register(with: self)

        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            self.shortcutItem = shortcutItem
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)

        if let shortcutItem = self.shortcutItem {
            handleQuickAction(shortcutItem)
            self.shortcutItem = nil
        }
    }

    @available(iOS 9.0, *)
    override func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        handleQuickAction(shortcutItem)
        completionHandler(true)
    }

    private func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) {
        if let controller = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(
                name: "plugins.flutter.io/quick_actions",
                binaryMessenger: controller.binaryMessenger
            )
            channel.invokeMethod("launch", arguments: shortcutItem.type)
        }
    }
}
