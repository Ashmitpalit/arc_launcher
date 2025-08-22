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

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
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
}
