import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_db.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/habit_repository.dart';

/// v11: read-only view of archived goals + the habits parked under them.
/// Restoring brings the goal back into Plan and its habits back into Today.
class ArchivedPage extends ConsumerWidget {
  const ArchivedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedAsync = ref.watch(_archivedGoalsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Archived')),
      body: archivedAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (goals) {
          if (goals.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: goals.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _ArchivedGoalCard(goal: goals[i]),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 48, color: colors.onSurfaceVariant),
            const SizedBox(height: 12),
            Text('Nothing archived yet.', style: text.titleMedium),
            const SizedBox(height: 6),
            Text(
              'When you archive a goal from Plan, it lands here. '
              'You can bring it back any time.',
              textAlign: TextAlign.center,
              style: text.bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchivedGoalCard extends ConsumerStatefulWidget {
  const _ArchivedGoalCard({required this.goal});
  final Goal goal;

  @override
  ConsumerState<_ArchivedGoalCard> createState() =>
      _ArchivedGoalCardState();
}

class _ArchivedGoalCardState extends ConsumerState<_ArchivedGoalCard> {
  bool _expanded = false;
  bool _restoring = false;
  late Future<List<Habit>> _habitsFuture;

  @override
  void initState() {
    super.initState();
    _habitsFuture = ref
        .read(habitRepositoryProvider)
        .readDeletedByGoal(widget.goal.id);
  }

  Future<void> _restore() async {
    setState(() => _restoring = true);
    try {
      await ref.read(goalRepositoryProvider).restore(widget.goal.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal restored.')),
      );
    } on GoalCapException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not restore: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final ts = widget.goal.archivedAt;
    final subtitle =
        ts == null ? null : 'archived ${_relativeDays(ts)}';
    return Card(
      elevation: 0,
      color: colors.surfaceContainerHigh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text(widget.goal.title),
            subtitle: subtitle == null ? null : Text(subtitle),
            trailing: _restoring
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child:
                        CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton.icon(
                    icon: const Icon(Icons.unarchive_outlined),
                    label: const Text('Restore'),
                    onPressed: _restore,
                  ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: FutureBuilder<List<Habit>>(
                future: _habitsFuture,
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const SizedBox(
                      height: 24,
                      child: Center(
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  final habits = snap.data!;
                  if (habits.isEmpty) {
                    return Text(
                      'No habits were attached.',
                      style: text.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final h in habits)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(h.name)),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

String _relativeDays(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inDays == 0) return 'today';
  if (diff.inDays == 1) return 'yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
  return '${(diff.inDays / 365).floor()}y ago';
}

final _archivedGoalsProvider = StreamProvider<List<Goal>>((ref) {
  return ref.watch(goalRepositoryProvider).watchArchived();
});
