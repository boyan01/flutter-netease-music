package tech.soit.quiet.player.service

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.os.Build
import android.support.annotation.VisibleForTesting
import android.support.v4.app.NotificationCompat
import com.google.android.exoplayer2.Player
import tech.soit.quiet.AppContext
import tech.soit.quiet.MainActivity
import tech.soit.quiet.R
import tech.soit.quiet.player.Music
import tech.soit.quiet.player.QuietMusicPlayer


/**
 * Utils for notify MediaStyle notification for music
 *
 * see more at [update]
 */
class MusicNotification {

    companion object {

        const val ID_PLAY_SERVICE = "music_play_service"

        const val ID_NOTIFICATION_PLAY_SERVICE = 0x30312


    }


    private val context: Context get() = AppContext


    private val notificationManger: NotificationManager by lazy {
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }

    init {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelMusicService =
                    NotificationChannel(ID_PLAY_SERVICE,
                            "quiet_music_player", NotificationManager.IMPORTANCE_LOW)

            channelMusicService.description = "music player service"
            channelMusicService.enableLights(false)
            channelMusicService.enableVibration(false)
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channelMusicService)
        }
    }


    /**
     * update current music notification
     *
     * Note: the notification will not refresh if music or player'state do not changed
     *
     * when player paused,the notification will be cancelAble for user and will stop foreground service.
     *
     * @param service the tech.soit.quiet.ui.service.QuietPlayerService
     */
    fun update(service: Service) {
        checkNotification(
                onCancel = {
                    notificationManger.cancel(ID_NOTIFICATION_PLAY_SERVICE)
                },
                onNotify = { builder, cancelAble ->
                    val notification = builder.build()
                    service.notify(notification, cancelAble)
                })
    }


    @VisibleForTesting
    fun checkNotification(
            onNotify: (builder: NotificationCompat.Builder, cancelAble: Boolean) -> Unit,
            onCancel: () -> Unit
    ) {

        val player = QuietMusicPlayer.getInstance()
        val music = player.current

        if (music == null) {
            onCancel()
            return
        }

        val isPlaying: Boolean
        val isFav: Boolean = music.isFavorite()
        val cancelAble: Boolean
        if (player.playbackState == Player.STATE_READY && player.playWhenReady) {
            isPlaying = true
            cancelAble = false
        } else {
            cancelAble = true
            isPlaying = false
        }


        val builder = NotificationCompat
                .Builder(context, ID_PLAY_SERVICE)
                .buildStep1()
                .buildStep2(music, isFav, isPlaying)
                .buildStep3(music.getCoverBitmap(), null)
        onNotify(builder, cancelAble)

    }


    private fun Service.notify(notification: Notification, cancelAble: Boolean) {
        if (cancelAble.not()) {
            startForeground(ID_NOTIFICATION_PLAY_SERVICE, notification)
        } else {
            stopForeground(false)
            notificationManger.notify(ID_NOTIFICATION_PLAY_SERVICE, notification)
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

    private fun NotificationCompat.Builder.buildStep2(music: Music, isFavorite: Boolean, isPlaying: Boolean): NotificationCompat.Builder {
        setContentTitle(music.getTitle())
        setContentText(music.getSubTitle())

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


    private fun NotificationCompat.Builder.buildStep3(image: Bitmap?, color: Int?): NotificationCompat.Builder {
        image?.let {
            setLargeIcon(it)
        }
        color?.let {
            setColorized(true)
            setColor(it)
        }
        return this
    }


    private fun buildContentIntent(): PendingIntent {
        val intent = Intent(context, MainActivity::class.java)
        intent.putExtra(MainActivity.KEY_DESTINATION, MainActivity.DESTINATION_PLAYING_PAGE)
        return PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)
    }

    private fun buildPlaybackAction(which: Int): PendingIntent {
        val intent = Intent(context, QuietPlayerService::class.java)
        val action: PendingIntent
        when (which) {
            0 -> {
                intent.action = QuietPlayerService.action_like
                action = PendingIntent.getService(context, 0, intent, 0)
            }
            1 -> {
                intent.action = QuietPlayerService.action_play_previous
                action = PendingIntent.getService(context, 1, intent, 0)
            }
            2 -> {
                intent.action = QuietPlayerService.action_play_pause
                action = PendingIntent.getService(context, 2, intent, 0)
            }
            3 -> {
                intent.action = QuietPlayerService.action_play_next
                action = PendingIntent.getService(context, 3, intent, 0)
            }
            4 -> {
                intent.action = QuietPlayerService.action_exit
                action = PendingIntent.getService(context, 4, intent, 0)
            }
            5 -> {
                intent.action = QuietPlayerService.action_dislike
                action = PendingIntent.getService(context, 5, intent, 0)
            }
            else -> error("")
        }
        return action
    }


}
