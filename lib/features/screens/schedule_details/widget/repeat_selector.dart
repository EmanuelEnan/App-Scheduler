import 'package:app_scheduler/core/enum/repeat_mode.dart';
import 'package:flutter/material.dart';
import 'section_card.dart';

class RepeatSelector extends StatelessWidget {
  final RepeatModes selected;
  final List<int> customWeekdays;
  final ValueChanged<RepeatModes> onModeChanged;
  final ValueChanged<int> onWeekdayToggled;

  const RepeatSelector({
    super.key,
    required this.selected,
    required this.customWeekdays,
    required this.onModeChanged,
    required this.onWeekdayToggled,
  });

  static const _modes = <(RepeatModes, String, IconData)>[
    (RepeatModes.once, 'Once', Icons.looks_one_outlined),
    (RepeatModes.daily, 'Daily', Icons.repeat_rounded),
    (RepeatModes.weekdays, 'Weekdays', Icons.work_outline_rounded),
    (RepeatModes.weekends, 'Weekends', Icons.weekend_outlined),
    (RepeatModes.custom, 'Custom', Icons.tune_rounded),
  ];

  static const _dayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      label: 'Repeat',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _modes.map((entry) {
                final (mode, label, icon) = entry;
                final isSelected = selected == mode;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onModeChanged(mode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6C63FF).withOpacity(0.15)
                            : const Color(0xFF252530),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6C63FF)
                              : const Color(0xFF2A2A38),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 14,
                            color: isSelected
                                ? const Color(0xFF6C63FF)
                                : const Color(0xFF9B99B5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF6C63FF)
                                  : const Color(0xFF9B99B5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          if (selected == RepeatModes.custom) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final day = i + 1; // 1 = Mon … 7 = Sun
                final isOn = customWeekdays.contains(day);
                return Tooltip(
                  message: const [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday',
                    'Sunday',
                  ][i],
                  child: GestureDetector(
                    onTap: () => onWeekdayToggled(day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOn
                            ? const Color(0xFF6C63FF)
                            : const Color(0xFF252530),
                        border: Border.all(
                          color: isOn
                              ? const Color(0xFF6C63FF)
                              : const Color(0xFF2A2A38),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _dayLabels[i],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isOn
                                ? Colors.white
                                : const Color(0xFF5C5A72),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (customWeekdays.isEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Select at least one day',
                style: TextStyle(fontSize: 11, color: Color(0xFFCF6679)),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
