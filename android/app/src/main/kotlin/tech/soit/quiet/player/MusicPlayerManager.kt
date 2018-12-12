package tech.soit.quiet.player

import android.arch.lifecycle.MutableLiveData
import tech.soit.quiet.model.vo.Music
import tech.soit.quiet.player.core.IMediaPlayer
import tech.soit.quiet.player.playlist.Playlist
import tech.soit.quiet.player.service.QuietPlayerService

/**
 *
 * use [MusicPlayerManager]
 *
 * provider [musicPlayer] to access [IMediaPlayer] , [Playlist]
 * and play action such as :
 * [QuietMusicPlayer.playNext],
 * [QuietMusicPlayer.playPrevious],
 * [QuietMusicPlayer.playPause]
 *
 * provider LiveData such as [playingMusic] [position] [playerState] [playlist]
 * to listen MusicPlayer' state
 *
 * provider [play] method for convenience to play music
 *
 */
interface IMusicPlayerManager {


    var musicPlayer: QuietMusicPlayer

    val playingMusic: MutableLiveData<Music?>

    val position: MutableLiveData<Position>


    /**
     * [IMediaPlayer.PlayerState]
     */
    val playerState: MutableLiveData<Int>

    val playlist: MutableLiveData<Playlist>


    fun play(token: String, music: Music, list: List<Music>)


    /**
     * unit is Millisecond
     *
     * @param current the current playing position
     * @param total music total length
     */
    data class Position(val current: Long, val total: Long)

}


class MusicPlayerManagerImpl : IMusicPlayerManager {

    /**
     * music player, manage the playlist and [IMediaPlayer]
     *
     * ATTENTION: setter is only for TEST!!
     *
     */
    override var musicPlayer = QuietMusicPlayer()

    /**
     * current playing music live data
     */
    override val playingMusic = liveDataWith(musicPlayer.playlist.current)

    override val position = MutableLiveData<IMusicPlayerManager.Position>()

    /**
     * @see IMediaPlayer.PlayerState
     */
    override val playerState = liveDataWith(IMediaPlayer.IDLE)

    init {
        musicPlayer.mediaPlayer.setOnStateChangeCallback {
            playerState.postValue(it)
        }
    }


    override val playlist = MutableLiveData<Playlist>()

    /**
     * @param token [Playlist.token]
     * @param music the music which will be play
     * @param list the music from
     */
    override fun play(token: String, music: Music, list: List<Music>) {
        val newPlaylist = Playlist(token, list)
        newPlaylist.current = music
        musicPlayer.playlist = newPlaylist
        musicPlayer.play(music)
    }

    init {
        QuietPlayerService.init(playerState)
    }
}

/**
 * create MutableLiveData with initial value
 */
fun <T> liveDataWith(initial: T): MutableLiveData<T> {
    val liveData = MutableLiveData<T>()
    liveData.postValue(initial)//use post to fit any thread
    return liveData
}

object MusicPlayerManager : IMusicPlayerManager by MusicPlayerManagerImpl()
