import 'package:app_scheduler/core/enum/repeat_mode.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter/foundation.dart';

export 'package:flutter/material.dart' show TimeOfDay;

@immutable
class ScheduleFormState {
  final String? appName;
  final String? packageName;
  final Uint8List? appIcon;
  final String label;
  final DateTime? date;
  final TimeOfDay? time;
  final RepeatModes repeatMode;
  final List<int> customWeekdays;

  // Validation / UI state
  final bool hasTriedSave;
  final List<String> conflicts; // display names of conflicting schedules

  const ScheduleFormState({
    this.appName,
    this.packageName,
    this.appIcon,
    this.label = '',
    this.date,
    this.time,
    this.repeatMode = RepeatModes.once,
    this.customWeekdays = const [],
    this.hasTriedSave = false,
    this.conflicts = const [],
  });

  bool get hasApp => appName != null && packageName != null;

  DateTime? get scheduledAt {
    if (date == null || time == null) return null;
    return DateTime(
      date!.year,
      date!.month,
      date!.day,
      time!.hour,
      time!.minute,
    );
  }

  bool get isInFuture {
    final dt = scheduledAt;
    if (dt == null) return false;
    return dt.isAfter(DateTime.now());
  }

  bool get isValid => hasApp && scheduledAt != null && isInFuture;

  String? get appError =>
      hasTriedSave && !hasApp ? 'Please select an app' : null;

  String? get dateTimeError {
    if (!hasTriedSave) return null;
    if (date == null || time == null) return 'Please set a date and time';
    if (!isInFuture) return 'Schedule must be set in the future';
    return null;
  }

  ScheduleFormState copyWith({
    String? appName,
    String? packageName,
    Uint8List? appIcon,
    String? label,
    DateTime? date,
    TimeOfDay? time,
    RepeatModes? repeatMode,
    List<int>? customWeekdays,
    bool? hasTriedSave,
    List<String>? conflicts,
    bool clearApp = false,
    bool clearDate = false,
    bool clearTime = false,
  }) {
    return ScheduleFormState(
      appName: clearApp ? null : (appName ?? this.appName),
      packageName: clearApp ? null : (packageName ?? this.packageName),
      appIcon: clearApp ? null : (appIcon ?? this.appIcon),
      label: label ?? this.label,
      date: clearDate ? null : (date ?? this.date),
      time: clearTime ? null : (time ?? this.time),
      repeatMode: repeatMode ?? this.repeatMode,
      customWeekdays: customWeekdays ?? this.customWeekdays,
      hasTriedSave: hasTriedSave ?? this.hasTriedSave,
      conflicts: conflicts ?? this.conflicts,
    );
  }
}
