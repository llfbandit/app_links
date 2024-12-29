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
  private var initialLinkSent = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = AppLinks.shared

    let methodChannel = FlutterMethodChannel(name: "com.llfbandit.app_links/messages", binaryMessenger: registrar.messenger)
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let eventChannel = FlutterEventChannel(name: "com.llfbandit.app_links/events", binaryMessenger: registrar.messenger)
    eventChannel.setStreamHandler(instance)

    registrar.addApplicationDelegate(instance)
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
    NSAppleEventManager.shared().setEventHandler(
      self,
      andSelector: #selector(handleEvent(_:with:)),
      forEventClass: AEEventClass(kInternetEventClass),
      andEventID: AEEventID(kAEGetURL)
    )
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
      
    if (!initialLinkSent && initialLink != nil) {
      initialLinkSent = true
      events(initialLink!)
    }
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }

  @objc
  private func handleEvent(
    _ event: NSAppleEventDescriptor,
    with replyEvent: NSAppleEventDescriptor) {

    if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
       let _ = URL(string: urlString) {
      handleLink(link: urlString)
    }
  }

  public func handleLink(link: String) {
    latestLink = link

    if (initialLink == nil) {
      initialLink = link
    }
    
    if let _eventSink = eventSink {
      initialLinkSent = true
      _eventSink(latestLink)
    }    
  }
}
