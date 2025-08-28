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
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "arc_launcher_settings"
    private val LAUNCHER_CHANNEL = "launcher_service"
    private val USAGE_STATS_CHANNEL = "usage_stats_channel"

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
        
        // Usage stats channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USAGE_STATS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkUsageStatsPermission" -> {
                    try {
                        val hasPermission = checkUsageStatsPermission()
                        result.success(hasPermission)
                    } catch (e: Exception) {
                        result.error("PERMISSION_ERROR", "Failed to check permission", e.message)
                    }
                }
                "requestUsageStatsPermission" -> {
                    try {
                        val success = requestUsageStatsPermission()
                        result.success(success)
                    } catch (e: Exception) {
                        result.error("PERMISSION_ERROR", "Failed to request permission", e.message)
                    }
                }
                "startUsageStatsService" -> {
                    try {
                        startUsageStatsService()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SERVICE_ERROR", "Failed to start service", e.message)
                    }
                }
                "getUsageStats" -> {
                    try {
                        val timeRange = call.argument<Number>("timeRange")?.toLong()
                        val limit = call.argument<Int>("limit")
                        val stats = getUsageStats(timeRange, limit)
                        result.success(stats)
                    } catch (e: Exception) {
                        result.error("STATS_ERROR", "Failed to get usage stats", e.message)
                    }
                }
                "getCurrentUsageStats" -> {
                    try {
                        val stats = getCurrentUsageStats()
                        result.success(stats)
                    } catch (e: Exception) {
                        result.error("STATS_ERROR", "Failed to get current usage stats", e.message)
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
                
                // Include all apps, but filter out some unnecessary system apps
                if (shouldShowApp(packageName)) {
                    apps.add(mapOf(
                        "packageName" to packageName,
                        "name" to appName,
                        "category" to getAppCategory(packageName)
                    ))
                }
            }
            
            // Sort apps alphabetically by name
            apps.sortBy { it["name"] as String }
            
        } catch (e: Exception) {
            // Return empty list if there's an error
        }
        
        return apps
    }

    private fun shouldShowApp(packageName: String): Boolean {
        // List of system apps that should be shown (important ones)
        val importantSystemApps = listOf(
            "com.android.settings",           // Settings
            "com.android.dialer",             // Phone
            "com.android.camera",             // Camera
            "com.android.gallery3d",          // Gallery
            "com.android.chrome",             // Chrome
            "com.google.android.gm",          // Gmail
            "com.google.android.apps.maps",   // Maps
            "com.android.vending",            // Play Store
            "com.google.android.youtube",     // YouTube
            "com.spotify.music",              // Spotify
            "com.whatsapp",                   // WhatsApp
            "com.instagram.android",          // Instagram
            "com.facebook.katana",            // Facebook
            "com.twitter.android",            // Twitter
            "com.android.calculator2",        // Calculator
            "com.android.calendar",           // Calendar
            "com.android.deskclock",          // Clock
            "com.android.documentsui",        // Files
            "com.google.android.apps.photos", // Photos
            "com.google.android.apps.docs"    // Drive
        )
        
        // Always show important system apps
        if (importantSystemApps.contains(packageName)) {
            return true
        }
        
        // Show user-installed apps
        if (!isSystemApp(packageName)) {
            return true
        }
        
        // For other system apps, show only if they have a launcher icon
        return try {
            val packageInfo = packageManager.getPackageInfo(packageName, 0)
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            intent != null
        } catch (e: Exception) {
            false
        }
    }

    private fun getAppCategory(packageName: String): String {
        return when {
            packageName.startsWith("com.android.settings") -> "system"
            packageName.startsWith("com.android.dialer") -> "communication"
            packageName.startsWith("com.android.camera") -> "media"
            packageName.startsWith("com.android.gallery") -> "media"
            packageName.startsWith("com.android.chrome") -> "browser"
            packageName.startsWith("com.google.android.gm") -> "communication"
            packageName.startsWith("com.google.android.apps.maps") -> "navigation"
            packageName.startsWith("com.android.vending") -> "store"
            packageName.startsWith("com.google.android.youtube") -> "media"
            packageName.startsWith("com.spotify.music") -> "media"
            packageName.startsWith("com.whatsapp") -> "communication"
            packageName.startsWith("com.instagram.android") -> "social"
            packageName.startsWith("com.facebook.katana") -> "social"
            packageName.startsWith("com.twitter.android") -> "social"
            packageName.startsWith("com.android.calculator") -> "productivity"
            packageName.startsWith("com.android.calendar") -> "productivity"
            packageName.startsWith("com.android.deskclock") -> "productivity"
            packageName.startsWith("com.android.documentsui") -> "productivity"
            packageName.startsWith("com.google.android.apps.photos") -> "media"
            packageName.startsWith("com.google.android.apps.docs") -> "productivity"
            else -> "unknown"
        }
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
    
    // Usage Stats Methods
    private fun checkUsageStatsPermission(): Boolean {
        return try {
            val appOps = getSystemService(android.app.AppOpsManager::class.java)
            val mode = appOps.checkOpNoThrow(
                android.app.AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
            mode == android.app.AppOpsManager.MODE_ALLOWED
        } catch (e: Exception) {
            false
        }
    }
    
    private fun requestUsageStatsPermission(): Boolean {
        return try {
            val intent = Intent(android.provider.Settings.ACTION_USAGE_ACCESS_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }
    
    private fun startUsageStatsService() {
        try {
            val serviceIntent = Intent(this, UsageStatsService::class.java)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                startForegroundService(serviceIntent)
            } else {
                startService(serviceIntent)
            }
            Log.d("MainActivity", "UsageStatsService started successfully")
        } catch (e: Exception) {
            Log.e("MainActivity", "Failed to start UsageStatsService: ${e.message}")
            // Don't crash the app if service fails to start
        }
    }
    
    private fun getUsageStats(timeRange: Long?, limit: Int?): List<Map<String, Any>> {
        return try {
            val usageStatsManager = getSystemService(android.app.usage.UsageStatsManager::class.java)
            val endTime = System.currentTimeMillis()
            val startTime = timeRange?.let { endTime - it } ?: (endTime - (24 * 60 * 60 * 1000)) // Default to 24 hours
            
            val usageStats = usageStatsManager.queryUsageStats(
                android.app.usage.UsageStatsManager.INTERVAL_DAILY,
                startTime,
                endTime
            )
            
            val statsList = mutableListOf<Map<String, Any>>()
            val maxResults = limit ?: 10
            
            for (i in 0 until minOf(usageStats.size, maxResults)) {
                val stats = usageStats[i]
                val packageName = stats.packageName
                val appName = try {
                    packageManager.getApplicationLabel(packageManager.getApplicationInfo(packageName, 0)).toString()
                } catch (e: Exception) {
                    packageName
                }
                
                statsList.add(mapOf(
                    "packageName" to packageName,
                    "appName" to appName,
                    "usageTime" to (stats.totalTimeInForeground / (1000 * 60)).toInt(), // Convert to minutes
                    "launchCount" to 1, // Default launch count since UsageStats doesn't provide this
                    "lastUsed" to stats.lastTimeUsed,
                    "category" to getAppCategory(packageName)
                ))
            }
            
            // Sort by usage time
            statsList.sortByDescending { it["usageTime"] as Int }
            statsList
        } catch (e: Exception) {
            emptyList()
        }
    }

    private fun getCurrentUsageStats(): Map<String, Long> {
        return try {
            // Try to get stats from our UsageStatsService if it's running
            val prefs = getSharedPreferences("usage_stats", MODE_PRIVATE)
            val stats = mutableMapOf<String, Long>()
            
            // Get all daily usage keys
            val allPrefs = prefs.all
            for ((key, value) in allPrefs) {
                if (key.endsWith("_daily") && value is Long) {
                    val packageName = key.removeSuffix("_daily")
                    stats[packageName] = value
                }
            }
            
            Log.d("MainActivity", "Current usage stats from SharedPreferences: $stats")
            stats
        } catch (e: Exception) {
            Log.e("MainActivity", "Error getting current usage stats: ${e.message}")
            emptyMap()
        }
    }
}
