package com.rmusic.android.utils

import android.app.ActivityManager
import android.os.Build
import com.rmusic.android.Dependencies

object DeviceConstraints {
    private val activityManager: ActivityManager? by lazy {
        Dependencies.application.getSystemService(ActivityManager::class.java)
    }

    val isLowRamDevice: Boolean by lazy {
        activityManager?.isLowRamDevice == true
    }

    val disableDiskCache: Boolean by lazy {
        isLowRamDevice || Build.SUPPORTED_ABIS.any { it.contains("armeabi", ignoreCase = true) }
    }

    val quickPicksEnabled: Boolean by lazy {
        true
    }
}
