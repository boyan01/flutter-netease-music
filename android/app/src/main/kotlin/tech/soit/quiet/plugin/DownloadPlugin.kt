package tech.soit.quiet.plugin

import com.tonyodev.fetch2.*
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import com.tonyodev.fetch2core.Func
import tech.soit.quiet.AppContext
import tech.soit.quiet.player.Music


/**
 * plugin for download
 */
class DownloadPlugin : MethodChannel.MethodCallHandler {

    companion object {

        private const val CHANNEL_NAME = "tech.soit.quiet/Download"

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
            val plugin = DownloadPlugin()
            channel.setMethodCallHandler(plugin)
            registrar.addViewDestroyListener {
                plugin.fetch.close()
                false
            }
        }

    }

    private lateinit var fetch: Fetch

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> {
                val fetchConfiguration = FetchConfiguration.Builder(AppContext)
                        .setDownloadConcurrentLimit(3)
                        .build()
                fetch = Fetch.getInstance(fetchConfiguration)
                fetch.addListener(object : AbstractFetchListener() {

                })
            }
            "getCompletedDownloads" -> {
                fetch.getDownloadsWithStatus(Status.COMPLETED, Func { downloads ->
                    downloads.map {
                        it.tag
                    }
                    result.success(downloads)
                })
            }
            "download" -> {
                val music = Music(call.arguments<HashMap<String, Any>>())
                val request = Request(music.getPlayUrl(), "sdcard/music")
//                request.networkType = NetworkType.WIFI_ONLY
                fetch.enqueue(request)
            }
        }
    }

}