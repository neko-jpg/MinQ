import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let liveActivityChannel = FlutterMethodChannel(name: "miinq/live_activity", binaryMessenger: controller.binaryMessenger)
      liveActivityChannel.setMethodCallHandler { call, result in
        result(nil)
      }

      let wearableChannel = FlutterMethodChannel(name: "miinq/wearables", binaryMessenger: controller.binaryMessenger)
      wearableChannel.setMethodCallHandler { call, result in
        result(nil)
      }

      let fitnessChannel = FlutterMethodChannel(name: "miinq/fitness_bridge", binaryMessenger: controller.binaryMessenger)
      fitnessChannel.setMethodCallHandler { call, result in
        switch call.method {
        case "isAvailable":
          result(true)
        case "fetchDailySteps":
          result(7200)
        case "syncHabitCompletion":
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
