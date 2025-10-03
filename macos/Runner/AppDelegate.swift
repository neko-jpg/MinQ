import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var statusItem: NSStatusItem?

  override func applicationDidFinishLaunching(_ notification: Notification) {
    super.applicationDidFinishLaunching(notification)
    guard let controller = mainFlutterWindow?.contentViewController as? FlutterViewController else {
      return
    }
    let channel = FlutterMethodChannel(name: "miinq/desktop_menu_bar", binaryMessenger: controller.engine.binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "updateTimer":
        if self?.statusItem == nil {
          self?.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        }
        if let args = call.arguments as? [String: Any], let remaining = args["remainingSeconds"] as? Int, let title = args["title"] as? String {
          self?.statusItem?.button?.title = "\(title) \(remaining / 60)m"
        }
        result(nil)
      case "clear":
        self?.statusItem?.button?.title = ""
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
