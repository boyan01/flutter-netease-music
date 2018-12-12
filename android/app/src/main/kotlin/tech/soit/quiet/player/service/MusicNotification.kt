package tech.soit.quiet.player.service

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Color
import android.os.Build
import android.support.annotation.VisibleForTesting
import android.support.v4.app.NotificationCompat
import android.support.v7.graphics.Palette
import android.support.v7.graphics.Target.MUTED
import android.support.v7.graphics.Target.VIBRANT
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.async
import kotlinx.coroutines.launch
import tech.soit.quiet.AppContext
import tech.soit.quiet.MainActivity
import tech.soit.quiet.R
import tech.soit.quiet.model.vo.Music
import tech.soit.quiet.player.MusicPlayerManager
import tech.soit.quiet.player.core.IMediaPlayer


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

    private var music: Music? = null

    private var isPlaying: Boolean = false

    private var isFavorite: Boolean = false

    /**
     * 标识是否通知正常完成
     *
     * 如果图片还在从服务端进行加载，而是使用的默认的图片来弹出通知的话，则视为当前通知还没完成。
     */
    private var isNotifyCompleted = false

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

        val playerState = MusicPlayerManager.playerState.value
        val music = MusicPlayerManager.playingMusic.value

        if (music == null) {
            onCancel()
            return
        }

        val isPlaying: Boolean
        val isFav: Boolean = music.isFavorite()
        val cancelAble: Boolean
        if (playerState == IMediaPlayer.PLAYING) {
            isPlaying = true
            cancelAble = false
        } else {
            cancelAble = true
            isPlaying = false
        }

        val isDataMatched =
                this.music == music && this.isPlaying == isPlaying
                        && isFavorite == isFav
        val notNeedNotify = isDataMatched && isNotifyCompleted
        if (notNeedNotify) {
            return
        }

        this.music = music
        this.isPlaying = isPlaying
        isFavorite = isFav
        isNotifyCompleted = false

        GlobalScope.launch(Dispatchers.Main) {
            val builder = NotificationCompat
                    .Builder(context, ID_PLAY_SERVICE)
                    .buildStep1()
                    .buildStep2(music)
                    .buildStep3(music.getCoverBitmap())
            onNotify(builder, cancelAble)
        }
        isNotifyCompleted = true

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

    private fun NotificationCompat.Builder.buildStep2(music: Music): NotificationCompat.Builder {
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


    private suspend fun NotificationCompat.Builder.buildStep3(image: Bitmap?): NotificationCompat.Builder {
        image?.let {
            setLargeIcon(it)
            val palette = GlobalScope
                    .async { Palette.from(it).clearTargets().addTarget(MUTED).addTarget(VIBRANT).generate() }
                    .await()
            val color = palette.getVibrantColor(palette.getMutedColor(Color.WHITE))
            setColorized(true)
            setColor(color)
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
