package tech.soit.quiet

import android.content.Intent
import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import tech.soit.quiet.plugin.PluginRegistrant
import tech.soit.quiet.service.QuietPlayerChannel

class MainActivity : FlutterActivity() {

    companion object {


        const val KEY_DESTINATION = "destination"

        const val DESTINATION_PLAYING_PAGE = "action_playing_page"

    }

    private lateinit var playerChannel: QuietPlayerChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        PluginRegistrant.registerWith(this)
        playerChannel = QuietPlayerChannel.registerWith(registrarFor("tech.soit.quiet.service.QuietPlayerChannel"))
    }

    override fun onDestroy() {
        playerChannel.destroy()
        super.onDestroy()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        when (intent.getStringExtra(KEY_DESTINATION)) {
            DESTINATION_PLAYING_PAGE -> {
                flutterView.pushRoute("/playing")
            }
        }
    }

}
