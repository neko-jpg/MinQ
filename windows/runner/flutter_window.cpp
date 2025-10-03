#include "flutter_window.h"

#include <optional>
#include <cstdint>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  auto messenger = flutter_controller_->engine()->messenger();
  desktop_menu_channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger, "miinq/desktop_menu_bar",
      &flutter::StandardMethodCodec::GetInstance());
  desktop_menu_channel_->SetMethodCallHandler([
    this
  ](const flutter::MethodCall<flutter::EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    if (call.method_name() == "updateTimer") {
      const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
      if (arguments) {
        const auto title_it = arguments->find(flutter::EncodableValue("title"));
        const auto remaining_it = arguments->find(flutter::EncodableValue("remainingSeconds"));
        if (title_it != arguments->end() && remaining_it != arguments->end()) {
          std::string title;
          if (const auto title_ptr = std::get_if<std::string>(&title_it->second)) {
            title = *title_ptr;
          }
          int remaining = 0;
          if (const auto int_ptr = std::get_if<int64_t>(&remaining_it->second)) {
            remaining = static_cast<int>(*int_ptr);
          } else if (const auto int32_ptr = std::get_if<int32_t>(&remaining_it->second)) {
            remaining = *int32_ptr;
          }
          std::wstring wide_title(title.begin(), title.end());
          wide_title.append(L" ");
          wide_title.append(std::to_wstring(remaining / 60));
          wide_title.append(L"m");
          SetTitle(wide_title);
        }
      }
      result->Success();
    } else if (call.method_name() == "clear") {
      SetTitle(L"MiinQ");
      result->Success();
    } else {
      result->NotImplemented();
    }
  });

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }
  desktop_menu_channel_.reset();

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
