import 'dart:async';
import 'package:app_links_platform_interface/app_links_platform_interface.dart';

/// App links handler.
///
/// This class is a singleton and should be accessed using `AppLinks()`.
class AppLinks extends AppLinksPlatform {
  static final AppLinks _instance = AppLinks._();

  factory AppLinks() => _instance;

  AppLinks._();

  @override
  Future<Uri?> getInitialLink() {
    return AppLinksPlatform.instance.getInitialLink();
  }

  @override
  Future<String?> getInitialLinkString() {
    return AppLinksPlatform.instance.getInitialLinkString();
  }

  @override
  Future<Uri?> getLatestLink() {
    return AppLinksPlatform.instance.getLatestLink();
  }

  @override
  Future<String?> getLatestLinkString() {
    return AppLinksPlatform.instance.getLatestLinkString();
  }

  @override
  Stream<String> get stringLinkStream {
    return AppLinksPlatform.instance.stringLinkStream;
  }

  @override
  Stream<Uri> get uriLinkStream {
    return AppLinksPlatform.instance.uriLinkStream;
  }

  @override
  Future<void> get onlyAppLinks => AppLinksPlatform.instance.onlyAppLinks;
}
