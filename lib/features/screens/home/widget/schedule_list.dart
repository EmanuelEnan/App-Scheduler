import 'package:app_scheduler/core/constant/months.dart';
import 'package:app_scheduler/core/enum/repeat_mode.dart';
import 'package:app_scheduler/features/screens/home/model/app_schedule.dart';
import 'package:app_scheduler/features/screens/home/widget/delete_sheet.dart';
import 'package:app_scheduler/features/screens/home/widget/schedule_card.dart';
import 'package:app_scheduler/features/screens/home/widget/section_label.dart';
import 'package:app_scheduler/features/screens/home/widget/stats_row.dart';
import 'package:app_scheduler/features/screens/home/provider/schedule_provider.dart';
import 'package:app_scheduler/features/screens/schedule_details/view/schedule_details_screen.dart';
import 'package:app_scheduler/features/screens/schedule_details/service/android_schedule_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduleList extends ConsumerWidget {
  final List<AppSchedule> schedules;
  const ScheduleList({super.key, required this.schedules});

  String _repeatLabel(AppSchedule s) {
    switch (s.repeatMode) {
      case RepeatModes.once:
        return 'Once';
      case RepeatModes.daily:
        return 'Daily';
      case RepeatModes.weekdays:
        return 'Mon – Fri';
      case RepeatModes.weekends:
        return 'Sat – Sun';
      case RepeatModes.weekly:
        return 'Weekly';
      case RepeatModes.custom:
        const labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
        return s.customWeekdays.map((d) => labels[d - 1]).join(', ');
    }
  }

  String _fmtTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  String _fmtDate(DateTime dt) {
    return '${months[dt.month]} ${dt.day}, ${dt.year}';
  }

  bool _isSoon(AppSchedule s) {
    final diff = s.scheduledAt.difference(DateTime.now());
    return diff.inMinutes > 0 && diff.inMinutes <= 60;
  }

  bool _isPast(AppSchedule s) =>
      s.scheduledAt.isBefore(DateTime.now()) &&
      s.repeatMode == RepeatModes.once;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group: upcoming vs past
    final upcoming = schedules.where((s) => !_isPast(s)).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final past = schedules.where(_isPast).toList()
      ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      children: [
        StatsRow(
          total: schedules.length,
          active: schedules.where((s) => s.isActive).length,
          today: schedules.where((s) {
            final now = DateTime.now();
            return s.scheduledAt.day == now.day &&
                s.scheduledAt.month == now.month &&
                s.scheduledAt.year == now.year &&
                s.isActive;
          }).length,
        ),
        const SizedBox(height: 20),

        if (upcoming.isNotEmpty) ...[
          SectionLabel('Upcoming', count: upcoming.length),
          const SizedBox(height: 10),
          ...upcoming.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ScheduleCard(
                schedule: s,
                timeLabel: _fmtTime(s.scheduledAt),
                dateLabel: _fmtDate(s.scheduledAt),
                repeatLabel: _repeatLabel(s),
                isSoon: _isSoon(s),
                isPast: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScheduleDetailsScreen(schedule: s),
                  ),
                ),
                onToggle: () async {
                  await ref.read(schedulesProvider.notifier).toggleActive(s.id);
                  if (s.isActive) {
                    await AndroidSchedulerService.cancelSchedule(s.id);
                  } else {
                    await AndroidSchedulerService.scheduleAppLaunch(
                      s.copyWith(isActive: true),
                    );
                  }
                },
                onDelete: () => _confirmDelete(context, ref, s),
              ),
            ),
          ),
        ],

        if (past.isNotEmpty) ...[
          const SizedBox(height: 8),
          SectionLabel('Past', count: past.length),
          const SizedBox(height: 10),
          ...past.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ScheduleCard(
                schedule: s,
                timeLabel: _fmtTime(s.scheduledAt),
                dateLabel: _fmtDate(s.scheduledAt),
                repeatLabel: _repeatLabel(s),
                isSoon: false,
                isPast: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScheduleDetailsScreen(schedule: s),
                  ),
                ),
                onToggle: () {},
                onDelete: () => _confirmDelete(context, ref, s),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, AppSchedule s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E28),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DeleteSheet(
        scheduleName: s.label ?? s.appName,
        onConfirm: () async {
          Navigator.pop(context);
          await AndroidSchedulerService.cancelSchedule(s.id);
          await ref.read(schedulesProvider.notifier).remove(s.id);
        },
      ),
    );
  }
}
