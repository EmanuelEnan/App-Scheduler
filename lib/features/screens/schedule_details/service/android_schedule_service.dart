import 'package:app_scheduler/features/screens/home/model/app_schedule.dart';
import 'package:flutter/services.dart';

/// Dart side wrapper around the native [SchedulerPlugin] MethodChannel.
///

class AndroidSchedulerService {
  AndroidSchedulerService._();

  static const _channel = MethodChannel('com.yourapp/scheduler');

  static Future<String?> scheduleAppLaunch(AppSchedule schedule) async {
    try {
      await _channel.invokeMethod<void>('scheduleAppLaunch', {
        'scheduleId': schedule.id,
        'packageName': schedule.packageName,

        'scheduledAt': schedule.scheduledAt.toIso8601String(),
        'hour': schedule.scheduledAt.hour,
        'minute': schedule.scheduledAt.minute,
        'repeatMode': schedule.repeatMode.name,
        'customWeekdays': schedule.customWeekdays,
      });
      return null; // null = success
    } on PlatformException catch (e) {
      final msg = '[${e.code}] ${e.message ?? "Unknown error"}';
      _log('scheduleAppLaunch failed: $msg');
      return msg;
    }
  }

  static Future<bool> cancelSchedule(String scheduleId) async {
    try {
      await _channel.invokeMethod<void>('cancelSchedule', {
        'scheduleId': scheduleId,
      });
      return true;
    } on PlatformException catch (e) {
      _log('cancelSchedule failed [${e.code}]: ${e.message}');
      return false;
    }
  }

  static Future<bool> canScheduleExactAlarms() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'canScheduleExactAlarms',
      );
      return result ?? true;
    } on PlatformException {
      return true;
    }
  }

  static Future<void> openExactAlarmSettings() async {
    try {
      await _channel.invokeMethod<void>('openExactAlarmSettings');
    } on PlatformException catch (e) {
      _log('openExactAlarmSettings failed: ${e.message}');
    }
  }

  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isIgnoringBatteryOptimizations',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      await _channel.invokeMethod<void>('requestIgnoreBatteryOptimizations');
    } on PlatformException catch (e) {
      _log('requestIgnoreBatteryOptimizations failed: ${e.message}');
    }
  }

  static Future<List<Map<String, String>>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'getInstalledApps',
      );
      if (result == null) return [];
      return result.map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        return {
          'appName': map['appName'] as String? ?? '',
          'packageName': map['packageName'] as String? ?? '',
        };
      }).toList();
    } on PlatformException catch (e) {
      _log('getInstalledApps failed: ${e.message}');
      return [];
    }
  }

  static void _log(String msg) {
    assert(() {
      print('[AndroidSchedulerService] $msg');
      return true;
    }());
  }
}
