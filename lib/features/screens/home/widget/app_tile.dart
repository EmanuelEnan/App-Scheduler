import 'package:app_scheduler/core/constant/app_colors.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

class AppTile extends StatelessWidget {
  final Application app;
  final VoidCallback onTap;

  const AppTile({super.key, required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appWithIcon = app is ApplicationWithIcon
        ? app as ApplicationWithIcon
        : null;

    return Material(
      color: const Color(0xFF17171F),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor:  AppColors.primary.withOpacity(0.08),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // App Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: appWithIcon != null
                    ? Image.memory(
                        appWithIcon.icon,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 48,
                        height: 48,
                        color: const Color(0xFF2A2A38),
                        child: const Icon(
                          Icons.apps_rounded,
                          color: Color(0xFF5C5A72),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // App Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.appName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFF0EFF8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D3B52),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        app.packageName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'JetBrainsMono',
                          color: Color(0xFF8B89A8),
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Arrow
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF5C5A72),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
