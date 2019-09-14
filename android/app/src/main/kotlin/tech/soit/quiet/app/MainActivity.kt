package tech.soit.quiet.app

import android.content.Intent
import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    companion object {


        const val KEY_DESTINATION = "destination"

        const val DESTINATION_PLAYING_PAGE = "action_playing_page"

    }


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        route(intent)
    }

    private fun route(intent: Intent) {
        when (intent.getStringExtra(KEY_DESTINATION)) {
            DESTINATION_PLAYING_PAGE -> {
                flutterView.pushRoute("/playing")
            }
        }
    }

}
