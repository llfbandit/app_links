#include "include/app_links_windows/app_links_windows_plugin.h"

#include <flutter/plugin_registrar_windows.h>
#include <cstdlib>

#include "app_links_plugin.h"

void AppLinksWindowsPluginRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar) {
    applinks_plugin::AppLinksWindowsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

// Parse command line
std::optional<std::string> GetLink() {
  int argc;
  wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  if (argv == nullptr) {
    return std::nullopt;
  }

  std::wstring arg(argv[1]);
  ::LocalFree(argv);

  // Convert wide string to basic string (flutter cannot handle wide strings?)
  int size_needed = WideCharToMultiByte(CP_UTF8, 0, &arg[0], (int)arg.size(), NULL, 0, NULL, NULL);
  std::string link(size_needed, 0);
  WideCharToMultiByte(CP_UTF8, 0, &arg[0], (int)arg.size(), &link[0], size_needed, NULL, NULL);
  return link;
}

// Method to dispatch new arguments to launched app
void SendAppLink(HWND hwnd) {
  auto link = GetLink();
  if (!link.has_value()) {
    return;
  }

  COPYDATASTRUCT cds = {0};
  cds.dwData = APPLINK_MSG_ID;
  cds.cbData = (DWORD)link.value().size() * sizeof(wchar_t);
  cds.lpData = (PVOID)link.value().c_str();

  SendMessage(hwnd, WM_COPYDATA, (WPARAM)hwnd, (LPARAM)(LPVOID)&cds);
}