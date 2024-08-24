# Windows

## Recommended setup (both custom scheme and web-to-app)
⚠️ By using this method, activation is only available on a packaged app. This won't work when debugging.

By using [msix](https://pub.dev/packages/msix), it will create the required manifest to register the protocols.

Note: As Flutter apps are win32 type apps, activation feature is only available from a manifest.

This method also provides, for free, a seamless way to cleanup the registrations when uninstalling the app.

Note: `app_uri_handler_hosts` parameter is only used for web-to-app feature (https://).
When registering a custom scheme, only the scheme matters.


```yaml
msix_config:
  display_name: app_links_example
  msix_version: 1.0.0.0
  protocol_activation: https, sample # Add the protocols to activate the app
  app_uri_handler_hosts: www.example.com, example.com # Add the app uri handler hosts. You can't use patterns here.
```

## Testing
For custom scheme, open your browser and type in your address bar:
```
sample://foo/#/book/hello-foo
sample://bar/#/book/hello-bar
```

For web-to-app, __outside__ of a browser, in an email for example:
```
https://www.example.com/#/book/hello-www-example
https://example.com/#/book/hello-example
```


## Custom scheme setup (foo://)

For un-packaged apps or manual setup you can follow this setup. ⚠️ For custom scheme only!

On Windows, URL protocols are setup in the Windows registry.

This package won't do it for you.

Two options I know (there may be others obviously):
- copy the available code in the example project to get rid of another dependency.
- or use `win32_registry` package with the following code to register the URL protocol.

```dart
Future<void> register(String scheme) async {
  String appPath = Platform.resolvedExecutable;

  String protocolRegKey = 'Software\\Classes\\$scheme';
  RegistryValue protocolRegValue = const RegistryValue(
    'URL Protocol',
    RegistryValueType.string,
    '',
  );
  String protocolCmdRegKey = 'shell\\open\\command';
  RegistryValue protocolCmdRegValue = RegistryValue(
    '',
    RegistryValueType.string,
    '"$appPath" "%1"',
  );

  final regKey = Registry.currentUser.createKey(protocolRegKey);
  regKey.createValue(protocolRegValue);
  regKey.createKey(protocolCmdRegKey).createValue(protocolCmdRegValue);
}
```

## Testing
Open your browser and type in your address bar:
```
sample://foo/#/book/hello-world2
```
