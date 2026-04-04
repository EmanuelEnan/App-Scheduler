import 'package:app_scheduler/features/screens/home/model/app_schedule.dart';
import 'package:flutter/material.dart';

class AppInfoCard extends StatelessWidget {
  final AppSchedule schedule;
  const AppInfoCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF17171F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A38), width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: schedule.appIcon != null
                ? Image.memory(
                    schedule.appIcon!,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF252530),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.apps_rounded,
                      color: Color(0xFF6C63FF),
                      size: 28,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.appName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF0EFF8),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252530),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    schedule.packageName,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Color(0xFF8B89A8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: schedule.isActive
                  ? const Color(0xFF4ECDC4).withOpacity(0.12)
                  : const Color(0xFF252530),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: schedule.isActive
                    ? const Color(0xFF4ECDC4).withOpacity(0.3)
                    : const Color(0xFF2A2A38),
              ),
            ),
            child: Text(
              schedule.isActive ? 'Active' : 'Paused',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: schedule.isActive
                    ? const Color(0xFF4ECDC4)
                    : const Color(0xFF5C5A72),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
