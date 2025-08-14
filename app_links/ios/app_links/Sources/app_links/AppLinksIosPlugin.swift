import Flutter
import UIKit

public class AppLinks {
  static public let shared = AppLinksIosPlugin()

  private init() {}
}

public final class AppLinksIosPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  
  private var initialLink: String?
  private var initialLinkSent = false
  private var latestLink: String?

  public static func register(with registrar: FlutterPluginRegistrar) {
    #if DEBUG
    // https://github.com/llfbandit/app_links/issues/211
    // https://github.com/flutter/flutter/issues/149214
    // Cancel registration because registrar is null while in swift it is referenced as non-nullable parameter.
    let messenger = (registrar as? NSObject)?.value(forKey: "messenger")
    if messenger == nil {
      print("Flutter application in debug mode can only be launched from Flutter tooling, use profile or release modes instead.")
      return
    }
    #endif

    let methodChannel = FlutterMethodChannel(name: "com.llfbandit.app_links/messages", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "com.llfbandit.app_links/events", binaryMessenger: registrar.messenger())
    
    let instance = AppLinks.shared

    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    eventChannel.setStreamHandler(instance)
    registrar.addApplicationDelegate(instance)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getInitialLink":
      result(initialLink)
    case "getLatestLink":
      result(latestLink)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  // Allow to capture links when apps also override application callbacks
  public func getLink(launchOptions: [AnyHashable : Any]?) -> URL? {
    guard let options = launchOptions else {
      return nil
    }

    // Custom URL
    if let url = options[UIApplication.LaunchOptionsKey.url] as? URL {
      return url
    }

    // Universal link
    else if let activityDictionary = options[UIApplication.LaunchOptionsKey.userActivityDictionary] as? [AnyHashable: Any] {
      for key in activityDictionary.keys {
        if let userActivity = activityDictionary[key] as? NSUserActivity {
          if let url = userActivity.webpageURL {
            return url
          }
        }
      }
    }
    
    return nil
  }
  
  // Universal Links
  public func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([Any]) -> Void
  ) -> Bool {
    
    if let url = userActivity.webpageURL {
      handleLink(url: url)
    }
    
    return false
  }
  
  // Custom URL schemes
  public func application(
    _ application: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    
    handleLink(url: url)
    return false
  }
  
  public func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    
    self.eventSink = events
    
    if !initialLinkSent && initialLink != nil {
      initialLinkSent = true
      events(initialLink!)
    }

    return nil
  }
  
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }
  
  public func handleLink(url: URL) -> Void {
    let link = url.absoluteString
    
    latestLink = link
    
    if (initialLink == nil) {
      initialLink = link
    }
    
    guard let _eventSink = eventSink, latestLink != nil else {
      return
    }
    
    initialLinkSent = true
    _eventSink(latestLink)
  }
}
