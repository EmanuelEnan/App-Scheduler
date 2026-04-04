import 'package:app_scheduler/core/constant/app_colors.dart';
import 'package:flutter/material.dart';

class StatsRow extends StatelessWidget {
  final int total;
  final int active;
  final int today;
  const StatsRow({
    super.key,
    required this.total,
    required this.active,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(label: 'Total', value: total, color: AppColors.primary),
        const SizedBox(width: 10),
        _StatChip(label: 'Active', value: active, color: AppColors.secondary),
        const SizedBox(width: 10),
        _StatChip(label: 'Today', value: today, color: AppColors.warning),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
