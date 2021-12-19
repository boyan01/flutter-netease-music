#include <Windows.h>
#include <CommCtrl.h>
#pragma comment(lib, "ComCtl32.lib")
#include <windowsx.h>

#include "flutter_window.h"

#include <optional>
#include <iostream>

#include "flutter/generated_plugin_registrant.h"

namespace {

static LRESULT FlutterViewWindowProc(HWND window,
                                     UINT message,
                                     WPARAM wparam,
                                     LPARAM lparam,
                                     UINT_PTR subclassID,
                                     DWORD_PTR refData) {
  switch (message) {
    case WM_NCHITTEST: {
      // intercept flutter mouse events, so we can handle the resize drag.
      auto result = BorderlessWindowHelper::hit_test(
          POINT{GET_X_LPARAM(lparam), GET_Y_LPARAM(lparam)}, window);
      if (result != HTCLIENT) {
        return HTTRANSPARENT;
      }
      break;
    }
  }
  return DefSubclassProc(window, message, wparam, lparam);
}
}

FlutterWindow::FlutterWindow(const flutter::DartProject &project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() = default;

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }
  borderless_helper_ = std::make_unique<BorderlessWindowHelper>(GetHandle());
  borderless_helper_->set_borderless(true);
  borderless_helper_->set_borderless_shadow(true);

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

  SetWindowSubclass(flutter_controller_->view()->GetNativeWindow(),
                    FlutterViewWindowProc, 1, NULL);

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {

  if (borderless_helper_) {
    std::optional<LRESULT> result = borderless_helper_->HandWndProc(hwnd, message, wparam, lparam);
    if (result) {
      return *result;
    }
  }

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
    case WM_FONTCHANGE: {
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
    }
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
