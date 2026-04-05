import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  final Widget child;
  final String? label;
  final bool hasError;

  const SectionCard({
    super.key,
    required this.child,
    this.label,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: const Color(0xFF17171F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasError
              ? const Color(0xFFCF6679).withOpacity(0.6)
              : const Color(0xFF2A2A38),
          width: hasError ? 1.0 : 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  // Shift label colour to red-tinted when in error state
                  color: hasError
                      ? const Color(0xFFCF6679).withOpacity(0.8)
                      : const Color(0xFF9B99B5),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
