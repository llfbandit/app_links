import 'dart:async';
import 'package:app_links_platform_interface/app_links_platform_interface.dart';

/// App links handler.
///
/// This class is a singleton and should be accessed using `AppLinks()`.
class AppLinks extends AppLinksPlatform {
  static final AppLinks _instance = AppLinks._();

  factory AppLinks() => _instance;

  AppLinks._();

  StreamController<String>? _stringStreamController;
  StreamController<Uri>? _uriStreamController;

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
    if (_stringStreamController == null) {
      _stringStreamController = StreamController.broadcast();

      _initController<String>(
        _stringStreamController!,
        AppLinksPlatform.instance.stringLinkStream,
        onCancel: () => _stringStreamController = null,
      );
    }

    return _stringStreamController!.stream;
  }

  @override
  Stream<Uri> get uriLinkStream {
    if (_uriStreamController == null) {
      _uriStreamController = StreamController.broadcast();

      _initController<Uri>(
        _uriStreamController!,
        AppLinksPlatform.instance.uriLinkStream,
        onCancel: () => _uriStreamController = null,
      );
    }

    return _uriStreamController!.stream;
  }

  void _initController<T>(
    StreamController<T> controller,
    Stream<T> stream, {
    required void Function() onCancel,
  }) {
    final subscription = stream.listen(
      controller.add,
      onError: controller.addError,
    );

    // Broadcast controller doesn't support pause/resume
    //
    // Forward cancel event when there's no more listeners
    // and dispose controller
    controller.onCancel = () async {
      await subscription.cancel();
      await controller.close();
      onCancel();
    };
  }
}
