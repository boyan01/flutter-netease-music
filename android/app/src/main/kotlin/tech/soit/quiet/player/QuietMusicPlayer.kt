package tech.soit.quiet.player

import android.content.Intent
import android.net.Uri
import com.google.android.exoplayer2.ExoPlayerFactory
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.SimpleExoPlayer
import com.google.android.exoplayer2.source.ExtractorMediaSource
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.upstream.cache.CacheDataSourceFactory
import com.google.android.exoplayer2.upstream.cache.LeastRecentlyUsedCacheEvictor
import com.google.android.exoplayer2.upstream.cache.SimpleCache
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import tech.soit.quiet.AppContext
import tech.soit.quiet.player.playlist.Playlist
import tech.soit.quiet.player.service.QuietPlayerService
import tech.soit.quiet.player.service.QuietPlayerService.Companion.ensureServiceRunning
import tech.soit.quiet.utils.LoggerLevel
import tech.soit.quiet.utils.log
import kotlin.properties.Delegates

/**
 * provide method could directly interaction with UI
 */
class QuietMusicPlayer {

    companion object {

        private const val USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" +
                " (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/13.10586"


        private val cache = SimpleCache(AppContext.filesDir,
                LeastRecentlyUsedCacheEvictor(1000 * 1000 * 100))

        private fun buildSource(uri: String): ExtractorMediaSource {
            return ExtractorMediaSource.Factory(CacheDataSourceFactory(cache,
                    DefaultDataSourceFactory(AppContext, USER_AGENT)))
                    .createMediaSource(Uri.parse(uri))
        }

        const val DURATION_UPDATE_PROGRESS = 200L

        private val instance = QuietMusicPlayer()

        fun getInstance(): QuietMusicPlayer {
            return instance
        }
    }


    private var player: SimpleExoPlayer? = null


    private fun initPlayer() {
        player = ExoPlayerFactory.newSimpleInstance(AppContext).also {
            it.addListener(object : Player.EventListener {
                override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
                    if (playbackState == Player.STATE_ENDED) {
                        if (playMode == PlayMode.Single) {
                            player?.apply {
                                seekTo(0)
                                setPlayWhenReady(true)
                            }
                        } else {
                            playNext()//auto play next when ended
                        }
                    }
                    if (playbackState == Player.STATE_BUFFERING || playbackState == Player.STATE_READY) {
                        ensureServiceRunning()
                    }
                }
            })
            eventListeners.forEach(it::addListener)
        }
    }

    var playWhenReady: Boolean
        get() = player?.playWhenReady ?: false
        set(value) {
            if (playbackState == Player.STATE_IDLE || playbackError != null) {
                val current = this.current
                if (current != null) {
                    play(current)
                } else {
                    playNext()
                }
            } else {
                player?.playWhenReady = value
            }
        }

    private val eventListeners = ArrayList<Player.EventListener>()

    fun addListener(listener: Player.EventListener) {
        eventListeners.add(listener)
        player?.addListener(listener)
    }

    fun removeListener(listener: Player.EventListener) {
        eventListeners.remove(listener)
        player?.removeListener(listener)
    }

    val playbackState: Int get() = player?.playbackState ?: Player.STATE_IDLE

    val playbackError get() = player?.playbackError

    /**
     * @see Playlist
     */
    var playlist: Playlist by Delegates.observable(Playlist.EMPTY) { _, oldValue, newValue ->

        musicPlayerCallback.onPlaylistUpdated(newValue)

        //stop player
        if (newValue != oldValue) {
            player?.stop()
        }
    }

    var current: Music? by Delegates.observable<Music?>(null) { _, _, new ->
        musicPlayerCallback.onMusicChanged(new)
    }

    var playMode: PlayMode by Delegates.observable(PlayMode.Sequence) { _, _, new ->
        musicPlayerCallback.onPlayModeChanged(new)
    }

    private val musicPlayerCallback = object : MusicPlayerCallback {
        override fun onMusicChanged(music: Music?) = callbacks.forEach {
            it.onMusicChanged(music)
        }

        override fun onPlaylistUpdated(playlist: Playlist) = callbacks.forEach {
            it.onPlaylistUpdated(playlist)
        }

        override fun onPlayModeChanged(playMode: PlayMode) = callbacks.forEach {
            it.onPlayModeChanged(playMode)
        }

        override fun onPositionChanged(position: Long, duration: Long) = callbacks.forEach {
            it.onPositionChanged(position, duration)
        }

        val callbacks = ArrayList<MusicPlayerCallback>()
    }

    val position: Long get() = player?.currentPosition ?: 0

    val duration: Long get() = player?.duration ?: 0

    /**
     * play the music which return by [Playlist.getNext]
     */
    fun playNext() = safeAsync {
        val next = playlist.getNext(current)
        if (next == null) {
            log(LoggerLevel.WARN) { "next music is null" }
            return@safeAsync
        }
        play(next)
    }


    /**
     * play the music which return by [Playlist.getPrevious]
     */
    fun playPrevious() = safeAsync {
        val previous = playlist.getPrevious(current)
        if (previous == null) {
            log(LoggerLevel.WARN) { "previous is null , op canceled!" }
            return@safeAsync
        }
        play(previous)
    }

    /**
     * play [music] , if music is not in [playlist] , insert ot next
     */
    fun play(music: Music) {
        if (!playlist.list.contains(music)) {
            playlist.insertToNext(music, current)
            musicPlayerCallback.onPlaylistUpdated(playlist)
        }
        log { "try to play $music" }
        current = music

        val source = buildSource(music.getPlayUrl())
        if (player == null) {
            initPlayer()
        }
        player?.prepare(source)
        playWhenReady = true
    }


    fun release() {
        player?.release()
        player = null
        eventListeners.forEach {
            it.onPlayerStateChanged(false, Player.STATE_IDLE)
        }
    }

    /**
     * stop play and clear playing list
     */
    fun quiet() {
        if (player != null) {
            release()
        }
        playlist = Playlist.EMPTY
        current = null
    }

    private fun safeAsync(block: suspend () -> Unit) =
            GlobalScope.launch(Dispatchers.Main) { block() }

    fun addCallback(callback: MusicPlayerCallback) {
        this.musicPlayerCallback.callbacks.add(callback)
    }

    fun removeCallback(callback: MusicPlayerCallback) {
        this.musicPlayerCallback.callbacks.remove(callback)
    }

    fun seekTo(position: Long) = player?.seekTo(position)
    fun setVolume(volume: Float) {
        player?.volume = volume
    }

    init {

        //indefinite to emit current playing music' duration and playing position
        //maybe have a cleverer way to do that!!
        GlobalScope.launch(Dispatchers.Main) {
            while (true) {
                delay(DURATION_UPDATE_PROGRESS)
                try {
                    val notify = current != null
                            && playWhenReady && playbackState == Player.STATE_READY

                    if (notify) {
                        musicPlayerCallback.onPositionChanged(position,
                                duration)
                    }
                } catch (e: Exception) {
                    //ignore
                }
            }
        }
    }

}


interface MusicPlayerCallback {

    fun onMusicChanged(music: Music?) {}

    fun onPlaylistUpdated(playlist: Playlist) {}

    fun onPlayModeChanged(playMode: PlayMode) {}

    fun onPositionChanged(position: Long, duration: Long) {}

}