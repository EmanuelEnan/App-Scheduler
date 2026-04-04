import 'package:flutter/material.dart';

class EmptyAppSelector extends StatelessWidget {
  final bool hasError;
  final VoidCallback onTap;
  const EmptyAppSelector({
    super.key,
    required this.hasError,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF252530),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasError
                    ? const Color(0xFFCF6679)
                    : const Color(0xFF2A2A38),
              ),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Color(0xFF6C63FF),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select App',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: hasError
                      ? const Color(0xFFCF6679)
                      : const Color(0xFFF0EFF8),
                ),
              ),
              const Text(
                'Tap to choose from installed apps',
                style: TextStyle(fontSize: 12, color: Color(0xFF5C5A72)),
              ),
            ],
          ),
          const Spacer(),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF5C5A72),
            size: 20,
          ),
        ],
      ),
    );
  }
}
