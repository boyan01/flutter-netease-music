package tech.soit.quiet.player

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import tech.soit.quiet.model.vo.Music
import tech.soit.quiet.player.core.IMediaPlayer
import tech.soit.quiet.player.core.QuietExoPlayer
import tech.soit.quiet.player.playlist.Playlist
import tech.soit.quiet.utils.LoggerLevel
import tech.soit.quiet.utils.log
import kotlin.properties.Delegates

/**
 * provide method could directly interaction with UI
 */
class QuietMusicPlayer {

    companion object {
        const val DURATION_UPDATE_PROGRESS = 200L

        private val instance = QuietMusicPlayer()

        fun getInstance(): QuietMusicPlayer {
            return instance
        }
    }

    /**
     * @see IMediaPlayer
     */
    val mediaPlayer: IMediaPlayer = QuietExoPlayer()

    /**
     * @see Playlist
     */
    var playlist: Playlist by Delegates.observable(Playlist.EMPTY) { _, oldValue, newValue ->

        musicPlayerCallback.onPlaylistUpdated(newValue)
        musicPlayerCallback.onMusicChanged(playlist.current)

        //stop player
        if (newValue != oldValue) {
            quiet()
        }
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

        override fun onError() = callbacks.forEach {
            it.onError()
        }

        override fun onBuffering() = callbacks.forEach {
            it.onBuffering()
        }

        override fun onPositionChanged(position: Long, duration: Long) = callbacks.forEach {
            it.onPositionChanged(position, duration)
        }

        val callbacks = ArrayList<MusicPlayerCallback>()

    }


    /**
     * play the music which return by [Playlist.getNext]
     */
    fun playNext() = safeAsync {
        val next = playlist.getNext()
        if (next == null) {
            log(LoggerLevel.WARN) { "next music is null" }
            return@safeAsync
        }
        play(next)
    }

    /**
     * pause player
     */
    fun pause() {
        mediaPlayer.isPlayWhenReady = false
    }

    /**
     * start player, if player is idle , try to play current music [Playlist.current]
     */
    fun play() = safeAsync {
        if (mediaPlayer.getState() == IMediaPlayer.IDLE) {
            val current = playlist.current
            if (current != null) {
                play(current)
            } else {
                playNext()
            }
        } else {
            mediaPlayer.isPlayWhenReady = true
        }
    }

    /**
     * play the music which return by [Playlist.getPrevious]
     */
    fun playPrevious() = safeAsync {
        val previous = playlist.getPrevious()
        if (previous == null) {
            log(LoggerLevel.WARN) { "previous is null , op canceled!" }
            return@safeAsync
        }
        play(previous)
    }

    /**
     * play [music] , if music is not in [playlist] , insert ot next
     */
    fun play(music: Music, playWhenReady: Boolean = true) {
        if (!playlist.list.contains(music)) {
            playlist.insertToNext(music)
            musicPlayerCallback.onPlaylistUpdated(playlist)
        }
        log { "try to play $music" }
        playlist.current = music

        musicPlayerCallback.onMusicChanged(music)

        val uri = music.getPlayUrl()
        mediaPlayer.prepare(uri, playWhenReady)
    }


    /**
     * stop play
     */
    fun quiet() {
        mediaPlayer.release()
    }


    private fun safeAsync(block: suspend () -> Unit) {
        GlobalScope.launch(Dispatchers.Main) { block() }
    }

    fun addCallback(callback: MusicPlayerCallback) {
        this.musicPlayerCallback.callbacks.add(callback)
    }

    fun removeCallback(callback: MusicPlayerCallback) {
        this.musicPlayerCallback.callbacks.remove(callback)
    }

    init {

        //indefinite to emit current playing music' duration and playing position
        //maybe have a cleverer way to do that!!
        GlobalScope.launch(Dispatchers.Main) {
            while (true) {
                delay(DURATION_UPDATE_PROGRESS)
                try {
                    val notify = playlist.current != null
                            && mediaPlayer.getState() == IMediaPlayer.PLAYING

                    if (notify) {
                        musicPlayerCallback?.onPositionChanged(mediaPlayer.getPosition(),
                                mediaPlayer.getDuration())
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

    fun onError() {}

    fun onBuffering() {}

    fun onPlayerStateChanged(state: Int) {}

    fun onPositionChanged(position: Long, duration: Long) {}

}