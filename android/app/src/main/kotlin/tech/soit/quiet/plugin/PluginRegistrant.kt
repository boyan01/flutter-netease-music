package tech.soit.quiet.plugin

import io.flutter.plugin.common.PluginRegistry

object PluginRegistrant {
    fun registerWith(registry: PluginRegistry) {
        if (alreadyRegisteredWith(registry)) {
            return
        }
        DownloadPlugin.registerWith(registry.registrarFor("tech.soit.quiet.plugin.DownloadPlugin"))
        NeteaseCryptoPlugin.registerWith(registry.registrarFor("tech.soit.quiet.plugin.NeteaseCryptoPlugin"))
    }

    private fun alreadyRegisteredWith(registry: PluginRegistry): Boolean {
        val key = PluginRegistrant::class.java.canonicalName
        if (registry.hasPlugin(key)) {
            return true
        }
        registry.registrarFor(key)
        return false
    }

}