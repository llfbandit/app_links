import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'app_links_platform_interface.dart';

class AppLinksMethodChannel extends AppLinksPlatform {
  /// Channel handlers
  final _method = const MethodChannel('com.llfbandit.app_links/messages');
  final _event = const EventChannel('com.llfbandit.app_links/events');

  @override
  Future<Uri?> getInitialLink() async {
    final result = await getInitialLinkString();
    return result != null ? Uri.tryParse(result) : null;
  }

  @override
  Future<String?> getInitialLinkString() async {
    final link = await _method.invokeMethod<String?>('getInitialLink');
    return link != null && link.isNotEmpty ? link : null;
  }

  @override
  Future<Uri?> getLatestLink() async {
    final result = await getLatestLinkString();
    return result != null ? Uri.tryParse(result) : null;
  }

  @override
  Future<String?> getLatestLinkString() async {
    final link = await _method.invokeMethod<String?>('getLatestLink');
    return link != null && link.isNotEmpty ? link : null;
  }

  @override
  Stream<String> get stringLinkStream => _event
      .receiveBroadcastStream()
      .where((link) => link != null && link.isNotEmpty)
      .map<String>((dynamic link) => link as String);

  @override
  Stream<Uri> get uriLinkStream {
    return stringLinkStream.transform<Uri>(
      StreamTransformer<String, Uri>.fromHandlers(
        handleData: (String uri, EventSink<Uri> sink) {
          sink.add(Uri.parse(uri));
        },
      ),
    );
  }

  @override
  Future<void> get onlyAppLinks async {
    if (Platform.isAndroid || Platform.isIOS) {
      await _method.invokeMethod('onlyAppLinks');
      return;
    }
  }
}
