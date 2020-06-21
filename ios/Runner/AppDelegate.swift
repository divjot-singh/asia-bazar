import UIKit
import Flutter
import Firebase
import GoogleMaps
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    var flutter_native_splash = 1
    UIApplication.shared.isStatusBarHidden = false

    GeneratedPluginRegistrant.register(with: self)
	GMSServices.provideAPIKey("AIzaSyA44if2p7nnYIy76PyUDawczq_gJk5u1hQ")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}