import 'dart:async';

import 'package:flutter/services.dart';
import 'package:app_links_platform_interface/app_links_platform_interface.dart';

class MethodChannelAppLinks extends AppLinksPlatform {
  /// Channel names
  static const String _messagesChannel = 'com.llfbandit.app_links/messages';
  static const String _eventsChannel = 'com.llfbandit.app_links/events';

  /// Channel handlers
  static const _method = MethodChannel(_messagesChannel);
  static const _event = EventChannel(_eventsChannel);

  /// [getInitialAppLink] method call name
  static const String _getInitialAppLinkMethod = 'getInitialAppLink';

  /// [getLatestAppLink] method call name
  static const String _getLatestAppLinkMethod = 'getLatestAppLink';

  @override
  Future<Uri?> getInitialAppLink() async {
    final result = await getInitialAppLinkString();
    return (result != null) ? Uri.tryParse(result) : null;
  }

  @override
  Future<String?> getInitialAppLinkString() async {
    final link = await _method.invokeMethod(_getInitialAppLinkMethod);
    return link.isNotEmpty ? link : null;
  }

  @override
  Future<Uri?> getLatestAppLink() async {
    final result = await getLatestAppLinkString();
    return (result != null) ? Uri.tryParse(result) : null;
  }

  @override
  Future<String?> getLatestAppLinkString() async {
    final link = await _method.invokeMethod(_getLatestAppLinkMethod);
    return link.isNotEmpty ? link : null;
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
}
