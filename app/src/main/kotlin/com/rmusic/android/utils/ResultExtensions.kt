package com.rmusic.android.utils

/**
 * Helper extension that previously wrapped nullable results to ensure chaining stays readable.
 * For now it simply returns the original [Result] instance so existing call-sites keep compiling
 * while we migrate providers.
 */
fun <T> Result<T>.completed(): Result<T> = this
