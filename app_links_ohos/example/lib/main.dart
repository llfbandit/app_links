import 'package:app_links_ohos/app_links_ohos.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _uriLink = 'Unknown';
  late AppLinksPluginOhos _appLinksOhosPlugin = AppLinksPluginOhos();

  @override
  void initState() {
    super.initState();
    _appLinksOhosPlugin.uriLinkStream.listen((uri) {
      setState(() {
        _uriLink = 'Received uri: $uri';
      });
    });

    _appLinksOhosPlugin.getInitialLinkString().then((uri) {
      setState(() {
        _uriLink = 'Received initial uri: $uri';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SizedBox.expand(
          child: Stack(
            children: [
              Align(alignment: Alignment.center, child: Text(_uriLink)),
              Positioned(
                  bottom: 50,
                  left: 32,
                  right: 32,
                  child: ElevatedButton(
                      onPressed: () {
                        _appLinksOhosPlugin?.getLatestLinkString().then((uri) {
                          setState(() {
                            _uriLink = 'Received latest uri: $uri';
                          });
                        });
                      },
                      child: Text('Fetch Lastest Uri'))),
            ],
          ),
        ),
      ),
    );
  }
}
