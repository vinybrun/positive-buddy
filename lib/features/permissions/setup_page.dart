import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'permissions_service.dart';

class SetupPage extends ConsumerWidget {
  const SetupPage({super.key, this.onComplete});

  /// Called once the core permissions are all granted. If null, the page
  /// just stays — useful when used as a re-entry point from settings.
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSnap = ref.watch(permissionsStatusControllerProvider);
    final service = ref.watch(permissionsServiceProvider);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: asyncSnap.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (snap) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              children: [
                Text('Quick setup — promise it’s worth it.',
                    style: text.headlineMedium),
                const SizedBox(height: 12),
                Text(
                  'Positive Buddy lives or dies by whether reminders actually arrive. '
                  'Phones are aggressive about closing apps in the background, so '
                  'we need two small permissions to keep that from happening.',
                  style: text.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant, height: 1.45),
                ),
                const SizedBox(height: 24),
                _PermissionCard(
                  icon: Icons.notifications_active_outlined,
                  title: 'Let me tap you on the shoulder',
                  subtitle:
                      'Permission to show notifications. Without it I literally can’t reach you.',
                  granted: snap.notificationsGranted,
                  actionLabel: 'Allow notifications',
                  onAction: () async {
                    await service.requestNotifications();
                    await ref
                        .read(permissionsStatusControllerProvider.notifier)
                        .refresh();
                  },
                ),
                const SizedBox(height: 12),
                _PermissionCard(
                  icon: Icons.battery_charging_full_outlined,
                  title: 'Don’t put me to sleep',
                  subtitle:
                      'Lets me wake up briefly when a reminder is due — even if you haven’t '
                      'opened the app in days. I’m not running constantly or watching anything; '
                      'I do nothing between reminders. Promise.',
                  granted: snap.batteryExempt,
                  actionLabel: 'Open battery settings',
                  onAction: () async {
                    await service.requestBatteryExemption();
                    await ref
                        .read(permissionsStatusControllerProvider.notifier)
                        .refresh();
                  },
                ),
                if (snap.oem == DeviceOem.xiaomi) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: colors.tertiaryContainer.withValues(alpha: 0.35),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.info_outline, color: colors.tertiary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'One more thing for Xiaomi',
                                style: text.titleMedium,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 8),
                          Text(
                            'MIUI / HyperOS is extra strict — even with the permissions above, '
                            'it’ll quietly kill apps it hasn’t seen in a while. Two more taps fix it:',
                            style: text.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant, height: 1.4),
                          ),
                          const SizedBox(height: 12),
                          Text('  1. Open Autostart and toggle Positive Buddy on.',
                              style: text.bodyMedium),
                          Text(
                              '  2. In Battery settings, choose “No restrictions”.',
                              style: text.bodyMedium),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: service.openXiaomiAutostart,
                                icon: const Icon(Icons.power_settings_new),
                                label: const Text('Open Autostart'),
                              ),
                              OutlinedButton.icon(
                                onPressed: service.openBatterySettings,
                                icon: const Icon(
                                    Icons.battery_charging_full_outlined),
                                label: const Text('Open battery settings'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: snap.coreGranted ? onComplete : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(snap.coreGranted
                      ? 'All set — let’s go'
                      : 'Grant the two above to continue'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    await ref
                        .read(permissionsStatusControllerProvider.notifier)
                        .refresh();
                  },
                  child: const Text('I just changed something — recheck'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.granted,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool granted;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: colors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(title, style: text.titleMedium)),
                      if (granted)
                        Icon(Icons.check_circle,
                            color: colors.primary, size: 22),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: text.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant, height: 1.4)),
                  if (!granted) ...[
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: onAction,
                      child: Text(actionLabel),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
