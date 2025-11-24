package com.rmusic.providers.intermusic.models

import kotlinx.serialization.Serializable

@Serializable
data class IntermusicLocale(
    val gl: String,
    val hl: String,
)

@Serializable
data class IntermusicContext(
    val client: Client,
) {
    @Serializable
    data class Client(
        val clientName: String,
        val clientVersion: String,
        val androidSdkVersion: Int? = null,
        val osVersion: String? = null,
        val gl: String,
        val hl: String,
        val visitorData: String? = null,
        val userAgent: String? = null,
        val deviceMake: String? = null,
        val deviceModel: String? = null,
        val osName: String? = null,
        val originalUrl: String? = null,
        val platform: String? = null,
        val clientFormFactor: String? = null,
        val timeZone: String? = null,
        val utcOffsetMinutes: Int? = null,
        val acceptLanguage: String? = null,
        val userInterfaceTheme: String? = null,
    )
}
