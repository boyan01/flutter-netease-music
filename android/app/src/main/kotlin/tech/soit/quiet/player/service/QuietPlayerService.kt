package tech.soit.quiet.player.service

import android.app.Service
import android.arch.lifecycle.*
import android.content.Context
import android.content.Intent
import android.os.Binder
import android.os.IBinder
import android.support.annotation.VisibleForTesting
import tech.soit.quiet.AppContext
import tech.soit.quiet.player.MusicPlayerManager
import tech.soit.quiet.player.QuietMusicPlayer
import tech.soit.quiet.player.core.IMediaPlayer
import tech.soit.quiet.utils.LoggerLevel
import tech.soit.quiet.utils.log

/**
 *
 * the player service which work on Background
 *
 *
 * author : YangBin
 * date   : 2017/12/27
 */
class QuietPlayerService : Service(), LifecycleOwner {

    private val lifecycleRegister = LifecycleRegistry(this)

    override fun getLifecycle(): Lifecycle {
        return lifecycleRegister
    }

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
         * register [MusicPlayerManager.playerState] to ensure service running.
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
            } else {
                log(LoggerLevel.DEBUG) {
                    "we do not need to start music MusicPlayer service ," +
                            "because it is already running..."
                }
            }
        }

        var notificationHelper: MusicNotification = MusicNotification()
            @VisibleForTesting set

    }

    private val playerServiceBinder = PlayerServiceBinder()

    private val musicPlayer get() = MusicPlayerManager.musicPlayer


    override fun onCreate() {
        isRunning = true
        super.onCreate()
        lifecycleRegister.markState(Lifecycle.State.STARTED)
        MusicPlayerManager.playerState.observe(this, Observer {
            notificationHelper.update(this)
        })
        MusicPlayerManager.playingMusic.observe(this, Observer {
            if (it == null) {
                stopForeground(false)
            }
            notificationHelper.update(this)
        })
    }

    override fun onBind(intent: Intent?): IBinder? = playerServiceBinder

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        when (action) {
            action_play_previous -> {
                MusicPlayerManager.musicPlayer.playPrevious()
            }
            action_play_pause -> {
                if (MusicPlayerManager.playerState.value == IMediaPlayer.PLAYING) {
                    MusicPlayerManager.musicPlayer.pause()
                } else {
                    MusicPlayerManager.musicPlayer.play()
                }
            }
            action_play_next -> {
                MusicPlayerManager.musicPlayer.playNext()
            }
            action_exit -> {
                stopForeground(true)
                MusicPlayerManager.musicPlayer.quiet()
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
        super.onDestroy()
        lifecycleRegister.markState(Lifecycle.State.DESTROYED)
        musicPlayer.quiet()
        isRunning = false
    }


    /**
     * service binder
     */
    inner class PlayerServiceBinder : Binder() {

        /**
         * [QuietPlayerService]
         */
        val service get() = this@QuietPlayerService

    }


}