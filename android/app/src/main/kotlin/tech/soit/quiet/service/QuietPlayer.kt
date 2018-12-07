package tech.soit.quiet.service

import android.net.Uri
import com.google.android.exoplayer2.ExoPlayerFactory
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.SimpleExoPlayer
import com.google.android.exoplayer2.source.ExtractorMediaSource
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.upstream.cache.CacheDataSourceFactory
import com.google.android.exoplayer2.upstream.cache.LeastRecentlyUsedCacheEvictor
import com.google.android.exoplayer2.upstream.cache.SimpleCache
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import tech.soit.quiet.AppContext
import java.util.*

class QuietPlayer(private val registrar: PluginRegistry.Registrar,
                  private val channel: MethodChannel) : MethodChannel.MethodCallHandler {

    companion object {

        private val cache = SimpleCache(AppContext.filesDir, LeastRecentlyUsedCacheEvictor(1000 * 1000 * 100))

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val methodChannel = MethodChannel(registrar.messenger(), "tech.soit.quiet/player")
            methodChannel.setMethodCallHandler(QuietPlayer(registrar, methodChannel))
        }

    }

    private val player: SimpleExoPlayer = ExoPlayerFactory.newSimpleInstance(registrar.context())

    init {
        player.addListener(object : Player.EventListener {
            override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
                if (playbackState == Player.STATE_BUFFERING) {
                    val event = HashMap<String, Any>()
                    event["event"] = "bufferingUpdate"
                    val range = listOf(0, player.bufferedPercentage)
                    event["values"] = Collections.singletonList(range)
                    channel.invokeMethod("onEvent", event)
                }
            }
        })
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> {
                if (player.playbackState != Player.STATE_IDLE) {
                    player.release()
                }
            }
            "prepare" -> {
                val source = ExtractorMediaSource.Factory(
                        CacheDataSourceFactory(cache, DefaultDataSourceFactory(AppContext, "")))
                        .createMediaSource(Uri.parse(requireNotNull(call.argument("url"))))
                player.prepare(source)
                result.success(null)
            }
            "play" -> {
                player.playWhenReady = true
                result.success(null)
            }
            "pause" -> {
                player.playWhenReady = false
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

            }

        }
    }


}