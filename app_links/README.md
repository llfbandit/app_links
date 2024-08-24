# app_links

Android App Links, Deep Links, iOS Universal Links and Custom URL schemes handler (desktop included linux, macOS, Windows).

This plugin allows you to open your app from:
- HTTPS URLs instead of the browser.
- custom schemes.

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
final appLinks = AppLinks(); // AppLinks is singleton

// Subscribe to all events (initial link and further)
final sub = appLinks.uriLinkStream.listen((uri) {
    // Do something (navigation, ...)
});
```

### Feature matrix
| Feature                   | Android     | iOS       | web     | Windows    | macOS  | linux
|---------------------------|-------------|-----------|---------|------------|-------|-----------
| web (https://)            | ✔️         |   ✔️      | ✔️*     |    ✔️     | ✔️    |    ?
| custom scheme (foo://)    | ✔️         |   ✔️      |         |    ✔️     |  ✔️   |    ✔️

\* : Only the very first call is provided. Web platform is mostly provided to get rid of specific setup.
