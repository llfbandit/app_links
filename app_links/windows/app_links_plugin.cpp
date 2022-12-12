#include "app_links_plugin.h"

using namespace flutter;

namespace applinks
{
	// static, Register the plugin
	void AppLinksPlugin::RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar)
	{
		auto plugin = std::make_unique<AppLinksPlugin>(registrar);

		auto methodChannel = std::make_unique<FlMethodChannel>(
			registrar->messenger(), "com.llfbandit.app_links/messages",
			&flutter::StandardMethodCodec::GetInstance());

		methodChannel->SetMethodCallHandler(
			[plugin_pointer = plugin.get()](const auto &call, auto result)
			{
				plugin_pointer->HandleMethodCall(call, std::move(result));
			});

		auto eventChannel = std::make_unique<FlEventChannel>(
			registrar->messenger(), "com.llfbandit.app_links/events",
			&flutter::StandardMethodCodec::GetInstance());

		auto eventHandler = std::make_unique<StreamHandlerFunctions<EncodableValue>>(
			[plugin_pointer = plugin.get()](const EncodableValue *arguments, std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> &&events) -> std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
			{
				return plugin_pointer->OnListen(arguments, std::move(events));
			},
			[plugin_pointer = plugin.get()](const EncodableValue *arguments) -> std::unique_ptr<FlStreamHandlerError>
			{
				return plugin_pointer->OnCancel(arguments);
			});

		eventChannel->SetStreamHandler(std::move(eventHandler));

		registrar->AddPlugin(std::move(plugin));
	}

	// static, Parse command line
	std::optional<std::string> AppLinksPlugin::GetLink()
	{
		int argc;
		wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
		if (argv == nullptr || argc < 2) {
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

	AppLinksPlugin::AppLinksPlugin(PluginRegistrarWindows *registrar)
		: registrar_(registrar)
	{

		window_proc_id_ = registrar->RegisterTopLevelWindowProcDelegate(
			[this](HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam)
			{
				return HandleWindowProc(hwnd, message, wparam, lparam);
			});
	}

	AppLinksPlugin::~AppLinksPlugin()
	{
		registrar_->UnregisterTopLevelWindowProcDelegate(window_proc_id_);
	}

	void AppLinksPlugin::HandleMethodCall(
		const flutter::MethodCall<flutter::EncodableValue> &method_call,
		std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
	{
		if (method_call.method_name().compare("getInitialAppLink") == 0)
		{
			auto link = GetLink();
			result->Success(flutter::EncodableValue(link.value_or("")));
		}
		else if (method_call.method_name().compare("getLatestAppLink") == 0)
		{
			result->Success(flutter::EncodableValue(latestLink_.value_or("")));
		}
		else
		{
			result->NotImplemented();
		}
	}

	std::optional<LRESULT> AppLinksPlugin::HandleWindowProc(
		HWND hwnd,
		UINT message,
		WPARAM wparam,
		LPARAM lparam)
	{

		if (message == WM_COPYDATA)
		{
			COPYDATASTRUCT *cds = (COPYDATASTRUCT *)lparam;

			if (cds->dwData == APPLINK_MSG_ID)
			{
				std::string link((char *)(cds->lpData));

				latestLink_ = link;

				if (eventSink_)
				{
					eventSink_->Success(latestLink_.value());
				}
			}
		}

		return std::nullopt;
	}

	std::unique_ptr<FlStreamHandlerError> AppLinksPlugin::OnListen(
		const flutter::EncodableValue *arguments,
		std::unique_ptr<FlEventSink> &&events)
	{

		eventSink_ = std::move(events);
		return nullptr;
	}

	std::unique_ptr<FlStreamHandlerError> AppLinksPlugin::OnCancel(
		const flutter::EncodableValue *arguments)
	{
		eventSink_ = nullptr;
		return nullptr;
	}

} // namespace
