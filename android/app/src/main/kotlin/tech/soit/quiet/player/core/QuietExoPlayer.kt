package tech.soit.quiet.player.core

import android.net.Uri
import com.google.android.exoplayer2.ExoPlayerFactory
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.SimpleExoPlayer
import com.google.android.exoplayer2.source.ExtractorMediaSource
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.upstream.cache.CacheDataSourceFactory
import com.google.android.exoplayer2.upstream.cache.LeastRecentlyUsedCacheEvictor
import com.google.android.exoplayer2.upstream.cache.SimpleCache
import tech.soit.quiet.AppContext

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
                onStateChangeCallback?.invoke(getState())
                if (playbackState == Player.STATE_ENDED) {
                    onCompleteListener?.invoke()
                }
            }
        })
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
        exoPlayer.release()
    }

    override fun getState(): Int {
        return when (exoPlayer.playbackState) {
            Player.STATE_BUFFERING -> IMediaPlayer.PREPARING
            Player.STATE_READY -> if (isPlayWhenReady) {
                IMediaPlayer.PLAYING
            } else {
                IMediaPlayer.PAUSING
            }
            else -> IMediaPlayer.IDLE
        }
    }

    private var onStateChangeCallback: ((Int) -> Unit)? = null

    override fun setOnStateChangeCallback(callBack: ((state: Int) -> Unit)?) {
        this.onStateChangeCallback = callBack
    }

    private var onCompleteListener: (() -> Unit)? = null

    override fun setOnCompleteListener(callBack: (() -> Unit)?) {
        this.onCompleteListener = callBack
    }

    override fun getPosition(): Long {
        return exoPlayer.currentPosition
    }

    override fun getDuration(): Long {
        return exoPlayer.duration
    }

}