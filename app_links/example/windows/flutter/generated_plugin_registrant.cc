//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <app_links_macos/app_links_macos_plugin.h>
#include <app_links_windows/app_links_windows_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AppLinksMacosPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AppLinksMacosPlugin"));
  AppLinksWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AppLinksWindowsPlugin"));
}
