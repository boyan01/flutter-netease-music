package tech.soit.quiet

import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import tech.soit.quiet.service.MusicPlayer
import tech.soit.quiet.service.NeteaseCrypto

class MainActivity : FlutterActivity() {

    companion object {

        /**
         * 网易云音乐加密
         */
        const val CHANNEL_NETEASE_CRYPTO = "tech.soit.netease/crypto"

        const val CHANNER_MUSIC_PLAYER = "tech.soit.quiet/player"

    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        NeteaseCrypto.init(flutterView)
        MusicPlayer.init(flutterView)
    }
}
