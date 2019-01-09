@file:Suppress("SpellCheckingInspection")

package tech.soit.quiet.plugin

import android.annotation.SuppressLint
import android.util.Base64
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.security.KeyFactory
import java.security.PublicKey
import java.security.spec.X509EncodedKeySpec
import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

/**
 * author : SUMMERLY
 * e-mail : yangbinyhbn@gmail.com
 * time   : 2017/8/22
 * desc   : 改编自 https://github.com/Binaryify/NeteaseCloudMusicApi/blob/master/util/crypto.js
 */
object NeteaseCryptoPlugin {
    private const val keys = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    private const val nonce = "0CoJUm6Qyw8W8jud"

    private const val publicKeyStr = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDgtQn2JZ34ZC28NWYpAUd98iZ37BUrX/aKzmFbt7clFSs6sXqHauqKWqdtLkF2KexO40H1YTX8z2lSgBBOAxLsvaklV8k4cBFK9snQXE9/DDaFt6Rr7iVZMldczhC0JNgTz+SHXT6CBHuX3e9SdB1Ua44oncaTWz7OBGLbCiK45wIDAQAB"


    private val iv = "0102030405060708".toByteArray()

    private const val linuxapiKey = "rFgB&h#%2?^eDg:Q"

    private const val CHANNEL_NAME = "tech.soit.netease/crypto"

    fun registerWith(registrar: PluginRegistry.Registrar) {
        MethodChannel(registrar.messenger(), CHANNEL_NAME).setMethodCallHandler { methodCall, result ->
            when (methodCall.method) {
                "encrypt" -> {
                    val json = methodCall.argument<String>("json")
                    if (json == null) {
                        result.error("error", "json param is null", null)
                    } else {
                        val type = methodCall.argument<String>("type")
                        if (type == "linux") {
                            result.success(encryptLinuxApi(json))
                        } else {
                            result.success(encrypt(json))
                        }
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }


    private fun encrypt(json: String): Map<String, String> {
        val secKey = createSecretKey()
        //对参数请求进行以 [nonce] 加密后的结果再次使用 createSecretKry() 产生的随机数进行加密
        val encText = aesEncrypt(aesEncrypt(json, nonce), secKey)
        //对第二次使用的随机串进行加密,以便在服务器端解析出具体的参数请求
        val encSecKey = rsaEncrypt(secKey.reversed())
        return mapOf("params" to encText, "encSecKey" to encSecKey)
    }

    private fun encryptLinuxApi(json: String): Map<String, String> {
        return mapOf("eparams" to aesEncryptForLinux(json, linuxapiKey))
    }


    /**
     * 随机一个 16 位的 字母数字序列
     */
    private fun createSecretKey(size: Int = 16): String {
        val key = StringBuilder()
        for (i in 1..size) {
            val pos = Math.floor(Math.random() * keys.length).toInt()
            key.append(keys[pos])
        }
        return key.toString()
    }

    /**
     * @param text 带加密字符串
     * @param secKey 加密的密码
     */
    private fun aesEncrypt(text: String, secKey: String): String {
        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        cipher.init(Cipher.ENCRYPT_MODE, SecretKeySpec(secKey.toByteArray(), "AES"), IvParameterSpec(iv))
        val results = cipher.doFinal(text.toByteArray())
        return android.util.Base64.encodeToString(results, Base64.DEFAULT)
    }

    @SuppressLint("GetInstance")
    private fun aesEncryptForLinux(text: String, secKey: String): String {
        val cipher = Cipher.getInstance("AES/ECB/PKCS5Padding")
        cipher.init(Cipher.ENCRYPT_MODE, SecretKeySpec(secKey.toByteArray(), "AES"))
        val results = cipher.doFinal(text.toByteArray())
        return results.toHex().toUpperCase()
    }

    private fun ByteArray.toHex() = this.joinToString(separator = "") { it.toInt().and(0xff).toString(16).padStart(2, '0') }


    private val publicKey: PublicKey

    init {
        val factory = KeyFactory.getInstance("RSA")
        publicKey = factory.generatePublic(X509EncodedKeySpec(Base64.decode(publicKeyStr, Base64.DEFAULT)))
    }

    private fun rsaEncrypt(text: String): String {
        val cipher = Cipher.getInstance("RSA")
        cipher.init(Cipher.ENCRYPT_MODE, publicKey)
        return cipher.doFinal(text.toByteArray()).toHex()
    }


}