import 'package:flutter/material.dart';

class EmptyPhase extends StatelessWidget {
  final String query;
  final String category;
  const EmptyPhase({super.key, required this.query, required this.category});

  @override
  Widget build(BuildContext context) {
    final String message;
    if (query.isNotEmpty && category != 'All') {
      message = 'No $category apps matching "$query"';
    } else if (query.isNotEmpty) {
      message = 'No results for "$query"';
    } else if (category != 'All') {
      message = 'No $category apps found';
    } else {
      message = 'No apps found';
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: Color(0xFF5C5A72),
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF9B99B5), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
