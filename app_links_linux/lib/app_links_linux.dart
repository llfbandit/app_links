import 'dart:async';

import 'package:app_links_platform_interface/app_links_platform_interface.dart';
import 'package:gtk/gtk.dart';

class AppLinksPluginLinux extends AppLinksPlatform {
  static void registerWith() {
    AppLinksPlatform.instance = AppLinksPluginLinux();
  }

  StreamController<String>? _controller;
  GtkApplicationNotifier? _notifier;
  String? _initialLink;
  bool _initialLinkSent = false;
  String? _latestLink;

  // Initialize the plugin.
  // This can't be done in the constructor because
  // binary messenger hasn't been initialized at this stage.
  void _init() {
    _controller ??= StreamController.broadcast()..onListen = _onListen;

    if (_notifier == null) {
      _notifier = GtkApplicationNotifier();
      _notifier?.addCommandLineListener((args) {
        if (args.isNotEmpty) {
          _send(args.first);
        }
      });
    }
  }

  @override
  Future<Uri?> getInitialLink() async {
    _init();

    if (_initialLink case final link?) {
      return Uri.tryParse(link);
    }
    return null;
  }

  @override
  Future<String?> getInitialLinkString() async {
    _init();

    return _initialLink;
  }

  @override
  Future<Uri?> getLatestLink() async {
    _init();

    if (_latestLink case final link?) {
      return Uri.tryParse(link);
    }
    return null;
  }

  @override
  Future<String?> getLatestLinkString() async {
    _init();
    return _latestLink;
  }

  @override
  Stream<String> get stringLinkStream {
    _init();
    return _controller!.stream;
  }

  @override
  Stream<Uri> get uriLinkStream {
    _init();

    return _controller!.stream
        .where((uri) => Uri.tryParse(uri) != null)
        .map(Uri.parse);
  }

  void _onListen() {
    if (!_initialLinkSent && _initialLink != null) {
      _initialLinkSent = true;
      _controller?.add(_initialLink!);
    }
  }

  void _send(String uri) {
    if (uri.isNotEmpty) {
      _latestLink = uri;
      _initialLink ??= uri;

      if (_controller?.hasListener ?? false) {
        _initialLinkSent = true;
        _controller?.add(uri);
      }
    }
  }
}
