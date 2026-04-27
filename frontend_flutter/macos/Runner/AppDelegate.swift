import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    let mainFlutterWindow = NSApplication.shared.windows.first(where: { $0.isKeyWindow })
    guard let controller = mainFlutterWindow?.rootViewController as? FlutterViewController else {
      return
    }
    
    let nativeChannel = FlutterMethodChannel(
      name: "com.nexibazaar.nexi_bazaar/native",
      binaryMessenger: controller.binaryMessenger
    )
    
    nativeChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "getPlatformVersion":
        let version = ProcessInfo.processInfo.operatingSystemVersionString
        result("macOS " + version)
      case "getDeviceInfo":
        result([
          "platform": "macOS",
          "version": ProcessInfo.processInfo.operatingSystemVersionString,
          "model": self.getMacModel(),
          "locale": Locale.current.languageCode ?? "en"
        ])
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  private func getMacModel() -> String {
    var modelIdentifier: String = ""
    let service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                             IOServiceMatching("IOPlatformExpertDevice"))
    if let service = service {
      if let model = IORegistryEntryCreateCFProperty(service, "model" as CFString,
                                                      kCFAllocatorDefault, 0).takeRetainedValue() as? String {
        modelIdentifier = model
      }
      IOObjectRelease(service)
    }
    return modelIdentifier.isEmpty ? "Unknown Mac" : modelIdentifier
  }
}
