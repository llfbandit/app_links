# app_links

Android App Links, Deep Links, iOs Universal Links and Custom URL schemes handler (desktop included).

This plugin allows you to:
- catch HTTPS URLs to open your app instead of the browser (App Link / Universal Link).
- catch custom schemes to open your app (Deep Link / Custom URL scheme).

## Getting Started

Before using the plugin, you'll need to setup each platforms you target.

### Android

- App Links: [Documentation](https://developer.android.com/training/app-links/verify-site-associations)
- Deep Links: [Documentation](https://developer.android.com/training/app-links/deep-linking)

### iOs

- Universal Links: [Documentation](https://developer.apple.com/documentation/safariservices/supporting_associated_domains)
- Custom URL schemes: [Documentation](https://developer.apple.com/documentation/xcode/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app)

### Windows

<details>
  <summary>How to setup</summary>

Don't be afraid, this is just copy/paste commands to follow.  
But yes, it we will be a bit painful...

Declare this method in <PROJECT_DIR>\windows\runner\win32_window.h
```cpp
  // Dispatches link if any.
  // This method enables our app to be with a single instance too.
  // This is optional but mandatory if you want to catch further links in same app.
  bool SendAppLinkToInstance(const std::wstring& title);
```

Add this inclusion at the top of <PROJECT_DIR>\windows\runner\win32_window.cpp
```cpp
#include "app_links_windows/app_links_windows_plugin.h"
```

Add this method in <PROJECT_DIR>\windows\runner\win32_window.cpp
```cpp
bool Win32Window::SendAppLinkToInstance(const std::wstring& title) {
  // Find our exact window
  HWND hwnd = ::FindWindow(kWindowClassName, title.c_str());
  
  if (hwnd) {
    // Dispatch new link to current window
    SendAppLink(hwnd);

    // (Optional) Restore our window to front in same state
    WINDOWPLACEMENT place = { sizeof(WINDOWPLACEMENT) };
    GetWindowPlacement(hwnd, &place);
    switch(place.showCmd) {
      case SW_SHOWMAXIMIZED:
          ShowWindow(hwnd, SW_SHOWMAXIMIZED);
          break;
      case SW_SHOWMINIMIZED:
          ShowWindow(hwnd, SW_RESTORE);
          break;
      default:
          ShowWindow(hwnd, SW_NORMAL);
          break;
    }
    SetWindowPos(0, HWND_TOP, 0, 0, 0, 0, SWP_SHOWWINDOW | SWP_NOSIZE | SWP_NOMOVE);
    SetForegroundWindow(hwnd);
    // END Restore

    // Window has been found, don't create another one.
    return true;
  }

  return false;
}
```

Add the call to the previous method in `CreateAndShow`
```cpp
bool Win32Window::CreateAndShow(const std::wstring& title,
                                const Point& origin,
                                const Size& size) {
if (SendAppLinkToInstance(title)) {
    return false;
}

...
```

Great!

Now you can register your own scheme.  
On Windows, URL protocols are setup in the Windows registry.

This package won't do it for you (and will never sorry).  

You can achieve it with [url_protocol](https://pub.dev/packages/url_protocol) inside you app.  

But... The most relevant solution is to include those registry modifications into your installer to allow the unregistration.
</details>

<br/>

### Mac OS
<details>
  <summary>How to setup</summary>

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
</details>

<br/>
All those configurations above are available in the example project.

---
  
### AppLinks usage
```dart
final _appLinks = AppLinks();

// Get the initial/first link.
// This is useful when app was terminated (i.e. not started)
final uri = await _appLinks.getInitialAppLink();
// Do something (navigation, ...)

// Subscribe to further events when app is started.
// (Use stringLinkStream to get it as [String])
_linkSubscription = _appLinks.uriLinkStream.listen((uri) {
    // Do something (navigation, ...)
});

...

// Maybe later. Get the latest link.
final uri = await _appLinks.getLatestAppLink();
```

Android notes:

- By default, flutter Activity is set with `android:launchMode="singleTop"`.
This is perfectly fine and expected, but this launches another instance of your app, specifically for the requested view.  
If you don't want this behaviour, you can set `android:launchMode="singleInstance"` in your `AndroidManifest.xml` and avoid another flutter warmup.

## Tests
The following commands will help you to test links.

### Android
```sh
adb shell am start
    -W -a android.intent.action.VIEW
    -d "<URI>" <PACKAGE>
```
For App Links, you can also test it from Android Studio: [Documentation](https://developer.android.com/studio/write/app-link-indexing#testindent).

### iOs
```sh
/usr/bin/xcrun simctl openurl booted "<URI>"
```
