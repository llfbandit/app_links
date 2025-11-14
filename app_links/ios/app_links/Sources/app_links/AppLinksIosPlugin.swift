import Flutter
import UIKit

/// AppLinks singleton shared object
public class AppLinks {
  static public let shared = AppLinksIosPlugin()

  private init() {}
}

/// Called to customize the returned value of event.
public typealias UrlHandledCallBack = (_ url: URL) -> Bool

/// Event propagation to other plugins
public enum UrlHandled {
  /// Always propagate to other plugins
  case never
  /// Propagate depending of URL availability
  case availability
}

public final class AppLinksIosPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, FlutterSceneLifeCycleDelegate {
  private var eventSink: FlutterEventSink?
  
  private var initialLink: String?
  private var initialLinkSent = false
  private var latestLink: String?
  
  /// Default returned value when handling an URL
  public var defaultUrlHandling: UrlHandled = .never

  /// Called to customize URL handling
  ///
  /// Takes precedence on `defaultUrlHandling`
  public var urlHandledCallBack: UrlHandledCallBack?

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
    registrar.addSceneDelegate(instance)
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
  @available(*, deprecated, message: "You should migrate to UISceneDelegate")
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
  
  /*----------------------------------------------------*/
  // Application events
  /*----------------------------------------------------*/
  
  // Universal Links
  public func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([Any]) -> Void
  ) -> Bool {
    
    var handled = defaultUrlHandling == .never ? false : userActivity.webpageURL != nil
    
    if let url = userActivity.webpageURL {
      if let cb = urlHandledCallBack {
        handled = handled || cb(url)
      }

      handleLink(url: url)
    }

    return handled
  }
  
  // Custom URL schemes
  public func application(
    _ application: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    
    handleLink(url: url)
    return defaultUrlHandling == .never
  }

  /*----------------------------------------------------*/
  // Scene events
  /*----------------------------------------------------*/
  
  // Check for initial link
  public func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions?
  ) -> Bool {
    
    var handled = false

    if let options = connectionOptions {
      handled = self.scene(scene, openURLContexts: options.urlContexts)

      for userActivity in options.userActivities {
        handled = handled || self.scene(scene, continue: userActivity)
      }
    }

    return handled
  }

  // Check for further Universal Links
  public func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) -> Bool {
    var handled = defaultUrlHandling == .never ? false : !URLContexts.isEmpty

    for context in URLContexts {
      if let cb = urlHandledCallBack {
        handled = handled || cb(context.url)
      }
      
      handleLink(url: context.url)
    }

    return handled
  }

  // Check for further Custom URL schemes
  public func scene(
    _ scene: UIScene,
    continue userActivity: NSUserActivity
  ) -> Bool {

    var handled = defaultUrlHandling == .never ? false : userActivity.webpageURL != nil
    
    if let url = userActivity.webpageURL {
      if let cb = urlHandledCallBack {
        handled = handled || cb(url)
      }

      handleLink(url: url)
    }

    return handled
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

  /// Fires given URL to dart side
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
