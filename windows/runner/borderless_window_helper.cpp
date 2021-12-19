//
// Created by yangbin on 2021/12/19.
//

#include <stdexcept>
#include <system_error>

#include <Windows.h>
#include <windowsx.h>
#include <dwmapi.h>
#pragma comment(lib, "dwmapi.lib")

#include <iostream>

#include "borderless_window_helper.h"

namespace {
// we cannot just use WS_POPUP style
// WS_THICKFRAME: without this the window cannot be resized and so aero snap, de-maximizing and minimizing won't work
// WS_SYSMENU: enables the context menu with the move, close, maximize, minize... commands (shift + right-click on the task bar item)
// WS_CAPTION: enables aero minimize animation/transition
// WS_MAXIMIZEBOX, WS_MINIMIZEBOX: enable minimize/maximize
enum class Style : DWORD {
  windowed = WS_OVERLAPPEDWINDOW,
  aero_borderless = WS_POPUP | WS_THICKFRAME | WS_CAPTION | WS_SYSMENU | WS_MAXIMIZEBOX | WS_MINIMIZEBOX,
  basic_borderless = WS_POPUP | WS_THICKFRAME | WS_SYSMENU | WS_MAXIMIZEBOX | WS_MINIMIZEBOX
};

auto maximized(HWND hwnd) -> bool {
  WINDOWPLACEMENT placement;
  if (!::GetWindowPlacement(hwnd, &placement)) {
    return false;
  }

  return placement.showCmd == SW_MAXIMIZE;
}

/* Adjust client rect to not spill over monitor edges when maximized.
 * rect(in/out): in: proposed window rect, out: calculated client rect
 * Does nothing if the window is not maximized.
 */
auto adjust_maximized_client_rect(HWND window, RECT &rect) -> void {
  if (!maximized(window)) {
    return;
  }

  auto monitor = ::MonitorFromWindow(window, MONITOR_DEFAULTTONULL);
  if (!monitor) {
    return;
  }

  MONITORINFO monitor_info{};
  monitor_info.cbSize = sizeof(monitor_info);
  if (!::GetMonitorInfoW(monitor, &monitor_info)) {
    return;
  }

  // when maximized, make the client area fill just the monitor (without task bar) rect,
  // not the whole window rect which extends beyond the monitor.
  rect = monitor_info.rcWork;
}

auto composition_enabled() -> bool {
  BOOL composition_enabled = FALSE;
  bool success = ::DwmIsCompositionEnabled(&composition_enabled) == S_OK;
  return composition_enabled && success;
}

auto select_borderless_style() -> Style {
  return composition_enabled() ? Style::aero_borderless : Style::basic_borderless;
}

auto set_shadow(HWND handle, bool enabled) -> void {
  if (composition_enabled()) {
    static const MARGINS shadow_state[2]{{0, 0, 0, 0}, {1, 1, 1, 1}};
    ::DwmExtendFrameIntoClientArea(handle, &shadow_state[enabled]);
  }
}

}

BorderlessWindowHelper::BorderlessWindowHelper(HWND hwnd) : handle_(hwnd) {
  set_borderless(borderless_);
  set_borderless_shadow(borderless_shadow_);
}

void BorderlessWindowHelper::set_borderless(bool enabled) {
  Style new_style = (enabled) ? select_borderless_style() : Style::windowed;
  Style old_style = static_cast<Style>(::GetWindowLongPtrW(handle_, GWL_STYLE));

  if (new_style != old_style) {
    borderless_ = enabled;

    ::SetWindowLongPtrW(handle_, GWL_STYLE, static_cast<LONG>(new_style));

    // when switching between borderless and windowed, restore appropriate shadow state
    set_shadow(handle_, borderless_shadow_ && (new_style != Style::windowed));

    // redraw frame
    ::SetWindowPos(handle_, nullptr, 0, 0, 0, 0, SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE);
    ::ShowWindow(handle_, SW_SHOW);
  }
}

void BorderlessWindowHelper::set_borderless_shadow(bool enabled) {
  if (borderless_) {
    borderless_shadow_ = enabled;
    set_shadow(handle_, enabled);
  }
}

std::optional<LRESULT> BorderlessWindowHelper::HandWndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
  switch (msg) {
    case WM_NCCALCSIZE: {
      if (wparam == TRUE && borderless_) {
        auto &params = *reinterpret_cast<NCCALCSIZE_PARAMS *>(lparam);
        adjust_maximized_client_rect(hwnd, params.rgrc[0]);
        return 0;
      }
      break;
    }
    case WM_NCHITTEST: {
      // When we have no border or title bar, we need to perform our
      // own hit testing to allow resizing and moving.
      if (borderless_) {
        return hit_test(POINT{GET_X_LPARAM(lparam), GET_Y_LPARAM(lparam)}, hwnd);
      }
      break;
    }
    case WM_NCACTIVATE: {
      if (!composition_enabled()) {
        // Prevents window frame reappearing on window activation
        // in "basic" theme, where no aero shadow is present.
        return 1;
      }
      break;
    }
  }
  return std::nullopt;
}

// static
LRESULT BorderlessWindowHelper::hit_test(POINT cursor, HWND handle) {
  // identify borders and corners to allow resizing the window.
  // Note: On Windows 10, windows behave differently and
  // allow resizing outside the visible window frame.
  // This implementation does not replicate that behavior.
  const POINT border{
      ::GetSystemMetrics(SM_CXFRAME) + ::GetSystemMetrics(SM_CXPADDEDBORDER),
      ::GetSystemMetrics(SM_CYFRAME) + ::GetSystemMetrics(SM_CXPADDEDBORDER)
  };
  RECT window;
  if (!::GetWindowRect(handle, &window)) {
    return HTCLIENT;
  }

//  const auto drag = borderless_drag_ ? HTCAPTION : HTCLIENT;

  enum region_mask {
    client = 0b0000,
    left = 0b0001,
    right = 0b0010,
    top = 0b0100,
    bottom = 0b1000,
  };

  const auto result =
      left * (cursor.x < (window.left + border.x)) |
          right * (cursor.x >= (window.right - border.x)) |
          top * (cursor.y < (window.top + border.y)) |
          bottom * (cursor.y >= (window.bottom - border.y));

  switch (result) {
    case left          : return HTLEFT;
    case right         : return HTRIGHT;
    case top           : return HTTOP;
    case bottom        : return HTBOTTOM;
    case top | left    : return HTTOPLEFT;
    case top | right   : return HTTOPRIGHT;
    case bottom | left : return HTBOTTOMLEFT;
    case bottom | right: return HTBOTTOMRIGHT;
    default            : return HTCLIENT;
  }
}
