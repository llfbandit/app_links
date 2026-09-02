# Linux

Linux supports custom schemes (`sample://`). There is no web-to-app (`https://`) equivalent.

## Setup

Make your app a single instance, so a link opened while it runs goes to the running instance.

Apply these 3 changes to `linux/runner/my_application.cc` (`linux/my_application.cc` in older projects).

1. In `my_application_new`, replace the `G_APPLICATION_NON_UNIQUE` flag with:
```cpp
G_APPLICATION_HANDLES_COMMAND_LINE | G_APPLICATION_HANDLES_OPEN
```

2. At the start of `my_application_activate`, show the existing window instead of opening a new one:
```cpp
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);

  GList* windows = gtk_application_get_windows(GTK_APPLICATION(application));
  if (windows) {
    gtk_window_present(GTK_WINDOW(windows->data));
    return;
  }

  ...
```

3. At the end of `my_application_local_command_line`, return `FALSE` instead of `TRUE`:
```cpp
  g_application_activate(application);
  *exit_status = 0;

  return FALSE;
}
```

See the full file in the [example](../app_links/example/linux/my_application.cc).

## Register the scheme

Linux opens links through `.desktop` files. Add the scheme to your app's desktop file:
```ini
[Desktop Entry]
Type=Application
Name=My App
Exec=/path/to/my_app %u
MimeType=x-scheme-handler/sample;
```

To make your app the default handler while developing, copy the file to `~/.local/share/applications/my_app.desktop`, then run:
```sh
xdg-mime default my_app.desktop x-scheme-handler/sample
# or: gio mime x-scheme-handler/sample my_app.desktop
```

### Packaging

- **Flathub:** use your `APPLICATION_ID` as the desktop file name. See the [AppFlowy Flathub setup](https://github.com/flathub/io.appflowy.AppFlowy).
- **Snap Store:** allow your app to own its D-Bus name in `snapcraft.yaml`. Replace `com.example.my_app` with your `APPLICATION_ID`. See the [AppFlowy Snapcraft setup](https://github.com/LucasXu0/appflowy-snap/blob/main/snap/snapcraft.yaml).
```yaml
slots:
  dbus-my-app:
    interface: dbus
    bus: session
    name: com.example.my_app
```
- **.deb or .rpm with [Flutter Distributor](https://pub.dev/packages/flutter_distributor):** add the scheme in `make_config.yaml`:
```yaml
supported_mime_type:
  - x-scheme-handler/sample
```

## Testing

Run the app with the link as argument:
```sh
./my_app sample://foo/#/book/hello-world
```

Or, once the scheme is registered:
```sh
xdg-open sample://foo/#/book/hello-world
# or: gio open sample://foo/#/book/hello-world
```

Run either command again while the app runs: the link goes to the running instance.
