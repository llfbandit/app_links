# Android

- App Links: [Documentation](https://developer.android.com/training/app-links/verify-android-applinks)
- Deep Links: [Documentation](https://developer.android.com/training/app-links/deep-linking)

## SETUP

In AndroidManifest.xml

  Don't use go_router deep linking feature: https://docs.flutter.dev/cookbook/navigation/set-up-app-links#2-modify-androidmanifest-xml
  by removing this:
  ```xml
  <!-- <meta-data android:name="flutter_deeplinking_enabled" android:value="true" /> -->
  ```

```xml
<!-- App Link sample -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
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

### ProGuard rules
When using ProGuard, those additional rules are added  
https://github.com/llfbandit/app_links/blob/master/app_links/android/proguard.txt

# Testing

```sh
adb shell am start -a android.intent.action.VIEW \
  -d "sample://open.my.app/#/book/hello-world"
```

When using ADB for testing, all special characters have to be escaped. [More info](https://stackoverflow.com/a/35645448/5498788).

For App Links, you can also test it from Android Studio: [Documentation](https://developer.android.com/studio/write/app-link-indexing#testindent).

Android 13 and beyond:
- While in development, you may need to manually activate your links.
- Go to your app info/settings: Open by default > Add link > (your links should be already filled).