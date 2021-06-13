import 'package:flutter/services.dart';
import 'package:app_links_platform_interface/app_links_platform_interface.dart';

class MethodChannelAppLinks extends AppLinksPlatform {
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

  void onAppLink({required OnAppLinkFunction onAppLink}) {
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

  Future<Uri?> getInitialAppLink() async {
    final result = await getInitialAppLinkString();
    if (result == null) return null;

    return Uri.tryParse(result);
  }

  Future<String?> getInitialAppLinkString() {
    return _channel.invokeMethod(_getInitialAppLinkMethod);
  }

  Future<Uri?> getLatestAppLink() async {
    final result = await getLatestAppLinkString();
    if (result == null) return null;

    return Uri.tryParse(result);
  }

  Future<String?> getLatestAppLinkString() {
    return _channel.invokeMethod(_getLatestAppLinkMethod);
  }
}
