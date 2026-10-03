import Cocoa
import FlutterMacOS

public class AppLinks {
  static public let shared = AppLinksMacosPlugin()

  private init() {}
}

public class AppLinksMacosPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, FlutterAppLifecycleDelegate {
  private var eventSink: FlutterEventSink?
  private var initialLink: String?
  private var latestLink: String?
  // Holds links until Dart first listens.
  private var pendingLinks: [String]? = []
  // The instance is shared, so add it as app delegate only once.
  private var appDelegateAdded = false
  // Set while handleEvent forwards a URL to the app delegate.
  private var forwardingUrl = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = AppLinks.shared

    let methodChannel = FlutterMethodChannel(name: "com.llfbandit.app_links/messages", binaryMessenger: registrar.messenger)
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let eventChannel = FlutterEventChannel(name: "com.llfbandit.app_links/events", binaryMessenger: registrar.messenger)
    eventChannel.setStreamHandler(instance)

    if !instance.appDelegateAdded {
      instance.appDelegateAdded = true
      registrar.addApplicationDelegate(instance)
      // An engine created after launch misses handleWillFinishLaunching.
      if NSRunningApplication.current.isFinishedLaunching {
        instance.setUpUrlHandler()
      }
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
    if forwardingUrl {
      return false
    }

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

  public func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink) -> FlutterError? {

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

  public func handleLink(link: String) {
    latestLink = link

    if (initialLink == nil) {
      initialLink = link
    }
    
    if let _eventSink = eventSink {
      _eventSink(link)
    } else {
      pendingLinks?.append(link)
    }
  }
}
