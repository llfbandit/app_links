#include "include/app_links_linux/app_links_plugin_linux.h"

#include <flutter_linux/flutter_linux.h>
#include <gio/gio.h>

#define APP_LINKS_PLUGIN_LINUX(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), app_links_plugin_linux_get_type(), \
                              AppLinksPluginLinux))

struct _AppLinksPluginLinux {
  GObject parent_instance;

  FlEventChannel* event_channel;
  gboolean listening;
  gchar* initial_link;
  gboolean initial_link_sent;
  gchar* latest_link;

  GApplication* application;
  guint command_line_signal;
  gulong command_line_hook;
  gulong fallback_handler;
  gboolean fallback_blocked;
};

G_DEFINE_TYPE(AppLinksPluginLinux, app_links_plugin_linux, g_object_get_type())

static void send_link(AppLinksPluginLinux* self, const gchar* link) {
  g_autoptr(FlValue) value = fl_value_new_string(link);
  fl_event_channel_send(self->event_channel, value, nullptr, nullptr);
}

static void handle_link(AppLinksPluginLinux* self, const gchar* link) {
  g_free(self->latest_link);
  self->latest_link = g_strdup(link);

  if (self->initial_link == nullptr) {
    self->initial_link = g_strdup(link);
  }

  if (self->listening) {
    self->initial_link_sent = TRUE;
    send_link(self, link);
  }
}

// Handle the command line when nothing else does, so GLib does not warn.
static gint command_line_fallback(GApplication* application,
                                  GApplicationCommandLine* command_line,
                                  gpointer user_data) {
  return 0;
}

// Run the fallback only if the app and other handlers ignore the signal.
static void update_fallback(AppLinksPluginLinux* self) {
  if (!self->fallback_blocked) {
    g_signal_handler_block(self->application, self->fallback_handler);
    self->fallback_blocked = TRUE;
  }

  GApplicationClass* base =
      G_APPLICATION_CLASS(g_type_class_peek(G_TYPE_APPLICATION));
  gboolean handled =
      G_APPLICATION_GET_CLASS(self->application)->command_line !=
          base->command_line ||
      g_signal_has_handler_pending(self->application,
                                   self->command_line_signal, 0, FALSE);

  if (!handled) {
    g_signal_handler_unblock(self->application, self->fallback_handler);
    self->fallback_blocked = FALSE;
  }
}

// Read the link from each command line, local or from another instance.
static gboolean command_line_hook(GSignalInvocationHint* hint,
                                  guint n_params,
                                  const GValue* params,
                                  gpointer user_data) {
  AppLinksPluginLinux* self = APP_LINKS_PLUGIN_LINUX(user_data);
  if (g_value_get_object(&params[0]) != self->application) {
    return TRUE;
  }

  // Hooks run before handlers, so this applies to the current signal.
  update_fallback(self);

  GApplicationCommandLine* command_line =
      G_APPLICATION_COMMAND_LINE(g_value_get_object(&params[1]));

  gint argc = 0;
  g_auto(GStrv) argv =
      g_application_command_line_get_arguments(command_line, &argc);
  if (argc > 1 && argv[1][0] != '\0') {
    handle_link(self, argv[1]);
  }

  // Keep the hook.
  return TRUE;
}

static void method_call_cb(FlMethodChannel* channel,
                           FlMethodCall* method_call,
                           gpointer user_data) {
  AppLinksPluginLinux* self = APP_LINKS_PLUGIN_LINUX(user_data);
  const gchar* method = fl_method_call_get_name(method_call);

  const gchar* link = nullptr;
  if (g_strcmp0(method, "getInitialLink") == 0) {
    link = self->initial_link;
  } else if (g_strcmp0(method, "getLatestLink") == 0) {
    link = self->latest_link;
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
    return;
  }

  g_autoptr(FlValue) result = fl_value_new_string(link ? link : "");
  g_autoptr(FlMethodResponse) response =
      FL_METHOD_RESPONSE(fl_method_success_response_new(result));

  fl_method_call_respond(method_call, response, nullptr);
}

static FlMethodErrorResponse* listen_cb(FlEventChannel* channel,
                                        FlValue* args,
                                        gpointer user_data) {
  AppLinksPluginLinux* self = APP_LINKS_PLUGIN_LINUX(user_data);
  self->listening = TRUE;

  if (!self->initial_link_sent && self->initial_link != nullptr) {
    self->initial_link_sent = TRUE;
    send_link(self, self->initial_link);
  }

  return nullptr;
}

static FlMethodErrorResponse* cancel_cb(FlEventChannel* channel,
                                        FlValue* args,
                                        gpointer user_data) {
  AppLinksPluginLinux* self = APP_LINKS_PLUGIN_LINUX(user_data);
  self->listening = FALSE;
  return nullptr;
}

static void app_links_plugin_linux_dispose(GObject* object) {
  AppLinksPluginLinux* self = APP_LINKS_PLUGIN_LINUX(object);

  if (self->command_line_hook != 0) {
    g_signal_remove_emission_hook(self->command_line_signal,
                                  self->command_line_hook);
    self->command_line_hook = 0;
  }
  if (self->fallback_handler != 0) {
    g_signal_handler_disconnect(self->application, self->fallback_handler);
    self->fallback_handler = 0;
  }
  g_clear_object(&self->event_channel);
  g_clear_pointer(&self->initial_link, g_free);
  g_clear_pointer(&self->latest_link, g_free);

  G_OBJECT_CLASS(app_links_plugin_linux_parent_class)->dispose(object);
}

static void app_links_plugin_linux_class_init(AppLinksPluginLinuxClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = app_links_plugin_linux_dispose;
}

static void app_links_plugin_linux_init(AppLinksPluginLinux* self) {}

void app_links_plugin_linux_register_with_registrar(
    FlPluginRegistrar* registrar) {
  AppLinksPluginLinux* plugin = APP_LINKS_PLUGIN_LINUX(
      g_object_new(app_links_plugin_linux_get_type(), nullptr));

  FlBinaryMessenger* messenger = fl_plugin_registrar_get_messenger(registrar);
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();

  g_autoptr(FlMethodChannel) method_channel = fl_method_channel_new(
      messenger, "com.llfbandit.app_links/messages", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      method_channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  plugin->event_channel = fl_event_channel_new(
      messenger, "com.llfbandit.app_links/events", FL_METHOD_CODEC(codec));
  fl_event_channel_set_stream_handlers(plugin->event_channel, listen_cb,
                                       cancel_cb, plugin, nullptr);

  plugin->application = g_application_get_default();
  if (plugin->application != nullptr) {
    // Use a hook, a signal handler would block the gtk package handler.
    plugin->command_line_signal =
        g_signal_lookup("command-line", G_TYPE_APPLICATION);
    plugin->command_line_hook = g_signal_add_emission_hook(
        plugin->command_line_signal, 0, command_line_hook, plugin, nullptr);

    plugin->fallback_handler =
        g_signal_connect(plugin->application, "command-line",
                         G_CALLBACK(command_line_fallback), nullptr);
    g_signal_handler_block(plugin->application, plugin->fallback_handler);
    plugin->fallback_blocked = TRUE;
  }

  g_object_unref(plugin);
}
