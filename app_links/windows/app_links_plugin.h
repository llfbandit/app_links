// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>

#define APPLINK_MSG_ID (WM_USER + 2)

namespace applinks
{
    class AppLinksPlugin : public flutter::Plugin
    {
    public:
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

        static std::optional<std::string> GetLink();

        AppLinksPlugin(flutter::PluginRegistrarWindows *registrar);
        virtual ~AppLinksPlugin();

    private:
        // Called when a method is called on this plugin's channel from Dart.
        void HandleMethodCall(
            const flutter::MethodCall<flutter::EncodableValue> &method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

        // Called from app when launching first
        std::optional<LRESULT> HandleWindowProc(
            HWND hwnd,
            UINT message,
            WPARAM wparam,
            LPARAM lparam);

        std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnListen(const flutter::EncodableValue *arguments, std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> &&events);
        std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>> OnCancel(const flutter::EncodableValue *arguments);

        // Our app instance ID
        int32_t window_proc_id_ = -1;        
        std::optional<std::string> latestLink_;
        std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> eventSink_;
        flutter::PluginRegistrarWindows *registrar_;
    };

    typedef flutter::EventChannel<flutter::EncodableValue> FlEventChannel;
    typedef flutter::EventSink<flutter::EncodableValue> FlEventSink;
    typedef flutter::MethodCall<flutter::EncodableValue> FlMethodCall;
    typedef flutter::MethodResult<flutter::EncodableValue> FlMethodResult;
    typedef flutter::MethodChannel<flutter::EncodableValue> FlMethodChannel;
    typedef flutter::StreamHandler<flutter::EncodableValue> FlStreamHandler;
    typedef flutter::StreamHandlerError<flutter::EncodableValue> FlStreamHandlerError;
}