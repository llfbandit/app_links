import Cocoa
import FlutterMacOS

public class AppLinksMacosPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var initialLink: String?
  private var latestLink: String?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = AppLinksMacosPlugin()

    let methodChannel = FlutterMethodChannel(name: "com.llfbandit.app_links/messages", binaryMessenger: registrar.messenger)
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let eventChannel = FlutterEventChannel(name: "com.llfbandit.app_links/events", binaryMessenger: registrar.messenger)
    eventChannel.setStreamHandler(instance)
  }

  @objc
  override init() {
    super.init();

    NSAppleEventManager.shared().setEventHandler(
      self,
      andSelector: #selector(handleEvent(_:with:)),
      forEventClass: AEEventClass(kInternetEventClass),
      andEventID: AEEventID(kAEGetURL)
    )
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

  public func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink) -> FlutterError? {

    self.eventSink = events
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

  private func handleLink(link: String) {
    debugPrint("macOS handleLink: \(link)")

    latestLink = link

    if (initialLink == nil) {
      initialLink = link
    }
    
    if let _eventSink = eventSink {
      _eventSink(latestLink)
    }    
  }
}
