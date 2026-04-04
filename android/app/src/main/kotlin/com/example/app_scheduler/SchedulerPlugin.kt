package com.example.app_scheduler

import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.net.Uri
import androidx.work.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.time.LocalDateTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.concurrent.TimeUnit

class SchedulerPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    // ── FlutterPlugin ─────────────────────────────────────────────────────────

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "com.yourapp/scheduler")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // ── Dispatch ──────────────────────────────────────────────────────────────

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "scheduleAppLaunch"                 -> handleSchedule(call, result)
            "cancelSchedule"                    -> handleCancel(call, result)
            "getInstalledApps"                  -> handleGetApps(result)
            "canScheduleExactAlarms"            -> handleCanScheduleExact(result)
            "openExactAlarmSettings"            -> handleOpenExactAlarmSettings(result)
            "isIgnoringBatteryOptimizations"    -> handleIsIgnoringBattery(result)
            "requestIgnoreBatteryOptimizations" -> handleRequestIgnoreBattery(result)
            else                                -> result.notImplemented()
        }
    }

    // ── scheduleAppLaunch ─────────────────────────────────────────────────────

    private fun handleSchedule(call: MethodCall, result: Result) {
        val scheduleId  = call.argument<String>("scheduleId")  ?: return result.error("MISSING", "scheduleId required", null)
        val packageName = call.argument<String>("packageName") ?: return result.error("MISSING", "packageName required", null)
        val scheduledAt = call.argument<String>("scheduledAt") ?: return result.error("MISSING", "scheduledAt required", null)
        val repeatMode  = call.argument<String>("repeatMode")  ?: "once"
        val weekdays    = call.argument<List<Int>>("customWeekdays") ?: emptyList()
        val hour        = call.argument<Int>("hour") ?: 0
        val minute      = call.argument<Int>("minute") ?: 0

        // Dart's DateTime.toIso8601String() produces a LOCAL time string with no
        // timezone offset, e.g. "2026-04-01T09:00:00.000". ISO_OFFSET_DATE_TIME
        // requires a "+HH:mm" suffix and throws on bare local strings.
        // We strip sub-second precision (.000) then parse as LocalDateTime and
        // attach the device's system timezone to get the correct epoch milliseconds.
        val targetMs: Long = try {
            val normalized = scheduledAt.substringBefore(".")
            val local = LocalDateTime.parse(normalized, DateTimeFormatter.ISO_LOCAL_DATE_TIME)
            local.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
        } catch (e: Exception) {
            return result.error("PARSE_ERROR", "Cannot parse scheduledAt '$scheduledAt': ${e.message}", null)
        }

        val delayMs = (targetMs - System.currentTimeMillis()).coerceAtLeast(0L)

        // workDataOf only supports primitive arrays — List<Int> must be converted
        val weekdaysArray: IntArray = weekdays.toIntArray()

        val inputData = workDataOf(
            "scheduleId"  to scheduleId,
            "packageName" to packageName,
            "hour"        to hour,
            "minute"      to minute,
            "repeatMode"  to repeatMode,
            "weekdays"    to weekdaysArray,
        )

        val constraints = Constraints.Builder()
            .setRequiresBatteryNotLow(false)
            .build()

        val request = OneTimeWorkRequestBuilder<AppLaunchWorker>()
            .setInitialDelay(delayMs, TimeUnit.MILLISECONDS)
            .setInputData(inputData)
            .setConstraints(constraints)
            .addTag(scheduleId)
            .build()

        WorkManager.getInstance(context)
            .enqueueUniqueWork(scheduleId, ExistingWorkPolicy.REPLACE, request)

        result.success(null)
    }

    // ── cancelSchedule ────────────────────────────────────────────────────────

    private fun handleCancel(call: MethodCall, result: Result) {
        val scheduleId = call.argument<String>("scheduleId")
            ?: return result.error("MISSING", "scheduleId required", null)
        WorkManager.getInstance(context).cancelUniqueWork(scheduleId)
        result.success(null)
    }

    // ── getInstalledApps ──────────────────────────────────────────────────────

    private fun handleGetApps(result: Result) {
        val pm = context.packageManager
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val resolvedApps = pm.queryIntentActivities(intent, 0)
        val apps = resolvedApps
            .map { info ->
                mapOf(
                    "appName"     to info.loadLabel(pm).toString(),
                    "packageName" to info.activityInfo.packageName,
                )
            }
            .distinctBy { it["packageName"] }
            .sortedBy { it["appName"]?.lowercase() }
        result.success(apps)
    }

    // ── canScheduleExactAlarms (API 31+) ──────────────────────────────────────

    private fun handleCanScheduleExact(result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            result.success(am.canScheduleExactAlarms())
        } else {
            result.success(true)
        }
    }

    // ── openExactAlarmSettings (API 31+) ─────────────────────────────────────

    private fun handleOpenExactAlarmSettings(result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                data = Uri.parse("package:${context.packageName}")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
        }
        result.success(null)
    }

    // ── isIgnoringBatteryOptimizations ────────────────────────────────────────

    private fun handleIsIgnoringBattery(result: Result) {
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        result.success(pm.isIgnoringBatteryOptimizations(context.packageName))
    }

    // ── requestIgnoreBatteryOptimizations ─────────────────────────────────────

    private fun handleRequestIgnoreBattery(result: Result) {
        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
            data = Uri.parse("package:${context.packageName}")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
        result.success(null)
    }
}