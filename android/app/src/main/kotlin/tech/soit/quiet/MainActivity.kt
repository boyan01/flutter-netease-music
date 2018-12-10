package tech.soit.quiet

import android.content.ComponentName
import android.content.Intent
import android.os.Bundle
import android.support.v4.media.MediaBrowserCompat
import android.util.Log
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import tech.soit.quiet.service.NeteaseCrypto
import tech.soit.quiet.service.QuietPlayerService


class MainActivity : FlutterActivity() {

    companion object {

        /**
         * 网易云音乐加密
         */
        const val CHANNEL_NETEASE_CRYPTO = "tech.soit.netease/crypto"

        const val KEY_DESTINATION = "destination"

        const val DESTINATION_PLAYING_PAGE = "action_playing_page"

        const val TAG = "MainActivity"

    }


    private lateinit var mediaBrowser: MediaBrowserCompat

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        NeteaseCrypto.init(flutterView)

        mediaBrowser = MediaBrowserCompat(this,
                ComponentName(this, QuietPlayerService::class.java),
                browserConnectCallback, null)
        mediaBrowser.connect()

    }

    private val browserConnectCallback = object : MediaBrowserCompat.ConnectionCallback() {

        override fun onConnected() {
            super.onConnected()
            Log.d(TAG, "onConnected")

            val mediaId = mediaBrowser.root

            Log.d(TAG, "onConnected : mediaId = $mediaId")

            mediaBrowser.subscribe(mediaId, browserSubscriptionCallback)
        }

        override fun onConnectionFailed() {
            super.onConnectionFailed()
            Log.d(TAG, "onConnectionFailed")
        }

    }

    private val browserSubscriptionCallback = object : MediaBrowserCompat.SubscriptionCallback() {

        override fun onChildrenLoaded(parentId: String, children: MutableList<MediaBrowserCompat.MediaItem>) {
            Log.e(TAG, "onChildrenLoaded------ $parentId , size = ${children.size}")
            QuietPlayerService.MediaControlChannel.registerWith(
                    registrarFor("tech.soit.quiet.service.QuietPlayerService.MediaControlChannel"),
                    mediaBrowser.sessionToken
            )
        }

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
