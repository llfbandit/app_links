# Windows

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
    // END (Optional) Restore

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

## Recommended setup for registration (both custom scheme and web-to-app)
⚠️ By using this method, activation is only available on a packaged app. This won't work when debugging.

By using [msix](https://pub.dev/packages/msix), it will create the required manifest to register the protocols.

Note: As Flutter apps are win32 type apps, activation feature is only available from a manifest.

This method also provides, for free, a seamless way to cleanup the registrations when uninstalling the app.

Note: `app_uri_handler_hosts` parameter is only used for web-to-app feature (https://).
When registering a custom scheme, only the scheme matters.


```yaml
msix_config:
  display_name: app_links_example
  msix_version: 1.0.0.0
  protocol_activation: https, sample # Add the protocols to activate the app
  app_uri_handler_hosts: www.example.com, example.com # Add the app uri handler hosts. You can't use patterns here.
```

## Testing
For custom scheme, open your browser and type in your address bar:
```
sample://foo/#/book/hello-foo
sample://bar/#/book/hello-bar
```

For web-to-app, __outside__ of a browser, in an email for example:
```
https://www.example.com/#/book/hello-www-example
https://example.com/#/book/hello-example
```


## Custom scheme setup for registration (foo://)

For un-packaged apps or manual setup you can follow this setup. ⚠️ For custom scheme only!

On Windows, URL protocols are setup in the Windows registry.

This package won't do it for you.

Two options I know (there may be others obviously):
- copy the available code in the example project to get rid of another dependency.
- or use `win32_registry` package with the following code to register the URL protocol.

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

## Testing
Open your browser and type in your address bar:
```
sample://foo/#/book/hello-world2
```
