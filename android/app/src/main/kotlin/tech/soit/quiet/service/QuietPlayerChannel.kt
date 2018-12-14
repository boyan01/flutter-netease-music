package tech.soit.quiet.service

import android.arch.lifecycle.Lifecycle
import android.arch.lifecycle.LifecycleOwner
import android.arch.lifecycle.LifecycleRegistry
import android.arch.lifecycle.Observer
import android.graphics.Bitmap
import android.os.Parcel
import android.os.Parcelable
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import tech.soit.quiet.model.vo.Music
import tech.soit.quiet.player.MusicPlayerManager
import tech.soit.quiet.player.PlayMode
import tech.soit.quiet.player.playlist.Playlist
import tech.soit.quiet.utils.log

class QuietPlayerChannel(private val channel: MethodChannel) : MethodChannel.MethodCallHandler, LifecycleOwner {

    private val lifecycle = LifecycleRegistry(this)

    override fun getLifecycle(): Lifecycle {
        return lifecycle
    }

    companion object {

        fun registerWith(registrar: PluginRegistry.Registrar): QuietPlayerChannel {
            val methodChannel = MethodChannel(registrar.messenger(), "tech.soit.quiet/player")
            val quietPlayerChannel = QuietPlayerChannel(methodChannel)
            methodChannel.setMethodCallHandler(quietPlayerChannel)
            return quietPlayerChannel
        }

    }

    //flag prevent duplicated init
    private var isInitialized = false

    private fun init() {
        if (isInitialized) {
            //It is unlikely that this will happen under normal circumstances.
            //but when hot restart dart code modify to running application, will cause this to happen.
            //so in order to help debug , we need resend events to flutter framework
            MusicPlayerManager.playerState.postValue(MusicPlayerManager.playerState.value)
            MusicPlayerManager.playingMusic.postValue(MusicPlayerManager.playingMusic.value)
            MusicPlayerManager.playlist.postValue(MusicPlayerManager.playlist.value)
            return
        }

        isInitialized = true
        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_START)

        MusicPlayerManager.playerState.observe(this, Observer {
            channel.invokeMethod("onPlayStateChanged", it)
        })

        MusicPlayerManager.playingMusic.observe(this, Observer {
            channel.invokeMethod("onPlayingMusicChanged", (it as ItemMusic?)?.map)
        })

        MusicPlayerManager.playlist.observe(this, Observer { playlist ->
            playlist ?: return@Observer
            channel.invokeMethod("onPlayingListChanged", mapOf(
                    "list" to playlist.list.map { (it as ItemMusic).map },
                    "token" to playlist.token
            ))
        })

        MusicPlayerManager.position.observe(this, Observer {
            channel.invokeMethod("onPositionChanged", mapOf<String, Any>(
                    "position" to (it?.current ?: 0),
                    "duration" to (it?.total ?: 0)
            ))
        })
    }


    /**
     * destroy this channel callback
     * remove observe callback
     */
    fun destroy() {
        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    }

    private val player get() = MusicPlayerManager.musicPlayer

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

        log { "call : ${call.method}" }

        when (call.method) {
            "init" -> {
                init()
                if (player.playlist.token != Playlist.TOKEN_EMPTY) {
                    //when current player is available, we do not need init playlist
                    //but also need send event to Flutter Framework
                    MusicPlayerManager.playlist.postValue(MusicPlayerManager.playlist.value)
                    return
                }
                val token = call.argument<String>("token") ?: return
                val list = call.argument<List<HashMap<String, Any>>>("list")?.map { ItemMusic(it) }
                        ?: return
                player.playlist = Playlist(token, list)
                player.playlist.current = call.argument<HashMap<String, Any>>("music")?.let { ItemMusic(it) }
                player.playlist.playMode = PlayMode.values()[call.argument<Int>("playMode") ?: 0]

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


