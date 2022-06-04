//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import dart_vlc
import desktop_drop
import path_provider_macos
import screen_retriever
import shared_preferences_macos
import system_clock
import url_launcher_macos
import window_manager

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  DartVlcPlugin.register(with: registry.registrar(forPlugin: "DartVlcPlugin"))
  DesktopDropPlugin.register(with: registry.registrar(forPlugin: "DesktopDropPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  ScreenRetrieverPlugin.register(with: registry.registrar(forPlugin: "ScreenRetrieverPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SystemClockPlugin.register(with: registry.registrar(forPlugin: "SystemClockPlugin"))
  UrlLauncherPlugin.register(with: registry.registrar(forPlugin: "UrlLauncherPlugin"))
  WindowManagerPlugin.register(with: registry.registrar(forPlugin: "WindowManagerPlugin"))
}
