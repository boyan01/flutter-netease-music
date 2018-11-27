package tech.soit.quiet

import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import tech.soit.quiet.service.NeteaseCrypto

class MainActivity : FlutterActivity() {

    companion object {

        /**
         * 网易云音乐加密
         */
        const val CHANNEL_NETEASE_CRYPTO = "tech.soit.netease/crypto"


    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        NeteaseCrypto.init(flutterView)
    }
}
