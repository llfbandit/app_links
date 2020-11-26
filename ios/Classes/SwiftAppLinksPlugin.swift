import Flutter
import UIKit

public class SwiftAppLinksPlugin: NSObject, FlutterPlugin {
  fileprivate FlutterMethodChannel methodChannel;
  fileprivate String initialLink;
  fileprivate String latestLink;

  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(name: "com.llfbandit.app_links/messages", binaryMessenger: registrar.messenger())
    let instance = SwiftAppLinksPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "getInitialLink":
        result(initialLink)
        break
      case "getLatestLink":
        result(latestLink)
        break
      default:
        result(FlutterMethodNotImplemented)
        break
    }
  }

  // Universal Links
  func application(_ application: UIApplication,
					continue userActivity: NSUserActivity,
					restorationHandler: @escaping ([Any]?) -> Void) -> Bool {

    switch userActivity.activityType {
      case NSUserActivityTypeBrowsingWeb:
        guard let url = userActivity.webpageURL else {
          return false
        }
        handleLink(url: url)
        return true
      default: return false
    }
  }

  // Custom URL schemes
  func application(_ application: UIApplication,
          open url: URL,
          options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    
    handleLink(url: url)
  }

  fileprivate handleLink(url: URL) -> Bool {
    if (initialLink == null) {
      initialLink = url.absoluteString
    }

    latestLink = url.absoluteString

    methodChannel.invokeMethod("onAppLink", arguments: latestLink)
  }
}
