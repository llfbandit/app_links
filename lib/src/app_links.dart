import 'dart:async';
import 'package:app_links/src/app_links_platform_interface.dart';

class AppLinks extends AppLinksPlatform {
  /// Android App Links, Deep Links,
  /// iOS Universal Links and Custom URL schemes handler.
  static final AppLinks _instance = AppLinks._();

  factory AppLinks() => _instance;

  AppLinks._();

  @override
  Future<Uri?> getInitialLink() {
    return AppLinksPlatform.instance.getInitialLink();
  }

  @override
  Future<String?> getInitialLinkString() async {
    return AppLinksPlatform.instance.getInitialLinkString();
  }

  @override
  Future<Uri?> getLatestLink() async {
    return AppLinksPlatform.instance.getLatestLink();
  }

  @override
  Future<String?> getLatestLinkString() async {
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
}
