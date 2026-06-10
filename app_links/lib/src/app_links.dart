import 'dart:async';
import 'package:app_links_platform_interface/app_links_platform_interface.dart';

/// App links handler.
///
/// This class is a singleton and should be accessed using `AppLinks()`.
class AppLinks {
  static final AppLinks _instance = AppLinks._();

  factory AppLinks() => _instance;

  AppLinks._();

  StreamController<String>? _stringStreamController;
  StreamController<Uri>? _uriStreamController;

  Future<Uri?> getInitialLink() {
    return AppLinksPlatform.instance.getInitialLink();
  }

  Future<String?> getInitialLinkString() {
    return AppLinksPlatform.instance.getInitialLinkString();
  }

  Future<Uri?> getLatestLink() {
    return AppLinksPlatform.instance.getLatestLink();
  }

  Future<String?> getLatestLinkString() {
    return AppLinksPlatform.instance.getLatestLinkString();
  }

  Stream<String> get stringLinkStream {
    _stringStreamController ??= _createController(
      AppLinksPlatform.instance.stringLinkStream,
      onSourceDone: () => _stringStreamController = null,
    );
    return _stringStreamController!.stream;
  }

  Stream<Uri> get uriLinkStream {
    _uriStreamController ??= _createController(
      AppLinksPlatform.instance.uriLinkStream,
      onSourceDone: () => _uriStreamController = null,
    );
    return _uriStreamController!.stream;
  }

  StreamController<T> _createController<T>(
    Stream<T> source, {
    required void Function() onSourceDone,
  }) {
    StreamSubscription<T>? subscription;
    late final StreamController<T> controller;

    controller = StreamController<T>.broadcast(
      onListen: () {
        subscription = source.listen(
          controller.add,
          onError: controller.addError,
          onDone: () {
            subscription = null;
            controller.close();
            onSourceDone();
          },
        );
      },
      onCancel: () async {
        await subscription?.cancel();
        subscription = null;
      },
    );

    return controller;
  }
}
