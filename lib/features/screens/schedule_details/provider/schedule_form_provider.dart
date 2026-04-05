import 'dart:typed_data';
import 'package:app_scheduler/core/enum/repeat_mode.dart';
import 'package:app_scheduler/features/screens/schedule_details/model/schedule_form_state.dart';
import 'package:app_scheduler/features/screens/home/provider/schedule_provider.dart';
import 'package:app_scheduler/features/screens/home/model/app_schedule.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduleFormNotifier extends Notifier<ScheduleFormState> {
  @override
  ScheduleFormState build() => const ScheduleFormState();

  void selectApp({
    required String appName,
    required String packageName,
    Uint8List? icon,
  }) {
    state = state.copyWith(
      appName: appName,
      packageName: packageName,
      appIcon: icon,
    );
  }

  void clearApp() => state = state.copyWith(clearApp: true);

  void setLabel(String value) => state = state.copyWith(label: value);

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
    _checkConflicts();
  }

  void setTime(TimeOfDay time) {
    state = state.copyWith(time: time);
    _checkConflicts();
  }

  void setRepeatMode(RepeatModes mode) =>
      state = state.copyWith(repeatMode: mode);

  void toggleWeekday(int day) {
    final days = List<int>.from(state.customWeekdays);
    days.contains(day) ? days.remove(day) : days.add(day);
    state = state.copyWith(customWeekdays: days..sort());
  }

  void _checkConflicts() {
    final dt = state.scheduledAt;
    if (dt == null) {
      state = state.copyWith(conflicts: []);
      return;
    }
    final conflicts = ref
        .read(schedulesProvider.notifier)
        .findConflicts(dt)
        .map((s) => s.label ?? s.appName)
        .toList();
    state = state.copyWith(conflicts: conflicts);
  }

  Future<AppSchedule?> trySave() async {
    state = state.copyWith(hasTriedSave: true);
    _checkConflicts();

    if (!state.isValid) return null;

    final schedule = AppSchedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      appName: state.appName!,
      packageName: state.packageName!,
      appIcon: state.appIcon,
      label: state.label.trim().isEmpty ? null : state.label.trim(),
      scheduledAt: state.scheduledAt!,
      repeatMode: state.repeatMode,
      customWeekdays: List<int>.from(state.customWeekdays),
      createdAt: DateTime.now(),
    );
    if (state.conflicts.isNotEmpty) {
      print('Conflicts detected with: ${state.conflicts.join(', ')}');
      return null;
    }
    await ref.read(schedulesProvider.notifier).add(schedule);
    return schedule;
  }

  void reset() => state = const ScheduleFormState();
}

final scheduleFormProvider =
    NotifierProvider<ScheduleFormNotifier, ScheduleFormState>(
      ScheduleFormNotifier.new,
    );

final installedAppsProvider = FutureProvider.autoDispose<List<Application>>((
  ref,
) async {
  // Keep alive for the session — re-fetching 100+ apps on every push is slow
  ref.keepAlive();

  final apps = await DeviceApps.getInstalledApplications(
    includeAppIcons: true,
    includeSystemApps: false,
    onlyAppsWithLaunchIntent: true,
  );

  return [
    ...apps,
  ]..sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
});
