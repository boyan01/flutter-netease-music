package tech.soit.quiet.player.playlist

import tech.soit.quiet.model.vo.Music
import tech.soit.quiet.player.MusicPlayerManager
import tech.soit.quiet.player.PlayMode
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
        _list.addAll(musics)
        if (musics.isNotEmpty()) {
            current = musics[0]
        }
    }

    protected val _list = ArrayList<Music>()

    /**
     * the playlist' Music List
     */
    val list: List<Music> get() = _list

    var current: Music? = null

    var playMode: PlayMode = PlayMode.Sequence

    /**
     * get current playing ' next music
     */
    open suspend fun getNext(): Music? {
        if (_list.isEmpty()) {
            log { "empty playlist" }
            return null
        }
        val anchor = this.current ?: /*fast return */ return _list[0]
        return when (playMode) {
            PlayMode.Single -> {
                anchor
            }
            PlayMode.Sequence -> {
                //if can not find ,index will be zero , it will right too
                val index = _list.indexOf(anchor) + 1
                if (index == _list.size) {
                    _list[0]
                } else {
                    _list[index]
                }
            }
            PlayMode.Shuffle -> {
                ensureShuffleListGenerate()
                val index = shuffleMusicList.indexOf(anchor)
                when (index) {
                    -1 -> _list[0]
                    _list.size - 1 -> {
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
        if (_list.isEmpty()) {
            log { "try too play next with empty playlist!" }
            return null
        }
        val anchor = this.current ?: return _list[0]
        return when (playMode) {
            PlayMode.Single -> {
                anchor
            }
            PlayMode.Sequence -> {
                val index = _list.indexOf(anchor)
                when (index) {
                    -1 -> _list[0]
                    0 -> _list[_list.size - 1]
                    else -> _list[index - 1]
                }
            }
            PlayMode.Shuffle -> {
                ensureShuffleListGenerate()
                val index = shuffleMusicList.indexOf(anchor)
                when (index) {
                    -1 -> _list[0]
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
        if (_list.isEmpty()) {
            _list.add(next)
        } else {
            ensureShuffleListGenerate()

            //check if music is playing
            if (current == next) {
                return
            }
            //remove if musicList contain this item
            _list.remove(next)

            val index = _list.indexOf(current) + 1
            _list.add(index, next)

            val indexShuffle = shuffleMusicList.indexOf(current) + 1
            shuffleMusicList.add(indexShuffle, next)
        }
        MusicPlayerManager.playlist.postValue(this)
    }


    private val shuffleMusicList = ArrayList<Music>()

    private fun ensureShuffleListGenerate() {
        // regenerate shuffle playlist when music changed
        if (shuffleMusicList.size != _list.size) {
            generateShuffleList()
        }
    }

    /**
     * create shuffle list for [PlayMode.Shuffle]
     */
    private fun generateShuffleList() {
        val list = ArrayList(_list)
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