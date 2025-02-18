import UIKit
import Flutter
import app_links

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Retrieve the link from parameters
    // if let url = AppLinks.shared.getLink(launchOptions: launchOptions) {
    //   // We have a link, propagate it to your Flutter app
    //   AppLinks.shared.handleLink(url: url)
    //   return true // Returning true will stop the propagation to other packages
    // }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
