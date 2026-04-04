import 'package:app_scheduler/features/screens/home/model/app_schedule.dart';
import 'package:app_scheduler/features/screens/schedule_details/view/schedule_details_screen.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/meta_row.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/section_card.dart';
import 'package:flutter/material.dart';

class MetaCard extends StatelessWidget {
  final AppSchedule schedule;
  const MetaCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      label: 'Info',
      child: Column(
        children: [
          MetaRow(label: 'Created', value: fmtDateTime(schedule.createdAt)),
          const SizedBox(height: 10),
          MetaRow(label: 'ID', value: schedule.id, mono: true),
        ],
      ),
    );
  }
}
