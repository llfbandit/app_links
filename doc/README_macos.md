# macOS
## SETUP

Add this XML chapter in your `macos/Runner/Info.plist` inside `<plist version="1.0"><dict>` chapter:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <!-- abstract name for this URL type (you can leave it blank) -->
        <string>sample_name</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- your schemes -->
            <string>sample</string>
        </array>
    </dict>
</array>
```

Done!

Setup for universal links:

For now, Flutter plugin embedder does not provide a way to do this in the plugin directly.

You'll have to add this in your own macOS AppDelegate:
```swift
import app_links

public override func application(_ application: NSApplication,
                                 continue userActivity: NSUserActivity,
                                 restorationHandler: @escaping ([any NSUserActivityRestoring]) -> Void) -> Bool {

  guard let url = AppLinks.shared.getUniversalLink(userActivity) else {
    return false
  }
  
  AppLinks.shared.handleLink(link: url.absoluteString)
  
  return false // Returning true will stop the propagation to other packages
}
```

## Testing
Open your browser and type in your address bar:
```
sample://foo/#/book/hello-world2
```
