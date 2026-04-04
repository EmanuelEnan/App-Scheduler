import 'package:app_scheduler/features/screens/schedule_details/model/schedule_form_state.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/empty_app_selector.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/section_card.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/selected_app.dart';
import 'package:flutter/material.dart';

class AppSelectionCard extends StatelessWidget {
  final ScheduleFormState form;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const AppSelectionCard({
    super.key,
    required this.form,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = form.hasTriedSave && !form.hasApp;

    return SectionCard(
      hasError: hasError,
      child: form.hasApp
          ? SelectedApp(form: form, onClear: onClear)
          : EmptyAppSelector(hasError: hasError, onTap: onTap),
    );
  }
}
