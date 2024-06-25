import 'dart:async';

import 'package:app_links_platform_interface/app_links_platform_interface.dart';
import 'package:gtk/gtk.dart';

class AppLinksPluginLinux extends AppLinksPlatform {
  static void registerWith() {
    AppLinksPlatform.instance = AppLinksPluginLinux();
  }

  late final StreamController<String> _controller;
  late final GtkApplicationNotifier _notifier;
  String? _initialLink;
  bool _initialLinkSent = false;
  String? _latestLink;

  AppLinksPluginLinux() {
    _controller = StreamController.broadcast()..onListen = _onListen;

    _notifier = GtkApplicationNotifier();
    _notifier.addCommandLineListener((args) {
      if (args.isNotEmpty) {
        _send(args.first);
      }
    });
  }

  @override
  Future<Uri?> getInitialLink() async {
    if (_initialLink case final link?) {
      return Uri.parse(link);
    }
    return null;
  }

  @override
  Future<String?> getInitialLinkString() async => _initialLink;

  @override
  Future<Uri?> getLatestLink() async {
    if (_latestLink case final link?) {
      return Uri.parse(link);
    }
    return null;
  }

  @override
  Future<String?> getLatestLinkString() async => _latestLink;

  @override
  Stream<String> get stringLinkStream => _controller.stream;

  @override
  Stream<Uri> get uriLinkStream => _controller.stream.map(Uri.parse);

  void _onListen() {
    if (!_initialLinkSent && _initialLink != null) {
      _initialLinkSent = true;
      _controller.add(_initialLink!);
    }
  }

  void _send(String uri) {
    if (uri.isNotEmpty) {
      _latestLink = uri;
      _initialLink ??= uri;

      if (_controller.hasListener) {
        _initialLinkSent = true;
        _controller.add(uri);
      }
    }
  }
}
