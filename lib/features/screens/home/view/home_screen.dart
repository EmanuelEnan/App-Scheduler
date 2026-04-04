import 'package:app_scheduler/core/constant/app_colors.dart';
import 'package:app_scheduler/features/screens/home/widget/empty_state.dart';
import 'package:app_scheduler/features/screens/home/widget/error_state.dart';
import 'package:app_scheduler/features/screens/home/widget/home_header.dart';
import 'package:app_scheduler/features/screens/home/widget/schedule_list.dart';
import 'package:app_scheduler/features/screens/home/provider/schedule_provider.dart';
import 'package:app_scheduler/features/screens/schedule_details/view/schedule_builder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(schedulesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(),
            Expanded(
              child: schedulesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
                error: (e, _) => ErrorState(error: e.toString()),
                data: (schedules) {
                  if (schedules.isEmpty) return const EmptyState();
                  return ScheduleList(schedules: schedules);
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.push(context, _slideRoute(const ScheduleBuilderScreen())),
        backgroundColor: AppColors.primary,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'New Schedule',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

PageRouteBuilder _slideRoute(Widget page) => PageRouteBuilder(
  pageBuilder: (_, _, _) => page,
  transitionsBuilder: (_, anim, _, child) => SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
    child: child,
  ),
  transitionDuration: const Duration(milliseconds: 340),
);
