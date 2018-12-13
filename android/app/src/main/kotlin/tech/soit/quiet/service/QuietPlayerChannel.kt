package tech.soit.quiet.service

import android.graphics.Bitmap
import android.os.Parcel
import android.os.Parcelable
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import tech.soit.quiet.model.vo.Music
import tech.soit.quiet.player.MusicPlayerManager
import tech.soit.quiet.player.playlist.Playlist
import tech.soit.quiet.utils.log

class QuietPlayerChannel(private val registrar: PluginRegistry.Registrar,
                         private val channel: MethodChannel) : MethodChannel.MethodCallHandler {

    companion object {

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val methodChannel = MethodChannel(registrar.messenger(), "tech.soit.quiet/player")
            methodChannel.setMethodCallHandler(QuietPlayerChannel(registrar, methodChannel))
        }

    }

    init {
        //FIXME memory leak
        //MusicPlayerManager have a long lifecycle than a channel
        MusicPlayerManager.playerState.observeForever {
            channel.invokeMethod("onPlayStateChanged", it)
        }

        MusicPlayerManager.playingMusic.observeForever {
            channel.invokeMethod("onPlayingMusicChanged", (it as ItemMusic?)?.map)
        }

        MusicPlayerManager.playlist.observeForever { playlist ->
            channel.invokeMethod("onPlayingListChanged", playlist?.list?.map { (it as ItemMusic).map })
        }

        MusicPlayerManager.position.observeForever {
            channel.invokeMethod("onPositionChanged", mapOf<String, Any>(
                    "position" to (it?.current ?: 0),
                    "duration" to (it?.total ?: 0)
            ))
        }

    }

    private val player get() = MusicPlayerManager.musicPlayer

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "play" -> {
                if (call.arguments == null) {
                    player.playPause()
                } else {
                    player.play(ItemMusic(call.arguments<HashMap<String, Any>>()))
                }
            }
            "pause" -> {
                player.playPause()
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
            @JvmField
            val CREATOR: Parcelable.Creator<ItemMusic> = object : Parcelable.Creator<ItemMusic> {
                override fun createFromParcel(source: Parcel): ItemMusic = ItemMusic(source)
                override fun newArray(size: Int): Array<ItemMusic?> = arrayOfNulls(size)
            }
        }
    }

}


