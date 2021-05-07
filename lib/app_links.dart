import 'dart:async';

import 'package:flutter/services.dart';

/// Callback when your app is woke up by an incoming link
/// [uri] and [stringUri] are same value.
/// [stringUri] is available for custom handling like uppercased uri.
///
typedef void OnAppLinkFunction(Uri uri, String stringUri);

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
  AppLinks({required OnAppLinkFunction onAppLink}) {
    _channel.setMethodCallHandler(
      (call) {
        switch (call.method) {
          case _onAppLinkMethod:
            if (call.arguments != null) {
              final uri = call.arguments.toString();
              onAppLink(Uri.parse(uri), uri);
            }
        }

        return Future.value();
      },
    );
  }

  /// Gets the initial / first link
  /// returns [Uri] or [null]
  Future<Uri?> getInitialAppLink() async {
    final result = await getInitialAppLinkString();
    if (result == null) return null;

    return Uri.tryParse(result);
  }

  /// Gets the initial / first link
  /// returns [Uri] as String or [null]
  Future<String?> getInitialAppLinkString() async {
    return await _channel.invokeMethod(_getInitialAppLinkMethod);
  }

  /// Gets the latest link
  /// returns [Uri] or [null]
  Future<Uri?> getLatestAppLink() async {
    final result = await getLatestAppLinkString();
    if (result == null) return null;

    return Uri.tryParse(result);
  }

  /// Gets the latest link
  /// returns [Uri] as String or [null]
  Future<String?> getLatestAppLinkString() async {
    return await _channel.invokeMethod(_getLatestAppLinkMethod);
  }
}
