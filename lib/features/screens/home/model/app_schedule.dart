import 'package:app_scheduler/core/enum/repeat_mode.dart';
import 'package:flutter/foundation.dart';

@immutable
class AppSchedule {
  final String id;
  final String appName;
  final String packageName;
  final Uint8List? appIcon;
  final String? label;
  final DateTime scheduledAt;
  final RepeatModes repeatMode;
  final List<int> customWeekdays; // 1=Mon … 7=Sun
  final bool isActive;
  final DateTime createdAt;

  const AppSchedule({
    required this.id,
    required this.appName,
    required this.packageName,
    this.appIcon,
    this.label,
    required this.scheduledAt,
    this.repeatMode = RepeatModes.once,
    this.customWeekdays = const [],
    this.isActive = true,
    required this.createdAt,
  });

  /// clearLabel — pass true to explicitly set label to null
  /// clearIcon  — pass true to explicitly set appIcon to null
  AppSchedule copyWith({
    String? id,
    String? appName,
    String? packageName,
    Uint8List? appIcon,
    String? label,
    DateTime? scheduledAt,
    RepeatModes? repeatMode,
    List<int>? customWeekdays,
    bool? isActive,
    DateTime? createdAt,
    bool clearLabel = false,
    bool clearIcon = false,
  }) {
    return AppSchedule(
      id: id ?? this.id,
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      appIcon: clearIcon ? null : (appIcon ?? this.appIcon),
      label: clearLabel ? null : (label ?? this.label),
      scheduledAt: scheduledAt ?? this.scheduledAt,
      repeatMode: repeatMode ?? this.repeatMode,
      customWeekdays: customWeekdays ?? this.customWeekdays,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'appName': appName,
    'packageName': packageName,
    'label': label,
    'scheduledAt': scheduledAt.toIso8601String(),
    'repeatMode': repeatMode.name,
    'customWeekdays': customWeekdays,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AppSchedule.fromJson(Map<String, dynamic> json) => AppSchedule(
    id: json['id'] as String,
    appName: json['appName'] as String,
    packageName: json['packageName'] as String,
    label: json['label'] as String?,
    scheduledAt: DateTime.parse(json['scheduledAt'] as String),
    repeatMode: RepeatModes.values.firstWhere(
      (e) => e.name == json['repeatMode'],
      orElse: () => RepeatModes.once,
    ),
    customWeekdays: List<int>.from(json['customWeekdays'] as List? ?? []),
    isActive: json['isActive'] as bool? ?? true,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  bool conflictsWith(AppSchedule other) {
    if (id == other.id) return false;
    return scheduledAt.hour == other.scheduledAt.hour &&
        scheduledAt.minute == other.scheduledAt.minute;
  }

  @override
  String toString() =>
      'AppSchedule(id: $id, app: $appName, at: $scheduledAt, repeat: ${repeatMode.name})';
}
