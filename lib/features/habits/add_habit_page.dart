import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/habit_repository.dart';
import '../notifications/local_notification_service.dart';
import 'category_picker.dart';
import 'habit_categories.dart';
import 'time_windows.dart';
import 'window_picker.dart';
import 'window_selection.dart';

enum _HabitKind { time, frequency }

enum _AlarmStyle {
  /// Engine picks the time within the chosen window. Default — works for
  /// most habits where "morning-ish" is more useful than "08:00 sharp".
  flexible('flexible'),

  /// User picks exact time(s). For habits genuinely tied to a clock
  /// (alarms, medication windows that matter to the minute).
  fixed('fixed');

  const _AlarmStyle(this.id);
  final String id;
}

/// Add-habit wizard. One question per page. Two behavioral rules:
///
/// 1. **Progressive save**: as soon as the user supplies a name and taps
///    Next, the habit is committed to the DB with sensible defaults for
///    everything they haven't picked yet. Each subsequent Next press
///    rewrites the row. If they back out, the partial habit stays — they
///    can keep tuning it from Edit. Nothing is lost.
///
/// 2. **Back stays in the wizard**: the AppBar back arrow + Android system
///    back both call `_back()`, which steps the PageView back. Only step 0
///    pops the wizard.
///
/// Pops with the habit's id (String) if one was created, else null.
class AddHabitPage extends ConsumerStatefulWidget {
  const AddHabitPage({super.key, this.goalId});

  /// The habit will belong to this goal. Required for non-orphan habits.
  final String? goalId;

  @override
  ConsumerState<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends ConsumerState<AddHabitPage> {
  final _ctrl = PageController();
  final _nameCtrl = TextEditingController();
  int _page = 0;

  String? _habitId;

  String _categoryId = HabitCategory.water.id;
  WindowSelection _windowSel =
      WindowSelection(windows: {TimeWindow.anytime});
  _HabitKind _kind = _HabitKind.time;
  _AlarmStyle _alarmStyle = _AlarmStyle.flexible;
  final List<TimeOfDay> _times = [const TimeOfDay(hour: 8, minute: 0)];
  int _targetPerWeek = 3;
  int? _preferredWeekday;
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  // Order: name → category → window → style → details. Total = 5.
  int get _totalPages => 5;

  bool get _canAdvance {
    switch (_page) {
      case 0:
        return _nameCtrl.text.trim().isNotEmpty;
      case 4:
        // Details page: only the "fixed daily" branch can be invalid
        // (no times entered). Flexible/freq are always valid.
        if (_kind == _HabitKind.time &&
            _alarmStyle == _AlarmStyle.fixed) {
          return _times.isNotEmpty;
        }
        return true;
      default:
        return true;
    }
  }

  /// Persist the current state. Creates the habit on first call, updates
  /// it on subsequent calls. Idempotent — safe to call multiple times.
  Future<void> _persist() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final repo = ref.read(habitRepositoryProvider);
    if (_kind == _HabitKind.time) {
      if (_habitId == null) {
        final id = await repo.createTimeBasedHabit(
          name: name,
          category: _categoryId,
          times: _times,
          windowSelection: _windowSel,
          goalId: widget.goalId,
          alarmStyle: _alarmStyle.id,
        );
        _habitId = id;
      } else {
        await repo.updateHabitWithSlots(
          id: _habitId!,
          name: name,
          category: _categoryId,
          times: _times,
          windowSelection: _windowSel,
          alarmStyle: _alarmStyle.id,
        );
      }
    } else {
      if (_habitId == null) {
        final id = await repo.createFrequencyHabit(
          name: name,
          category: _categoryId,
          targetPerWeek: _targetPerWeek,
          windowSelection: _windowSel,
          goalId: widget.goalId,
          preferredWeekday: _preferredWeekday,
        );
        _habitId = id;
      } else {
        await repo.updateFrequencyHabit(
          id: _habitId!,
          name: name,
          category: _categoryId,
          targetPerWeek: _targetPerWeek,
          preferredWeekday: _preferredWeekday,
          windowSelection: _windowSel,
        );
      }
    }
    // Re-reconcile so the new/updated alarm gets booked.
    final notif = ref.read(localNotificationServiceProvider);
    final db = ref.read(appDbProvider);
    unawaited(notif.reconcile(db));
  }

  Future<void> _next() async {
    if (!_canAdvance) return;
    setState(() => _saving = true);
    bool persisted = false;
    try {
      await _persist();
      persisted = true;
    } catch (e) {
      // Surface the error so the Save button doesn't look dead.
      // (Pre-fix: a thrown exception in _persist bubbled out of onTap,
      // Flutter logged it silently, and the user just saw a dead button.)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save habit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (!mounted || !persisted) return;
    if (_page < _totalPages - 1) {
      await _ctrl.nextPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.of(context).pop(_habitId);
    }
  }

  void _back() {
    if (_page == 0) {
      // Pop with whatever id we have (null if user never advanced past
      // name). Progressive save means a partial habit may exist.
      Navigator.of(context).pop(_habitId);
    } else {
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
    final trimmedName = _nameCtrl.text.trim();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          // Once the user names the habit, the header echoes it back so the
          // wizard feels like it's about *their* habit, not a generic form.
          title: Text(trimmedName.isEmpty ? 'New habit' : trimmedName,
              overflow: TextOverflow.ellipsis),
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
                    _NameStep(
                      controller: _nameCtrl,
                      onChanged: () => setState(() {}),
                    ),
                    _CategoryStep(
                      selectedId: _categoryId,
                      onChanged: (v) => setState(() => _categoryId = v),
                    ),
                    _WhenStep(
                      selection: _windowSel,
                      onChanged: (sel) => setState(() => _windowSel = sel),
                    ),
                    _StyleStep(
                      value: _kind,
                      onChanged: (v) => setState(() => _kind = v),
                    ),
                    _kind == _HabitKind.time
                        ? _DailyDetailsStep(
                            alarmStyle: _alarmStyle,
                            times: _times,
                            onAlarmStyleChanged: (v) =>
                                setState(() => _alarmStyle = v),
                            onTimesChanged: () => setState(() {}),
                          )
                        : _FrequencyDetailsStep(
                            target: _targetPerWeek,
                            preferredWeekday: _preferredWeekday,
                            onTargetChanged: (v) =>
                                setState(() => _targetPerWeek = v),
                            onDayChanged: (v) =>
                                setState(() => _preferredWeekday = v),
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
                          : Text(onLastPage ? 'Save habit' : 'Next'),
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

class _WizardScaffold extends StatelessWidget {
  const _WizardScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.headlineSmall),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: text.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return _WizardScaffold(
      title: 'What habit are you adding?',
      subtitle: 'Short and clear works best — you\'ll see it on Today.',
      child: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'e.g. Drink water · Take meds · Read 10 pages',
        ),
        onChanged: (_) => onChanged(),
      ),
    );
  }
}

class _CategoryStep extends StatelessWidget {
  const _CategoryStep({required this.selectedId, required this.onChanged});
  final String selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _WizardScaffold(
      title: 'What kind of habit is this?',
      subtitle: 'Pick the closest match, or tap "+ New" for something custom.',
      child: CategoryPicker(
        selectedId: selectedId,
        onChanged: onChanged,
      ),
    );
  }
}

class _WhenStep extends StatelessWidget {
  const _WhenStep({required this.selection, required this.onChanged});
  final WindowSelection selection;
  final ValueChanged<WindowSelection> onChanged;

  @override
  Widget build(BuildContext context) {
    return _WizardScaffold(
      title: 'When during the day?',
      subtitle: 'A rough window — I\'ll pick the best moment within it.',
      child: WindowPicker(selection: selection, onChanged: onChanged),
    );
  }
}

class _StyleStep extends StatelessWidget {
  const _StyleStep({required this.value, required this.onChanged});
  final _HabitKind value;
  final ValueChanged<_HabitKind> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return _WizardScaffold(
      title: 'How often?',
      subtitle: 'Daily nudges, or a weekly count you hit when it fits.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<_HabitKind>(
            segments: const [
              ButtonSegment(
                value: _HabitKind.time,
                label: Text('Daily'),
                icon: Icon(Icons.schedule),
              ),
              ButtonSegment(
                value: _HabitKind.frequency,
                label: Text('X / week'),
                icon: Icon(Icons.repeat),
              ),
            ],
            selected: {value},
            onSelectionChanged: (s) => onChanged(s.first),
          ),
          const SizedBox(height: 14),
          Text(
            value == _HabitKind.time
                ? 'I\'ll nudge you every day during the window you picked.'
                : 'I\'ll prime you toward a weekly target — pick a day if '
                    'there\'s one that works best.',
            style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DailyDetailsStep extends StatefulWidget {
  const _DailyDetailsStep({
    required this.alarmStyle,
    required this.times,
    required this.onAlarmStyleChanged,
    required this.onTimesChanged,
  });
  final _AlarmStyle alarmStyle;
  final List<TimeOfDay> times;
  final ValueChanged<_AlarmStyle> onAlarmStyleChanged;
  final VoidCallback onTimesChanged;

  @override
  State<_DailyDetailsStep> createState() => _DailyDetailsStepState();
}

class _DailyDetailsStepState extends State<_DailyDetailsStep> {
  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: widget.times[index],
    );
    if (picked != null) {
      setState(() => widget.times[index] = picked);
      widget.onTimesChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return _WizardScaffold(
      title: 'When should the alarm fire?',
      subtitle:
          'Flexible lets me pick the best moment in the window. Fixed locks '
          'it to specific clock times.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<_AlarmStyle>(
            segments: const [
              ButtonSegment(
                value: _AlarmStyle.flexible,
                label: Text('Flexible'),
                icon: Icon(Icons.auto_awesome),
              ),
              ButtonSegment(
                value: _AlarmStyle.fixed,
                label: Text('Fixed time'),
                icon: Icon(Icons.alarm),
              ),
            ],
            selected: {widget.alarmStyle},
            onSelectionChanged: (s) => widget.onAlarmStyleChanged(s.first),
          ),
          const SizedBox(height: 16),
          if (widget.alarmStyle == _AlarmStyle.flexible)
            Text(
              "I'll learn when you're usually around and nudge then.",
              style: text.bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant, height: 1.4),
            )
          else ...[
            for (var i = 0; i < widget.times.length; i++)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(widget.times[i].format(context)),
                  trailing: widget.times.length > 1
                      ? IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            setState(() => widget.times.removeAt(i));
                            widget.onTimesChanged();
                          },
                        )
                      : null,
                  onTap: () => _pickTime(i),
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add time'),
                onPressed: () {
                  setState(() => widget.times
                      .add(const TimeOfDay(hour: 20, minute: 0)));
                  widget.onTimesChanged();
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FrequencyDetailsStep extends StatelessWidget {
  const _FrequencyDetailsStep({
    required this.target,
    required this.preferredWeekday,
    required this.onTargetChanged,
    required this.onDayChanged,
  });
  final int target;
  final int? preferredWeekday;
  final ValueChanged<int> onTargetChanged;
  final ValueChanged<int?> onDayChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return _WizardScaffold(
      title: 'How many times per week?',
      subtitle: 'I\'ll prime you toward that target — pick a preferred day '
          'if there\'s one that works best.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$target', style: text.headlineMedium),
              const SizedBox(width: 8),
              Text(target == 1 ? 'time / week' : 'times / week',
                  style: text.bodyLarge
                      ?.copyWith(color: colors.onSurfaceVariant)),
            ],
          ),
          Slider(
            value: target.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            label: '$target',
            onChanged: (v) => onTargetChanged(v.round()),
          ),
          const SizedBox(height: 16),
          Text('Preferred day', style: text.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Any'),
                selected: preferredWeekday == null,
                onSelected: (_) => onDayChanged(null),
              ),
              for (final d in const [
                DateTime.monday,
                DateTime.tuesday,
                DateTime.wednesday,
                DateTime.thursday,
                DateTime.friday,
                DateTime.saturday,
                DateTime.sunday,
              ])
                ChoiceChip(
                  label: Text(_weekdayShort(d)),
                  selected: preferredWeekday == d,
                  onSelected: (_) => onDayChanged(d),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _weekdayShort(int wd) => switch (wd) {
        DateTime.monday => 'Mon',
        DateTime.tuesday => 'Tue',
        DateTime.wednesday => 'Wed',
        DateTime.thursday => 'Thu',
        DateTime.friday => 'Fri',
        DateTime.saturday => 'Sat',
        DateTime.sunday => 'Sun',
        _ => '?',
      };
}
