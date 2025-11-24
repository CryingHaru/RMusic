package com.rmusic.providers.intermusic.auth

import kotlinx.serialization.Serializable

@Serializable
data class IntermusicAuth(
    val cookies: String,
    val sapisid: String? = null,
    val visitorId: String? = null
) {
    companion object {
        fun fromCookieString(cookieString: String): IntermusicAuth {
            val cookiesMap = parseCookies(cookieString)
            val sapisid = cookiesMap["SAPISID"]
            return IntermusicAuth(
                cookies = cookieString,
                sapisid = sapisid
            )
        }

        private fun parseCookies(cookieString: String): Map<String, String> {
            return cookieString.split(";")
                .map { it.trim() }
                .filter { it.isNotEmpty() }
                .mapNotNull {
                    val parts = it.split("=", limit = 2)
                    if (parts.size == 2) {
                        parts[0] to parts[1]
                    } else {
                        null
                    }
                }.toMap()
        }
    }
}
