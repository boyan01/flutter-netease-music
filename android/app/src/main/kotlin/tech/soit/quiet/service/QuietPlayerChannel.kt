package tech.soit.quiet.service

import android.net.Uri
import com.google.android.exoplayer2.ExoPlaybackException
import com.google.android.exoplayer2.ExoPlayerFactory
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.SimpleExoPlayer
import com.google.android.exoplayer2.source.ExtractorMediaSource
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.upstream.cache.CacheDataSourceFactory
import com.google.android.exoplayer2.upstream.cache.LeastRecentlyUsedCacheEvictor
import com.google.android.exoplayer2.upstream.cache.SimpleCache
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import tech.soit.quiet.AppContext
import java.util.*

class QuietPlayerChannel(private val registrar: PluginRegistry.Registrar,
                         private val channel: MethodChannel) : MethodChannel.MethodCallHandler {

    companion object {

//        const val TAG = "QuietPlayerChannel"

        private const val USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" +
                " (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/13.10586"

        private val cache = SimpleCache(AppContext.filesDir, LeastRecentlyUsedCacheEvictor(1000 * 1000 * 100))

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val methodChannel = MethodChannel(registrar.messenger(), "tech.soit.quiet/player")
            methodChannel.setMethodCallHandler(QuietPlayerChannel(registrar, methodChannel))
        }

    }

    private var _player: SimpleExoPlayer? = null

    private val player
        get() = _player ?: ExoPlayerFactory
                .newSimpleInstance(registrar.context(), DefaultTrackSelector()).also {
                    _player = it
                    initPlayer(it)
                }

    private fun initPlayer(player: SimpleExoPlayer) {
        player.addListener(object : Player.DefaultEventListener() {
            override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
                when (playbackState) {
                    Player.STATE_BUFFERING -> {
                        val event = HashMap<String, Any>()
                        event["eventId"] = "bufferingUpdate"
                        val range = listOf(0, player.bufferedPercentage)
                        event["values"] = Collections.singletonList(range)
                        channel.invokeMethod("onEvent", event)

                        channel.invokeMethod("onEvent", mapOf("eventId" to "bufferingStart"))

                    }
                    Player.STATE_ENDED -> channel.invokeMethod("onEvent", mapOf("eventId" to "complete"))
                    Player.STATE_READY -> channel.invokeMethod("onEvent", mapOf("eventId" to "ready"))
                }
            }

            override fun onPlayerError(error: ExoPlaybackException) {

                error.printStackTrace()

                channel.invokeMethod("onEvent", mapOf(
                        "eventId" to "error",
                        "msg" to error.localizedMessage
                ))
            }
        })
//        player.audioAttributes = AudioAttributes.Builder()
//                .setContentType(C.CONTENT_TYPE_MUSIC)
//                .build()
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> {
                player?.release()
                _player = null
            }
            "prepare" -> {
                val source = buildSource(requireNotNull(call.argument("url")))
                //send duration when player has been ready
                val listener = object : Player.DefaultEventListener() {
                    override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
                        if (playbackState == Player.STATE_READY) {
                            player.removeListener(this)
                            result.success(mapOf("duration" to player.duration))
                        }
                    }
                }
                player.addListener(listener)
                player.prepare(source)
            }
            "setPlayWhenReady" -> {
                player.playWhenReady = call.arguments as? Boolean ?: false
                result.success(null)
            }
            "seekTo" -> {
                val position = requireNotNull(call.argument<Number>("position")).toLong()
                player.seekTo(position)
                result.success(null)
            }
            "setVolume" -> {
                player.volume = requireNotNull(call.argument("volume"))
            }
            "position" -> {
                result.success(player.currentPosition)
            }
            "duration" -> {
                result.success(player.duration)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun buildSource(url: String): ExtractorMediaSource {
//        Log.i(TAG, "build source : $url")
        return ExtractorMediaSource.Factory(
                CacheDataSourceFactory(cache, DefaultDataSourceFactory(AppContext, USER_AGENT)))
                .createMediaSource(Uri.parse(requireNotNull(url)))
    }

}


