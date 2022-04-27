#ifndef FLUTTER_PLUGIN_APP_LINKS_WINDOWS_PLUGIN_H_
#define FLUTTER_PLUGIN_APP_LINKS_WINDOWS_PLUGIN_H_

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

FLUTTER_PLUGIN_EXPORT void AppLinksWindowsPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

#define APPLINK_MSG_ID (WM_USER + 2)
FLUTTER_PLUGIN_EXPORT void SendAppLink(HWND hwnd);

#if defined(__cplusplus)
}  // extern "C"
#endif

#endif  // FLUTTER_PLUGIN_APP_LINKS_WINDOWS_PLUGIN_H_
