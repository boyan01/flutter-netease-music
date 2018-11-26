package tech.soit.quiet

import android.app.Application
import io.flutter.app.FlutterApplication

/**
 * application context
 */
class AppContext : FlutterApplication() {

    /**
     * singleton for application
     */
    companion object : Application()

    override fun onCreate() {
        super.onCreate()
        AppContext.attachBaseContext(this)
    }
}