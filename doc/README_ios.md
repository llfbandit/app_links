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

## Notice

[Version 6.x.x](https://github.com/llfbandit/app_links/blob/master/doc/README_ios_6.md)

[Version 7.x.x](https://github.com/llfbandit/app_links/blob/master/doc/README_ios_7.md)