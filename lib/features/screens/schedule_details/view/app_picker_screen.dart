import 'dart:async';
import 'package:app_scheduler/core/constant/app_colors.dart';
import 'package:app_scheduler/features/screens/home/widget/app_tile.dart';
import 'package:app_scheduler/features/screens/schedule_details/provider/schedule_form_provider.dart';
import 'package:app_scheduler/features/screens/schedule_details/widget/empty_phase.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _categoryKeywords = <String, List<String>>{
  'Social': ['facebook', 'instagram', 'twitter', 'whatsapp'],
  'Productivity': ['gmail', 'drive', 'notion', 'slack'],
  'Fitness': ['strava', 'fitbit', 'nike', 'adidas'],
  'Media': ['youtube', 'netflix', 'spotify'],
};

bool _matchesCategory(Application app, String category) {
  if (category == 'All') return true;
  final keywords = _categoryKeywords[category] ?? [];
  final haystack = '${app.appName} ${app.packageName}'.toLowerCase();
  return keywords.any(haystack.contains);
}

class AppPickerScreen extends ConsumerStatefulWidget {
  const AppPickerScreen({super.key});

  @override
  ConsumerState<AppPickerScreen> createState() => _AppPickerScreenState();
}

class _AppPickerScreenState extends ConsumerState<AppPickerScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _query = '';
  String _selectedCategory = 'All';

  static const _categories = [
    'All',
    'Social',
    'Productivity',
    'Fitness',
    'Media',
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      if (mounted) {
        setState(() => _query = _searchCtrl.text.toLowerCase().trim());
      }
    });
  }

  List<Application> _filter(List<Application> apps) {
    return apps.where((app) {
      final matchesQuery =
          _query.isEmpty ||
          app.appName.toLowerCase().contains(_query) ||
          app.packageName.toLowerCase().contains(_query);
      final matchesCategory = _matchesCategory(app, _selectedCategory);
      return matchesQuery && matchesCategory;
    }).toList();
  }

  void _selectApp(Application app) {
    final icon = app is ApplicationWithIcon ? app.icon : null;
    ref
        .read(scheduleFormProvider.notifier)
        .selectApp(
          appName: app.appName,
          packageName: app.packageName,
          icon: icon,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(installedAppsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Select App',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF0EFF8),
                    ),
                  ),
                  const Spacer(),

                  GestureDetector(
                    onTap: () => ref.invalidate(installedAppsProvider),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E28),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF2A2A38)),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Color(0xFF9B99B5),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E28),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2A2A38)),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(
                    color: Color(0xFFF0EFF8),
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search apps or package name...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF5C5A72),
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF5C5A72),
                      size: 20,
                    ),
                    suffixIcon: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchCtrl,
                      builder: (_, val, _) => val.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Color(0xFF5C5A72),
                                size: 18,
                              ),
                              onPressed: _searchCtrl.clear,
                            )
                          : const SizedBox.shrink(),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 4,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final isSelected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 4),

            Expanded(
              child: appsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
                error: (e, stack) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 36,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load apps',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(installedAppsProvider),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Color(0xFF6C63FF)),
                        ),
                      ),
                    ],
                  ),
                ),
                data: (apps) {
                  final filtered = _filter(apps);
                  return Column(
                    children: [
                      // Count header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                        child: Row(
                          children: [
                            Text(
                              _selectedCategory == 'All'
                                  ? 'ALL APPS'
                                  : _selectedCategory.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5C5A72),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${filtered.length} app${filtered.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6C63FF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: filtered.isEmpty
                            ? EmptyPhase(
                                query: _query,
                                category: _selectedCategory,
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  12,
                                  24,
                                ),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 2),
                                itemBuilder: (_, i) => AppTile(
                                  app: filtered[i],
                                  onTap: () => _selectApp(filtered[i]),
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
