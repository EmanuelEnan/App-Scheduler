import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  final String error;
  const ErrorState({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Error: $error',
        style: const TextStyle(color: Color(0xFFCF6679)),
      ),
    );
  }
}
