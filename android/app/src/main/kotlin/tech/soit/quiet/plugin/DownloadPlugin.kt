package tech.soit.quiet.plugin

import com.tonyodev.fetch2.*
import com.tonyodev.fetch2core.DownloadBlock
import com.tonyodev.fetch2core.Downloader
import com.tonyodev.fetch2core.Extras
import com.tonyodev.fetch2core.Func
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import org.json.JSONObject
import tech.soit.quiet.AppContext
import tech.soit.quiet.player.Music
import tech.soit.quiet.utils.log
import java.io.File


/**
 * plugin for download
 */
class DownloadPlugin(
        private val channel: MethodChannel) : MethodChannel.MethodCallHandler {

    companion object {

        private const val CHANNEL_NAME = "tech.soit.quiet/Download"

        const val DEFAULT_DOWNLOAD_PATH = "sdcard/music"

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
            val plugin = DownloadPlugin(channel)
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
                        .setNotificationManager(DefaultFetchNotificationManager(AppContext))
                        .setHttpDownloader(object : HttpUrlConnectionDownloader() {
                            override fun getRequestBufferSize(request: Downloader.ServerRequest): Int {
                                return 1//slow down the download speed
                            }
                        })
                        .build()
                fetch = Fetch.getInstance(fetchConfiguration)
                fetch.addListener(object : FetchListener {

                    override fun onAdded(download: Download) {
                        update(download)
                    }

                    override fun onCancelled(download: Download) {
                        update(download)
                    }

                    override fun onCompleted(download: Download) {
                        update(download)
                    }

                    private fun update(download: Download) {
                        channel.invokeMethod("update", mapOf(
                                "download" to download.toMap()
                        ))
                    }

                    override fun onDeleted(download: Download) {
                        update(download)
                    }

                    override fun onDownloadBlockUpdated(download: Download, downloadBlock: DownloadBlock, totalBlocks: Int) {
                        update(download)
                    }

                    override fun onError(download: Download, error: Error, throwable: Throwable?) {
                        channel.invokeMethod("update", mapOf(
                                "download" to download.toMap()
                        ))
                    }

                    override fun onPaused(download: Download) {
                        update(download)
                    }

                    override fun onProgress(download: Download, etaInMilliSeconds: Long, downloadedBytesPerSecond: Long) {
                        channel.invokeMethod("update", mapOf(
                                "download" to download.toMap()
                        ))
                    }

                    override fun onQueued(download: Download, waitingOnNetwork: Boolean) {
                        update(download)

                    }

                    override fun onRemoved(download: Download) {
                        update(download)

                    }

                    override fun onResumed(download: Download) {
                        update(download)

                    }

                    override fun onStarted(download: Download, downloadBlocks: List<DownloadBlock>, totalBlocks: Int) {
                        update(download)
                    }

                    override fun onWaitingNetwork(download: Download) {
                        channel.invokeMethod("update", mapOf(
                                "download" to download.toMap()
                        ))
                    }
                })
                result.success(null)
            }
            "getDownloads" -> {
                val status = call.argument<Int>("status")
                if (status == null) {
                    result.error("status can not be null", null, null)
                    return
                }
                fetch.getDownloadsWithStatus(Status.valueOf(status), Func { downloads ->
                    log { "${Status.valueOf(status).name} : $downloads" }
                    val response: List<Map<String, Any>> = downloads.map {
                        return@map it.toMap()
                    }
                    result.success(response)
                })
            }
            "download" -> {
                val list: List<HashMap<String, Any>> = call.arguments()
                val requests = list.map { buildRequest(Music(it)) }
                try {
                    fetch.enqueue(requests)
                    result.success(null)
                } catch (e: FileAlreadyExistsException) {
                    e.printStackTrace()
                    result.error("file already exists", null, null)
                    return
                } catch (e: Exception) {
                    e.printStackTrace()
                    result.error("error:${e.message}", null, null)
                    return
                }
            }
            "pause" -> {
                val id: Int = call.arguments()
                fetch.pause(id, func = Func {
                    result.success(null)
                }, func2 = Func { error: Error ->
                    result.error(error.name, null, null)
                })
            }
            "freeze" -> {
                fetch.freeze()
                result.success(null)
            }
            "unfreeze" -> {
                fetch.unfreeze()
                result.success(null)
            }
            "delete" -> {
                val ids: List<Int> = call.arguments()
                fetch.delete(ids, func = Func {
                    result.success(it.size)
                }, func2 = Func {
                    result.error(it.name, null, null)
                })
            }
            else -> {
                result.notImplemented()
            }
        }
    }

}


//convert [Download] to Map
private fun Download.toMap(): Map<String, Any> {
    return mapOf(
            "id" to id,
            "file" to file,
            "total" to total,
            "status" to status.ordinal,
            "error" to error.name,
            "progress" to progress,
            "extras" to extras.map
    )
}

private fun buildRequest(music: Music): Request {
    val url = music.getPlayUrl()

    var suffix = url.substringAfterLast(".", missingDelimiterValue = "")
    if (suffix.isEmpty()) {
        suffix = "mp3"
    }
    val file = File("${DownloadPlugin.DEFAULT_DOWNLOAD_PATH}/${music.getSubTitle()}.$suffix")
    if (file.exists()) {
        log { "file exists" }
        throw FileAlreadyExistsException(file)
    }
    val request = Request(url, file.path)
    request.identifier = music.getId()
    request.extras = Extras(mapOf(
            "music" to JSONObject(music.map).toString()
    ))
    return request
}