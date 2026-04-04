import 'package:app_scheduler/core/constant/app_colors.dart';
import 'package:app_scheduler/features/screens/home/model/app_schedule.dart';
import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final AppSchedule schedule;
  final String timeLabel;
  final String dateLabel;
  final String repeatLabel;
  final bool isSoon;
  final bool isPast;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.timeLabel,
    required this.dateLabel,
    required this.repeatLabel,
    required this.isSoon,
    required this.isPast,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = schedule.isActive && !isPast;
    final cardOpacity = (!schedule.isActive || isPast) ? 0.5 : 1.0;

    return Opacity(
      opacity: cardOpacity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF17171F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSoon
                  ? const Color(0xFFF97316).withOpacity(0.4)
                  : const Color(0xFF2A2A38),
              width: isSoon ? 1.0 : 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: schedule.appIcon != null
                          ? Image.memory(
                              schedule.appIcon!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF252530),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Icon(
                                Icons.apps_rounded,
                                color: AppColors.primary,
                                size: 26,
                              ),
                            ),
                    ),
                    if (isSoon)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF97316),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              schedule.label ?? schedule.appName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF0EFF8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSoon)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFF97316,
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Soon',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF97316),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (schedule.label != null)
                        Text(
                          schedule.appName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5C5A72),
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Time + date row
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            timeLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: Color(0xFF5C5A72),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isPast ? 'Completed' : dateLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: isPast
                                  ? const Color(0xFF4ECDC4)
                                  : const Color(0xFF9B99B5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Repeat badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252530),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF2A2A38)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.repeat_rounded,
                              size: 11,
                              color: Color(0xFF9B99B5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              repeatLabel,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9B99B5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    if (!isPast)
                      GestureDetector(
                        onTap: onToggle,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : const Color(0xFF2A2A38),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 200),
                            alignment: isActive
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFF5C5A72),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
