# app_links

Android App Links, Deep Links, iOs Universal Links and Custom URL schemes handler.

This plugin allows you to:
- catch HTTPS URLs to open your app instead of the browser (App Links / Universal Links).
- catch custom schemes to open your app (Deep Links / Custom URL schemes).

## Getting Started

Before using the plugin, you'll need to setup each platforms you target.

### Android

- App Links: [Documentation](https://developer.android.com/training/app-links/deep-linking)
- Deep Links: [Documentation](https://developer.android.com/training/app-links/deep-linking)

### iOs

- Universal Links: [Documentation](https://developer.apple.com/documentation/safariservices/supporting_associated_domains)
- Custom URL schemes: [Documentation](https://developer.apple.com/documentation/xcode/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app)

### AppLinks
```dart
    final _appLinks = AppLinks(
        // Called when a new uri has been redirected to the app
        onAppLink: (Uri uri) {
            // Do something (navigation, ...)
        },
    );

    // Get the initial/first link.
    // This is also useful when app was terminated (i.e. not started)
    final uri = await _appLinks.getInitialUri();

    ...

    // Maybe later. Get the latest link.
    final uri = await _appLinks.getLatestLink();
```

## Tests
The following commands will let you simply test the links

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
