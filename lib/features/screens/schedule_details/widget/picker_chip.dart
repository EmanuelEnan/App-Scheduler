import 'package:flutter/material.dart';

class PickerChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isEmpty;
  final bool hasError;
  final VoidCallback onTap;

  const PickerChip({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.isEmpty,
    required this.hasError,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF252530),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasError ? const Color(0xFFCF6679) : const Color(0xFF2A2A38),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isEmpty
                      ? const Color(0xFF5C5A72)
                      : const Color(0xFFF0EFF8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
