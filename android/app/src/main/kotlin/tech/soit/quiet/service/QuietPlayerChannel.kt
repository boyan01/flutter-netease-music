package tech.soit.quiet.service

import android.arch.lifecycle.Lifecycle
import android.arch.lifecycle.LifecycleOwner
import android.arch.lifecycle.LifecycleRegistry
import android.graphics.Bitmap
import android.os.Parcel
import android.os.Parcelable
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import tech.soit.quiet.model.vo.Music
import tech.soit.quiet.player.MusicPlayerCallback
import tech.soit.quiet.player.PlayMode
import tech.soit.quiet.player.QuietMusicPlayer
import tech.soit.quiet.player.core.IMediaPlayer
import tech.soit.quiet.player.playlist.Playlist
import tech.soit.quiet.utils.log

object BufferedChannelCallback : MusicPlayerCallback {

    private var channel: MethodChannel? = null

    fun setUpChannel(channel: MethodChannel?) {
        this.channel = channel
        channel ?: return
        onMusicChanged(holder.playing)
        onPlayerStateChanged(holder.state)
        onPlaylistUpdated(holder.playlist)
        onPositionChanged(holder.position, holder.duration)
    }

    private val holder = object {
        var playing: Music? = null
        var state: Int = IMediaPlayer.IDLE
        var playlist = Playlist.EMPTY
        var position: Long = 0
        var duration: Long = 0
    }

    override fun onMusicChanged(music: Music?) {
        holder.playing = music
        channel?.invokeMethod("onPlayingMusicChanged", (music as QuietPlayerChannel.ItemMusic?)?.map)
    }

    override fun onPlayerStateChanged(state: Int) {
        holder.state = state
        channel?.invokeMethod("onPlayStateChanged", state)
    }

    override fun onPlaylistUpdated(playlist: Playlist) {
        holder.playlist = playlist
        channel?.invokeMethod("onPlayingListChanged", mapOf(
                "list" to playlist.list.map { (it as QuietPlayerChannel.ItemMusic).map },
                "token" to playlist.token
        ))
    }

    override fun onPositionChanged(position: Long, duration: Long) {
        holder.position = position
        holder.duration = duration
        channel?.invokeMethod("onPositionChanged", mapOf<String, Any>(
                "position" to (position),
                "duration" to (duration)
        ))

    }
}


/**
 * channel contact with Dart
 *
 * if dart vm reload: call 'init', to synchronize data with Platform and Flutter
 *
 */
class QuietPlayerChannel(private val channel: MethodChannel) : MethodChannel.MethodCallHandler, LifecycleOwner {

    private val lifecycle = LifecycleRegistry(this)

    override fun getLifecycle(): Lifecycle {
        return lifecycle
    }

    companion object {

        private const val CHANNEL_ID = "tech.soit.quiet/player"

        fun registerWith(registrar: PluginRegistry.Registrar): QuietPlayerChannel {
            val methodChannel = MethodChannel(registrar.messenger(), CHANNEL_ID)
            val quietPlayerChannel = QuietPlayerChannel(methodChannel)
            methodChannel.setMethodCallHandler(quietPlayerChannel)
            return quietPlayerChannel
        }

    }

    /**
     * destroy this channel callback
     * remove observe callback
     */
    fun destroy() {
        BufferedChannelCallback.setUpChannel(null)
    }

    private val player get() = QuietMusicPlayer.getInstance()

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

        log { "call : ${call.method}" }

        when (call.method) {
            "init" -> {
                BufferedChannelCallback.setUpChannel(channel)
                if (player.playlist.token != Playlist.TOKEN_EMPTY) {
                    //when current player is available, we do not need init playlist
                    //but also need send event to Flutter Framework
                    return
                }
                val token = call.argument<String>("token") ?: return
                val list = call.argument<List<HashMap<String, Any>>>("list")?.map { ItemMusic(it) }
                        ?: return
                player.playlist = Playlist(token, list)
                player.playlist.current = call.argument<HashMap<String, Any>>("music")?.let { ItemMusic(it) }
                player.playMode = PlayMode.values()[call.argument<Int>("playMode") ?: 0]
            }
            "play" -> {
                player.play()
            }
            "playWithPlaylist" -> {
                //token , list , music argument must not be null

                val token = call.argument<String>("token")!!
                val list = call.argument<List<HashMap<String, Any>>>("list")!!.map { ItemMusic(it) }
                val music = ItemMusic(call.argument<HashMap<String, Any>>("music")!!)

                player.playlist = Playlist(token, list)
                player.play(music)

            }
            "pause" -> {
                player.pause()
            }
            "playNext" -> {
                player.playNext()
            }
            "playPrevious" -> {
                player.playPrevious()
            }
            "setPlaylist" -> {
                val token = call.argument<String>("token")!!
                val list = call.argument<List<HashMap<String, Any>>>("list")!!.map { ItemMusic(it) }
                player.playlist = Playlist(
                        token = token,
                        musics = list
                )
            }
            "insertToNext" -> {
                val music = ItemMusic(call.arguments<HashMap<String, Any>>())
                player.playlist.insertToNext(music)
            }
            "seekTo" -> {
                player.mediaPlayer.seekTo(call.arguments())
            }
            "setVolume" -> {

            }
            "setPlayMode" -> {
                val index: Int = call.arguments()
                player.playMode = PlayMode.values()[index]
            }
            "position" -> {
                result.success(player.mediaPlayer.getPosition())
            }
            "duration" -> {
                result.success(player.mediaPlayer.getDuration())
            }
            else -> {
                result.notImplemented()
            }
        }
    }


    class ItemMusic(
            val map: HashMap<String, Any>
    ) : Music(), Parcelable {
        override fun getId(): Long {
            return (map["id"] as Number).toLong()
        }

        override fun getTitle(): String {
            return map["title"] as String
        }

        override fun getSubTitle(): String {
            return map["subTitle"] as String
        }

        override fun getPlayUrl(): String {
            return map["url"] as String
        }

        override fun isFavorite(): Boolean {
            return map["isFavorite"] as? Boolean ?: false
        }

        override fun getCoverBitmap(): Bitmap? {
            return null
        }

        @Suppress("UNCHECKED_CAST")
        constructor(source: Parcel) : this(
                source.readHashMap(null) as HashMap<String, Any>
        )

        override fun describeContents() = 0

        override fun writeToParcel(dest: Parcel, flags: Int) = with(dest) {
            writeSerializable(map)
        }

        companion object {
            @Suppress("unused")
            @JvmField
            val CREATOR: Parcelable.Creator<ItemMusic> = object : Parcelable.Creator<ItemMusic> {
                override fun createFromParcel(source: Parcel): ItemMusic = ItemMusic(source)
                override fun newArray(size: Int): Array<ItemMusic?> = arrayOfNulls(size)
            }
        }
    }

}


