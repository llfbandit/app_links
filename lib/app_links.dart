import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef void OnAppLinkFunction(Uri uri);

class AppLinks {
  static const String _messagesChannel = 'com.llfbandit.app_links/messages';
  static const MethodChannel _channel = const MethodChannel(_messagesChannel);

  static const String _onAppLinkMethod = 'onAppLink';
  static const String _getInitialAppLinkMethod = 'getInitialAppLink';
  static const String _getLatestAppLinkMethod = 'getLatestAppLink';

  AppLinks({@required OnAppLinkFunction onAppLink}) : assert(onAppLink != null) {
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

  Future<Uri> getInitialAppLink() async {
    return Uri.tryParse(await _channel.invokeMethod(_getInitialAppLinkMethod));
  }

  Future<Uri> getLatestAppLink() async {
    return Uri.tryParse(await _channel.invokeMethod(_getLatestAppLinkMethod));
  }
}
