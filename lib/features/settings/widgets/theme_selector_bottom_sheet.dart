import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class ThemeSelectorBottomSheet extends StatelessWidget {
  const ThemeSelectorBottomSheet({super.key});

  @override
  Widget build(BuildContext context) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Choose Theme',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your preferred theme appearance',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),

          // Theme options
          ValueListenableBuilder<AdaptiveThemeMode>(
            valueListenable: AdaptiveTheme.of(context).modeChangeNotifier,
            builder: (context, AdaptiveThemeMode themeMode, _) => Column(
              children: [
                _ThemeOption(
                  icon: Icons.brightness_auto,
                  title: 'System',
                  subtitle: 'Follow system theme',
                  isSelected: themeMode == AdaptiveThemeMode.system,
                  onTap: () {
                    AdaptiveTheme.of(context).setSystem();
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 12),
                _ThemeOption(
                  icon: Icons.light_mode,
                  title: 'Light',
                  subtitle: 'Light mode',
                  isSelected: themeMode == AdaptiveThemeMode.light,
                  onTap: () {
                    AdaptiveTheme.of(context).setLight();
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 12),
                _ThemeOption(
                  icon: Icons.dark_mode,
                  title: 'Dark',
                  subtitle: 'Dark mode',
                  isSelected: themeMode == AdaptiveThemeMode.dark,
                  onTap: () {
                    AdaptiveTheme.of(context).setDark();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.1) 
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).primaryColor 
                  : Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isSelected 
                              ? Theme.of(context).primaryColor 
                              : null,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
}
