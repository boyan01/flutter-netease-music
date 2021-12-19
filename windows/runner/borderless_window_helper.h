#include "Windows.h"

#include <optional>

class BorderlessWindowHelper {
 public:
  explicit BorderlessWindowHelper(HWND hwnd);

  auto set_borderless(bool enabled) -> void;
  auto set_borderless_shadow(bool enabled) -> void;

  std::optional<LRESULT> HandWndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam);

  static LRESULT hit_test(POINT cursor, HWND handle);

 private:

  bool borderless_ = true; // is the window currently borderless
  bool borderless_resize_ = true; // should the window allow resizing by dragging the borders while borderless
  bool borderless_drag_ = true; // should the window allow moving my dragging the client area
  bool borderless_shadow_ = true; // should the window display a native aero shadow while borderless

  HWND handle_;
};
