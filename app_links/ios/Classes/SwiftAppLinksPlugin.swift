import Flutter
import UIKit

public class SwiftAppLinksPlugin: NSObject, FlutterPlugin {
  fileprivate var methodChannel: FlutterMethodChannel
  fileprivate var initialLink: String?
  fileprivate var latestLink: String?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(name: "com.llfbandit.app_links/messages", binaryMessenger: registrar.messenger())

    let instance = SwiftAppLinksPlugin(methodChannel: methodChannel)

    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    registrar.addApplicationDelegate(instance)
  }

  init(methodChannel: FlutterMethodChannel) {
    self.methodChannel = methodChannel
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
      case "getInitialAppLink":
        result(initialLink)
        break
      case "getLatestAppLink":
        result(latestLink)
        break      
      default:
        result(FlutterMethodNotImplemented)
        break
    }
  }

  // Universal Links
  public func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([Any]) -> Void) -> Bool {

    switch userActivity.activityType {
      case NSUserActivityTypeBrowsingWeb:
        guard let url = userActivity.webpageURL else {
          return false
        }
        handleLink(url: url)
        return false
      default: return false
    }
  }

  // Custom URL schemes
  public func application(
    _ application: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    
    handleLink(url: url)
    return true
  }

  fileprivate func handleLink(url: URL) -> Void {
    let link = url.absoluteString

    debugPrint("iOS handleLink: \(link)")

    latestLink = link

    if (initialLink == nil) {
      initialLink = link
    } else {
      methodChannel.invokeMethod("onAppLink", arguments: latestLink)
    }
  }
}
