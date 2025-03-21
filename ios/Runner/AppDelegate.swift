import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    var keys: NSDictionary?

    if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
        keys = NSDictionary(contentsOfFile: path)
    }
    if let dict = keys {
        let googleMapsAPIKey = dict["googleMapsAPIKey"] as? String
        // Google maps api key for iOS use
        GMSServices.provideAPIKey(googleMapsAPIKey!)
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
