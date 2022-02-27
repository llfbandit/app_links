# app_links_example

Demonstrates how to use the app_links plugin.

## Test on Android

```sh
adb shell am start -a android.intent.action.VIEW \
  -d "https://www.example.com/#/book/hello-world"
```

## Test on iOS

```sh
/usr/bin/xcrun simctl openurl booted "app://www.example.com/#/book/hello-world"
```
