package tech.soit.quiet.player.playlist

import tech.soit.quiet.model.vo.Music
import tech.soit.quiet.player.PlayMode
import tech.soit.quiet.player.QuietMusicPlayer
import tech.soit.quiet.utils.log


/**
 *
 * playlist: music list which wait to be play
 *
 * a [Playlist] Object holder [list] [playMode] [current]
 * and provide method [getNext] and [getPrevious]
 *
 * @param token token to identify this playlist
 *
 * @author yangbinyhbn@gmail.com
 */
open class Playlist(
        val token: String
) {

    companion object {

        /**
         * the [token] identify that this Playlist is a FmPlayList
         */
        const val TOKEN_FM = "token_fm_player"

        const val TOKEN_EMPTY = "empty_playlist"


        val EMPTY = Playlist(TOKEN_EMPTY)

    }

    constructor(token: String, musics: List<Music>) : this(token) {
        listInternal.addAll(musics)
        if (musics.isNotEmpty()) {
            current = musics[0]
        }
    }

    private val listInternal = ArrayList<Music>()

    /**
     * the playlist' Music List
     */
    val list: List<Music> get() = listInternal

    var current: Music? = null

    private val playMode: PlayMode get() = QuietMusicPlayer.getInstance().playMode

    /**
     * get current playing ' next music
     */
    open suspend fun getNext(): Music? {
        if (listInternal.isEmpty()) {
            log { "empty playlist" }
            return null
        }
        val anchor = this.current ?: /*fast return */ return listInternal[0]
        return when (playMode) {
            PlayMode.Single -> {
                anchor
            }
            PlayMode.Sequence -> {
                //if can not find ,index will be zero , it will right too
                val index = listInternal.indexOf(anchor) + 1
                if (index == listInternal.size) {
                    listInternal[0]
                } else {
                    listInternal[index]
                }
            }
            PlayMode.Shuffle -> {
                ensureShuffleListGenerate()
                val index = shuffleMusicList.indexOf(anchor)
                when (index) {
                    -1 -> listInternal[0]
                    listInternal.size - 1 -> {
                        generateShuffleList()
                        shuffleMusicList[0]
                    }
                    else -> shuffleMusicList[index + 1]
                }
            }
        }
    }


    /**
     * get current playing ' previous music
     */
    open suspend fun getPrevious(): Music? {
        if (listInternal.isEmpty()) {
            log { "try too play next with empty playlist!" }
            return null
        }
        val anchor = this.current ?: return listInternal[0]
        return when (playMode) {
            PlayMode.Single -> {
                anchor
            }
            PlayMode.Sequence -> {
                val index = listInternal.indexOf(anchor)
                when (index) {
                    -1 -> listInternal[0]
                    0 -> listInternal[listInternal.size - 1]
                    else -> listInternal[index - 1]
                }
            }
            PlayMode.Shuffle -> {
                ensureShuffleListGenerate()
                val index = shuffleMusicList.indexOf(anchor)
                when (index) {
                    -1 -> listInternal[0]
                    0 -> {
                        generateShuffleList()
                        shuffleMusicList[shuffleMusicList.size - 1]
                    }
                    else -> shuffleMusicList[index - 1]
                }
            }
        }
    }


    /**
     * insert a music to playlist
     * it will be played when this music over
     */
    open fun insertToNext(next: Music) {
        if (listInternal.isEmpty()) {
            listInternal.add(next)
        } else {
            ensureShuffleListGenerate()

            //check if music is playing
            if (current == next) {
                return
            }
            //remove if musicList contain this item
            listInternal.remove(next)

            val index = listInternal.indexOf(current) + 1
            listInternal.add(index, next)

            val indexShuffle = shuffleMusicList.indexOf(current) + 1
            shuffleMusicList.add(indexShuffle, next)
        }
    }


    private val shuffleMusicList = ArrayList<Music>()

    private fun ensureShuffleListGenerate() {
        // regenerate shuffle playlist when music changed
        if (shuffleMusicList.size != listInternal.size) {
            generateShuffleList()
        }
    }

    /**
     * create shuffle list for [PlayMode.Shuffle]
     */
    private fun generateShuffleList() {
        val list = ArrayList(listInternal)
        var position = list.size - 1
        while (position > 0) {
            //生成一个随机数
            val random = (Math.random() * (position + 1)).toInt()
            //将random和position两个元素交换
            val temp = list[position]
            list[position] = list[random]
            list[random] = temp
            position--
        }
        shuffleMusicList.clear()
        shuffleMusicList.addAll(list)
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Playlist) return false

        if (token != other.token) return false

        return true
    }

    override fun hashCode(): Int {
        return token.hashCode()
    }


}