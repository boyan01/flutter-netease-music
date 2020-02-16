package tech.soit.quiet.app

import io.flutter.app.FlutterApplication
import io.flutter.plugins.pathprovider.PathProviderPlugin
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin
import tech.soit.quiet.MusicPlayerServicePlugin

@Suppress("unused")
class AppContext : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        MusicPlayerServicePlugin.setOnRegisterCallback { engine ->
            engine.plugins.add(PathProviderPlugin())
            engine.plugins.add(SharedPreferencesPlugin())
        }
    }
}