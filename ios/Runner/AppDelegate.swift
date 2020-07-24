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
    UIApplication.shared.isStatusBarHidden = false
	
    GeneratedPluginRegistrant.register(with: self)
	GMSServices.provideAPIKey("AIzaSyA44if2p7nnYIy76PyUDawczq_gJk5u1hQ")
	if #available(iOS 10.0, *) {
  // For iOS 10 display notification (sent via APNS)
	UNUserNotificationCenter.current().delegate = self
	let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
	UNUserNotificationCenter.current().requestAuthorization(
    options: authOptions,
    completionHandler: {_, _ in })
	} else {
	let settings: UIUserNotificationSettings =
	UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
	application.registerUserNotificationSettings(settings)
	}
    
	application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) { Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
      Messaging.messaging().apnsToken = deviceToken;
  }
}