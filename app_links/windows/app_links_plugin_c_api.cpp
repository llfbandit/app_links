#include "include/app_links/app_links_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "app_links_plugin.h"

void AppLinksPluginCApiRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar) {
    applinks::AppLinksPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

// Method to dispatch new arguments to launched app
void SendAppLink(HWND hwnd) {
    auto link = applinks::AppLinksPlugin::GetLink();
    if (!link.has_value()) {
        return;
    }

    COPYDATASTRUCT cds = { 0 };
    cds.dwData = APPLINK_MSG_ID;
    cds.cbData = (DWORD)link.value().size() * sizeof(wchar_t);
    cds.lpData = (PVOID)link.value().c_str();

    SendMessage(hwnd, WM_COPYDATA, (WPARAM)hwnd, (LPARAM)(LPVOID)&cds);
}
