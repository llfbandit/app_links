import Cocoa
import FlutterMacOS

public class AppLinks {
  static public let shared = AppLinksMacosPlugin()

  private init() {}
}

public class AppLinksMacosPlugin: NSObject, FlutterPlugin, FlutterAppLifecycleDelegate {
  // Holds one sink per listening engine.
  private var listeners: [Listener] = []

  private var initialLink: String?
  private var latestLink: String?
  // Holds links received before Dart first listens. The first engine gets them.
  private var launchLinks: [String] = []
  private var listenedOnce = false
  // Every engine passes on the same URLs. These skip the repeats.
  private var openedUrls: [URL]?
  // Set while handleEvent forwards a URL to the app delegate.
  private var forwardingUrl = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = AppLinks.shared

    let methodChannel = FlutterMethodChannel(name: "com.llfbandit.app_links/messages", binaryMessenger: registrar.messenger)
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let eventChannel = FlutterEventChannel(name: "com.llfbandit.app_links/events", binaryMessenger: registrar.messenger)
    // Each engine gets its own handler, so every engine gets the links.
    let handler = LinkStreamHandler(plugin: instance)
    eventChannel.setStreamHandler(handler)

    // A released engine removes the app delegates it added, so each engine adds its own.
    registrar.addApplicationDelegate(handler)

    // An engine created after launch misses handleWillFinishLaunching.
    if NSRunningApplication.current.isFinishedLaunching {
      instance.setUpUrlHandler()
    }
  }
  
  public func getUniversalLink(_ userActivity: NSUserActivity) -> URL? {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
        let url = userActivity.webpageURL,
        let _ = NSURLComponents(url: url, resolvingAgainstBaseURL: true) else {
        return nil
    }
    
    return url
  }

  // Custom URL schemes
  public func handleWillFinishLaunching(_ notification: Notification) {
    setUpUrlHandler()
  }

  // If the app delegate overrides application(_:open:), it may not call super.
  // Catch the URL event directly, then forward it to the app delegate.
  private func setUpUrlHandler() {
    guard let delegate = NSApp.delegate else { return }

    let selector = NSSelectorFromString("application:openURLs:")
    let appImp = class_getMethodImplementation(object_getClass(delegate), selector)
    let flutterImp = class_getMethodImplementation(FlutterAppDelegate.self, selector)
    if appImp == flutterImp { return }

    NSAppleEventManager.shared().setEventHandler(
      self,
      andSelector: #selector(handleEvent(_:with:)),
      forEventClass: AEEventClass(kInternetEventClass),
      andEventID: AEEventID(kAEGetURL)
    )
  }

  @objc
  private func handleEvent(
    _ event: NSAppleEventDescriptor,
    with replyEvent: NSAppleEventDescriptor) {

    if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
       let url = URL(string: urlString) {
      handleLink(link: urlString)

      // Let the app and other plugins see the URL too.
      forwardingUrl = true
      NSApp.delegate?.application?(NSApp, open: [url])
      forwardingUrl = false
    }
  }

  public func handleOpen(_ urls: [URL]) -> Bool {
    // handleEvent already sent the URL it forwards.
    if forwardingUrl || urls == openedUrls {
      return false
    }

    openedUrls = urls
    DispatchQueue.main.async { self.openedUrls = nil }

    for url in urls where !url.isFileURL {
      handleLink(link: url.absoluteString)
    }
    // Let other delegates see the URLs too.
    return false
  }

  // Universal links
//  public override func application(_ application: NSApplication,
//                                   continue userActivity: NSUserActivity,
//                                   restorationHandler: @escaping ([any NSUserActivityRestoring]) -> Void) -> Bool {
//
//    guard let url = getUniversalLink(userActivity) else {
//      return false
//    }
//    
//    handleLink(link: url.absoluteString)
//    
//    return false
//  }

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

  fileprivate func addListener(_ handler: LinkStreamHandler, sink: @escaping FlutterEventSink) {
    removeListener(handler)
    listeners.append(Listener(handler: handler, sink: sink))

    if !listenedOnce {
      listenedOnce = true
      for link in launchLinks {
        sink(link)
      }
      launchLinks = []
    }
  }

  // Also drops the listeners of released engines.
  fileprivate func removeListener(_ handler: LinkStreamHandler?) {
    listeners.removeAll { $0.handler == nil || $0.handler === handler }
  }

  public func handleLink(link: String) {
    latestLink = link

    if (initialLink == nil) {
      initialLink = link
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
}

private struct Listener {
  weak var handler: LinkStreamHandler?
  let sink: FlutterEventSink
}

// Listens to the event channel and the app events of one engine.
private final class LinkStreamHandler: NSObject, FlutterStreamHandler, FlutterAppLifecycleDelegate {
  private let plugin: AppLinksMacosPlugin

  init(plugin: AppLinksMacosPlugin) {
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

  func handleWillFinishLaunching(_ notification: Notification) {
    plugin.handleWillFinishLaunching(notification)
  }

  func handleOpen(_ urls: [URL]) -> Bool {
    return plugin.handleOpen(urls)
  }
}
