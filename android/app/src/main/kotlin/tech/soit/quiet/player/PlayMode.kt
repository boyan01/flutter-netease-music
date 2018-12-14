package tech.soit.quiet.player


/**
 *
 * PlayMode of MusicPlayer
 *
 * please ensure that this enum values index the same as Dart enum PlayMode
 *
 * @author YangBin
 */
enum class PlayMode {
    //单曲循环
    Single,
    //列表循环
    Sequence,
    //随机播放
    Shuffle;

    companion object {

        /**
         * safely convert enum name to instance
         */
        fun from(name: String?) = when (name) {
            Shuffle.name -> Shuffle
            Single.name -> Single
            Sequence.name -> Sequence
            else -> Sequence
        }

    }

    fun next(): PlayMode = when (this) {
        Single -> Shuffle
        Shuffle -> Sequence
        Sequence -> Single
    }

}