package tech.soit.quiet.utils

import android.util.Log
import tech.soit.quiet.BuildConfig

/**
 * Created by summer on 17-12-17
 */


private val DEBUG get() = BuildConfig.DEBUG

private const val TAG = "QUIET"

fun logError(error: Throwable?) {
    error ?: return
    if (DEBUG) {
        error.printStackTrace()
    }
}

fun log(level: LoggerLevel = LoggerLevel.INFO, lazyMessage: () -> Any?) {
    if (DEBUG) {
        //TODO logger 调整
        val traceElement = Exception().stackTrace[2]
        val traceInfo = with(traceElement) {
            val source = if (isNativeMethod) {
                "(Native Method)"
            } else if (fileName != null && lineNumber >= 0) {
                "($fileName:$lineNumber)"
            } else if (fileName != null) {
                "($fileName)"
            } else {
                "(Unknown Source)"
            }
            source + className.substringAfterLast('.') + "." + methodName
        }
        val tag = traceElement.className.substringAfterLast('.')
        val message = "$traceInfo: ${lazyMessage().toString()}"
        logByAndroid(message, level, tag)
    }
}

private fun logByAndroid(message: String, level: LoggerLevel, tag: String = TAG) = when (level) {
    LoggerLevel.DEBUG -> Log.d(tag, message)
    LoggerLevel.INFO -> Log.i(tag, message)
    LoggerLevel.WARN -> Log.w(tag, message)
    LoggerLevel.ERROR -> Log.e(tag, message)
}

enum class LoggerLevel {
    DEBUG,
    INFO,
    WARN,
    ERROR
}