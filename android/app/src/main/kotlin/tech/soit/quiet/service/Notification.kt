package tech.soit.quiet.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.Build
import android.os.IBinder
import android.support.v4.app.NotificationCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import tech.soit.quiet.MainActivity
import tech.soit.quiet.MainActivity.Companion.DESTINATION_PLAYING_PAGE
import tech.soit.quiet.MainActivity.Companion.KEY_DESTINATION
import tech.soit.quiet.R

class Notification(
        private val registrar: PluginRegistry.Registrar
) : MethodChannel.MethodCallHandler {

    companion object {

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(
                    registrar.messenger(), "tech.soit.quiet/notification")
            channel.setMethodCallHandler(Notification(registrar))
            QuietPlayerService.channel = channel
        }


        private const val ID_PLAY_SERVICE = "music_play_service"

        private const val ID_NOTIFICATION_PLAY_SERVICE = 0x30312


    }

    init {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelMusicService =
                    NotificationChannel(ID_PLAY_SERVICE, "music player service", NotificationManager.IMPORTANCE_LOW)
            channelMusicService.description = "控制音乐播放"
            channelMusicService.enableLights(false)
            channelMusicService.enableVibration(false)
            val notificationManager = registrar.context().getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channelMusicService)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "update" -> {
                update(title = call.argument("title") ?: "title",
                        subTitle = call.argument("subtitle") ?: "subtitle",
                        isPlaying = call.argument("isPlaying") ?: false,
                        isFavorite = call.argument("isFavorite") ?: false,
                        imageBytes = call.argument("coverBytes"),
                        backgroundColor = call.argument("background") ?: Color.GRAY)
            }
            "cancel" -> {
                cancel()
            }
            else -> result.notImplemented()
        }
    }


    private fun cancel() {
        val notificationManager = registrar.context().getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(ID_NOTIFICATION_PLAY_SERVICE)
        QuietPlayerService.close(registrar.context())
    }


    private fun update(title: String,
                       subTitle: String,
                       isPlaying: Boolean,
                       isFavorite: Boolean,
                       imageBytes: ByteArray?,
                       backgroundColor: Int) {
        QuietPlayerService.onServiceAvailable(registrar.context()) { service ->
            val notification = NotificationCompat.Builder(registrar.context(), ID_PLAY_SERVICE)
                    .buildStep1()
                    .buildStep2(title, subTitle, isFavorite, isPlaying)
                    .buildStep3(imageBytes, color = backgroundColor)
                    .build()
            service.startForeground(ID_NOTIFICATION_PLAY_SERVICE, notification)
            if (!isPlaying) {
                service.stopForeground(false)
            }
        }
    }

    private fun NotificationCompat.Builder.buildStep1(): NotificationCompat.Builder {
        setShowWhen(true)
        val mediaStyle = android.support.v4.media.app.NotificationCompat.MediaStyle()
                .setShowActionsInCompactView(0, 1, 2)
        setStyle(mediaStyle)
        setSmallIcon(R.drawable.ic_music_note_black_24dp)
        setColorized(true)
        setContentIntent(buildContentIntent())
        return this
    }

    private fun NotificationCompat.Builder.buildStep2(
            title: String,
            subTitle: String,
            isFavorite: Boolean,
            isPlaying: Boolean
    ): NotificationCompat.Builder {

        setContentTitle(title)
        setContentText(subTitle)


        if (isFavorite) {
            addAction(R.drawable.ic_favorite_black_24dp, "收藏", buildPlaybackAction(0))
        } else {
            addAction(R.drawable.ic_favorite_border_black_24dp, "取消收藏", buildPlaybackAction(0))
        }

        addAction(R.drawable.ic_skip_previous_black_24dp, "上一首", buildPlaybackAction(1))

        if (isPlaying) {
            addAction(R.drawable.ic_pause_black_24dp, "暂停", buildPlaybackAction(2))
        } else {
            addAction(R.drawable.ic_play_arrow_black_24dp, "播放", buildPlaybackAction(2))
        }

        addAction(R.drawable.ic_skip_next_black_24dp, "下一首", buildPlaybackAction(3))

        addAction(R.drawable.ic_close_black_24dp, "退出", buildPlaybackAction(4))

        setContentIntent(buildContentIntent())

        return this
    }

    private fun buildContentIntent(): PendingIntent {
        val intent = Intent(registrar.context(), MainActivity::class.java)
        intent.putExtra(KEY_DESTINATION, DESTINATION_PLAYING_PAGE)
        return PendingIntent.getActivity(registrar.context(), 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
    }

    private fun buildPlaybackAction(which: Int): PendingIntent {
        val intent = Intent(registrar.context(), QuietPlayerService::class.java)
        val action: PendingIntent
        when (which) {
            0 -> {
                intent.action = QuietPlayerService.action_like
                action = PendingIntent.getService(registrar.context(), 0, intent, 0)
            }
            1 -> {
                intent.action = QuietPlayerService.action_play_previous
                action = PendingIntent.getService(registrar.context(), 1, intent, 0)
            }
            2 -> {
                intent.action = QuietPlayerService.action_play_pause
                action = PendingIntent.getService(registrar.context(), 2, intent, 0)
            }
            3 -> {
                intent.action = QuietPlayerService.action_play_next
                action = PendingIntent.getService(registrar.context(), 3, intent, 0)
            }
            4 -> {
                intent.action = QuietPlayerService.action_exit
                action = PendingIntent.getService(registrar.context(), 4, intent, 0)
            }
            5 -> {
                intent.action = QuietPlayerService.action_dislike
                action = PendingIntent.getService(registrar.context(), 5, intent, 0)
            }
            else -> error("")
        }
        return action
    }

    private fun NotificationCompat.Builder.buildStep3(image: ByteArray?, color: Int): NotificationCompat.Builder {
        if (image != null) {
            setLargeIcon(BitmapFactory.decodeByteArray(image, 0, image.size))
        }
        setColor(color)
        return this
    }

}


class QuietPlayerService : Service() {

    companion object {


        /**
         * action skip to play previous
         */
        const val action_play_previous = "previous"

        /**
         * action play when not playing, pause when playing
         */
        const val action_play_pause = "play_pause"

        /**
         * action skip to play next
         */
        const val action_play_next = "next"

        /**
         * action close player
         */
        const val action_exit = "exit"

        /**
         * action add this music to favorite
         */
        const val action_like = "like"

        /**
         * action remove this music from favorite
         */
        const val action_dislike = "dislike"

        private var service: QuietPlayerService? = null

        private var waitForService: ((service: QuietPlayerService) -> Unit)? = null

        /**
         * run block when service is available
         */
        fun onServiceAvailable(context: Context, block: (service: QuietPlayerService) -> Unit) {
            val service = this.service
            if (service != null) {
                block(service)
                return
            }
            waitForService = block
            context.startService(Intent(context, QuietPlayerService::class.java))
        }

        fun close(context: Context) {
            service ?: return
            context.stopService(Intent(context, QuietPlayerService::class.java))
        }

        var channel: MethodChannel? = null

    }

    override fun onCreate() {
        super.onCreate()
        waitForService?.invoke(this)
        waitForService = null
        service = this
    }


    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        when (action) {
            action_play_previous -> {
                channel?.invokeMethod("playPrevious",null)
            }
            action_play_pause -> {
                channel?.invokeMethod("playOrPause",null)
            }
            action_play_next -> {
                channel?.invokeMethod("playNext",null)
            }
            action_exit -> {
                stopForeground(true)
                channel?.invokeMethod("quiet",null)
                stopSelf()
            }
            action_like -> {
                channel?.invokeMethod("like",null)
            }
            action_dislike -> {
                channel?.invokeMethod("dislike",null)
            }
        }
        return super.onStartCommand(intent, flags, startId)
    }



    override fun onDestroy() {
        super.onDestroy()
        service = null
    }

}