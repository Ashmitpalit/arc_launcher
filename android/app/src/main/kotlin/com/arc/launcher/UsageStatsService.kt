package com.arc.launcher

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

class UsageStatsService : Service() {
    companion object {
        private const val TAG = "UsageStatsService"
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "usage_stats_channel"
        private const val CHANNEL_NAME = "Usage Statistics"
        private const val TRACKING_INTERVAL_SECONDS = 5L
    }

    private lateinit var usageStatsManager: UsageStatsManager
    private lateinit var powerManager: PowerManager
    private lateinit var wakeLock: PowerManager.WakeLock
    private lateinit var scheduler: ScheduledExecutorService
    private var currentPackageName: String? = null
    private var sessionStartTime: Long = 0
    private var isTracking = false

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "UsageStatsService created")
        
        try {
            usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "LauncherAndroid::UsageStatsWakeLock"
            )
            
            createNotificationChannel()
            startForeground(NOTIFICATION_ID, createNotification())
            
            scheduler = Executors.newSingleThreadScheduledExecutor()
            startUsageTracking()
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing service: ${e.message}")
            // Stop the service if we can't initialize properly
            stopSelf()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "UsageStatsService started")
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Tracks app usage for launcher statistics"
                setShowBadge(false)
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("App Usage Tracker")
            .setContentText("Tracking app usage for launcher statistics")
            .setSmallIcon(android.R.drawable.ic_menu_info_details)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()
    }

    private fun startUsageTracking() {
        if (isTracking) return
        
        isTracking = true
        scheduler.scheduleAtFixedRate({
            try {
                trackCurrentAppUsage()
            } catch (e: Exception) {
                Log.e(TAG, "Error tracking usage: ${e.message}")
            }
        }, 0, TRACKING_INTERVAL_SECONDS, TimeUnit.SECONDS)
        
        Log.d(TAG, "Usage tracking started")
    }

    private fun trackCurrentAppUsage() {
        try {
            val currentTime = System.currentTimeMillis()
            val endTime = currentTime
            val startTime = endTime - (TRACKING_INTERVAL_SECONDS * 1000)
            
            Log.d(TAG, "Checking usage events from $startTime to $endTime")
            
            val usageEvents = usageStatsManager.queryEvents(startTime, endTime)
            val event = UsageEvents.Event()
            var hasEvents = false
            
            while (usageEvents.hasNextEvent()) {
                usageEvents.getNextEvent(event)
                hasEvents = true
                Log.d(TAG, "Event: ${event.eventType} - ${event.packageName}")
                
                when (event.eventType) {
                    UsageEvents.Event.MOVE_TO_FOREGROUND -> {
                        val packageName = event.packageName
                        if (packageName != currentPackageName) {
                            // App switched, record previous session
                            recordAppSession()
                            
                            // Start new session
                            currentPackageName = packageName
                            sessionStartTime = currentTime
                            Log.d(TAG, "App switched to: $packageName")
                        }
                    }
                    UsageEvents.Event.MOVE_TO_BACKGROUND -> {
                        // App went to background, record session
                        recordAppSession()
                        currentPackageName = null
                    }
                }
            }
            
            if (!hasEvents) {
                Log.d(TAG, "No usage events in this time window")
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error tracking usage: ${e.message}")
        }
    }

    private fun recordAppSession() {
        currentPackageName?.let { packageName ->
            val sessionDuration = System.currentTimeMillis() - sessionStartTime
            if (sessionDuration > 1000) { // Only record sessions longer than 1 second
                Log.d(TAG, "Recording session: $packageName for ${sessionDuration}ms")
                
                // Send data to Flutter via method channel
                sendUsageDataToFlutter(packageName, sessionDuration)
            } else {
                Log.d(TAG, "Session too short: $packageName for ${sessionDuration}ms (skipping)")
            }
        } ?: run {
            Log.d(TAG, "No current package to record session")
        }
    }

    private fun sendUsageDataToFlutter(packageName: String, duration: Long) {
        try {
            Log.d(TAG, "Usage: $packageName - ${duration}ms")
            
            // Store in SharedPreferences for Flutter to read
            val prefs = getSharedPreferences("usage_stats", Context.MODE_PRIVATE)
            val currentTime = System.currentTimeMillis()
            val key = "${packageName}_${currentTime}"
            prefs.edit().putLong(key, duration).apply()
            
            // Also store aggregated daily usage
            val dailyKey = "${packageName}_daily"
            val existingDaily = prefs.getLong(dailyKey, 0)
            val newDaily = existingDaily + duration
            prefs.edit().putLong(dailyKey, newDaily).apply()
            
            Log.d(TAG, "Stored daily usage for $packageName: ${newDaily}ms")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error sending usage data: ${e.message}")
        }
    }

    /// Get current usage stats for testing
    fun getCurrentUsageStats(): Map<String, Long> {
        val prefs = getSharedPreferences("usage_stats", Context.MODE_PRIVATE)
        val stats = mutableMapOf<String, Long>()
        
        // Get all daily usage keys
        val allPrefs = prefs.all
        for ((key, value) in allPrefs) {
            if (key.endsWith("_daily") && value is Long) {
                val packageName = key.removeSuffix("_daily")
                stats[packageName] = value
            }
        }
        
        Log.d(TAG, "Current usage stats: $stats")
        return stats
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "UsageStatsService destroyed")
        
        isTracking = false
        scheduler.shutdown()
        
        if (wakeLock.isHeld) {
            wakeLock.release()
        }
    }
}
