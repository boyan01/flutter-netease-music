package tech.soit.quiet.player.core

import android.net.Uri
import com.google.android.exoplayer2.ExoPlaybackException
import com.google.android.exoplayer2.ExoPlayerFactory
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.SimpleExoPlayer
import com.google.android.exoplayer2.source.ExtractorMediaSource
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.upstream.cache.CacheDataSourceFactory
import com.google.android.exoplayer2.upstream.cache.LeastRecentlyUsedCacheEvictor
import com.google.android.exoplayer2.upstream.cache.SimpleCache
import tech.soit.quiet.AppContext
import kotlin.properties.Delegates

class QuietExoPlayer(
        private val exoPlayer: SimpleExoPlayer = ExoPlayerFactory.newSimpleInstance(AppContext)
) : IMediaPlayer {

    companion object {

        private const val USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" +
                " (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/13.10586"


        private val cache = SimpleCache(AppContext.filesDir, LeastRecentlyUsedCacheEvictor(1000 * 1000 * 100))

    }

    init {
        exoPlayer.addListener(object : Player.EventListener {
            override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
                when (playbackState) {
                    Player.STATE_READY -> {
                        _state = if (playWhenReady) {
                            IMediaPlayer.PLAYING
                        } else {
                            IMediaPlayer.PAUSING
                        }
                    }
                    Player.STATE_BUFFERING -> {
                        _state = IMediaPlayer.PREPARING
                    }
                    Player.STATE_IDLE -> {
                        _state = IMediaPlayer.IDLE
                    }
                    Player.STATE_ENDED -> {
                        _state = IMediaPlayer.IDLE
                    }
                }
            }

            override fun onPlayerError(error: ExoPlaybackException) {
                _state = IMediaPlayer.ERROR
                onStateChangeCallback?.invoke(IMediaPlayer.ERROR, error)
            }
        })
    }

    private var _state: Int by Delegates.observable(IMediaPlayer.IDLE) { _, _, new ->
        if (new != IMediaPlayer.ERROR) {
            onStateChangeCallback?.invoke(new, null)
        }
    }

    override fun prepare(uri: String, playWhenReady: Boolean) {
        val source = ExtractorMediaSource.Factory(CacheDataSourceFactory(cache,
                DefaultDataSourceFactory(AppContext, USER_AGENT)))
                .createMediaSource(Uri.parse(uri))
        exoPlayer.prepare(source)
        exoPlayer.playWhenReady = playWhenReady
    }

    override fun seekTo(position: Long) {
        exoPlayer.seekTo(position)
    }

    override var isPlayWhenReady: Boolean
        get() = exoPlayer.playWhenReady
        set(value) {
            exoPlayer.playWhenReady = value
        }

    override fun release() {
        exoPlayer.stop(true)
    }

    override fun getState(): Int = _state

    private var onStateChangeCallback: ((Int, payload: Any?) -> Unit)? = null

    override fun setOnStateChangeCallback(callBack: ((state: Int, payload: Any?) -> Unit)?) {
        this.onStateChangeCallback = callBack
    }

    override fun getPosition(): Long {
        return exoPlayer.currentPosition
    }

    override fun getDuration(): Long {
        return exoPlayer.duration
    }

}