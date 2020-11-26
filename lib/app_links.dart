import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Callback when your app is woke up by an incoming link
///
typedef void OnAppLinkFunction(Uri uri);

/// Android App Links, Deep Links,
/// iOs Universal Links and Custom URL schemes handler
class AppLinks {
  /// Method channel name
  static const String _messagesChannel = 'com.llfbandit.app_links/messages';

  /// Channel handler
  static const MethodChannel _channel = const MethodChannel(_messagesChannel);

  /// List of methods called by [MethodChannel]
  ///
  /// Callback when your app is woke up by an incoming link
  static const String _onAppLinkMethod = 'onAppLink';

  /// [getInitialAppLink] method call name
  static const String _getInitialAppLinkMethod = 'getInitialAppLink';

  /// [getLatestAppLink] method call name
  static const String _getLatestAppLinkMethod = 'getLatestAppLink';

  /// Constructor
  /// You must provide a non-null [onAppLink] callback.
  AppLinks({@required OnAppLinkFunction onAppLink})
      : assert(onAppLink != null) {
    _channel.setMethodCallHandler(
      (call) {
        switch (call.method) {
          case _onAppLinkMethod:
            if (call.arguments != null) {
              onAppLink(Uri.tryParse(call.arguments.toString()));
            }
        }

        return Future.value();
      },
    );
  }

  /// Gets the initial / first link
  /// returns [Uri] or [null]
  Future<Uri> getInitialAppLink() async {
    final result = await _channel.invokeMethod(_getInitialAppLinkMethod);
    if (result == null) return null;

    return Uri.tryParse(result);
  }

  /// Gets the latest link
  /// returns [Uri] or [null]
  Future<Uri> getLatestAppLink() async {
    final result = await _channel.invokeMethod(_getLatestAppLinkMethod);
    if (result == null) return null;

    return Uri.tryParse(result);
  }
}
