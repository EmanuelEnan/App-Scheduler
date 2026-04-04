import 'dart:convert';
import 'package:app_scheduler/core/enum/repeat_mode.dart';
import 'package:app_scheduler/features/screens/home/model/app_schedule.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SchedulesNotifier extends AsyncNotifier<List<AppSchedule>> {
  static const _prefsKey = 'app_schedules_v2';

  @override
  Future<List<AppSchedule>> build() => _load();

  // Helpers

  Future<List<AppSchedule>> _current() async {
    final value = state.value;
    if (value != null) return value;

    return await future;
  }

  Future<void> _setValue(List<AppSchedule> updated) async {
    await _persist(updated);
    state = AsyncData(updated);
  }

  Future<void> add(AppSchedule schedule) async {
    final current = await _current();
    await _setValue([...current, schedule]);
  }

  Future<void> saveSchedule(AppSchedule schedule) async {
    final current = await _current();

    final updated = <AppSchedule>[];
    bool found = false;

    for (final existing in current) {
      if (existing.id == schedule.id) {
        updated.add(schedule);
        found = true;
      } else {
        updated.add(existing);
      }
    }

    if (!found) {
      updated.add(schedule);
    }

    await _setValue(updated);
  }

  Future<void> remove(String id) async {
    final current = await _current();
    final updated = current.where((s) => s.id != id).toList();
    await _setValue(updated);
  }

  Future<void> toggleActive(String id) async {
    final current = await _current();
    final updated = <AppSchedule>[];

    for (final s in current) {
      if (s.id == id) {
        updated.add(s.copyWith(isActive: !s.isActive));
      } else {
        updated.add(s);
      }
    }

    await _setValue(updated);
  }

  Future<void> clearAll() async {
    await _setValue([]);
  }

  // Conflict detection

  List<AppSchedule> findConflicts(DateTime candidate, {String? excludeId}) {
    final current = state.value ?? [];
    final results = <AppSchedule>[];

    for (final s in current) {
      if (!s.isActive) continue;
      if (s.id == excludeId) continue;
      if (s.scheduledAt.hour == candidate.hour &&
          s.scheduledAt.minute == candidate.minute) {
        results.add(s);
      }
    }

    return results;
  }

  // persistence

  Future<List<AppSchedule>> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];

    final loaded = <AppSchedule>[];
    for (final entry in raw) {
      try {
        final map = jsonDecode(entry) as Map<String, dynamic>;
        loaded.add(AppSchedule.fromJson(map));
      } catch (e) {
        assert(() {
          print('[SchedulesNotifier] Skipped corrupt entry: $e\n$entry');
          return true;
        }());
      }
    }

    return loaded;
  }

  Future<void> _persist(List<AppSchedule> schedules) async {
    final prefs = await SharedPreferences.getInstance();
    final serialised = <String>[];

    for (final s in schedules) {
      try {
        serialised.add(jsonEncode(s.toJson()));
      } catch (e) {
        assert(() {
          // ignore: avoid_print
          print('[SchedulesNotifier] Failed to serialise schedule ${s.id}: $e');
          return true;
        }());
      }
    }

    await prefs.setStringList(_prefsKey, serialised);
  }
}

// Providers

final schedulesProvider =
    AsyncNotifierProvider<SchedulesNotifier, List<AppSchedule>>(
      SchedulesNotifier.new,
    );

/// All schedules sorted chronologically. Safe to use directly in widgets
final sortedSchedulesProvider = Provider<List<AppSchedule>>((ref) {
  final all = ref.watch(schedulesProvider).value ?? [];
  final copy = List<AppSchedule>.from(all);
  copy.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  return copy;
});

/// Only active schedules that are either upcoming or repeating
final activeUpcomingProvider = Provider<List<AppSchedule>>((ref) {
  final now = DateTime.now();
  final all = ref.watch(schedulesProvider).value ?? [];

  final filtered = all.where((s) {
    if (!s.isActive) return false;
    // Repeating schedules are always "upcoming"
    if (s.repeatMode != RepeatModes.once) return true;
    // One time schedules are only upcoming if they haven't fired yet
    return s.scheduledAt.isAfter(now);
  }).toList();

  filtered.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  return filtered;
});
