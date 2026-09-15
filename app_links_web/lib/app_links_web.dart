import 'dart:async';

import 'package:web/web.dart' as web;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:app_links_platform_interface/app_links_platform_interface.dart';

class AppLinksPluginWeb extends AppLinksPlatform {
  static void registerWith(Registrar registrar) {
    AppLinksPlatform.instance = AppLinksPluginWeb();
  }

  final _initialLink = web.window.location.href;

  // Keep the streams open and send the launch link only once,
  // like the broadcast streams of the other platforms.
  late final _stringController = _createController<String>(_initialLink);
  late final _uriController = _createController<Uri>(Uri.parse(_initialLink));

  @override
  Future<Uri?> getInitialLink() async => Uri.parse(_initialLink);

  @override
  Future<String?> getInitialLinkString() async => _initialLink;

  @override
  Future<Uri?> getLatestLink() async => Uri.parse(_initialLink);

  @override
  Future<String?> getLatestLinkString() async => _initialLink;

  @override
  Stream<Uri> get uriLinkStream => _uriController.stream;

  @override
  Stream<String> get stringLinkStream => _stringController.stream;

  StreamController<T> _createController<T>(T initialLink) {
    var sent = false;
    late final StreamController<T> controller;

    controller = StreamController<T>.broadcast(
      onListen: () {
        if (sent) return;
        sent = true;
        controller.add(initialLink);
      },
    );

    return controller;
  }
}
