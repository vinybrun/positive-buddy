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
  flexible('flexible'),
  fixed('fixed');

  const _AlarmStyle(this.id);
  final String id;
}

/// Edit screen for an existing habit. Same shape as Add Habit, prefilled,
/// with a delete button. The kind toggle (Daily / X per week) lets the user
/// flip between modes after creation.
class EditHabitPage extends ConsumerStatefulWidget {
  const EditHabitPage({super.key, required this.habitId});

  final String habitId;

  @override
  ConsumerState<EditHabitPage> createState() => _EditHabitPageState();
}

class _EditHabitPageState extends ConsumerState<EditHabitPage> {
  final _nameCtrl = TextEditingController();
  String _categoryId = HabitCategory.water.id;
  WindowSelection _windowSel =
      WindowSelection(windows: {TimeWindow.anytime});
  _HabitKind _kind = _HabitKind.time;
  _AlarmStyle _alarmStyle = _AlarmStyle.flexible;
  final List<TimeOfDay> _times = [];
  int _targetPerWeek = 3;
  int? _preferredWeekday;
  bool _loaded = false;
  bool _saving = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(habitRepositoryProvider);
    final data = await repo.getWithSlots(widget.habitId);
    if (data == null || !mounted) return;
    setState(() {
      _nameCtrl.text = data.habit.name;
      _categoryId = data.habit.category;
      _windowSel = WindowSelection.fromDb(
        timeWindowsJson: data.habit.timeWindowsJson,
        customStartMinutes: data.habit.customStartMinutes,
        customEndMinutes: data.habit.customEndMinutes,
        legacyTimeWindow: data.habit.timeWindow,
      );
      _kind = data.habit.kind == 'freq' ? _HabitKind.frequency : _HabitKind.time;
      _alarmStyle = data.habit.alarmStyle == 'fixed'
          ? _AlarmStyle.fixed
          : _AlarmStyle.flexible;
      _targetPerWeek = data.habit.targetPerWeek ?? 3;
      _preferredWeekday = data.habit.preferredWeekday;
      _times.clear();
      for (final s in data.slots) {
        // Only show 'time' slots; the priming slot for freq habits is
        // engine-managed and shouldn't be exposed for direct editing.
        if (s.kind == 'time') {
          _times.add(
              TimeOfDay(hour: s.timeOfDay ~/ 60, minute: s.timeOfDay % 60));
        }
      }
      if (_times.isEmpty) {
        _times.add(const TimeOfDay(hour: 8, minute: 0));
      }
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Give it a name first.')),
      );
      return;
    }
    if (_kind == _HabitKind.time &&
        _alarmStyle == _AlarmStyle.fixed &&
        _times.isEmpty) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('Pick at least one time.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(habitRepositoryProvider);
      final notif = ref.read(localNotificationServiceProvider);
      final db = ref.read(appDbProvider);
      if (_kind == _HabitKind.time) {
        await repo.updateHabitWithSlots(
          id: widget.habitId,
          name: name,
          category: _categoryId,
          times: _times,
          windowSelection: _windowSel,
          alarmStyle: _alarmStyle.id,
        );
      } else {
        await repo.updateFrequencyHabit(
          id: widget.habitId,
          name: name,
          category: _categoryId,
          targetPerWeek: _targetPerWeek,
          preferredWeekday: _preferredWeekday,
          windowSelection: _windowSel,
        );
      }
      await notif.reconcile(db);
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this habit?'),
        content: Text(
          'I\'ll stop reminding you about "${_nameCtrl.text.trim()}". '
          'Your history stays.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep it'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              foregroundColor:
                  Theme.of(ctx).colorScheme.onErrorContainer,
              backgroundColor:
                  Theme.of(ctx).colorScheme.errorContainer,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting = true);
    try {
      final repo = ref.read(habitRepositoryProvider);
      final notif = ref.read(localNotificationServiceProvider);
      final db = ref.read(appDbProvider);
      await repo.softDelete(widget.habitId);
      await notif.reconcile(db);
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _pickTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _times[index],
    );
    if (picked != null) setState(() => _times[index] = picked);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Edit habit')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'What are you trying to do?',
              hintText: 'e.g. Drink water · Take meds · Stretch',
            ),
          ),
          const SizedBox(height: 24),
          Text('Style', style: text.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<_HabitKind>(
            segments: const [
              ButtonSegment(
                value: _HabitKind.time,
                label: Text('Daily reminders'),
                icon: Icon(Icons.schedule),
              ),
              ButtonSegment(
                value: _HabitKind.frequency,
                label: Text('X times / week'),
                icon: Icon(Icons.repeat),
              ),
            ],
            selected: {_kind},
            onSelectionChanged: (s) => setState(() => _kind = s.first),
          ),
          const SizedBox(height: 24),
          Text('Category', style: text.titleSmall),
          const SizedBox(height: 8),
          CategoryPicker(
            selectedId: _categoryId,
            onChanged: (v) => setState(() => _categoryId = v),
          ),
          const SizedBox(height: 24),
          Text('When?', style: text.titleSmall),
          const SizedBox(height: 8),
          WindowPicker(
            selection: _windowSel,
            onChanged: (sel) => setState(() => _windowSel = sel),
          ),
          const SizedBox(height: 24),
          if (_kind == _HabitKind.time) ..._timeFields(text) else
            ..._frequencyFields(text, colors),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: (_saving || _deleting) ? null : _save,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save changes'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: (_saving || _deleting) ? null : _delete,
            icon: const Icon(Icons.delete_outline),
            label: _deleting
                ? const Text('Deleting…')
                : const Text('Delete habit'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.error,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _timeFields(TextTheme text) => [
        Text('Alarm style', style: text.titleSmall),
        const SizedBox(height: 8),
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
          selected: {_alarmStyle},
          onSelectionChanged: (s) =>
              setState(() => _alarmStyle = s.first),
        ),
        const SizedBox(height: 16),
        if (_alarmStyle == _AlarmStyle.fixed) ...[
          Row(
            children: [
              Text('Reminders', style: text.titleSmall),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(
                    () => _times.add(const TimeOfDay(hour: 20, minute: 0))),
                icon: const Icon(Icons.add),
                label: const Text('Add time'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < _times.length; i++)
            Card(
              child: ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(_times[i].format(context)),
                trailing: _times.length > 1
                    ? IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () =>
                            setState(() => _times.removeAt(i)),
                      )
                    : null,
                onTap: () => _pickTime(i),
              ),
            ),
        ],
      ];

  List<Widget> _frequencyFields(TextTheme text, ColorScheme colors) => [
        Text('Target', style: text.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('$_targetPerWeek', style: text.headlineSmall),
            const SizedBox(width: 6),
            Text(_targetPerWeek == 1 ? 'time / week' : 'times / week',
                style:
                    text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
          ],
        ),
        Slider(
          value: _targetPerWeek.toDouble(),
          min: 1,
          max: 7,
          divisions: 6,
          label: '$_targetPerWeek',
          onChanged: (v) => setState(() => _targetPerWeek = v.round()),
        ),
        const SizedBox(height: 16),
        Text('Preferred day (optional)', style: text.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Any'),
              selected: _preferredWeekday == null,
              onSelected: (_) => setState(() => _preferredWeekday = null),
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
                selected: _preferredWeekday == d,
                onSelected: (_) => setState(() => _preferredWeekday = d),
              ),
          ],
        ),
      ];

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
