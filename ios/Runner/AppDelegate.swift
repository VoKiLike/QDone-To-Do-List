import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let hapticsChannelName = "qdone/haptics"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      let hapticsChannel = FlutterMethodChannel(
        name: hapticsChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      hapticsChannel.setMethodCallHandler { call, result in
        if call.method == "taskTap" {
          UIImpactFeedbackGenerator(style: .light).impactOccurred()
          result(nil)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
