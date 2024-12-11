import 'dart:async';

import 'package:app_links_platform_interface/app_links_platform_interface.dart';
import 'package:flutter/services.dart';


/// This plugin is based on version oh-3.22.3
/// [oh-3.22.3](https://gitee.com/harmonycommando_flutter/flutter/tree/oh-3.22.3/)
///
/// About testing Ohos Deep Link:
/// You can use the Harmony-provided aa tool for testing. Specific steps are as follows:
/// [aa Tool Documentation](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V13/aa-tool-V13)
/// ```shell
/// hdc shell aa start -U myscheme://www.test.com:8080/path
/// ```
class AppLinksPluginOhos extends AppLinksPlatform {
  static void registerWith() {
    AppLinksPlatform.instance = AppLinksPluginOhos();
  }

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
}
