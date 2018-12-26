package tech.soit.quiet.player.service

import android.app.Service
import android.arch.lifecycle.LiveData
import android.content.Context
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import android.support.annotation.VisibleForTesting
import tech.soit.quiet.AppContext
import tech.soit.quiet.model.vo.Music
import tech.soit.quiet.player.MusicPlayerCallback
import tech.soit.quiet.player.QuietMusicPlayer
import tech.soit.quiet.player.core.IMediaPlayer

/**
 *
 * the player service which work on Background
 *
 *
 * author : YangBin
 * date   : 2017/12/27
 */
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


        /** flag that [QuietPlayerService] is Running */
        private var isRunning: Boolean = false


        /**
         * init with application.
         * to ensure service running.
         */
        fun init(playerState: LiveData<Int>) {
            playerState.observeForever {
                if (it == IMediaPlayer.PLAYING || it == IMediaPlayer.PREPARING) {
                    ensureServiceRunning()
                }
            }
        }

        /**
         * ensure [QuietPlayerService] is Running
         */
        private fun ensureServiceRunning(context: Context = AppContext) {
            if (!isRunning) {
                context.startService(Intent(context, QuietPlayerService::class.java))
            }
        }

        var notificationHelper: MusicNotification = MusicNotification()
            @VisibleForTesting set

    }

    private val playerServiceBinder = PlayerServiceBinder()

    private val musicPlayer get() = QuietMusicPlayer.getInstance()

    private val callback = object : MusicPlayerCallback {
        override fun onMusicChanged(music: Music?) {
            if (music == null) {
                stopForeground(false)
            }
            notificationHelper.update(this@QuietPlayerService)
        }

        override fun onPlayerStateChanged(state: Int) {
            notificationHelper.update(this@QuietPlayerService)
        }
    }

    override fun onCreate() {
        isRunning = true
        super.onCreate()
        musicPlayer.addCallback(callback)
    }

    override fun onBind(intent: Intent?): IBinder? = playerServiceBinder

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        when (action) {
            action_play_previous -> {
                musicPlayer.playPrevious()
            }
            action_play_pause -> {
                if (musicPlayer.mediaPlayer.getState() == IMediaPlayer.PLAYING) {
                    musicPlayer.pause()
                } else {
                    musicPlayer.play()
                }
            }
            action_play_next -> {
                musicPlayer.playNext()
            }
            action_exit -> {
                musicPlayer.quiet()
                stopForeground(true)
                stopSelf()
            }
            action_like -> {

            }
            action_dislike -> {

            }
        }
        bindPlayerToService()
        return super.onStartCommand(intent, flags, startId)
    }

    // to holder the instance of MusicPlayer
    private var instanceHolder: QuietMusicPlayer? = null

    private fun bindPlayerToService() {
        instanceHolder = musicPlayer
    }

    override fun onDestroy() {
        musicPlayer.removeCallback(callback)
        super.onDestroy()
        musicPlayer.quiet()
        isRunning = false
    }


    /**
     * service binder
     */
    inner class PlayerServiceBinder : Binder()


}