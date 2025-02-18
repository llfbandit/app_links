# Linux
## SETUP

Apply the following changes to your `linux/my_application.cc` file:
```patch
diff --git a/example/linux/my_application.cc b/example/linux/my_application.cc
index 0ba8f43..f07f765 100644
--- a/example/linux/my_application.cc
+++ b/example/linux/my_application.cc
@@ -17,6 +17,13 @@ G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)
 // Implements GApplication::activate.
 static void my_application_activate(GApplication* application) {
   MyApplication* self = MY_APPLICATION(application);
+
+  GList* windows = gtk_application_get_windows(GTK_APPLICATION(application));
+  if (windows) {
+    gtk_window_present(GTK_WINDOW(windows->data));
+    return;
+  }
+
   GtkWindow* window =
       GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

@@ -78,7 +85,7 @@ static gboolean my_application_local_command_line(GApplication* application, gch
   g_application_activate(application);
   *exit_status = 0;

-  return TRUE;
+  return FALSE;
 }

 // Implements GObject::dispose.
@@ -99,6 +106,6 @@ static void my_application_init(MyApplication* self) {}
 MyApplication* my_application_new() {
   return MY_APPLICATION(g_object_new(my_application_get_type(),
                                      "application-id", APPLICATION_ID,
-                                     "flags", G_APPLICATION_NON_UNIQUE,
+                                     "flags", G_APPLICATION_HANDLES_COMMAND_LINE | G_APPLICATION_HANDLES_OPEN,
                                      nullptr));
```

Notes:
- Please ensure your `APPLICATION_ID` is the same as your desktop file name if you're using Flathub.
- Please ensure you have added this section in your `snapcraft.yaml` file if you're using SnapStore:
```yaml
slots:
  dbus-appflowy:
    interface: dbus
    bus: session
    name: `APPLICATION_ID`
```
- You can refer to these two repositories for more details: [FlatHub setup](https://github.com/flathub/io.appflowy.AppFlowy) and [Snapcraft setup](https://github.com/LucasXu0/appflowy-snap/blob/main/snap/snapcraft.yaml).

- If you created the .deb or .rpm installer with [Flutter Distributor](https://pub.dev/packages/flutter_distributor), please ensure that in the make_config.yaml you set
```yaml
supported_mime_type:
  - x-scheme-handler/my_custom_scheme # necessary so that the flutter app can open custom urls of type my_custom_scheme:/...
```