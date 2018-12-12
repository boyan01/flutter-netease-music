package tech.soit.quiet.player


/**
 *
 * PlayMode of MusicPlayer
 *
 * @author 杨彬
 */
enum class PlayMode {
    //随机播放
    Shuffle,
    //单曲循环
    Single,
    //列表循环
    Sequence;

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