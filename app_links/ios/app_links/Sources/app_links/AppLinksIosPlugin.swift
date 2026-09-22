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
  /// Always forward event to other plugins
  case never
  /// Event forward depending of URL availability
  case availability
}

public final class AppLinksIosPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, FlutterSceneLifeCycleDelegate {
  private var eventSink: FlutterEventSink?
  
  private var initialLink: String?
  private var latestLink: String?
  // Holds links until Dart first listens.
  private var pendingLinks: [String]? = []

  /// Enables / disables automatic link handling
  ///
  /// Useful for manual handling
  public var enabled = true
  
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
    if let activityDictionary = options[UIApplication.LaunchOptionsKey.userActivityDictionary] as? [AnyHashable: Any] {
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

    return handleUserActivity(userActivity)
  }
  
  // Custom URL schemes
  public func application(
    _ application: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {

    if !enabled {
      return false
    }
    
    handleLink(url: url)
    return defaultUrlHandling == .availability
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

    if !enabled {
      return false
    }
    
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

    if !enabled {
      return false
    }

    var handled = false

    for context in URLContexts {
      handled = handleUrl(context.url) || handled
    }

    return handled
  }

  // Check for further Custom URL schemes
  public func scene(
    _ scene: UIScene,
    continue userActivity: NSUserActivity
  ) -> Bool {

    return handleUserActivity(userActivity)
  }

  /*----------------------------------------------------*/
  // Link handling
  /*----------------------------------------------------*/

  // Handles the universal link of the activity.
  private func handleUserActivity(_ userActivity: NSUserActivity) -> Bool {
    guard enabled, let url = userActivity.webpageURL else {
      return false
    }

    return handleUrl(url)
  }

  // Sends the link and tells if other plugins should skip it.
  private func handleUrl(_ url: URL) -> Bool {
    let handled = urlHandledCallBack?(url) ?? (defaultUrlHandling == .availability)
    handleLink(url: url)
    return handled
  }

  public func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    
    self.eventSink = events
    
    let links = pendingLinks ?? []
    pendingLinks = nil
    for link in links {
      events(link)
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
    
    guard let _eventSink = eventSink else {
      pendingLinks?.append(link)
      return
    }

    _eventSink(link)
  }
}
