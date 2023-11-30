import 'dart:async';

import 'package:app_links/src/app_links_platform_interface.dart';
import 'package:gtk/gtk.dart';

class AppLinksPluginLinux extends AppLinksPlatform {
  static void registerWith() {
    AppLinksPlatform.instance = AppLinksPluginLinux();
  }

  AppLinksPluginLinux() {
    _notifier = GtkApplicationNotifier();
    _notifier.addCommandLineListener((args) {
      if (args.isEmpty) {
        return;
      }
      final uri = args.first;
      _uris.add(uri);
      _controller.add(uri);
    });
  }

  final StreamController<String> _controller = StreamController<String>();
  final List<String> _uris = [];
  late final GtkApplicationNotifier _notifier;

  @override
  Future<Uri?> getInitialAppLink() async {
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
    return getLatestAppLinkString().then(
      (value) => value != null ? Uri.parse(value) : null,
    );
  }

  @override
  Future<String?> getLatestAppLinkString() async {
    return _uris.isNotEmpty ? _uris.last : null;
  }

  @override
  Stream<String> get stringLinkStream => _controller.stream;

  @override
  Stream<Uri> get uriLinkStream => _controller.stream.map(Uri.parse);

  @override
  Stream<String> get allStringLinkStream => _controller.stream;

  @override
  Stream<Uri> get allUriLinkStream => _controller.stream.map(Uri.parse);
}
