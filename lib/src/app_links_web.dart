import 'package:web/web.dart' as web;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:app_links/src/app_links_platform_interface.dart';

class AppLinksPluginWeb extends AppLinksPlatform {
  static void registerWith(Registrar registrar) {
    AppLinksPlatform.instance = AppLinksPluginWeb();
  }

  final _initialLink = web.window.location.href;

  @override
  Future<Uri?> getInitialLink() async => Uri.parse(_initialLink);

  @override
  Future<String?> getInitialLinkString() async => _initialLink;

  @override
  Future<Uri?> getLatestLink() async => Uri.parse(_initialLink);

  @override
  Future<String?> getLatestLinkString() async => _initialLink;

  @override
  Stream<Uri> get uriLinkStream => Stream.value(Uri.parse(_initialLink));

  @override
  Stream<String> get stringLinkStream => Stream.value(_initialLink);
}
