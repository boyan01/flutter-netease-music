package tech.soit.quiet.player.core

import android.support.annotation.IntDef


/**
 * player interface
 */
interface IMediaPlayer {

    companion object {

        const val IDLE = 0

        const val PLAYING = 1

        const val PAUSING = 2

        const val PREPARING = 3

        const val ERROR = 4

        const val COMPLETE = 5


        @IntDef(IDLE, PLAYING, PAUSING, PREPARING, ERROR, COMPLETE)
        @Target(AnnotationTarget.TYPE)
        annotation class PlayerState

    }

    /**
     * start to play uri
     *
     * if source is not ready, this call will posted until source available
     */
    fun prepare(uri: String, playWhenReady: Boolean)

    /**
     * seek play position to [position]
     *
     * @param position millisecond
     */
    fun seekTo(position: Long)

    /**
     * flag to change the state of player
     *
     *  if set to false
     * [PLAYING] -> [PAUSING]
     * [PREPARING] -> do not play when source ready
     *
     */
    var isPlayWhenReady: Boolean

    /**
     * release all source of the player
     *
     * stop play and interrupt all jobs
     */
    fun release()

    /**
     * get current PlayerState
     *
     * @see PlayerState
     */
    fun getState(): @PlayerState Int


    /**
     *
     * set a callback to listener state change
     *
     * @param callBack on state change callback, null to remove
     *
     */
    fun setOnStateChangeCallback(callBack: ((state: @PlayerState Int, payload: Any?) -> Unit)?)

    /**
     * get current playing position
     *
     * if filed is not available , return 0
     */
    fun getPosition(): Long

    /**
     * get current playing music duration
     *
     * if filed is not available , return 0
     *
     */
    fun getDuration(): Long
}