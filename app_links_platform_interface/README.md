# app_links_platform_interface

A common platform interface for the [app_links](https://pub.dev/packages/app_links) plugin.

This interface allows platform-specific implementations of the app_links plugin, as well as the plugin itself, to ensure they are supporting the same interface.

## Usage

To implement a new platform-specific implementation of app_links, extend AppLinksPlatform with an implementation that performs the platform-specific behavior, and when you register your plugin, set the default AppLinksPlatform by calling AppLinksPlatform.instance = MyPlatformAppLinks().
