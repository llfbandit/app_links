import 'dart:async';

import 'package:app_links/src/app_links_platform_interface.dart';
import 'package:gtk/gtk.dart';

class AppLinksPluginLinux extends AppLinksPlatform {
  static void registerWith() {
    AppLinksPlatform.instance = AppLinksPluginLinux();
  }

  final _controller = StreamController<String>();
  final _uris = <String>[];
  GtkApplicationNotifier? _notifier;

  @override
  Future<Uri?> getInitialAppLink() async {
    _initNotifier();

    return getInitialAppLinkString().then(
      (value) => value != null ? Uri.parse(value) : null,
    );
  }

  @override
  Future<String?> getInitialAppLinkString() async {
    return _uris.isNotEmpty ? _uris.first : null;
  }

  @override
  Future<Uri?> getLatestAppLink() async {
    _initNotifier();

    return getLatestAppLinkString().then(
      (value) => value != null ? Uri.parse(value) : null,
    );
  }

  @override
  Future<String?> getLatestAppLinkString() async {
    _initNotifier();
    return _uris.isNotEmpty ? _uris.last : null;
  }

  @override
  Stream<String> get stringLinkStream {
    _initNotifier();
    return _controller.stream;
  }

  @override
  Stream<Uri> get uriLinkStream {
    _initNotifier();
    return _controller.stream.map(Uri.parse);
  }

  @override
  Stream<String> get allStringLinkStream {
    _initNotifier();
    return _controller.stream;
  }

  @override
  Stream<Uri> get allUriLinkStream {
    _initNotifier();
    return _controller.stream.map(Uri.parse);
  }

  void _initNotifier() {
    if (_notifier == null) {
      _notifier = GtkApplicationNotifier();
      _notifier?.addCommandLineListener((args) {
        if (args.isEmpty) {
          return;
        }
        final uri = args.first;
        _uris.add(uri);
        _controller.add(uri);
      });
    }
  }
}
