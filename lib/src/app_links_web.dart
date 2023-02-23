import 'dart:html';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:app_links/src/app_links_platform_interface.dart';

class AppLinksPluginWeb extends AppLinksPlatform {
  static void registerWith(Registrar registrar) {
    AppLinksPlatform.instance = AppLinksPluginWeb();
  }

  final _initialLink = window.location.href;

  @override
  Future<Uri?> getInitialAppLink() async {
    return Uri.parse(_initialLink);
  }

  @override
  Future<String?> getInitialAppLinkString() async {
    return _initialLink;
  }

  @override
  Future<Uri?> getLatestAppLink() async {
    return Uri.parse(_initialLink);
  }

  @override
  Future<String?> getLatestAppLinkString() async {
    return _initialLink;
  }

  @override
  Stream<String> get stringLinkStream => Stream.empty();

  @override
  Stream<Uri> get uriLinkStream => Stream.empty();
}
