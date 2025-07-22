import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings for the dashboard
class DashboardSettings {
  const DashboardSettings({
    required this.useDemoData,
    required this.showDebugInfo,
    required this.autoRefreshInterval,
  });

  final bool useDemoData;
  final bool showDebugInfo;
  final Duration autoRefreshInterval;

  DashboardSettings copyWith({
    bool? useDemoData,
    bool? showDebugInfo,
    Duration? autoRefreshInterval,
  }) {
    return DashboardSettings(
      useDemoData: useDemoData ?? this.useDemoData,
      showDebugInfo: showDebugInfo ?? this.showDebugInfo,
      autoRefreshInterval: autoRefreshInterval ?? this.autoRefreshInterval,
    );
  }
}

/// Dashboard settings provider
final dashboardSettingsProvider = StateNotifierProvider<DashboardSettingsNotifier, DashboardSettings>((ref) {
  return DashboardSettingsNotifier();
});

class DashboardSettingsNotifier extends StateNotifier<DashboardSettings> {
  DashboardSettingsNotifier() : super(const DashboardSettings(
    useDemoData: true, // Default to demo data for easier testing
    showDebugInfo: false,
    autoRefreshInterval: Duration(minutes: 5),
  ));

  void toggleDemoData() {
    state = state.copyWith(useDemoData: !state.useDemoData);
  }

  void toggleDebugInfo() {
    state = state.copyWith(showDebugInfo: !state.showDebugInfo);
  }

  void setAutoRefreshInterval(Duration duration) {
    state = state.copyWith(autoRefreshInterval: duration);
  }
}

/// Debug information widget
class DashboardDebugInfo extends ConsumerWidget {
  const DashboardDebugInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(dashboardSettingsProvider);
    
    if (!settings.showDebugInfo) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🛠️ Debug Info',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Demo Data: ${settings.useDemoData ? 'Enabled' : 'Disabled'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'Auto Refresh: ${settings.autoRefreshInterval.inMinutes}min',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => ref.read(dashboardSettingsProvider.notifier).toggleDemoData(),
                icon: Icon(settings.useDemoData ? Icons.science : Icons.storage),
                label: Text(settings.useDemoData ? 'Switch to Real Data' : 'Switch to Demo Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: settings.useDemoData ? Colors.orange : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => ref.read(dashboardSettingsProvider.notifier).toggleDebugInfo(),
                icon: const Icon(Icons.close),
                tooltip: 'Hide Debug Info',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
