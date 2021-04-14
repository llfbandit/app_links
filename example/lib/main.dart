import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

///////////////////////////////////////////////////////////////////////////////
/// Please make sure to follow the setup instructions below
///
/// Please take a look at:
/// - example/android/app/main/AndroidManifest.xml for Android.
///
/// - example/ios/Runner/Runner.entitlements for Universal Link sample.
/// - example/ios/Runner/Info.plist for Custom URL scheme sample.
///
/// You can launch an intent on an Android Emulator like this:
///    adb shell am start -a android.intent.action.VIEW \
//     -c android.intent.category.BROWSABLE \
//     -d "http://example.com/book/hello-world"
///////////////////////////////////////////////////////////////////////////////

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    initDeepLinks();
    super.initState();
  }

  void initDeepLinks() async {
    final _appLinks = AppLinks(
      onAppLink: (Uri uri) {
        openAppLink(uri);
      },
    );

    final lastAppLinkUri = await _appLinks.getLatestAppLink();
    if (lastAppLinkUri != null) {
      openAppLink(lastAppLinkUri);
    }
  }

  void openAppLink(Uri uri) {
    _navigatorKey.currentState
        .pushNamed(uri.path, arguments: uri.queryParameters);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      initialRoute: "/",
      onGenerateRoute: (RouteSettings settings) {
        Widget routeWidget = defaultScreen();

        // Parse route to extract dynamic parameters
        var uri = Uri.parse(settings.name);
        var firstLevel =
            uri.pathSegments.length > 0 ? uri.pathSegments.first : "";
        switch(firstLevel) {
          case "book":
            if (uri.pathSegments.length > 1) {
              // Navigated to /book/:id
              routeWidget = customScreen(uri.pathSegments[1]);
            } else {
              // Navigated to /book without other parameters
              routeWidget = customScreen("None");
            }
            break;
        }

        return MaterialPageRoute(
          builder: (context) => routeWidget,
          settings: settings,
          fullscreenDialog: true,
        );
      },
    );
  }

  Widget defaultScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('Default Screen')),
      body: Center(child: const Text('Launch an intent to get to the second screen')),
    );
  }

  Widget customScreen(String bookId) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Screen')),
      body: Center(child: Text('Opened with parameter: ' + bookId)),
    );
  }
}
