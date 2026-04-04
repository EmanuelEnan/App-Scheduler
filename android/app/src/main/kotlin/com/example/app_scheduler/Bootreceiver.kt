package com.example.app_scheduler

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import androidx.work.*
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.TimeUnit
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter

/**
 * Fires on BOOT_COMPLETED.  Reads the schedules that Flutter persisted
 * in SharedPreferences (same key as the Dart side) and re-enqueues
 * WorkManager jobs for any that are still in the future.
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action !in listOf(
                Intent.ACTION_BOOT_COMPLETED,
                Intent.ACTION_LOCKED_BOOT_COMPLETED,
                Intent.ACTION_MY_PACKAGE_REPLACED,
            )
        ) return

        val prefs: SharedPreferences =
            context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        // flutter/shared_preferences stores list as JSON under "flutter.app_schedules"
        val raw = prefs.getString("flutter.app_schedules", null) ?: return
        val arr = try { JSONArray(raw) } catch (_: Exception) { return }

        val wm = WorkManager.getInstance(context)
        val now = System.currentTimeMillis()

        for (i in 0 until arr.length()) {
            val obj: JSONObject = arr.optJSONObject(i) ?: continue
            val scheduleId  = obj.optString("id")         .ifBlank { continue }
            val packageName = obj.optString("packageName").ifBlank { continue }
            val scheduledAt = obj.optString("scheduledAt").ifBlank { continue }
            val repeatMode  = obj.optString("repeatMode", "once")
            val isActive    = obj.optBoolean("isActive", true)

            if (!isActive) continue

            val targetMs = try {
                ZonedDateTime.parse(scheduledAt, DateTimeFormatter.ISO_OFFSET_DATE_TIME)
                    .withZoneSameInstant(java.time.ZoneId.systemDefault())
                    .toInstant()
                    .toEpochMilli()
            } catch (_: Exception) { continue }

            // Skip past one-time schedules that have already elapsed
            if (repeatMode == "once" && targetMs < now) continue

            val delayMs = (targetMs - now).coerceAtLeast(0L)

            val cal = java.util.Calendar.getInstance().apply {
                timeInMillis = targetMs
            }

            val inputData = workDataOf(
                "scheduleId"  to scheduleId,
                "packageName" to packageName,
                "hour"        to cal.get(java.util.Calendar.HOUR_OF_DAY),
                "minute"      to cal.get(java.util.Calendar.MINUTE),
                "repeatMode"  to repeatMode,
                "weekdays"    to intArrayOf(), // re-parsed from JSON if needed
            )

            val request = OneTimeWorkRequestBuilder<AppLaunchWorker>()
                .setInitialDelay(delayMs, TimeUnit.MILLISECONDS)
                .setInputData(inputData)
                .addTag(scheduleId)
                .build()

            wm.enqueueUniqueWork(scheduleId, ExistingWorkPolicy.REPLACE, request)
        }
    }
}