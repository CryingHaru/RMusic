package com.rmusic.providers.ytmusic.utils

import java.security.MessageDigest

fun sha1(input: String): String {
    val digest = MessageDigest.getInstance("SHA-1")
    val hash = digest.digest(input.toByteArray(Charsets.UTF_8))
    return hash.joinToString("") { "%02x".format(it) }
}
