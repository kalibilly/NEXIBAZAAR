import UIKit
import Flutter

@UIApplicationMain
@objc class GeneratedPluginRegistrant: NSObject {
  @objc class func registerWith(registry: FlutterPluginRegistry) {
    // Plugin registration placeholder
  }
}

@main
class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let nativeChannel = FlutterMethodChannel(name: "com.nexibazaar.nexi_bazaar/native",
                                            binaryMessenger: controller.binaryMessenger)
    nativeChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "getPlatformVersion":
        result("iOS " + UIDevice.current.systemVersion)
      case "getDeviceInfo":
        result([
          "platform": "iOS",
          "version": UIDevice.current.systemVersion,
          "model": UIDevice.current.model
        ])
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
