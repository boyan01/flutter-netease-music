package tech.soit.quiet.player.service

import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import android.support.annotation.VisibleForTesting
import com.google.android.exoplayer2.Player
import tech.soit.quiet.AppContext
import tech.soit.quiet.player.Music
import tech.soit.quiet.player.MusicPlayerCallback
import tech.soit.quiet.player.QuietMusicPlayer

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
         * ensure [QuietPlayerService] is Running
         */
        fun ensureServiceRunning(context: Context = AppContext) {
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
    }

    private val playerEventListener = object : Player.EventListener {
        override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
            notificationHelper.update(this@QuietPlayerService)
        }
    }

    override fun onCreate() {
        isRunning = true
        super.onCreate()
        musicPlayer.addCallback(callback)
        musicPlayer.addListener(playerEventListener)
    }

    override fun onBind(intent: Intent?): IBinder? = playerServiceBinder

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        when (action) {
            action_play_previous -> {
                musicPlayer.playPrevious()
            }
            action_play_pause -> {
                musicPlayer.playWhenReady = !(musicPlayer.playWhenReady && musicPlayer.playbackState == Player.STATE_READY)
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
        musicPlayer.removeListener(playerEventListener)
        super.onDestroy()
        musicPlayer.quiet()
        isRunning = false
    }


    /**
     * service binder
     */
    inner class PlayerServiceBinder : Binder()


}