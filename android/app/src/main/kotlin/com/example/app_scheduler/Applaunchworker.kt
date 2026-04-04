package com.example.app_scheduler

import android.content.Context
import android.content.Intent
import androidx.work.*
import java.util.concurrent.TimeUnit

/**
 * WorkManager Worker that launches the target app and re-schedules
 * itself for the next occurrence when repeatMode != "once".
 */
class AppLaunchWorker(
    private val ctx: Context,
    params: WorkerParameters,
) : CoroutineWorker(ctx, params) {

    override suspend fun doWork(): Result {
        val packageName = inputData.getString("packageName")
            ?: return Result.failure()

        // ── Launch the app ─────────────────────────────────────────────
        val launchIntent = ctx.packageManager
            .getLaunchIntentForPackage(packageName)
            ?.apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }

        if (launchIntent != null) {
            ctx.startActivity(launchIntent)
        }

        // ── Re-schedule for next occurrence ────────────────────────────
        val repeatMode  = inputData.getString("repeatMode") ?: "once"
        val scheduleId  = inputData.getString("scheduleId") ?: return Result.success()
        val hour        = inputData.getInt("hour", 0)
        val minute      = inputData.getInt("minute", 0)
        val weekdays    = inputData.getIntArray("weekdays")?.toList() ?: emptyList()

        if (repeatMode != "once") {
            scheduleNextOccurrence(
                scheduleId  = scheduleId,
                packageName = packageName,
                hour        = hour,
                minute      = minute,
                repeatMode  = repeatMode,
                weekdays    = weekdays,
            )
        }

        return Result.success()
    }

    private fun scheduleNextOccurrence(
        scheduleId: String,
        packageName: String,
        hour: Int,
        minute: Int,
        repeatMode: String,
        weekdays: List<Int>,
    ) {
        val now = java.util.Calendar.getInstance()

        val next = java.util.Calendar.getInstance().apply {
            set(java.util.Calendar.HOUR_OF_DAY, hour)
            set(java.util.Calendar.MINUTE, minute)
            set(java.util.Calendar.SECOND, 0)
            set(java.util.Calendar.MILLISECOND, 0)
        }

        // Advance next to the correct day based on repeatMode
        when (repeatMode) {
            "daily" -> next.add(java.util.Calendar.DAY_OF_YEAR, 1)

            "weekdays" -> {
                // Move to next Mon–Fri
                next.add(java.util.Calendar.DAY_OF_YEAR, 1)
                while (next.get(java.util.Calendar.DAY_OF_WEEK) in
                    listOf(java.util.Calendar.SATURDAY, java.util.Calendar.SUNDAY)) {
                    next.add(java.util.Calendar.DAY_OF_YEAR, 1)
                }
            }

            "weekends" -> {
                next.add(java.util.Calendar.DAY_OF_YEAR, 1)
                while (next.get(java.util.Calendar.DAY_OF_WEEK) !in
                    listOf(java.util.Calendar.SATURDAY, java.util.Calendar.SUNDAY)) {
                    next.add(java.util.Calendar.DAY_OF_YEAR, 1)
                }
            }

            "custom" -> {
                if (weekdays.isEmpty()) return
                // Calendar day of week: 1=Sun, 2=Mon … 7=Sat
                // Our format: 1=Mon … 7=Sun → convert
                val calWeekdays = weekdays.map { it % 7 + 1 } // Mon(1)→2, Sun(7)→1
                next.add(java.util.Calendar.DAY_OF_YEAR, 1)
                var tries = 0
                while (next.get(java.util.Calendar.DAY_OF_WEEK) !in calWeekdays && tries < 7) {
                    next.add(java.util.Calendar.DAY_OF_YEAR, 1)
                    tries++
                }
            }

            else -> return // "once" — do nothing
        }

        val delayMs = (next.timeInMillis - System.currentTimeMillis()).coerceAtLeast(0L)

        val inputData = workDataOf(
            "scheduleId"  to scheduleId,
            "packageName" to packageName,
            "hour"        to hour,
            "minute"      to minute,
            "repeatMode"  to repeatMode,
            "weekdays"    to weekdays.toIntArray(),
        )

        val request = OneTimeWorkRequestBuilder<AppLaunchWorker>()
            .setInitialDelay(delayMs, TimeUnit.MILLISECONDS)
            .setInputData(inputData)
            .addTag(scheduleId)
            .build()

        WorkManager.getInstance(ctx)
            .enqueueUniqueWork(scheduleId, ExistingWorkPolicy.REPLACE, request)
    }
}