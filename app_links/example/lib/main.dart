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
//     -d "https://www.example.com/#/book/hello-world"
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
  late AppLinks _appLinks;

  @override
  void initState() {
    initDeepLinks();
    super.initState();
  }

  void initDeepLinks() async {
    _appLinks = AppLinks(
      onAppLink: (Uri uri, String stringUri) {
        print('onAppLink: $stringUri');
        openAppLink(uri);
      },
    );

    final appLink = await _appLinks.getInitialAppLink();
    if (appLink != null && appLink.hasFragment && appLink.fragment != '/') {
      print('getInitialAppLink: ${appLink.toString()}');
      openAppLink(appLink);
    }
  }

  void openAppLink(Uri uri) {
    _navigatorKey.currentState?.pushNamed(uri.fragment);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      initialRoute: "/",
      onGenerateRoute: (RouteSettings settings) {
        Widget routeWidget = defaultScreen();

        // Mimic web routing
        final routeName = settings.name;
        if (routeName != null) {
          if (routeName.startsWith('/book/')) {
            // Navigated to /book/:id
            routeWidget = customScreen(
              routeName.substring(routeName.indexOf('/book/')),
            );
          } else if (routeName == '/book') {
            // Navigated to /book without other parameters
            routeWidget = customScreen("None");
          }
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
      body: Center(child: const Text('''
              Launch an intent to get to the second screen.
              On web you can http://localhost:<port>/#/book/1 for example.
              ''')),
    );
  }

  Widget customScreen(String bookId) {
    return Scaffold(
      appBar: AppBar(title: const Text('Second Screen')),
      body: Center(child: Text('Opened with parameter: ' + bookId)),
    );
  }
}
