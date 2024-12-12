#include "app_links_plugin.h"

#include <regex>
#include "include/app_links/app_links_plugin_c_api.h"

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
		if (argv == nullptr || argc != 2) {
			::LocalFree(argv);
			return std::nullopt;
		}

		std::wstring arg(argv[1]);
		::LocalFree(argv);

		// Convert wide string to basic string (flutter cannot handle wide strings?)
		int size_needed = WideCharToMultiByte(CP_UTF8, 0, &arg[0], (int)arg.size(), NULL, 0, NULL, NULL);
		std::string link(size_needed, 0);
		WideCharToMultiByte(CP_UTF8, 0, &arg[0], (int)arg.size(), &link[0], size_needed, NULL, NULL);

		// Check if the argument has a valid scheme (https://datatracker.ietf.org/doc/html/rfc3986#section-3.1)
		std::regex schemeRegex(R"(^([a-z][a-z0-9+.-]+):)", std::regex_constants::icase);
		if (std::regex_search(link, schemeRegex))
		{
			return link;
		}

		return std::nullopt;
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
		if (method_call.method_name().compare("getInitialLink") == 0)
		{
			auto link = GetLink();
			result->Success(flutter::EncodableValue(link.value_or("")));
		}
		else if (method_call.method_name().compare("getLatestLink") == 0)
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

				if (!initialLink_)
				{
					initialLink_ = link;
				}

				if (eventSink_)
				{
					initialLinkSent_ = true;
					eventSink_->Success(latestLink_.value());
				}
			}
		}

		if (message == WM_COMMAND)
		{
			int wmId = LOWORD(wparam);
			if (wmId == IDM_GETARGSWAS) {
				SendAppLink(hwnd);
			}
		}


		return std::nullopt;
	}

	std::unique_ptr<FlStreamHandlerError> AppLinksPlugin::OnListen(
		const flutter::EncodableValue *arguments,
		std::unique_ptr<FlEventSink> &&events)
	{

		eventSink_ = std::move(events);

		auto link = GetLink();
		if (!initialLinkSent_ && link) {
			initialLinkSent_ = true;
			initialLink_ = link;
		  eventSink_->Success(initialLink_.value());
		}

		return nullptr;
	}

	std::unique_ptr<FlStreamHandlerError> AppLinksPlugin::OnCancel(
		const flutter::EncodableValue *arguments)
	{
		eventSink_ = nullptr;
		return nullptr;
	}

} // namespace
