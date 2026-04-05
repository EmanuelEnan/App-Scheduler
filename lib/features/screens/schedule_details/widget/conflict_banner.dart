import 'package:flutter/material.dart';

/// Shown in the Schedule Builder when time conflicts with one or more
/// existing schedules. Non-blocking — the user can still save.
class ConflictBanner extends StatelessWidget {
  final List<String> conflicts;

  final TimeOfDay time;

  const ConflictBanner({
    super.key,
    required this.conflicts,
    required this.time,
  });

  String get _names {
    if (conflicts.length == 1) return conflicts.first;
    final shown = conflicts.take(2).join(', ');
    final extra = conflicts.length > 2 ? ' +${conflicts.length - 2} more' : '';
    return '$shown$extra';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D1F10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF97316).withOpacity(0.4)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withOpacity(0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFF97316),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conflict Warning!',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF97316),
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFBBAA99),
                      height: 1.55,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Another schedule already exists at ',
                      ),
                      TextSpan(
                        text: _formatTime(time),
                        style: const TextStyle(
                          color: Color(0xFFF97316),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: '\n'),
                      TextSpan(
                        text: _names,
                        style: const TextStyle(
                          color: Color(0xFFF0EFF8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Please choose a different time to avoid conflicts.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF9B99B5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
