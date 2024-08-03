import 'dart:async';
import 'package:app_links_platform_interface/app_links_platform_interface.dart';

/// App links handler.
///
/// This class is a singleton and should be accessed using `AppLinks()`.
class AppLinks extends AppLinksPlatform {
  static final AppLinks _instance = AppLinks._();

  factory AppLinks() => _instance;

  // Override the uriLinkStream and stringLinkStream to return broadcast streams
  final _uriLinkStreamController = StreamController<Uri>.broadcast();
  final _stringLinkStreamController = StreamController<String>.broadcast();

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
    _ensureBroadcastStream(_stringLinkStreamController,
        AppLinksPlatform.instance.stringLinkStream);
    return _stringLinkStreamController.stream;
  }

  @override
  Stream<Uri> get uriLinkStream {
    _ensureBroadcastStream(
        _uriLinkStreamController, AppLinksPlatform.instance.uriLinkStream);
    return _uriLinkStreamController.stream;
  }

  // Helper method to ensure the stream is a broadcast stream
  void _ensureBroadcastStream<T>(
      StreamController<T> controller, Stream<T> stream) {
    if (!controller.hasListener) {
      stream.listen((event) {
        controller.add(event);
      });
    }
  }
}
