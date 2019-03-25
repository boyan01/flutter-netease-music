package tech.soit.quiet.plugin

import io.flutter.plugin.common.PluginRegistry

object PluginRegistrant {
    fun registerWith(registry: PluginRegistry) {
        if (alreadyRegisteredWith(registry)) {
            return
        }
        NeteaseCryptoPlugin.registerWith(registry.registrarFor("tech.soit.quiet.plugin.NeteaseCryptoPlugin"))
        PaletteGeneratorPlugin.registerWith(registry.registrarFor("tech.soit.quiet.plugin.PaletteGeneratorPlugin"))
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