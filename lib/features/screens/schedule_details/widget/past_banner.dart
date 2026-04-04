import 'package:app_scheduler/features/screens/schedule_details/view/schedule_details_screen.dart';
import 'package:flutter/material.dart';

class PastBanner extends StatelessWidget {
  final DateTime scheduledAt;
  const PastBanner({super.key, required this.scheduledAt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF4ECDC4).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFF4ECDC4),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ran on ${fmtDateTime(scheduledAt)}.',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4ECDC4),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
