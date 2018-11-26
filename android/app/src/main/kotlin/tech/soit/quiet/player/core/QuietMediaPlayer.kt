package tech.soit.quiet.player.core

import android.media.MediaPlayer
import android.net.Uri
import tech.soit.quiet.AppContext
import kotlin.properties.Delegates

/**
 * [IMediaPlayer] impl by [android.media.MediaPlayer]
 */
class QuietMediaPlayer(
        private val player: MediaPlayer = MediaPlayer()
) : IMediaPlayer {


    private var onStateChangeListener: ((Int) -> Unit)? = null

    private var onCompletedListener: (() -> Unit)? = null

    init {
        player.setOnCompletionListener {
            onCompletedListener?.invoke()
        }
    }

    private var _state by Delegates.observable(IMediaPlayer.IDLE) { _, _, newValue ->
        //might invoke by worker thread
        onStateChangeListener?.invoke(newValue)
    }


    private var _isPlayWhenReady: Boolean = false

    override var isPlayWhenReady: Boolean
        get() = _isPlayWhenReady
        set(value) {
            _isPlayWhenReady = value
            if (value && _state == IMediaPlayer.PAUSING) {
                player.start()
                _state = IMediaPlayer.PLAYING
            } else if (!value && _state == IMediaPlayer.PLAYING) {
                player.pause()
                _state = IMediaPlayer.PAUSING
            }
        }

    override fun prepare(uri: String, playWhenReady: Boolean) {
        if (_state != IMediaPlayer.IDLE) {
            if (player.isPlaying) {
                player.stop()
            }
            player.reset()
            _state = IMediaPlayer.IDLE
        }
        isPlayWhenReady = playWhenReady
        player.setDataSource(AppContext, Uri.parse(uri))
        player.setOnPreparedListener {
            //change _state when player prepared
            _state = IMediaPlayer.PAUSING

            if (isPlayWhenReady) {
                it.start()
                _state = IMediaPlayer.PLAYING
            }
        }
        _state = IMediaPlayer.PREPARING
        player.prepareAsync()
    }


    override fun seekTo(position: Long) {
        if (_state == IMediaPlayer.IDLE) {
            return
        } else if (_state == IMediaPlayer.PREPARING) {
            //do nothing if is preparing
            return
        } else if (_state == IMediaPlayer.PLAYING || _state == IMediaPlayer.PAUSING) {
            player.seekTo(position.toInt())
        }
    }


    override fun release() {
        isPlayWhenReady = false
        _state = IMediaPlayer.IDLE
        player.reset()
    }

    override fun getState() = _state

    override fun getPosition(): Long {
        return player.currentPosition.toLong()
    }

    override fun getDuration(): Long {
        if (_state == IMediaPlayer.IDLE || _state == IMediaPlayer.PREPARING) {
            return 0L
        }
        return player.duration.toLong()
    }

    override fun setOnStateChangeCallback(callBack: ((state: Int) -> Unit)?) {
        this.onStateChangeListener = callBack
    }

    override fun setOnCompleteListener(callBack: (() -> Unit)?) {
        this.onCompletedListener = callBack
    }


}