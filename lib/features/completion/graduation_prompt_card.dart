import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_db.dart';
import '../../data/repositories/habit_repository.dart';
import '../../personalization/completion_detector.dart';
import 'completed_habit_detail_page.dart';
import 'completion_service.dart';

/// Phase 5 — top-of-Today celebratory card surfaced when a habit's
/// log history meets the graduation heuristic. The user confirms or
/// snoozes (we don't auto-graduate — the user marking it "done" is
/// what makes the moment feel earned).
class GraduationPromptCard extends ConsumerStatefulWidget {
  const GraduationPromptCard({super.key});

  @override
  ConsumerState<GraduationPromptCard> createState() =>
      _GraduationPromptCardState();
}

class _GraduationPromptCardState
    extends ConsumerState<GraduationPromptCard> {
  Future<List<({Habit habit, GraduationVerdict verdict})>>? _future;
  final Set<String> _dismissedThisSession = {};

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = ref.read(completionServiceProvider).eligibleForGraduation();
  }

  Future<void> _graduate(Habit h) async {
    await ref.read(habitRepositoryProvider).graduate(h.id);
    if (!mounted) return;
    setState(_refresh);
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Graduated 🎓 see you in Completed.')),
    );
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CompletedHabitDetailPage(habitId: h.id),
      ),
    );
  }

  void _snooze(Habit h) {
    setState(() => _dismissedThisSession.add(h.id));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<({Habit habit, GraduationVerdict verdict})>>(
      future: _future,
      builder: (context, snap) {
        final list = (snap.data ?? const [])
            .where((e) => !_dismissedThisSession.contains(e.habit.id))
            .toList();
        if (list.isEmpty) return const SizedBox.shrink();
        final entry = list.first;
        final colors = Theme.of(context).colorScheme;
        final text = Theme.of(context).textTheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Card(
            color: colors.tertiaryContainer.withValues(alpha: 0.45),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events,
                          color: colors.tertiary, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Looks like you\'ve got "${entry.habit.name}"',
                          style: text.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.verdict.reason,
                    style: text.bodyMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _snooze(entry.habit),
                        child: const Text('Not yet'),
                      ),
                      const SizedBox(width: 6),
                      FilledButton(
                        onPressed: () => _graduate(entry.habit),
                        child: const Text('Yes — I\'ve got this 🎉'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
