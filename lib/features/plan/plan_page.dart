import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_db.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/habit_repository.dart';
import '../../main.dart' show notificationRefreshTickProvider;
import '../habits/add_habit_page.dart';
import '../habits/edit_habit_page.dart';
import '../habits/habit_categories.dart';
import 'goal_creator_page.dart';

/// Phase 2 — the editing surface. Today never owns add/edit affordances;
/// they all live here.
class PlanPage extends ConsumerWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(_activeGoalsProvider);
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Plan')),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (goals) {
          // Use ListView.builder so children are keyed by index — avoids
          // the "_children.contains(child)" assertion that fires when the
          // explicit children list mutates around stateful subtrees
          // (PopupMenuButton's overlay, _AddGoalTile's transactional flow).
          final items = <Widget>[
            if (goals.isEmpty)
              Padding(
                key: const ValueKey('plan:empty'),
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
                child: Text(
                  'No goals yet. Add your first one — pick something you\'d '
                  'genuinely want to work on for a few weeks.',
                  style: text.bodyMedium
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ),
            for (final g in goals) _GoalCard(key: ValueKey(g.id), goal: g),
            const SizedBox(key: ValueKey('plan:gap'), height: 12),
            _AddGoalTile(
              key: const ValueKey('plan:add-goal'),
              disabled: goals.length >= GoalRepository.activeGoalCap,
            ),
          ];
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            itemCount: items.length,
            itemBuilder: (_, i) => items[i],
          );
        },
      ),
    );
  }
}

/// ConsumerStatefulWidget so `ref` and `context` come from the State and
/// stay valid across rebuilds — important because `PopupMenuButton.onSelected`
/// fires asynchronously and a captured `WidgetRef` from a build callback can
/// reference a deactivated element after the underlying stream re-emits.
class _GoalCard extends ConsumerStatefulWidget {
  const _GoalCard({super.key, required this.goal});
  final Goal goal;

  @override
  ConsumerState<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends ConsumerState<_GoalCard> {
  Future<void> _onMenu(_GoalAction a) async {
    switch (a) {
      case _GoalAction.rename:
        await _rename();
      case _GoalAction.archive:
        await _archive();
    }
  }

  Future<void> _rename() async {
    final ctrl = TextEditingController(text: widget.goal.title);
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Rename goal'),
          content: TextField(controller: ctrl, autofocus: true),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.of(ctx).pop(ctrl.text),
                child: const Text('Save')),
          ],
        ),
      );
      if (result == null || result.trim().isEmpty) return;
      await ref.read(goalRepositoryProvider).rename(widget.goal.id, result.trim());
    } finally {
      ctrl.dispose();
    }
  }

  Future<void> _archive() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Archive "${widget.goal.title}"?'),
        content: const Text(
            'The goal and its habits will move out of your active list. '
            'You can restore it later from You → Archived.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Archive')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(goalRepositoryProvider).archive(widget.goal.id);
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(_habitsForGoalProvider(widget.goal.id));
    final text = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.goal.title, style: text.titleMedium)),
                PopupMenuButton<_GoalAction>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: _onMenu,
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: _GoalAction.rename,
                      child: Text('Rename'),
                    ),
                    PopupMenuItem(
                      value: _GoalAction.archive,
                      child: Text('Archive goal'),
                    ),
                  ],
                ),
              ],
            ),
            habitsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(8),
                child: LinearProgressIndicator(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(8),
                child: Text('$e'),
              ),
              data: (habits) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final h in habits)
                    _HabitRow(key: ValueKey(h.id), habit: h),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add habit'),
                      onPressed: () async {
                        // AddHabitPage pops with the new habit's id (a
                        // String?), so the route must be typed <String?>.
                        // A <bool> route here threw a type error on pop —
                        // the wizard never closed and Save looked dead.
                        await Navigator.of(context).push(
                          MaterialPageRoute<String?>(
                            builder: (_) =>
                                AddHabitPage(goalId: widget.goal.id),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _GoalAction { rename, archive }

class _HabitRow extends StatelessWidget {
  const _HabitRow({super.key, required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final category = HabitCategory.fromId(habit.category);
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<bool>(
          builder: (_) => EditHabitPage(habitId: habit.id),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: colors.surfaceContainerHighest,
              child: Icon(category.icon,
                  size: 14, color: colors.onSurfaceVariant),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(habit.name, style: text.bodyLarge),
            ),
            Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// ConsumerStatefulWidget so `ref` and `context` come from the State and
/// stay valid across the await on Navigator.push — captured `WidgetRef`s
/// from a ConsumerWidget become stale when the StreamProvider re-emits
/// during the long-lived push, which would skip the rollback archive call.
class _AddGoalTile extends ConsumerStatefulWidget {
  const _AddGoalTile({super.key, required this.disabled});
  final bool disabled;

  @override
  ConsumerState<_AddGoalTile> createState() => _AddGoalTileState();
}

class _AddGoalTileState extends ConsumerState<_AddGoalTile> {
  /// Push the GoalCreatorPage wizard. The wizard owns the create-goal +
  /// loop-add-habit flow and handles the empty-goal rollback. We just
  /// trigger the push.
  Future<void> _addGoalFlow() async {
    await Navigator.of(context).push<String?>(
      MaterialPageRoute<String?>(
        builder: (_) => const GoalCreatorPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final disabled = widget.disabled;
    return Opacity(
      opacity: disabled ? 0.4 : 1.0,
      child: Card(
        color: colors.primaryContainer.withValues(alpha: 0.4),
        child: InkWell(
          onTap: disabled ? null : _addGoalFlow,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.flag_outlined, color: colors.onPrimaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        disabled
                            ? 'Goal cap reached (3 max)'
                            : 'Add a goal',
                        style: text.titleMedium,
                      ),
                      if (!disabled)
                        Text(
                          'You\'ll add the first habit in the next step.',
                          style: text.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.add),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final _activeGoalsProvider = StreamProvider<List<Goal>>((ref) {
  ref.watch(notificationRefreshTickProvider);
  return ref.watch(goalRepositoryProvider).watchActive();
});

final _habitsForGoalProvider =
    StreamProvider.family<List<Habit>, String>((ref, goalId) {
  ref.watch(notificationRefreshTickProvider);
  return ref.watch(habitRepositoryProvider).watchByGoal(goalId);
});
