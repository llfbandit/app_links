#ifndef FLUTTER_PLUGIN_APP_LINKS_PLUGIN_C_API_H_
#define FLUTTER_PLUGIN_APP_LINKS_PLUGIN_C_API_H_

#include <windows.h>
#include <flutter_plugin_registrar.h>

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

#if defined(__cplusplus)
extern "C" {
#endif

FLUTTER_PLUGIN_EXPORT void AppLinksPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

FLUTTER_PLUGIN_EXPORT void SendAppLink(HWND hwnd);

// Finds an existing instance of this app, forwards the app link to it,
// brings it to the foreground, and returns true. Returns false if no
// existing instance is found.
FLUTTER_PLUGIN_EXPORT bool SendAppLinkToInstance();

#if defined(__cplusplus)
}  // extern "C"
#endif

#endif  // FLUTTER_PLUGIN_APP_LINKS_PLUGIN_C_API_H_
