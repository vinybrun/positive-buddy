import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/widget_data.dart';

import '../../data/db/app_db.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/log_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../notifications/local_notification_service.dart';

class DebugPage extends ConsumerWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitRepo = ref.watch(habitRepositoryProvider);
    final logRepo = ref.watch(logRepositoryProvider);
    final profileRepo = ref.watch(profileRepositoryProvider);
    final notifications = ref.watch(localNotificationServiceProvider);
    final habitsAsync = ref.watch(_habitsWatcherProvider);
    final logCountAsync = ref.watch(_logCountProvider);
    final profileAsync = ref.watch(_profileWatcherProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Debug')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: habitRepo.createTestHabit,
        icon: const Icon(Icons.add),
        label: const Text('Create test habit'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'notifications',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.maybeOf(context);
                        final granted = await notifications.requestPermissions();
                        messenger?.showSnackBar(
                          SnackBar(
                            content: Text(granted
                                ? 'Notification permission granted'
                                : 'Permission denied — enable in system settings'),
                          ),
                        );
                      },
                      child: const Text('Request permission'),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        // Use the live settings so the test reflects the
                        // chosen buddy's custom sound (defaults are silent).
                        final s = await profileRepo.readSettings();
                        await notifications.fireTestNotification(settings: s);
                      },
                      child: const Text('Fire test notification'),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.maybeOf(context);
                        final habits = await ref
                            .read(habitRepositoryProvider)
                            .watchAll()
                            .first;
                        if (habits.isEmpty) {
                          messenger?.showSnackBar(const SnackBar(
                              content: Text(
                                  'Create a habit first (tap the FAB).')));
                          return;
                        }
                        final when =
                            DateTime.now().add(const Duration(seconds: 30));
                        await notifications.scheduleHabitReminder(
                          habitId: habits.first.id,
                          when: when,
                          title: 'Quick check 🙂',
                          body: 'Did you ${habits.first.name.toLowerCase()}?',
                          db: ref.read(appDbProvider),
                        );
                        messenger?.showSnackBar(SnackBar(
                            content: Text(
                                'Scheduled for ${when.toIso8601String().substring(11, 19)} — close app to test bg path')));
                      },
                      child: const Text('Schedule reminder 30s ahead'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _Section(
            title: 'home widgets',
            child: Wrap(
              spacing: 8,
              children: [
                for (final entry in const {
                  'Small': widgetSmallName,
                  'Big': widgetBigName,
                  'Tiny': widgetTinyName,
                }.entries)
                  OutlinedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.maybeOf(context);
                      final ok = await const MethodChannel(
                              'habit_buddy/launcher_icon')
                          .invokeMethod<bool>(
                        'pinWidget',
                        {'provider': entry.value},
                      );
                      messenger?.showSnackBar(SnackBar(
                        content: Text(ok == true
                            ? 'Requested pin: ${entry.key}'
                            : 'Pin not supported by launcher'),
                      ));
                    },
                    child: Text('Pin ${entry.key}'),
                  ),
              ],
            ),
          ),
          _Section(
            title: 'user_profile',
            child: profileAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (p) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p == null
                      ? '(no profile row yet)'
                      : 'tone=${p.tonePreference}  budget=${p.dailyNotifBudget}  updated=${p.updatedAt.toIso8601String().substring(0, 19)}'),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: profileRepo.ensureExists,
                    child: const Text('Ensure profile row exists'),
                  ),
                ],
              ),
            ),
          ),
          _Section(
            title: 'notification_log',
            child: logCountAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (count) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('count: $count'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => _insertFakeLog(ref, logRepo, 'yes'),
                        child: const Text('Log "yes"'),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            _insertFakeLog(ref, logRepo, 'not_yet'),
                        child: const Text('Log "not_yet"'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _Section(
            title: 'habits',
            child: habitsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Error: $e'),
              data: (habits) {
                if (habits.isEmpty) {
                  return const Text(
                      'No habits. Tap the FAB to insert one, then kill & reopen the app to confirm it persists.');
                }
                return Column(
                  children: [
                    for (final h in habits)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(h.name),
                        subtitle: Text(
                          '${h.category} · ${h.kind} · ${h.createdAt.toIso8601String().substring(0, 19)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Text(
                          h.id.substring(0, 6),
                          style: const TextStyle(
                              fontFamily: 'monospace', fontSize: 11),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: habitRepo.deleteAll,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear all habits'),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<void> _insertFakeLog(
      WidgetRef ref, LogRepository logRepo, String response) async {
    final messenger = ScaffoldMessenger.maybeOf(ref.context);
    final habits = await ref.read(habitRepositoryProvider).watchAll().first;
    if (habits.isEmpty) {
      messenger?.showSnackBar(
        const SnackBar(content: Text('Create a habit first.')),
      );
      return;
    }
    await logRepo.insertFake(habitId: habits.first.id, response: response);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: 'monospace',
                    )),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

final _habitsWatcherProvider = StreamProvider<List<Habit>>((ref) {
  return ref.watch(habitRepositoryProvider).watchAll();
});

final _logCountProvider = StreamProvider<int>((ref) {
  return ref.watch(logRepositoryProvider).watchCount();
});

final _profileWatcherProvider =
    StreamProvider<UserProfileTableData?>((ref) {
  return ref.watch(profileRepositoryProvider).watch();
});
