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

public final class AppLinksIosPlugin: NSObject, FlutterPlugin, FlutterSceneLifeCycleDelegate {
  // Holds one sink per listening engine.
  private var listeners: [Listener] = []
  
  private var initialLink: String?
  private var latestLink: String?
  // Holds app links received before Dart first listens. The first engine gets them.
  private var launchLinks: [String] = []
  private var listenedOnce = false

  // Flutter sends scene events once per engine of the scene. These skip the repeats.
  private weak var lastSceneEvent: AnyObject?
  private var lastSceneEventHandled = false
  private var applicationDelegateAdded = false

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
    // Each engine gets its own handler, so scene links reach only the engines of their scene.
    let handler = LinkStreamHandler(plugin: instance)
    eventChannel.setStreamHandler(handler)
    // Add the app delegate once, Flutter shares it between engines.
    if !instance.applicationDelegateAdded {
      instance.applicationDelegateAdded = true
      registrar.addApplicationDelegate(instance)
    }
    registrar.addSceneDelegate(handler)
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
        if let userActivity = activityDictionary[key] as? NSUserActivity,
           userActivity.activityType == NSUserActivityTypeBrowsingWeb {
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

    guard enabled, let url = universalLink(userActivity) else {
      return false
    }

    return handleUrl(url, for: nil)
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
    
    return handleUrl(url, for: nil)
  }

  /*----------------------------------------------------*/
  // Scene events
  /*----------------------------------------------------*/

  // Flutter sends scene events to the handler of each engine.
  // These send to all engines, for apps that call them directly.

  // Check for initial link
  public func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions?
  ) -> Bool {

    return handleConnection(connectionOptions, for: nil)
  }

  // Custom URL schemes
  public func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) -> Bool {

    return handleUrlContexts(URLContexts, for: nil)
  }

  // Universal Links
  public func scene(
    _ scene: UIScene,
    continue userActivity: NSUserActivity
  ) -> Bool {

    return handleUserActivity(userActivity, for: nil)
  }

  /*----------------------------------------------------*/
  // Link handling
  /*----------------------------------------------------*/

  fileprivate func handleConnection(_ options: UIScene.ConnectionOptions?, for handler: LinkStreamHandler?) -> Bool {
    guard let options = options else {
      return false
    }

    let urls = options.urlContexts.map { $0.url }
      + options.userActivities.compactMap { universalLink($0) }

    return handleSceneUrls(urls, of: options, for: handler)
  }

  fileprivate func handleUrlContexts(_ URLContexts: Set<UIOpenURLContext>, for handler: LinkStreamHandler?) -> Bool {
    return handleSceneUrls(URLContexts.map { $0.url }, of: URLContexts.first, for: handler)
  }

  fileprivate func handleUserActivity(_ userActivity: NSUserActivity, for handler: LinkStreamHandler?) -> Bool {
    guard let url = universalLink(userActivity) else {
      return false
    }

    return handleSceneUrls([url], of: userActivity, for: handler)
  }

  // Handles the event for the first engine. The other engines of the scene only get its links.
  private func handleSceneUrls(_ urls: [URL], of event: AnyObject?, for handler: LinkStreamHandler?) -> Bool {
    guard enabled, let event = event else {
      return false
    }

    if event === lastSceneEvent {
      if let handler = handler {
        for url in urls {
          send(url.absoluteString, to: handler)
        }
      }
      return lastSceneEventHandled
    }

    var handled = false

    for url in urls {
      handled = handleUrl(url, for: handler) || handled
    }

    lastSceneEvent = event
    lastSceneEventHandled = handled
    return handled
  }

  // Returns the universal link of the activity.
  private func universalLink(_ userActivity: NSUserActivity) -> URL? {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else {
      return nil
    }

    return userActivity.webpageURL
  }

  // Sends the link and tells if other plugins should skip it.
  private func handleUrl(_ url: URL, for handler: LinkStreamHandler?) -> Bool {
    let handled = urlHandledCallBack?(url) ?? (defaultUrlHandling == .availability)
    handleLink(url: url, for: handler)
    return handled
  }

  /*----------------------------------------------------*/
  // Event streams
  /*----------------------------------------------------*/

  fileprivate func addListener(_ handler: LinkStreamHandler, sink: @escaping FlutterEventSink) {
    removeListener(handler)
    listeners.append(Listener(handler: handler, sink: sink))

    listenedOnce = true

    if !handler.listened {
      handler.listened = true
      for link in launchLinks + handler.pendingLinks {
        sink(link)
      }
      launchLinks = []
      handler.pendingLinks = []
    }
  }

  // Also drops the listeners of released engines.
  fileprivate func removeListener(_ handler: LinkStreamHandler?) {
    listeners.removeAll { $0.handler == nil || $0.handler === handler }
  }

  /// Fires given URL to dart side
  public func handleLink(url: URL) -> Void {
    handleLink(url: url, for: nil)
  }

  // Sends the link to the given engine, or to all engines when nil.
  private func handleLink(url: URL, for handler: LinkStreamHandler?) {
    let link = url.absoluteString
    
    latestLink = link
    
    if (initialLink == nil) {
      initialLink = link
    }

    if let handler = handler {
      send(link, to: handler)
      return
    }
    
    removeListener(nil)

    if listeners.isEmpty {
      if !listenedOnce {
        launchLinks.append(link)
      }
      return
    }

    for listener in listeners {
      listener.sink(link)
    }
  }

  // Sends the link to one engine. Keeps it until Dart first listens.
  private func send(_ link: String, to handler: LinkStreamHandler) {
    if let listener = listeners.first(where: { $0.handler === handler }) {
      listener.sink(link)
    } else if !handler.listened {
      handler.pendingLinks.append(link)
    }
  }
}

private struct Listener {
  weak var handler: LinkStreamHandler?
  let sink: FlutterEventSink
}

// Listens to the event channel and the scene events of one engine.
private final class LinkStreamHandler: NSObject, FlutterStreamHandler, FlutterSceneLifeCycleDelegate {
  private let plugin: AppLinksIosPlugin
  fileprivate var listened = false
  // Holds links of this engine's scene received before Dart first listens.
  fileprivate var pendingLinks: [String] = []

  init(plugin: AppLinksIosPlugin) {
    self.plugin = plugin
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    plugin.addListener(self, sink: events)
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    plugin.removeListener(self)
    return nil
  }

  // Check for initial link
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions?
  ) -> Bool {

    return plugin.handleConnection(connectionOptions, for: self)
  }

  // Custom URL schemes
  func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) -> Bool {

    return plugin.handleUrlContexts(URLContexts, for: self)
  }

  // Universal Links
  func scene(
    _ scene: UIScene,
    continue userActivity: NSUserActivity
  ) -> Bool {

    return plugin.handleUserActivity(userActivity, for: self)
  }
}
