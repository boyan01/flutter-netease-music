package tech.soit.quiet.plugin

import android.graphics.BitmapFactory
import android.graphics.Color
import android.support.v7.graphics.Palette
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.*
import tech.soit.quiet.utils.log

class PaletteGeneratorPlugin : MethodChannel.MethodCallHandler {


    companion object {

        private const val NAME = "tech.soit.quiet/palette"

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val plugin = PaletteGeneratorPlugin()
            val channel = MethodChannel(registrar.messenger(), NAME)
            channel.setMethodCallHandler(plugin)
        }

    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        GlobalScope.launch(Dispatchers.Main) {
            when (call.method) {
                "getPrimaryColor" -> {
                    val bytes = call.arguments<ByteArray>()
                    log { "invoke getPrimaryColor : bytesLength : ${bytes.size}" }
                    if (bytes == null) {
                        result.success(Color.DKGRAY)
                    } else {
                        val color = getPrimaryColor(bytes).await()
                        log { "generated color $color" }
                        result.success(color ?: Color.DKGRAY)
                    }
                }
            }
        }
    }

    private fun getPrimaryColor(byteArray: ByteArray): Deferred<Int?> = GlobalScope.async {
        val bitmap = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)
        if (bitmap == null) {
            log { "generate bitmap failed" }
            return@async null
        }
        val palette = Palette.from(bitmap).generate()
        return@async palette.mutedSwatch?.rgb
                ?: palette.darkMutedSwatch?.rgb
                ?: palette.darkVibrantSwatch?.rgb
                ?: palette.lightVibrantSwatch?.rgb
                ?: palette.vibrantSwatch?.rgb
    }


}