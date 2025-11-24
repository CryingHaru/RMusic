package com.rmusic.android.utils

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

object PermissionManager {
    
    /**
     * Check if all required storage permissions are granted
     */
    fun hasStoragePermissions(context: Context): Boolean {
        return when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU -> {
                // Android 13+ supports scoped storage fully; MANAGE_EXTERNAL_STORAGE is optional
                Environment.isExternalStorageManager() ||
                    ContextCompat.checkSelfPermission(
                        context,
                        Manifest.permission.READ_MEDIA_AUDIO
                    ) == PackageManager.PERMISSION_GRANTED ||
                    hasScopedStorageAccess(context)
            }
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.R -> {
                // Android 11-12L: allow either MANAGE_EXTERNAL_STORAGE, legacy READ permission, or scoped access
                Environment.isExternalStorageManager() ||
                    ContextCompat.checkSelfPermission(
                        context,
                        Manifest.permission.READ_EXTERNAL_STORAGE
                    ) == PackageManager.PERMISSION_GRANTED ||
                    hasScopedStorageAccess(context)
            }
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q -> {
                // Android 10: scoped storage is available, but READ permission also works
                ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.READ_EXTERNAL_STORAGE
                ) == PackageManager.PERMISSION_GRANTED ||
                    hasScopedStorageAccess(context)
            }
            else -> {
                // Android 9 and below - Check both READ and WRITE
                ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.READ_EXTERNAL_STORAGE
                ) == PackageManager.PERMISSION_GRANTED &&
                ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE
                ) == PackageManager.PERMISSION_GRANTED
            }
        }
    }
    
    /**
     * Request storage permissions based on Android version
     */
    fun requestStoragePermissions(activity: Activity) {
        when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.R -> {
                // Android 11+ - Prefer scoped storage; only prompt for MANAGE access if absolutely necessary
                if (hasScopedStorageAccess(activity)) return
                val intent = Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION).apply {
                    data = Uri.parse("package:${activity.packageName}")
                }
                activity.startActivity(intent)
            }
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q -> {
                // Android 10 - Request READ_EXTERNAL_STORAGE
                ActivityCompat.requestPermissions(
                    activity,
                    arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE),
                    STORAGE_PERMISSION_REQUEST_CODE
                )
            }
            else -> {
                // Android 9 and below - Request both READ and WRITE
                ActivityCompat.requestPermissions(
                    activity,
                    arrayOf(
                        Manifest.permission.READ_EXTERNAL_STORAGE,
                        Manifest.permission.WRITE_EXTERNAL_STORAGE
                    ),
                    STORAGE_PERMISSION_REQUEST_CODE
                )
            }
        }
    }
    
    /**
     * Check storage permissions and request if needed
     */
    fun checkAndRequestStoragePermissions(activity: Activity): Boolean {
        return if (hasStoragePermissions(activity)) {
            true
        } else {
            requestStoragePermissions(activity)
            false
        }
    }
    
    /**
     * Get the required permissions array for the current Android version
     */
    fun getRequiredStoragePermissions(): Array<String> {
        return when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.R -> {
                // Android 11+ uses MANAGE_EXTERNAL_STORAGE which is handled differently
                arrayOf()
            }
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q -> {
                arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE)
            }
            else -> {
                arrayOf(
                    Manifest.permission.READ_EXTERNAL_STORAGE,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE
                )
            }
        }
    }
    
    /**
     * Check if permission rationale should be shown
     */
    fun shouldShowPermissionRationale(activity: Activity, permission: String): Boolean {
        return ActivityCompat.shouldShowRequestPermissionRationale(activity, permission)
    }
    
    const val STORAGE_PERMISSION_REQUEST_CODE = 1001

    private fun hasScopedStorageAccess(context: Context): Boolean {
        return runCatching {
            val dir = context.getExternalFilesDir(Environment.DIRECTORY_MUSIC)
                ?: context.getExternalFilesDir(null)
            if (dir != null) {
                if (!dir.exists()) dir.mkdirs()
                dir.canWrite()
            } else {
                false
            }
        }.getOrDefault(false)
    }
}
