package com.arc.launcher

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.os.Build
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.content.ComponentName

class MainActivity : FlutterActivity() {
    private val CHANNEL = "arc_launcher_settings"
    private val LAUNCHER_CHANNEL = "launcher_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Settings channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openDefaultLauncherSettings" -> {
                    try {
                        openDefaultLauncherSettings()
                        result.success("Settings opened successfully")
                    } catch (e: Exception) {
                        result.error("SETTINGS_ERROR", "Failed to open settings", e.message)
                    }
                }
                "isDefaultLauncher" -> {
                    try {
                        val isDefault = checkIfDefaultLauncher()
                        result.success(isDefault)
                    } catch (e: Exception) {
                        result.error("CHECK_ERROR", "Failed to check default launcher status", e.message)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Launcher service channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LAUNCHER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "launchApp" -> {
                    try {
                        val packageName = call.argument<String>("packageName")
                        if (packageName != null) {
                            val success = launchApp(packageName)
                            result.success(success)
                        } else {
                            result.error("INVALID_PACKAGE", "Package name is required", null)
                        }
                    } catch (e: Exception) {
                        result.error("LAUNCH_ERROR", "Failed to launch app", e.message)
                    }
                }
                "getInstalledApps" -> {
                    try {
                        val apps = getInstalledApps()
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("APPS_ERROR", "Failed to get installed apps", e.message)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun openDefaultLauncherSettings() {
        try {
            // Method 1: Try to open the specific home settings (Android 5.0+)
            val intent = Intent(Settings.ACTION_HOME_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        } catch (e: Exception) {
            try {
                // Method 2: Try to open default apps settings (Android 6.0+)
                val intent = Intent(Settings.ACTION_MANAGE_DEFAULT_APPS_SETTINGS)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
            } catch (e2: Exception) {
                try {
                    // Method 3: Try to open general settings
                    val intent = Intent(Settings.ACTION_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                } catch (e3: Exception) {
                    // Method 4: Open app settings as last resort
                    val intent = Intent(Settings.ACTION_APPLICATION_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                }
            }
        }
    }

    private fun checkIfDefaultLauncher(): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_MAIN)
            intent.addCategory(Intent.CATEGORY_HOME)
            
            val packageManager = packageManager
            val resolveInfo = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
            
            val currentHomePackage = resolveInfo?.activityInfo?.packageName
            val thisPackage = packageName
            
            currentHomePackage == thisPackage
        } catch (e: Exception) {
            false
        }
    }

    private fun launchApp(packageName: String): Boolean {
        return try {
            val packageManager = packageManager
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                true
            } else {
                // Try to open app info if launch intent is not available
                val appInfoIntent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                appInfoIntent.data = android.net.Uri.fromParts("package", packageName, null)
                appInfoIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(appInfoIntent)
                false
            }
        } catch (e: Exception) {
            false
        }
    }

    private fun getInstalledApps(): List<Map<String, Any>> {
        val apps = mutableListOf<Map<String, Any>>()
        val packageManager = packageManager
        
        try {
            val intent = Intent(Intent.ACTION_MAIN, null)
            intent.addCategory(Intent.CATEGORY_LAUNCHER)
            
            val resolveInfoList = packageManager.queryIntentActivities(intent, 0)
            
            for (resolveInfo in resolveInfoList) {
                val packageName = resolveInfo.activityInfo.packageName
                val appName = resolveInfo.loadLabel(packageManager).toString()
                
                // Skip system apps that shouldn't be shown
                if (!isSystemApp(packageName)) {
                    apps.add(mapOf(
                        "packageName" to packageName,
                        "name" to appName,
                        "category" to "unknown"
                    ))
                }
            }
        } catch (e: Exception) {
            // Return empty list if there's an error
        }
        
        return apps
    }

    private fun isSystemApp(packageName: String): Boolean {
        return try {
            val packageInfo = packageManager.getPackageInfo(packageName, 0)
            val flags = packageInfo.applicationInfo?.flags ?: 0
            (flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0
        } catch (e: Exception) {
            false
        }
    }
}
