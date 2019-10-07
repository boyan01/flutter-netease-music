package tech.soit.quiet.app

import io.flutter.app.FlutterApplication
import io.flutter.plugins.pathprovider.PathProviderPlugin
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin
import tech.soit.quiet.MusicPlayerBackgroundPlugin

@Suppress("unused")
class AppContext : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        MusicPlayerBackgroundPlugin.setOnRegisterCallback { registry ->
            PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"))
            SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"))
        }
    }
}