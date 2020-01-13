package tech.soit.quiet.app

import io.flutter.app.FlutterApplication
import io.flutter.plugins.pathprovider.PathProviderPlugin
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin
import tech.soit.quiet.MusicPlayerBackgroundChannel

@Suppress("unused")
class AppContext : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        MusicPlayerBackgroundChannel.setOnRegisterCallback { engine ->
            engine.plugins.add(PathProviderPlugin())
            engine.plugins.add(SharedPreferencesPlugin())
        }
    }
}