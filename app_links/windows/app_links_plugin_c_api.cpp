#include "include/app_links/app_links_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "app_links_plugin.h"

void AppLinksPluginCApiRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar) {
    applinks::AppLinksPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

// Method to dispatch new arguments to launched app
bool SendAppLink(HWND hwnd) {
    auto link = applinks::AppLinksPlugin::GetLink();
    if (!link.has_value()) {
        return true;
    }

    COPYDATASTRUCT cds = { 0 };
    cds.dwData = APPLINK_MSG_ID;
    cds.cbData = (DWORD)(link.value().size() + 1);
    cds.lpData = (PVOID)link.value().c_str();

    // Time out if the target hangs.
    // Windows drops the message if the target runs elevated.
    DWORD_PTR result = FALSE;
    LRESULT sent = SendMessageTimeout(hwnd, WM_COPYDATA, 0, (LPARAM)(LPVOID)&cds,
        SMTO_ABORTIFHUNG, APPLINK_SEND_TIMEOUT_MS, &result);

    return sent != 0 && result == TRUE;
}

bool SendAppLinkToInstance() {
    struct State { HWND found; wchar_t ourExe[MAX_PATH]; };
    State s = {};
    GetModuleFileNameW(nullptr, s.ourExe, MAX_PATH);

    EnumWindows([](HWND hwnd, LPARAM lp) -> BOOL {
        auto* s = reinterpret_cast<State*>(lp);
        wchar_t cls[64] = {};
        GetClassNameW(hwnd, cls, 64);
        if (_wcsicmp(cls, L"FLUTTER_RUNNER_WIN32_WINDOW") != 0) return TRUE;

        DWORD pid = 0;
        GetWindowThreadProcessId(hwnd, &pid);
        HANDLE h = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
        if (!h) return TRUE;
        wchar_t exe[MAX_PATH] = {};
        DWORD len = MAX_PATH;
        QueryFullProcessImageNameW(h, 0, exe, &len);
        CloseHandle(h);
        if (_wcsicmp(exe, s->ourExe) == 0) { s->found = hwnd; return FALSE; }
        return TRUE;
    }, reinterpret_cast<LPARAM>(&s));

    if (!s.found) return false;

    // Let the caller start a new instance.
    if (!SendAppLink(s.found)) return false;

    WINDOWPLACEMENT place = {sizeof(WINDOWPLACEMENT)};
    GetWindowPlacement(s.found, &place);
    switch (place.showCmd) {
        case SW_SHOWMAXIMIZED: ShowWindow(s.found, SW_SHOWMAXIMIZED); break;
        case SW_SHOWMINIMIZED: ShowWindow(s.found, SW_RESTORE); break;
        default:               ShowWindow(s.found, SW_NORMAL); break;
    }
    SetWindowPos(s.found, HWND_TOP, 0, 0, 0, 0, SWP_SHOWWINDOW | SWP_NOSIZE | SWP_NOMOVE);
    SetForegroundWindow(s.found);
    return true;
}
