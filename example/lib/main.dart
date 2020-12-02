import 'package:flutter/material.dart';

///////////////////////////////////////////////////////////////////////////////
/// This example does nothing.
///
/// Please take a look at:
/// - example/android/app/main/AndroidManifest.xml for Android.
///
/// - example/ios/Runner/Runner.entitlements for Universal Link sample.
/// - example/ios/Runner/Info.plist for Custom URL scheme sample.
///////////////////////////////////////////////////////////////////////////////

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(child: Text('Foo')),
      ),
    );
  }
}
