import 'dart:async';

import 'package:app_links_platform_interface/app_links_platform_interface.dart';
import 'package:gtk/gtk.dart';

class AppLinksPluginLinux extends AppLinksPlatform {
  static void registerWith() {
    AppLinksPlatform.instance = AppLinksPluginLinux();
  }

  // Stop waiting if the app never sends its command line (missing setup).
  static const _startupTimeout = Duration(seconds: 1);

  StreamController<String>? _controller;
  GtkApplicationNotifier? _notifier;
  String? _initialLink;
  bool _initialLinkSent = false;
  String? _latestLink;
  final _startupReceived = Completer<void>();
  Future<void>? _startup;

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
        if (!_startupReceived.isCompleted) {
          _startupReceived.complete();
        }
      });
    }
  }

  // Wait for the launch command line, it arrives after the first listen.
  Future<void> _waitStartup() {
    _init();
    return _startup ??=
        _startupReceived.future.timeout(_startupTimeout, onTimeout: () {});
  }

  @override
  Future<Uri?> getInitialLink() async {
    await _waitStartup();

    if (_initialLink case final link?) {
      return Uri.tryParse(link);
    }
    return null;
  }

  @override
  Future<String?> getInitialLinkString() async {
    await _waitStartup();

    return _initialLink;
  }

  @override
  Future<Uri?> getLatestLink() async {
    await _waitStartup();

    if (_latestLink case final link?) {
      return Uri.tryParse(link);
    }
    return null;
  }

  @override
  Future<String?> getLatestLinkString() async {
    await _waitStartup();
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
