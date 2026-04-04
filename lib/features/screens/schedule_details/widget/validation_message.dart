import 'package:flutter/material.dart';

class ValidationMessage extends StatelessWidget {
  final String message;
  const ValidationMessage(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFCF6679),
            size: 14,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: Color(0xFFCF6679)),
            ),
          ),
        ],
      ),
    );
  }
}