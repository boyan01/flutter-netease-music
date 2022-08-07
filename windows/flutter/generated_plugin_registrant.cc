//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <desktop_drop/desktop_drop_plugin.h>
#include <lychee_player/media_player_plugin.h>
#include <screen_retriever/screen_retriever_plugin.h>
#include <system_clock/system_clock_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>
#include <window_manager/window_manager_plugin.h>
#include <windows_taskbar/windows_taskbar_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  DesktopDropPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DesktopDropPlugin"));
  MediaPlayerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("MediaPlayerPlugin"));
  ScreenRetrieverPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenRetrieverPlugin"));
  SystemClockPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SystemClockPlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  WindowManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowManagerPlugin"));
  WindowsTaskbarPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowsTaskbarPlugin"));
}
