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
