# iOS

- Universal Links: [Documentation](https://developer.apple.com/documentation/safariservices/supporting_associated_domains)
- Custom URL schemes: [Documentation](https://developer.apple.com/documentation/xcode/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app)

Don't use go_router deep linking feature: https://docs.flutter.dev/cookbook/navigation/set-up-universal-links#add-support-for-go_router

**Warning:**

If you have a custom AppDelegate with overridden methods either:
- `application(_:willFinishLaunchingWithOptions:)`
- or `application(_:didFinishLaunchingWithOptions:)`
- or another package also dealing with Universal Links or Custom URL schemes.

Both methods must call super and return true to enable app link workflow.

If you can't respect those two constraints, or you need a specific behaviour, proceed with the following setup.

## SETUP (only if if can't conform to warning above)

```swift
import app_links

@UIApplicationMain
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

<br/>  
If you have a scene-based app.


```swift
import app_links

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    for context in URLContexts {
      AppLinks.shared.handleLink(url: context.url)
    }
  }
  
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