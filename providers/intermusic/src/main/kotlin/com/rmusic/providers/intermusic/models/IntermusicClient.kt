package com.rmusic.providers.intermusic.models

import kotlinx.serialization.Serializable

@Serializable
data class IntermusicClient(
    val clientName: String,
    val clientVersion: String,
    val apiKey: String,
    val userAgent: String,
    val osVersion: String? = null,
    val referer: String? = null,
    val deviceMake: String? = null,
    val deviceModel: String? = null,
    val osName: String? = null,
    val xClientName: Int? = null,
) {
    fun toContext(
        locale: IntermusicLocale,
        visitorData: String?,
    ) = IntermusicContext(
        client = IntermusicContext.Client(
            clientName = clientName,
            clientVersion = clientVersion,
            osVersion = osVersion,
            gl = locale.gl,
            hl = locale.hl,
            visitorData = visitorData,
            userAgent = userAgent,
            deviceMake = deviceMake,
            deviceModel = deviceModel,
            osName = osName,
        ),
    )

    companion object {
    private const val REFERER_YOUTUBE_MUSIC = "https://music.youtube.com"
    private const val REFERER_YOUTUBE = "https://www.youtube.com"

        const val USER_AGENT_WEB =
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
        // Actualizado para coincidir con ejemplo funcional youtube-request.js
        private const val USER_AGENT_ANDROID =
            "com.google.android.youtube/19.49.37 (Linux; U; Android 11) gzip"

        val ANDROID_MUSIC =
            IntermusicClient(
                clientName = "ANDROID_MUSIC",
                clientVersion = "7.29.52",
                apiKey = "AIzaSyAOghZGza2MQSZkY_zfZ370N-PUdXEo8AI",
                userAgent = USER_AGENT_ANDROID,
                osName = "Android",
                osVersion = "11", // Actualizado para coincidir con UA
                xClientName = 21,
            )

        // Nuevo cliente ANDROID regular (como en youtube-request.js)
        val ANDROID =
            IntermusicClient(
                clientName = "ANDROID",
                clientVersion = "19.49.37",
                apiKey = "AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8",
                userAgent = USER_AGENT_ANDROID,
                osName = "Android",
                osVersion = "11",
                xClientName = 3,
            )

        
        
        val IOS =
            IntermusicClient(
                clientName = "IOS",
                clientVersion = "20.10.4",
                apiKey = "AIzaSyB-63vPrdThhKuerbB2N_l7Kwwcxj6yUAc",
                userAgent = "com.google.ios.youtube/20.10.4 (iPhone16,2; U; CPU iOS 18_3_2 like Mac OS X;)",
                osName = "iPhone",
                osVersion = "18.3.2",
                referer = REFERER_YOUTUBE,
                xClientName = 5,
            )

        val WEB_REMIX =
            IntermusicClient(
                clientName = "WEB_REMIX",
                clientVersion = "1.20250215.01.00",
                apiKey = "AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30",
                userAgent = USER_AGENT_WEB,
                referer = REFERER_YOUTUBE_MUSIC,
                xClientName = 67,
            )

        val WEB =
            IntermusicClient(
                clientName = "WEB",
                clientVersion = "2.20250215",
                apiKey = "AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30",
                userAgent = USER_AGENT_WEB,
            )
    }
}
