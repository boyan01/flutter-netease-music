package tech.soit.quiet.service

import android.annotation.SuppressLint
import com.google.android.exoplayer2.ExoPlaybackException
import com.google.android.exoplayer2.Player
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.view.FlutterNativeView
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import tech.soit.quiet.player.Music
import tech.soit.quiet.player.MusicPlayerCallback
import tech.soit.quiet.player.PlayMode
import tech.soit.quiet.player.QuietMusicPlayer
import tech.soit.quiet.player.playlist.Playlist
import tech.soit.quiet.utils.log

/**
 * channel contact with Dart
 *
 * if dart vm reload: call 'init', to synchronize data with Platform and Flutter
 *
 */
class QuietPlayerChannel(private val channel: MethodChannel) : MethodChannel.MethodCallHandler {


    companion object {

        private const val CHANNEL_ID = "tech.soit.quiet/player"

        private var initialized = false

        //native view Context field is Application
        //will not leak activity context
        @SuppressLint("StaticFieldLeak")
        private var destroyedNativeView: FlutterNativeView? = null

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val methodChannel = MethodChannel(registrar.messenger(), CHANNEL_ID)
            val quietPlayerChannel = QuietPlayerChannel(methodChannel)
            methodChannel.setMethodCallHandler(quietPlayerChannel)
            registrar.addViewDestroyListener {
                quietPlayerChannel.destroy()
                destroyedNativeView = it
                //remain native view
                return@addViewDestroyListener true
            }
        }

        fun destroyNativeView() {
            destroyedNativeView?.destroy()
            destroyedNativeView = null
        }

    }


    private val eventListener = object : Player.EventListener {

        override fun onPlayerError(error: ExoPlaybackException?) {
            error ?: return
            channel.invokeMethod("onPlayerError", mapOf(
                    "type" to error.type,
                    "message" to (error.localizedMessage ?: "player error")
            ))
        }

        override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
            channel.invokeMethod("onPlayerStateChanged", mapOf(
                    "playWhenReady" to playWhenReady,
                    "playbackState" to playbackState
            ))
        }

    }

    private val playerCallback = object : MusicPlayerCallback {
        override fun onPlayModeChanged(playMode: PlayMode) {
            channel.invokeMethod("onPlayModeChanged", playMode.ordinal)
        }

        override fun onMusicChanged(music: Music?) {
            channel.invokeMethod("onMusicChanged", music?.map)
        }

        override fun onPlaylistUpdated(playlist: Playlist) {
            channel.invokeMethod("onPlaylistUpdated", mapOf(
                    "token" to playlist.token,
                    "list" to playlist.list.map { it.map }
            ))
        }

        override fun onPositionChanged(position: Long, duration: Long) {
            channel.invokeMethod("onPositionChanged", mapOf(
                    "position" to position,
                    "duration" to duration
            ))
        }

    }


    private fun init(dispatch: Boolean = false) {
        player.addListener(eventListener)
        player.addCallback(playerCallback)
        if (dispatch) {
            eventListener.onPlayerError(player.playbackError)
            eventListener.onPlayerStateChanged(player.playWhenReady, player.playbackState)

            playerCallback.onMusicChanged(player.current)
            playerCallback.onPlaylistUpdated(player.playlist)
            playerCallback.onPlayModeChanged(player.playMode)
        }
    }

    /**
     * destroy this channel callback
     * remove observe callback
     */
    private fun destroy() {
        player.removeListener(eventListener)
        player.removeCallback(playerCallback)
    }

    private val player get() = QuietMusicPlayer.getInstance()

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        log { "call : ${call.method}" }
        GlobalScope.launch(Dispatchers.Main) {
            when (call.method) {
                "init" -> {
                    if (initialized) {
                        //when current player is available, we do not need init playlist
                        //but also need send event to Flutter Framework
                        init(true)
                        destroyNativeView()
                    } else {
                        initialized = true
                        init(false)
                        val token = call.argument<String>("token")
                        val list = call.argument<List<HashMap<String, Any>>>("list")?.map { Music(it) }

                        if (token != null && list != null) {
                            player.playlist = Playlist(token, list)
                            player.current = call.argument<HashMap<String, Any>>("music")?.let { Music(it) }
                            player.playMode = PlayMode.values()[call.argument<Int>("playMode") ?: 0]
                        }
                    }
                    result.success(null)
                }
                "setPlayWhenReady" -> {
                    player.playWhenReady = call.arguments()
                    result.success(null)
                }
                "playWithQinDing" -> {
                    //token , list , music argument must not be null
                    val music = Music(call.arguments<HashMap<String, Any>>())
                    player.play(music)
                    result.success(null)
                }
                "playNext" -> {
                    player.playNext().join()
                    result.success(null)
                }
                "playPrevious" -> {
                    player.playPrevious().join()
                    result.success(null)
                }
                "updatePlaylist" -> {
                    val token = call.argument<String>("token")!!
                    val list = call.argument<List<HashMap<String, Any>>>("list")!!.map { Music(it) }
                    val newPlaylist = Playlist(token = token, musics = list)
                    player.playlist = newPlaylist
                    result.success(null)
                }
                "seekTo" -> {
                    player.seekTo(call.arguments())
                    result.success(null)
                }
                "setVolume" -> {
                    player.setVolume(call.arguments<Number>().toFloat())
                    result.success(null)
                }
                "setPlayMode" -> {
                    val index: Int = call.arguments()
                    player.playMode = PlayMode.values()[index]
                    result.success(null)
                }
                "position" -> {
                    result.success(player.position)
                }
                "duration" -> {
                    result.success(player.duration)
                }
                "getNext" -> {
                    result.success(player.playlist.getNext(player.current)?.map)
                }
                "getPrevious" -> {
                    result.success(player.playlist.getPrevious(player.current)?.map)
                }
                "quiet" -> {
                    player.quiet()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

}


