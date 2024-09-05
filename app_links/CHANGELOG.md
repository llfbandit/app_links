## 6.3.2
* fix(windows): Revert main.cpp modifications.

## 6.3.1
* fix(Windows): Open scheme detection to wider range.

## 6.3.0
* feat(Windows): Handle activation from packaged app.
  * This means you can either use https://, sample://, ... protocols with related hosts.
  * More info in [Windows setup docs](https://github.com/llfbandit/app_links/blob/master/doc/README_windows.md).
* ~~feat(Windows): No more `main.cpp` modification required!~~
  * ~~⚠️ Please, remove it if you're coming from an update.~~
* ~~chore: Remove previous setup `main.cpp` from example.~~
* chore: docs update.

## 6.2.1
* fix(Android): Add ProGuard rules.
* fix(Windows): Send link if only there's 1 argument with a scheme.
* chore(Android): Upgrade to latest AGP 8 and compileSdk 34.
* chore: Update dependencies to latest.
* chore(Android): Update example setup.
* chore(iOS): Set minimum OS version to 12.0.
* chore: Set minimum Flutter version to 3.19.0.

## 6.2.0
* feat: Allow multiple listeners.

## 6.1.4
* fix: Channel method names.

## 6.1.3
* chore: Update dependency app_links_platform_interface to 2.0.0+ because of breaking changes.

## 6.1.2
* fix: WASM compilation by re-introducing partial federated structure.
* fix: Platforms with dependencies are now isolated in a dedicated package.
* chore: Makes example project compatible with WASM compilation.

## 6.1.1
* fix: README.md doc links.

## 6.1.0
* feat(macOS): Handle universal links. See README.md for setup.
* chore: Cleanup README.md.

## 6.0.2
* __Breaking__ iOs: Revert behaviour change introduced in 5.0.0.  
There's no point to use Flutter/go_router deep linking feature with this plugin.  
For more info: https://docs.flutter.dev/ui/navigation/deep-linking.

## 6.0.1
* fix(linux): Initialization process.

## 6.0.0
* __Breaking__: Replaced `allStringLinkStream` by `stringLinkStream` and `allUriLinkStream` by `uriLinkStream`.
* __Breaking__: Removed `allStringLinkStream`, `allUriLinkStream`.  
The changes above should clarify the usage of the plugin. Both streams handle initial and further links.
* __Breaking__: Renamed `getInitialApp*` and `getLatestApp*` methods to `getInitialLink*` and `getLatestLink*`.
* chore(QoL): The plugin should not send again initial link when restarting, reloading the app or subscribing again to the stream.
* fix(macOS): Handle link from cold state (i.e. terminated).
* fix(linux): Refactor code to not store all URIs.
* fix(linux): Stream is not filled anymore when there's no listener.

## 5.0.0
* __Breaking__ iOs: Application Delegate now returns `true` for both Universal Links and Custom URL schemes.
If you have other packages which could conflict with it, report to the README.md for custom handling.
This change is motived by the basic deep linking provided by Flutter and the fact that there is now a workaround for such cases.

## 4.0.1
* fix(Android): Reworked capture by explicitly discarding `ACTION_SEND*` and let other basic actions succeed (NFC for example).

## 4.0.0
* __Breaking__ fix(Windows): Updated setup to be more resilient to Flutter changes. Can work with v3 but mandatory from Flutter 3.19 with new projects.
* __Breaking__ chore(Android): Remove capture of ACTION_SEND to avoid conflicts with others packages.
* __Breaking__ chore(web): move from dart:html to package:web to allow WASM compilation.
* chore: Updated setup for iOS to handle result while other packages are around.

## 3.5.1
* chore: Add privacy manifest to iOS and macOS platforms.

## 3.5.0
* feat: Add linux support.
* fix(macOS): Flutter 3.16 broke macOS behaviour.
* fix(iOS): Allow to call AppLinks plugin from outside for custom AppDelegate or SceneDelegate.
* chore: README update.

## 3.4.5
* fix(Android): Code improvements and correctly skip event firing when comming from history.

## 3.4.4
* fix: Add missing `allUriLinkStream` and `allStringLinkStream` methods web platform.

## 3.4.3
* chore: Add support for Flutter 3.10.
* chore(Android): Add support for AGP 8.0.
* fix(iOS): Code improvements (Thanks to [michalsrutek](https://github.com/michalsrutek))

## 3.4.2
* chore: Merge platform interface in main project.

## 3.4.1
* fix(macOS): wrong plugin definition resulting in build errors.

## 3.4.0
* feat(Android): Allow ACTION_SEND with Intent.EXTRA_STREAM, Intent.EXTRA_TEXT. (thanks to [espresso3389](https://github.com/espresso3389))
* feat: Add single stream for all links (See README for updated usage).
* chore: Unify platform packages in app_links main package (__Windows #include directive must be updated!__).
* chore: Remove duplicated code in windows implementation.

## 3.3.0
* feat: Triggering Firebase dynamic links for Android >= 12 (behaviour changes). (thanks to [AdrienAudouard](https://github.com/AdrienAudouard))

## 3.2.0
* feat: Add macOS support.

## 3.1.0
* feat: Add Windows support.

## 3.0.2
* fix: iOS `application` callbacks do not return `true` anymore.

## 3.0.1
* core: Improve Android code.

## 3.0.0
* core: __Breaking__ API changed to use stream instead of callback.
* fix: Consistent behaviour between iOS & Android with (deffered) stream usage (for onAppLink vs. getInitialLink "duplicated" links).
* fix: remove example splashscreen deprecation.

## 2.2.2
* core: Add linter.
* fix: Get rid of Android LocalBroadcastReceiver deprecation (removed dependency & import...).

## 2.2.1
* fix: Duplicated iOS call when app is on terminated status.
* fix: iOS `application` callback does not return `true` anymore.
* fix: Get rid of Android LocalBroadcastReceiver deprecation.
* core: Updated dependencies.

## 2.2.0
* Add web support. (getInitialAppLink() only).

## 2.1.0
* Breaking: String uri added on `onAppLink` for custom handling like uppercased uri.
* Feat: `getInitialAppLinkString` and `getLatestAppLinkString` added to reflect the above change.

## 2.0.0+1
* Minimal sample added (Thanks to @JamesCullum).

## 2.0.0
* Add null safety support.

## 1.0.0
* Same as 0.2.0.
* No known issue. Bumping to 1.0 to be prepared for null safety version.

## 0.2.0
* Add configurations in example.

## 0.1.0+2
* Update README.md.

## 0.1.0+1
* Add documentation.
* Format dart source code.

## 0.1.0
* Initial release.
* Android App Links, Deep Links, iOS Universal Links and Custom URL schemes.
