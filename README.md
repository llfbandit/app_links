# app_links

Android App Links, Deep Links, iOS Universal Links and Custom URL schemes handler (desktop included linux, macOS, Windows).

This plugin allows you to:
- catch HTTPS URLs to open your app instead of the browser (App Link / Universal Link).
- catch custom schemes to open your app (Deep Link / Custom URL scheme).

## Getting Started

Before using the plugin, you'll need to setup each platform you target.

All those configurations below are also accessible in the example project.

* [Android](https://github.com/llfbandit/app_links/blob/master/doc/README_android.md)
* [iOS](https://github.com/llfbandit/app_links/blob/master/doc/README_ios.md)
* [Linux](https://github.com/llfbandit/app_links/blob/master/doc/README_linux.md)
* [macOS](https://github.com/llfbandit/app_links/blob/master/doc/README_macos.md)
* [Windows](https://github.com/llfbandit/app_links/blob/master/doc/README_windows.md)
* There's nothing to setup for web platform. Only the initial link is provided.

---

### AppLinks usage
Please, ensure to instantiate `AppLinks` early in your app to catch the very first link when the app is in cold state.

```dart
final _appLinks = AppLinks(); // AppLinks is singleton

// Subscribe to all events (initial link and further)
_appLinks.uriLinkStream.listen((uri) {
    // Do something (navigation, ...)
});
```
