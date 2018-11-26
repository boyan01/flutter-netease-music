package tech.soit.quiet.service

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import tech.soit.quiet.MainActivity
import tech.soit.quiet.player.core.QuietMediaPlayer

object MusicPlayer {

    private val player = QuietMediaPlayer()

    fun init(messenger: BinaryMessenger) {
        MethodChannel(messenger, MainActivity.CHANNER_MUSIC_PLAYER).setMethodCallHandler { methodCall, result ->
            when (methodCall.method) {
                "play" -> {
                    val url = methodCall.argument<String>("playUrl")
                    if (url == null) {
                        result.success(false)
                    } else {
                        player.prepare(url, true)
                        result.success(true)
                    }
                }
                "pause" -> {
                    player.isPlayWhenReady = false
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }


}