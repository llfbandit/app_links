# app_links

Android App Links, Deep Links, iOS Universal Links and Custom URL schemes handler (desktop included).

This plugin allows you to:
- catch HTTPS URLs to open your app instead of the browser (App Link / Universal Link).
- catch custom schemes to open your app (Deep Link / Custom URL scheme).

## Getting Started

Before using the plugin, you'll need to setup each platforms you target.

All those configurations below are accessible in the example project.

### Android

- App Links: [Documentation](https://developer.android.com/training/app-links/verify-android-applinks)
- Deep Links: [Documentation](https://developer.android.com/training/app-links/deep-linking)

**Notes:**

- By default, flutter Activity is set with `android:launchMode="singleTop"`.
This is perfectly fine and expected, but this launches another instance of your app, specifically for the requested view.  
If you don't want this behaviour, you can set `android:launchMode="singleInstance"` in your `AndroidManifest.xml` and avoid another flutter warmup.

<details>
  <summary>Here's how to setup</summary>

  In AndroidManifest.xml

```xml
<!-- App Link sample -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="http" android:host="www.example.com" android:pathPrefix="/foo" />
    <data android:scheme="https" android:host="www.example.com" android:pathPrefix="/foo" />
</intent-filter>

<!-- Deep Link sample -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <!-- Add optional android:host to distinguish your app
          from others in case of conflicting scheme name -->
    <data android:scheme="sample" android:host="open.my.app" />
    <!-- <data android:scheme="sample" /> -->
</intent-filter>
```

</details>

### iOS

- Universal Links: [Documentation](https://developer.apple.com/documentation/safariservices/supporting_associated_domains)
- Custom URL schemes: [Documentation](https://developer.apple.com/documentation/xcode/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app)

**Warning:**

If you have a custom AppDelegate with overriden methods either:
- application(_:willFinishLaunchingWithOptions:)
- or application(_:didFinishLaunchingWithOptions:)

Both methods must call super and return true to enable app link workflow.
If you can't respect those two constraints or you need a specific process.

<details>
  <summary>Here's how to setup in those cases</summary>

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
      // We have a link, propagate it to your Flutter app
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

</details>


### Windows

<details>
  <summary>How to setup</summary>

Add this inclusion in <PROJECT_DIR>\windows\runner\main.cpp
```cpp
#include "app_links/app_links_plugin_c_api.h"
```

Add this method before `wWinMain`
```cpp
bool SendAppLinkToInstance(const std::wstring& title) {
  // Find our exact window
  HWND hwnd = ::FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", title.c_str());

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

Add the call to the previous method in `wWinMain`
```cpp
int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Replace "example" with the generated title found as parameter of `window.Create` in this file.
  // You may ignore the result if you need to create another window.
  if (SendAppLinkToInstance(L"example")) {
    return EXIT_SUCCESS;
  }

...
```

Great!

Now you can register your own scheme.
On Windows, URL protocols are setup in the Windows registry.

This package won't do it for you (and will never sorry).

You may achieve it with using the win32_registry package with the following code to register the URL protocol:


```dart
Future<void> register(String scheme) async {
  String appPath = Platform.resolvedExecutable;

  String protocolRegKey = 'Software\\Classes\\$scheme';
  RegistryValue protocolRegValue = const RegistryValue(
    'URL Protocol',
    RegistryValueType.string,
    '',
  );
  String protocolCmdRegKey = 'shell\\open\\command';
  RegistryValue protocolCmdRegValue = RegistryValue(
    '',
    RegistryValueType.string,
    '"$appPath" "%1"',
  );

  final regKey = Registry.currentUser.createKey(protocolRegKey);
  regKey.createValue(protocolRegValue);
  regKey.createKey(protocolCmdRegKey).createValue(protocolCmdRegValue);
}

```

</details>


### macOS
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


### Linux
<details>
  <summary>How to setup</summary>

Apply the following changes to your `linux/my_application.cc` file:
```patch
diff --git a/example/linux/my_application.cc b/example/linux/my_application.cc
index 0ba8f43..f07f765 100644
--- a/example/linux/my_application.cc
+++ b/example/linux/my_application.cc
@@ -17,6 +17,13 @@ G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)
 // Implements GApplication::activate.
 static void my_application_activate(GApplication* application) {
   MyApplication* self = MY_APPLICATION(application);
+
+  GList* windows = gtk_application_get_windows(GTK_APPLICATION(application));
+  if (windows) {
+    gtk_window_present(GTK_WINDOW(windows->data));
+    return;
+  }
+
   GtkWindow* window =
       GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

@@ -78,7 +85,7 @@ static gboolean my_application_local_command_line(GApplication* application, gch
   g_application_activate(application);
   *exit_status = 0;

-  return TRUE;
+  return FALSE;
 }

 // Implements GObject::dispose.
@@ -99,6 +106,6 @@ static void my_application_init(MyApplication* self) {}
 MyApplication* my_application_new() {
   return MY_APPLICATION(g_object_new(my_application_get_type(),
                                      "application-id", APPLICATION_ID,
-                                     "flags", G_APPLICATION_NON_UNIQUE,
+                                     "flags", G_APPLICATION_HANDLES_COMMAND_LINE | G_APPLICATION_HANDLES_OPEN,
                                      nullptr));
```

Notes:
- Please ensure your `APPLICATION_ID` is the same as your desktop file name if you're using Flathub.
- Please ensure you have added this section in your `snapcraft.yaml` file if you're using SnapStore:
```yaml
slots:
  dbus-appflowy:
    interface: dbus
    bus: session
    name: `APPLICATION_ID`
```
- You can refer to these two repositories for more details: [FlatHub setup](https://github.com/flathub/io.appflowy.AppFlowy) and [Snapcraft setup](https://github.com/LucasXu0/appflowy-snap/blob/main/snap/snapcraft.yaml).

Done!
</details>

---

### AppLinks usage
Please, ensure to instanciate `AppLinks` early in your app to catch the very first link when the app is in cold state.

Simpliest usage with a single stream
```dart
final _appLinks = AppLinks();

// Subscribe to all events when app is started.
// (Use allStringLinkStream to get it as [String])
_appLinks.allUriLinkStream.listen((uri) {
    // Do something (navigation, ...)
});
```

Decomposed usage
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

## Tests
The following commands will help you to test links.

### Test on Android

```sh
adb shell am start -a android.intent.action.VIEW \
  -d "sample://open.my.app/#/book/hello-world"
```

For App Links, you can also test it from Android Studio: [Documentation](https://developer.android.com/studio/write/app-link-indexing#testindent).

Android 13:
- While in development, you may need to manually activate your links.
- Go to your app info/settings: Open by default > Add link > (your links should be already filled).

### Test on iOS

```sh
/usr/bin/xcrun simctl openurl booted "app://www.example.com/#/book/hello-world"
```

### Test on windows & macOS
Open your browser and type in your address bar:
```
sample://foo/#/book/hello-world2
```
