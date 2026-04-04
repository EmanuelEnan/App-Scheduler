import 'package:app_scheduler/features/screens/schedule_details/model/schedule_form_state.dart';
import 'package:flutter/material.dart';

class SelectedApp extends StatelessWidget {
  final ScheduleFormState form;
  final VoidCallback onClear;
  const SelectedApp({super.key, required this.form, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: form.appIcon != null
              ? Image.memory(
                  form.appIcon!,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF252530),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.apps_rounded,
                    color: Color(0xFF6C63FF),
                    size: 24,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                form.appName!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF0EFF8),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF252530),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  form.packageName!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Color(0xFF8B89A8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onClear,
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.close_rounded,
              color: Color(0xFF5C5A72),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
