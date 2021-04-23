import UIKit
import Flutter
import batch_flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    BatchFlutterPlugin.configuration.APIKey = "6082F280A2A98586FD421AADEE5AB5"
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
