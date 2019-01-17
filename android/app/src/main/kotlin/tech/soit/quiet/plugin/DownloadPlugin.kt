package tech.soit.quiet.plugin

import android.Manifest
import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.support.v4.app.NotificationCompat
import com.tonyodev.fetch2.*
import com.tonyodev.fetch2core.DownloadBlock
import com.tonyodev.fetch2core.Downloader
import com.tonyodev.fetch2core.Extras
import com.tonyodev.fetch2core.Func
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import org.json.JSONObject
import tech.soit.quiet.AppContext
import tech.soit.quiet.MainActivity
import tech.soit.quiet.player.Music
import tech.soit.quiet.utils.log
import java.io.File
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

private const val MUSIC_DOWNLOAD_GROUP = 1

/**
 * plugin for download
 */
class DownloadPlugin(
        private val channel: MethodChannel) : MethodChannel.MethodCallHandler {

    companion object {

        private const val CHANNEL_NAME = "tech.soit.quiet/Download"

        const val DEFAULT_DOWNLOAD_PATH = "sdcard/music"

        private val fetch: Fetch = Fetch.getInstance(FetchConfiguration.Builder(AppContext)
                .setDownloadConcurrentLimit(1)
                .setNotificationManager(DefaultFetchNotificationManager(AppContext))
                .setHttpDownloader(object : HttpUrlConnectionDownloader() {
                    override fun getRequestBufferSize(request: Downloader.ServerRequest): Int {
                        return 1//slow down the download speed
                    }
                })
                .setNotificationManager(MusicDownloadNotificationManager())
                .enableAutoStart(false)
                .enableLogging(false)
                .build())

        private var fetchListener: FetchListener? = null


        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
            val plugin = DownloadPlugin(channel)
            channel.setMethodCallHandler(plugin)
            registrar.addViewDestroyListener {
                fetchListener?.let { l ->
                    fetch.removeListener(l)
                }
                false//we do not interest in adopt flutter view
            }
        }

    }


    private var initialized = false

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        GlobalScope.launch(context = Dispatchers.Main) {
            when (call.method) {
                "init" -> {
                    if (!initialized) {
                        init()
                        initialized = true
                    }
                    result.success(null)
                }
                "getDownloads" -> {
                    fetch.getDownloads(Func { downloads ->
                        val response: List<Map<String, Any>> = downloads.map {
                            return@map it.toMap()
                        }
                        result.success(response)
                    })
                }
                "download" -> {
                    val list: List<HashMap<String, Any>> = call.arguments()
                    val msg = downloadMusicList(list.map { Music(it) })
                    result.success(mapOf(
                            "succeed" to (msg == null),
                            "msg" to msg
                    ))
                }
                "pause" -> {
                    val ids: List<Int> = call.arguments()
                    fetch.pause(ids, func = Func {
                        result.success(null)
                    }, func2 = Func { error: Error ->
                        result.error(error.name, null, null)
                    })
                }
                "resume" -> {
                    val ids: List<Int> = call.arguments()
                    fetch.resume(ids, func = Func {
                        result.success(null)
                    }, func2 = Func { error: Error ->
                        result.error(error.name, null, null)
                    })
                }
                "retry" -> {
                    val ids: List<Int> = call.arguments()
                    fetch.retry(ids, func = Func {
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
                    val ids: List<Int> = call.argument("ids")!!
                    val removeFile: Boolean = call.argument("removeFile")!!

                    val func = Func<List<Download>> {
                        result.success(it.size)
                    }
                    val func2 = Func<Error> {
                        result.error(it.name, null, null)
                    }
                    if (removeFile) {
                        fetch.delete(ids, func = func, func2 = func2)
                    } else {
                        fetch.remove(ids, func = func, func2 = func2)
                    }
                }
                "isDownloaded" -> {
                    val id = call.argument<Long>("musicId")!!
                    val download = getDownloadByMusicId(id)
                    result.success(download != null && download.status == Status.COMPLETED)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }


    private suspend fun isMusicShouldDownload(music: Music, resumeIfPause: Boolean = true): Boolean {
        val download = getDownloadByMusicId(music.getId()) ?: return true
        if (download.status == Status.PAUSED && resumeIfPause) {
            fetch.resume(download.id)
        }
        return false
    }

    private suspend fun downloadMusicList(musicList: List<Music>): String? {
        if (AppContext.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {
            return "未获取权限"
        }
        val requests = musicList.filter { isMusicShouldDownload(it) }.map { buildRequest(it) }
        try {
            fetch.enqueue(requests)
        } catch (e: Exception) {
            e.printStackTrace()
            return "加入下载列表失败"
        }
        return null
    }

    private fun init() {
        val listener = object : FetchListener {

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
                log { "update :${download.toMap()}" }
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
                log { throwable?.printStackTrace();"on error $error" }
                channel.invokeMethod("update", mapOf(
                        "download" to download.toMap(),
                        "error" to throwable?.message
                ))
            }

            override fun onPaused(download: Download) {
                update(download)
            }

            override fun onProgress(download: Download, etaInMilliSeconds: Long, downloadedBytesPerSecond: Long) {
                channel.invokeMethod("update", mapOf(
                        "download" to download.toMap(),
                        "eta" to etaInMilliSeconds,
                        "speed" to downloadedBytesPerSecond
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
        }
        fetch.addListener(listener)
        fetchListener = listener
    }

    private suspend fun getDownloadByMusicId(musicId: Long) = suspendCoroutine<Download?> { continuation ->
        try {
            fetch.getDownloadsByRequestIdentifier(musicId, func = Func {
                continuation.resume(it.firstOrNull())
            })
        } catch (e: Exception) {
            continuation.resume(null)
        }

    }

}


/**
 * download notification manager for fetch
 */
private class MusicDownloadNotificationManager : DefaultFetchNotificationManager(AppContext) {

    private val notificationManager = AppContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

    private val downloadList = mutableListOf<DownloadNotification>()

    private var downloading: DownloadNotification? = null

    override fun postNotificationUpdate(download: Download, etaInMilliSeconds: Long, downloadedBytesPerSecond: Long): Boolean {
        if (download.group != MUSIC_DOWNLOAD_GROUP) {
            return false
        }
        downloadList.removeAll { it.download.id == download.id }
        val downloadNotification = DownloadNotification(download)

        if (downloadNotification.notificationId == downloading?.notificationId && !downloadNotification.isDownloading) {
            downloading = null
        }
        if (downloading == null && downloadNotification.isDownloading) {
            downloading = downloadNotification
        }

        if (downloadNotification.isCancelledNotification) {
            downloadList.removeAll { it.notificationId == downloadNotification.notificationId }
        } else {
            downloadList.add(downloadNotification)
        }
        val notification = buildNotification(downloading, downloadList.count { it.isCompleted },
                downloadList.size)
        notificationManager.notify(MUSIC_DOWNLOAD_GROUP, notification)
        return true
    }

    //will be called when Fetch closed
    override fun cancelOngoingNotifications() {
        downloading = null
        val notification = buildNotification(null, downloadList.count { it.isCompleted }, downloadList.size)
        notificationManager.notify(MUSIC_DOWNLOAD_GROUP, notification)
    }

    private fun buildNotification(downloading: DownloadNotification?, downloaded: Int, total: Int): Notification {
        val ongoing = downloading != null
        val title: String =
                (if (ongoing) "正在下载第${downloaded + 1}" else "已下载$downloaded") + " / $total 首歌曲"
        var content = downloading?.download?.file?.substringAfterLast('/')?.substringBeforeLast('.')
        content = if (content == null) null else "下载中: $content"
        val intent = Intent(AppContext, MainActivity::class.java)
        intent.putExtra(MainActivity.KEY_DESTINATION, MainActivity.DESTINATION_DOWNLOAD_PAGE)
        return NotificationCompat.Builder(AppContext, getChannelId(0, AppContext))
                .setContentTitle(title)
                .setContentText(content)
                .setOngoing(ongoing)
                .setContentIntent(PendingIntent.getActivity(AppContext, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT))
                .setSmallIcon(android.R.drawable.stat_sys_download_done)
                .build()
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

/**
 * @param addition addition after the title, eg(addition = 1, filename will be title(1) - artists.mp3 )
 *        if addition = 0 , do not effect
 */
private fun getFileName(url: String, music: Music, addition: Int = 0): String {
    val suffix = url.substringAfterLast('.', "mp3")
    val name = music.getTitle() + if (addition > 0) "($addition)" else ""
    val artist = music.getArtistsString().replace('/', ' ')
    return "$name - $artist.$suffix"
}

//music have permission [WRITE_EXTERNAL_STORAGE]
private fun buildRequest(music: Music): Request {
    val url = music.getPlayUrl()
    var i = 0
    var file = File("${DownloadPlugin.DEFAULT_DOWNLOAD_PATH}/${getFileName(url, music, addition = i)}")
    //loop to look for a not exists file
    while (file.exists()) {
        i++
        file = File("${DownloadPlugin.DEFAULT_DOWNLOAD_PATH}/${getFileName(url, music, addition = i)}")
    }
    val request = Request(url, file.path)
    request.identifier = music.getId()
    request.extras = Extras(mapOf(
            "music" to JSONObject(music.map).toString()
    ))
    request.groupId = MUSIC_DOWNLOAD_GROUP

    log { "${music.getTitle()} file: ${file.path}" }

    return request
}