import 'package:app_scheduler/core/constant/months.dart';
import 'package:app_scheduler/core/enum/repeat_mode.dart';
import 'package:app_scheduler/features/screens/home/provider/schedule_provider.dart';
import 'package:app_scheduler/features/screens/schedule_details/service/android_schedule_service.dart';
import 'package:app_scheduler/features/screens/home/model/app_schedule.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/app_info_card.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/detail_bottom_bar.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/meta_card.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/past_banner.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/repeat_selector.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/schedule_picker.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _fmtDate(DateTime dt) => '${months[dt.month]} ${dt.day}, ${dt.year}';

String _fmtTime(DateTime dt) {
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  final p = dt.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $p';
}

String fmtDateTime(DateTime dt) => '${_fmtDate(dt)}  ${_fmtTime(dt)}';

class ScheduleDetailsScreen extends ConsumerStatefulWidget {
  final AppSchedule schedule;
  const ScheduleDetailsScreen({super.key, required this.schedule});

  @override
  ConsumerState<ScheduleDetailsScreen> createState() =>
      _ScheduleDetailsScreenState();
}

class _ScheduleDetailsScreenState extends ConsumerState<ScheduleDetailsScreen> {
  late AppSchedule _draft;
  late TextEditingController _labelCtrl;
  bool _isDirty = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.schedule;
    _labelCtrl = TextEditingController(text: widget.schedule.label ?? '');
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.scheduledAt.isAfter(now)
          ? _draft.scheduledAt
          : now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => _darkTheme(ctx, child),
    );
    if (picked == null) return;
    final prev = _draft.scheduledAt;
    setState(() {
      _draft = _draft.copyWith(
        scheduledAt: DateTime(
          picked.year,
          picked.month,
          picked.day,
          prev.hour,
          prev.minute,
        ),
      );
      _isDirty = true;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _draft.scheduledAt.hour,
        minute: _draft.scheduledAt.minute,
      ),
      builder: (ctx, child) => _darkTheme(ctx, child),
    );
    if (picked == null) return;
    final prev = _draft.scheduledAt;
    setState(() {
      _draft = _draft.copyWith(
        scheduledAt: DateTime(
          prev.year,
          prev.month,
          prev.day,
          picked.hour,
          picked.minute,
        ),
      );
      _isDirty = true;
    });
  }

  Widget _darkTheme(BuildContext context, Widget? child) => Theme(
    data: ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6C63FF),
        onPrimary: Colors.white,
        surface: Color(0xFF1E1E28),
        onSurface: Color(0xFFF0EFF8),
      ),
      dialogBackgroundColor: const Color(0xFF17171F),
    ),
    child: child!,
  );

  Future<void> _save() async {
    final dt = _draft.scheduledAt;
    if (_draft.repeatMode == RepeatModes.once && !dt.isAfter(DateTime.now())) {
      _showSnack('Scheduled time must be in the future.', isError: true);
      return;
    }

    if (_draft.repeatMode == RepeatModes.custom &&
        _draft.customWeekdays.isEmpty) {
      _showSnack('Select at least one day for custom repeat.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final labelText = _labelCtrl.text.trim();
    final updated = labelText.isEmpty
        ? _draft.copyWith(clearLabel: true)
        : _draft.copyWith(label: labelText);

    await AndroidSchedulerService.cancelSchedule(updated.id);
    if (updated.isActive) {
      final scheduleError = await AndroidSchedulerService.scheduleAppLaunch(
        updated,
      );
      if (scheduleError != null) {
        setState(() => _isSaving = false);
        _showSnack('Scheduling failed: $scheduleError', isError: true);
        return;
      }
    }
    await ref.read(schedulesProvider.notifier).saveSchedule(updated);

    if (!mounted) return;
    setState(() {
      _draft = updated;
      _isSaving = false;
      _isDirty = false;
    });
    _showSnack(
      'Schedule updated.',
      icon: Icons.check_circle_outline_rounded,
      iconColor: const Color(0xFF4ECDC4),
    );
  }

  void _showSnack(
    String message, {
    IconData? icon,
    Color? iconColor,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Color(0xFFF0EFF8)),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFB00020)
            : const Color(0xFF1E1E28),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPast =
        _draft.scheduledAt.isBefore(DateTime.now()) &&
        _draft.repeatMode == RepeatModes.once;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(isPast),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App info
                    AppInfoCard(schedule: _draft),
                    const SizedBox(height: 12),

                    if (isPast) ...[
                      PastBanner(scheduledAt: _draft.scheduledAt),
                      const SizedBox(height: 12),
                    ],

                    SectionCard(
                      label: 'Label (Optional)',
                      child: TextField(
                        controller: _labelCtrl,
                        onChanged: (_) => setState(() => _isDirty = true),
                        enabled: !isPast,
                        style: const TextStyle(
                          color: Color(0xFFF0EFF8),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'e.g. Daily Standup',
                          hintStyle: TextStyle(
                            color: Color(0xFF5C5A72),
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLength: 50,
                        buildCounter:
                            (
                              _, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) => Text(
                              '$currentLength / $maxLength',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF5C5A72),
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Date & Time
                    SectionCard(
                      label: 'Date & Time',
                      child: Row(
                        children: [
                          Expanded(
                            child: SchedulePicker(
                              icon: Icons.calendar_today_rounded,
                              iconColor: const Color(0xFFE53935),
                              label: _fmtDate(_draft.scheduledAt),
                              onTap: isPast ? null : _pickDate,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SchedulePicker(
                              icon: Icons.schedule_rounded,
                              iconColor: const Color(0xFF6C63FF),
                              label: _fmtTime(_draft.scheduledAt),
                              onTap: isPast ? null : _pickTime,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Repeat
                    RepeatSelector(
                      selected: _draft.repeatMode,
                      customWeekdays: _draft.customWeekdays,
                      onModeChanged: isPast
                          ? (_) {}
                          : (mode) => setState(() {
                              _draft = _draft.copyWith(repeatMode: mode);
                              _isDirty = true;
                            }),
                      onWeekdayToggled: isPast
                          ? (_) {}
                          : (day) {
                              final days = List<int>.from(
                                _draft.customWeekdays,
                              );
                              days.contains(day)
                                  ? days.remove(day)
                                  : days.add(day);
                              setState(() {
                                _draft = _draft.copyWith(
                                  customWeekdays: days..sort(),
                                );
                                _isDirty = true;
                              });
                            },
                    ),
                    const SizedBox(height: 12),

                    MetaCard(schedule: _draft),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            if (!isPast)
              DetailBottomBar(
                isDirty: _isDirty,
                isSaving: _isSaving,
                onSave: _save,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isPast) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Row(
              children: [
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF6C63FF),
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'Schedules',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            isPast ? 'Completed' : 'Schedule Detail',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF0EFF8),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 80), // visual balance
        ],
      ),
    );
  }
}
