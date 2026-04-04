import 'package:app_scheduler/core/constant/app_colors.dart';
import 'package:app_scheduler/core/constant/months.dart';
import 'package:app_scheduler/features/screens/schedule_details/provider/schedule_form_provider.dart';
import 'package:app_scheduler/features/screens/schedule_details/service/android_schedule_service.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/app_selection_card.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/bottom_bar.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/conflict_banner.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/picker_chip.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/repeat_selector.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/section_card.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/top_bar.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/validation_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_picker_screen.dart';

class ScheduleBuilderScreen extends ConsumerStatefulWidget {
  const ScheduleBuilderScreen({super.key});

  @override
  ConsumerState<ScheduleBuilderScreen> createState() =>
      _ScheduleBuilderScreenState();
}

class _ScheduleBuilderScreenState extends ConsumerState<ScheduleBuilderScreen> {
  final _labelCtrl = TextEditingController();

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final current = ref.read(scheduleFormProvider).date;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => _darkPickerTheme(ctx, child),
    );
    if (picked != null) {
      ref.read(scheduleFormProvider.notifier).setDate(picked);
    }
  }

  Future<void> _pickTime() async {
    final current = ref.read(scheduleFormProvider).time;
    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) => _darkPickerTheme(ctx, child),
    );
    if (picked != null) {
      ref.read(scheduleFormProvider.notifier).setTime(picked);
    }
  }

  Widget _darkPickerTheme(BuildContext context, Widget? child) => Theme(
    data: ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: AppColors.surfaceElevated,
        onSurface: AppColors.textPrimary,
      ),
      dialogTheme: DialogThemeData(backgroundColor: AppColors.surface),
    ),
    child: child!,
  );

  Future<void> _save() async {
    final schedule = await ref.read(scheduleFormProvider.notifier).trySave();
    if (schedule == null) return; // validation failed

    final error = await AndroidSchedulerService.scheduleAppLaunch(schedule);
    if (!mounted) return;

    if (error == null) {
      _showSnack(
        '${schedule.appName} scheduled for ${_fmtDateTime(schedule.scheduledAt)}',
        icon: Icons.check_circle_outline_rounded,
        iconColor: AppColors.secondary,
      );
      ref.read(scheduleFormProvider.notifier).reset();
      Navigator.pop(context);
    } else {
      // Check if missing exact alarm permission
      final canSchedule =
          await AndroidSchedulerService.canScheduleExactAlarms();
      if (!canSchedule && mounted) {
        _showPermissionDialog();
      } else {
        _showSnack('Scheduling failed: $error', isError: true);
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Permission Required',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Android 12+ requires "Alarms & Reminders" permission to schedule exact launch times.\n\nOpen Settings to grant it.',
          style: TextStyle(color: Color(0xFF9B99B5), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Later',
              style: TextStyle(color: Color(0xFF9B99B5)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AndroidSchedulerService.openExactAlarmSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              elevation: 0,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
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

  String _fmtDate(DateTime dt) => '${months[dt.month]} ${dt.day}, ${dt.year}';

  String _fmtDateTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour < 12 ? 'AM' : 'PM';
    return '${months[dt.month]} ${dt.day}, ${dt.year}  $h:$m $p';
  }

  String _fmtTime(TimeOfDay t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(scheduleFormProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      body: SafeArea(
        child: Column(
          children: [
            TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSelectionCard(
                      form: form,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AppPickerScreen(),
                        ),
                      ),
                      onClear: () =>
                          ref.read(scheduleFormProvider.notifier).clearApp(),
                    ),
                    if (form.hasTriedSave && form.appError != null)
                      ValidationMessage(form.appError!),

                    const SizedBox(height: 12),

                    SectionCard(
                      label: 'Label (Optional)',
                      child: TextField(
                        controller: _labelCtrl,
                        onChanged: (v) =>
                            ref.read(scheduleFormProvider.notifier).setLabel(v),
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

                    SectionCard(
                      label: 'Date & Time',
                      hasError: form.hasTriedSave && form.dateTimeError != null,
                      child: Row(
                        children: [
                          Expanded(
                            child: PickerChip(
                              icon: Icons.calendar_today_rounded,
                              iconColor: const Color(0xFFE53935),
                              label: form.date != null
                                  ? _fmtDate(form.date!)
                                  : 'Select date',
                              isEmpty: form.date == null,
                              hasError: form.hasTriedSave && form.date == null,
                              onTap: _pickDate,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: PickerChip(
                              icon: Icons.schedule_rounded,
                              iconColor: const Color(0xFF6C63FF),
                              label: form.time != null
                                  ? _fmtTime(form.time!)
                                  : 'Select time',
                              isEmpty: form.time == null,
                              hasError: form.hasTriedSave && form.time == null,
                              onTap: _pickTime,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (form.hasTriedSave && form.dateTimeError != null)
                      ValidationMessage(form.dateTimeError!),

                    const SizedBox(height: 12),

                    RepeatSelector(
                      selected: form.repeatMode,
                      customWeekdays: form.customWeekdays,
                      onModeChanged: (m) => ref
                          .read(scheduleFormProvider.notifier)
                          .setRepeatMode(m),
                      onWeekdayToggled: (d) => ref
                          .read(scheduleFormProvider.notifier)
                          .toggleWeekday(d),
                    ),

                    const SizedBox(height: 12),

                    if (form.conflicts.isNotEmpty)
                      ConflictBanner(
                        conflicts: form.conflicts,
                        time: form.time!,
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            BottomBar(
              onCancel: () {
                ref.read(scheduleFormProvider.notifier).reset();
                Navigator.pop(context);
              },
              onSave: _save,
            ),
          ],
        ),
      ),
    );
  }
}
