import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/goal_repository.dart';
import '../habits/add_habit_page.dart';

/// Goal-creator wizard. Wraps the habit wizard — the goal is created on
/// step 0 (after the user enters a title), then the habit wizard is
/// pushed for the first habit. On return we offer "Add another habit" or
/// "Done". If the user closes without ever adding a habit, the goal is
/// archived (Phase 5 transactional rule).
///
/// Pops with the goal id (String) if a goal was created, else null.
class GoalCreatorPage extends ConsumerStatefulWidget {
  const GoalCreatorPage({super.key});

  @override
  ConsumerState<GoalCreatorPage> createState() => _GoalCreatorPageState();
}

class _GoalCreatorPageState extends ConsumerState<GoalCreatorPage> {
  final _ctrl = PageController();
  final _titleCtrl = TextEditingController();
  int _page = 0;
  String? _goalId;
  int _habitCount = 0;
  bool _saving = false;
  String? _capMessage;

  static const int _totalPages = 2; // title → done/add another

  @override
  void dispose() {
    _ctrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  bool get _canAdvance =>
      _page != 0 || _titleCtrl.text.trim().isNotEmpty;

  Future<void> _next() async {
    if (_page == 0) {
      await _createGoalAndAddFirstHabit();
    } else {
      await _finish();
    }
  }

  Future<void> _createGoalAndAddFirstHabit() async {
    if (_goalId == null) {
      setState(() => _saving = true);
      try {
        final id = await ref
            .read(goalRepositoryProvider)
            .create(title: _titleCtrl.text.trim());
        _goalId = id;
        _capMessage = null;
      } on GoalCapException catch (e) {
        if (mounted) setState(() => _capMessage = e.toString());
        return;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not create goal: $e')),
          );
        }
        return;
      } finally {
        if (mounted) setState(() => _saving = false);
      }
    }
    if (!mounted) return;
    await _pushHabitWizard();
    if (!mounted) return;
    // Always advance to the "Done / Add another" step after the habit
    // wizard pops — even if no habit was added, the user gets a chance
    // to add one or finish (which will archive the empty goal).
    await _ctrl.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _pushHabitWizard() async {
    final id = _goalId;
    if (id == null) return;
    final habitId = await Navigator.of(context).push<String?>(
      MaterialPageRoute<String?>(
        builder: (_) => AddHabitPage(goalId: id),
      ),
    );
    if (habitId != null && mounted) {
      setState(() => _habitCount += 1);
    }
  }

  Future<void> _finish() async {
    final id = _goalId;
    if (id != null && _habitCount == 0) {
      // No habits added — clean up the orphan goal.
      await ref.read(goalRepositoryProvider).archive(id);
      if (mounted) Navigator.of(context).pop(null);
    } else {
      if (mounted) Navigator.of(context).pop(id);
    }
  }

  void _back() {
    if (_page == 0) {
      // No goal created yet — nothing to clean up.
      Navigator.of(context).pop(null);
    } else {
      // Going back to the title step is allowed (user might want to
      // adjust the goal name). The goal stays in DB.
      _ctrl.previousPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final onLastPage = _page == _totalPages - 1;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New goal'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _back,
          ),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: LinearProgressIndicator(
                  value: (_page + 1) / _totalPages,
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(6),
                  backgroundColor:
                      colors.primaryContainer.withValues(alpha: 0.4),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _ctrl,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (p) => setState(() => _page = p),
                  children: [
                    _TitleStep(
                      controller: _titleCtrl,
                      errorText: _capMessage,
                      onChanged: () => setState(() {}),
                    ),
                    _DoneOrAddAnotherStep(
                      goalTitle: _titleCtrl.text.trim(),
                      habitCount: _habitCount,
                      onAddAnother: _pushHabitWizard,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: _saving ? null : _back,
                      child: Text(_page == 0 ? 'Cancel' : 'Back'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed:
                          (_saving || !_canAdvance) ? null : _next,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            )
                          : Text(onLastPage ? 'Done' : 'Next'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleStep extends StatelessWidget {
  const _TitleStep({
    required this.controller,
    required this.onChanged,
    this.errorText,
  });
  final TextEditingController controller;
  final VoidCallback onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What's the goal?", style: text.headlineSmall),
          const SizedBox(height: 6),
          Text(
            "Something you'd want to work on for a few weeks. Habits hang off this.",
            style: text.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'e.g. Sleep before midnight · Read every day',
              errorText: errorText,
            ),
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }
}

class _DoneOrAddAnotherStep extends StatelessWidget {
  const _DoneOrAddAnotherStep({
    required this.goalTitle,
    required this.habitCount,
    required this.onAddAnother,
  });
  final String goalTitle;
  final int habitCount;
  final Future<void> Function() onAddAnother;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final summary = habitCount == 0
        ? 'No habits added yet.'
        : habitCount == 1
            ? '1 habit on this goal.'
            : '$habitCount habits on this goal.';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(goalTitle, style: text.headlineSmall),
          const SizedBox(height: 6),
          Text(
            summary,
            style: text.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: Text(habitCount == 0
                ? 'Add a habit'
                : 'Add another habit'),
            onPressed: onAddAnother,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          if (habitCount == 0) ...[
            const SizedBox(height: 16),
            Text(
              'Tapping Done now will archive the goal — it needs at least '
              'one habit to live.',
              style: text.bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}
