package com.arc.launcher

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    companion object {
        private const val TAG = "BootReceiver"
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED -> {
                Log.d(TAG, "Boot completed, starting UsageStatsService")
                startUsageStatsService(context)
            }
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                Log.d(TAG, "Package replaced, starting UsageStatsService")
                startUsageStatsService(context)
            }
        }
    }

    private fun startUsageStatsService(context: Context) {
        try {
            val serviceIntent = Intent(context, UsageStatsService::class.java)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
            Log.d(TAG, "UsageStatsService started successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start UsageStatsService: ${e.message}")
        }
    }
}
