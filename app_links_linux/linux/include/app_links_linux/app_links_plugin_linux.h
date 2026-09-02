#ifndef FLUTTER_PLUGIN_APP_LINKS_PLUGIN_LINUX_H_
#define FLUTTER_PLUGIN_APP_LINKS_PLUGIN_LINUX_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

typedef struct _AppLinksPluginLinux AppLinksPluginLinux;
typedef struct {
  GObjectClass parent_class;
} AppLinksPluginLinuxClass;

FLUTTER_PLUGIN_EXPORT GType app_links_plugin_linux_get_type();

FLUTTER_PLUGIN_EXPORT void app_links_plugin_linux_register_with_registrar(
    FlPluginRegistrar* registrar);

G_END_DECLS

#endif  // FLUTTER_PLUGIN_APP_LINKS_PLUGIN_LINUX_H_
