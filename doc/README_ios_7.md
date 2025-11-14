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

## Requirements:
- Flutter >= 3.35

## Notice

By default, you have nothing to do, scene events are propagated to other plugins.

But you may want to catch the events from other plugins...

We can't be sure that app_links is called before other conflicting plugins.

If you want to customize the propagation you have the options below:
- Set `defaultUrlHandling` to `.availability` to propagate globally only if there's no URL provided.
- Set `urlHandledCallBack` to react on each URL provided.
- Or manual handling.

## Samples

Semi-automatic handling

```swift
import app_links

class MyClass {
  // ...

  // Global
  AppLinks.shared.defaultUrlHandling = .availability

  // or/and local
  AppLinks.shared.urlHandledCallBack = { (_ url: URL) -> Bool in
    // return false to propagate event, otherwise true if handled
  }
}
```

Manual handling
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