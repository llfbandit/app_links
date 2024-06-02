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

## Deploy Website And Configure Native App
this guide will show you how to deploy a website and configure your native app to handle app links, deep links, and custom URL schemes.

### WebSite Configuration
1. use [this template](https://github.com/melodysdreamj/app_link_web_template), create new repository in your github account.
2. clone the repository to your local computer.
3. go to [cloudflare](https://dash.cloudflare.com/), login and select Workers & Pages > Overview > Create application > Pages Tap >
   Connect to Git > select the repository you just created. > Begin setup > Save and Deploy.
4. open cloned project, go to index.html file, replace the content with the following code.
- [your_scheme] -> your app scheme name. ex) myapp
- [your.app.package] -> your app package name. ex) com.example.myapp

#### 1.android part setting in web site
5. get sha-256 fingerprint from your app
- if you want get **debug fingerprint on mac**, enter the following command in terminal.
    - if your computer not installed java, please install it first.
        - go to [install page](https://www.oracle.com/java/technologies/javase/jdk16-archive-downloads.html), download and install [macOS x64 Installer.]
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```
- if you want get **debug fingerprint on windows**, enter the following command in terminal.
    - if your computer not installed java, please install it first.
        - go to [install page](https://www.oracle.com/java/technologies/javase/jdk16-archive-downloads.html), download and install [Windows x64 Installer.]
        - go to settings > system > about > advanced system settings > environment variables > system variables > path > edit > new > paste the path.
            - ex) C:\Program Files\Java\jdk-16\bin
        - create new android project and run once to generate the debug.keystore file.
```bash
keytool -list -v -keystore "C:\Users\[UserName]\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```
- if you want get **release fingerprint**, create appbundle and upload to google play store, then you can find the sha-256 fingerprint in app signing section in google play console.
```bash
flutter build appbundle
```
6. replace [11:22:33:44:55:66...] in [.well-known/assetlinks.json] file with the sha-256 fingerprint you just got.
7. replace [your.package.name] in [.well-known/assetlinks.json] file with your app package name. ex) com.example.myapp

#### 2. ios part setting in web site
8. replace [apple team id] in [.well-known/apple-app-site-association] file with your apple team id.
    - you can find your apple team id membership section in [apple developer account](https://developer.apple.com/account/).
9. replace [[app bundle id]] in [.well-known/apple-app-site-association] file with your app package name. ex) com.example.myapp


10. commit and push to github for update cloudflare pages.


### Android Configuration

1. add the app link and deep link code inside .MainActivity activity in android/app/src/main/AndroidManifest.xml file.
- replace [your_scheme] with your app scheme name. ex) myapp
- replace [your.app.package] with your app package name. ex) com.example.myapp
- replace [your.web.site] with your web site url that you created in step 5.
```xml
<!-- App Link -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="http" android:host="[your.web.site]" />
    <data android:scheme="https" android:host="[your.web.site]" />
</intent-filter>

<!-- Deep Link -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <!-- Add optional android:host to distinguish your app
         from others in case of conflicting scheme name -->
    <data android:scheme="[your_scheme]" android:host="[your.app.package]" />
    <!-- <data android:scheme="sample" /> -->
</intent-filter>
```

### iOS Configuration
1. open xcode in /ios/Runner.xcworkspace, go to Runner > Info > URL Types > add new URL Type. > add URL Schemes with your app scheme name. ex) sample
2. go to Signing & Capabilities > + Capability > Associated Domains > add new Associated Domain. > add your web site url with applinks prefix. ex) applinks:your.web.site
    * Warning
        * when write applinks prefix, do not add https:// prefix. ex) applinks:your.web.site
        * do not add / at the end of the url. ex) applinks:your.web.site

### MacOS Configuration
1. open xcode in /macos/Runner.xcworkspace, go to Runner > Info > URL Types > add new URL Type. > add URL Schemes with your app scheme name. ex) sample
2. go to Signing & Capabilities > + Capability > Associated Domains > add new Associated Domain. > add your web site url with applinks prefix. ex) applinks:your.web.site
    * Warning: when write applinks prefix, do not add https:// prefix. ex) applinks:your.web.site
    * do not add / at the end of the url. ex) applinks:your.web.site


