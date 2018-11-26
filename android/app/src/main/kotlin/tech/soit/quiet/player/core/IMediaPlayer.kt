package tech.soit.quiet.player.core


/**
 * player interface
 */
interface IMediaPlayer {

    companion object {

        const val IDLE = 0x0

        const val PLAYING = 0x1

        const val PAUSING = 0x2

        const val PREPARING = 0x3

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
     */
    fun setOnStateChangeCallback(callBack: ((state: @PlayerState Int) -> Unit)?)


    /**
     * @param callBack invoke when music play complete
     */
    fun setOnCompleteListener(callBack: (() -> Unit)?)

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