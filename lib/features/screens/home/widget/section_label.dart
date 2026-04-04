import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  final String title;
  final int count;
  const SectionLabel(this.title, {super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5C5A72),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF252530),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9B99B5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}