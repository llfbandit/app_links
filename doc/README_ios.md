# iOS

Apple documentation:
- Universal Links: [Documentation](https://developer.apple.com/documentation/safariservices/supporting_associated_domains)
- Custom URL schemes: [Documentation](https://developer.apple.com/documentation/xcode/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app)

Disable default Flutter deep linking:
- https://docs.flutter.dev/cookbook/navigation/set-up-universal-links#add-support-for-go_router

From Flutter 3.24, you must disable it explicitly.
1. Navigate to ios/Runner/Info.plist file. 
2. Add the following in `<dict>` chapter:
```xml
<key>FlutterDeepLinkingEnabled</key>
<false/>
```

## Notice

If you have a custom AppDelegate with overridden methods either:
- `application(_:willFinishLaunchingWithOptions:)`
- or `application(_:didFinishLaunchingWithOptions:)`
- or another package also dealing with Universal Links or Custom URL schemes (This can be difficult to detect, so try the example project if links are not forwarded).

this may break the workflow to catch links or provide unwanted behaviours.

The default workflow requires that both methods call super and return true to enable app link workflow.

If you can't respect those constraints, or you need a specific behaviour, proceed with the following setup.

## SETUP (only if you can't conform to the notice above)

### Standard app sample

```swift
import app_links

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Retrieve the link from parameters
    if let url = AppLinks.shared.getLink(launchOptions: launchOptions) {
      // We have a link, propagate it to your Flutter app or not
      AppLinks.shared.handleLink(url: url)
      return true // Returning true will stop the propagation to other packages
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```


### Scene-based app sample

```swift
import app_links

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  // Check for initial link
  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions
  ) {
    // ...

    self.scene(scene, openURLContexts: connectionOptions.urlContexts)

    for userActivity in connectionOptions.userActivities {
      self.scene(scene, continue: userActivity)
    }
  }

  // Check for further Universal Links
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    for context in URLContexts {
      AppLinks.shared.handleLink(url: context.url)
    }
  }

  // Check for further Custom URL schemes
  func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    if let url = userActivity.webpageURL {
      AppLinks.shared.handleLink(url: url)
    }
  }
}
```

# Testing

```sh
/usr/bin/xcrun simctl openurl booted "app://www.example.com/#/book/hello-world"
```