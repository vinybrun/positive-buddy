import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../theme/buddy.dart';
import '../../theme/buddy_themes.dart';
import '../../theme/theme_palettes.dart';
import '../archived/archived_page.dart';
import '../buddy_progress/buddy_progress_repository.dart';
import '../notifications/local_notification_service.dart';
import '../notifications/presence.dart';
import '../onboarding/onboarding_model.dart';
import '../plan/plan_page.dart';
import '../profile/backup_section.dart';
import '../profile/background_picker.dart';
import '../profile/buddy_picker_widget.dart';
import '../profile/color_swatch_picker.dart';
import '../widgets/widget_data.dart';

/// Phase 4 — single config surface. Replaces the old split between
/// Profile (identity + reminder cap/waking) and Settings (notification
/// behaviour). Three collapsible sections: Buddy & look, Reminders, Data.
class YouPage extends ConsumerStatefulWidget {
  const YouPage({super.key});

  @override
  ConsumerState<YouPage> createState() => _YouPageState();
}

class _YouPageState extends ConsumerState<YouPage> {
  int? _draggingBudget;
  Timer? _budgetDebounce;
  Timer? _reconcileDebounce;
  static const _debounce = Duration(milliseconds: 600);

  /// Stored budget that means "no daily cap". Large enough that the engine's
  /// `indices.length <= budget` check is always true, so nothing is dropped.
  static const int unlimitedBudget = 100000;

  /// Snap points for the cap slider: 1–10 one-by-one, then 15, then no cap.
  static const List<int> _budgetStops = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, unlimitedBudget,
  ];

  /// The slider index whose stop best matches the stored [v].
  int _budgetIndex(int v) {
    final exact = _budgetStops.indexOf(v);
    if (exact >= 0) return exact;
    if (v >= unlimitedBudget) return _budgetStops.length - 1;
    var best = 0;
    for (var k = 1; k < _budgetStops.length - 1; k++) {
      if ((_budgetStops[k] - v).abs() < (_budgetStops[best] - v).abs()) {
        best = k;
      }
    }
    return best;
  }

  @override
  void dispose() {
    _budgetDebounce?.cancel();
    _reconcileDebounce?.cancel();
    super.dispose();
  }

  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  void _scheduleReconcile() {
    _reconcileDebounce?.cancel();
    _reconcileDebounce = Timer(_debounce, () {
      final notif = ref.read(localNotificationServiceProvider);
      final db = ref.read(appDbProvider);
      unawaited(notif.reconcile(db));
    });
  }

  Future<void> _writeTone(TonePreference t) async {
    await _repo.updateSettings(tonePreference: t.id);
    _scheduleReconcile();
  }

  void _writeBudget(int v) {
    setState(() => _draggingBudget = v);
    _budgetDebounce?.cancel();
    _budgetDebounce = Timer(_debounce, () async {
      await _repo.updateSettings(dailyNotifBudget: v);
      _scheduleReconcile();
      if (mounted) setState(() => _draggingBudget = null);
    });
  }

  Future<void> _writeWaking({TimeOfDay? start, TimeOfDay? end}) async {
    final row = await _repo.read();
    final cur = row == null
        ? null
        : OnboardingData.parseWakingWindow(row.wakingWindowJson);
    final s = start ?? cur?.start ?? const TimeOfDay(hour: 7, minute: 0);
    final e = end ?? cur?.end ?? const TimeOfDay(hour: 22, minute: 0);
    final tmp = OnboardingData(wakeStart: s, wakeEnd: e);
    await _repo.updateSettings(wakingWindowJson: tmp.wakingWindowJson());
    _scheduleReconcile();
  }

  /// v8/v9: writes commit the picked value verbatim. The theme provider
  /// composes the final scaffold from (base, tint, strength).
  Future<void> _writePrimary(Color c) =>
      _repo.updateSettings(customPrimaryColor: c.toARGB32());

  Future<void> _writeBase(BackgroundBase b) =>
      _repo.updateSettings(bgBase: b);

  Future<void> _writeTint(Color c) =>
      _repo.updateSettings(bgTintColor: c.toARGB32());

  Future<void> _writeTintStrength(int s) =>
      _repo.updateSettings(bgTintStrength: s);

  Future<void> _writeWidgetColorMode(WidgetColorMode m) =>
      _repo.updateSettings(widgetColorMode: m.id);

  Future<void> _writeWidgetShowCount(bool v) =>
      _repo.updateSettings(widgetShowCount: v);

  /// Picking a buddy switches the primary AND the BG tint to that buddy's
  /// brand color. The base (light/dark/colorful) and strength stay where
  /// the user left them — only the *hue* follows the buddy.
  Future<void> _writeBuddy(BuddyId b) async {
    final pack = buddyDefaultThemes[b]!;
    // Use the light-pack seed as the canonical "buddy color" so a dark
    // base + buddy switch reads as the buddy's hue tinting the dark.
    final seed = palettes[pack.light]!.seed;
    await _repo.updateSettings(
      selectedBuddy: b,
      customPrimaryColor: seed.toARGB32(),
      bgTintColor: seed.toARGB32(),
    );
    // v12: the new buddy may have never been scored — bring its row up
    // to date so the picker + Today header read the right stage. Cheap
    // when nothing has changed since the last reconcile.
    unawaited(ref.read(buddyProgressRepositoryProvider).reconcile(b));
  }

  Future<void> _updateBehavior({
    bool? followUpEnabled,
    bool? popupEnabled,
    bool? vibrationEnabled,
    bool? soundEnabled,
    bool? customSoundsEnabled,
    int? ttlMinutes,
    String? presenceMode,
  }) async {
    await _repo.updateSettings(
      followUpEnabled: followUpEnabled,
      popupEnabled: popupEnabled,
      vibrationEnabled: vibrationEnabled,
      soundEnabled: soundEnabled,
      customSoundsEnabled: customSoundsEnabled,
      ttlMinutes: ttlMinutes,
      presenceMode: presenceMode,
    );
    // Re-reconcile so already-scheduled reminders pick up the new behaviour.
    final notif = ref.read(localNotificationServiceProvider);
    final db = ref.read(appDbProvider);
    unawaited(notif.cancelAll().then((_) => notif.reconcile(db)));
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('You')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (row) {
          final settings = UserSettings.fromRow(row);
          final tone = row == null
              ? TonePreference.mixed
              : TonePreference.fromId(row.tonePreference);
          final dailyBudget = _draggingBudget ?? row?.dailyNotifBudget ?? 4;
          final waking = row == null
              ? null
              : OnboardingData.parseWakingWindow(row.wakingWindowJson);
          final wakeStart =
              waking?.start ?? const TimeOfDay(hour: 7, minute: 0);
          final wakeEnd =
              waking?.end ?? const TimeOfDay(hour: 22, minute: 0);
          return ListView(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
            children: [
              _Section(
                title: 'Buddy & look',
                children: _buddyAndLook(context, settings),
              ),
              const Divider(height: 24, indent: 16, endIndent: 16),
              _Section(
                title: 'Reminders',
                children: _reminders(
                    context, settings, tone, dailyBudget, wakeStart, wakeEnd),
              ),
              const Divider(height: 24, indent: 16, endIndent: 16),
              _Section(
                title: 'Data',
                children: _data(context),
              ),
              const _AboutCard(),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buddyAndLook(BuildContext context, UserSettings settings) {
    // v9: BG is composed from base + tint + strength. Buddy switch
    // updates primary + tint to the buddy's brand color. Primary picker
    // is compact (one swatch row) so the buddy preview stays in view
    // when the user expands the RGB mixer.
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
        child: BuddyPickerRow(
          selected: settings.selectedBuddy,
          onSelected: _writeBuddy,
          compact: true,
          order: settings.effectiveBuddyOrder,
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: BackgroundPicker(
          base: settings.bgBase,
          tint: Color(settings.bgTintColor),
          strength: settings.bgTintStrength,
          tintSwatches: ColorSwatchPicker.tintSwatches,
          onBaseChanged: _writeBase,
          onTintChanged: _writeTint,
          onStrengthChanged: _writeTintStrength,
        ),
      ),
      const Divider(height: 16),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: ColorSwatchPicker(
          label: 'Primary color',
          current: settings.customPrimaryColor == null
              ? scheme.primary
              : Color(settings.customPrimaryColor!),
          overridden: settings.customPrimaryColor != null,
          onChanged: _writePrimary,
          onCleared: () => _repo.updateSettings(clearCustomPrimary: true),
        ),
      ),
      const Divider(height: 16),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Text('Home-screen widgets', style: text.labelLarge),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
        child: Text(
          'How the progress bar & ring fill in.',
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: SegmentedButton<WidgetColorMode>(
          segments: const [
            ButtonSegment(
              value: WidgetColorMode.progressive,
              label: Text('Red → green'),
              icon: Icon(Icons.gradient),
            ),
            ButtonSegment(
              value: WidgetColorMode.primary,
              label: Text('Primary'),
              icon: Icon(Icons.circle),
            ),
          ],
          selected: {WidgetColorMode.fromId(settings.widgetColorMode)},
          onSelectionChanged: (s) => _writeWidgetColorMode(s.first),
        ),
      ),
      SwitchListTile(
        secondary: Icon(Icons.numbers, color: scheme.primary),
        title: const Text('Show count'),
        subtitle: const Text("The \"done / total\" number on the widgets."),
        value: settings.widgetShowCount,
        onChanged: _writeWidgetShowCount,
      ),
    ];
  }

  List<Widget> _reminders(
    BuildContext context,
    UserSettings settings,
    TonePreference tone,
    int dailyBudget,
    TimeOfDay wakeStart,
    TimeOfDay wakeEnd,
  ) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
        child: Text('Tone', style: text.labelLarge),
      ),
      RadioGroup<TonePreference>(
        groupValue: tone,
        onChanged: (v) {
          if (v != null) _writeTone(v);
        },
        child: Column(
          children: [
            for (final t in TonePreference.values)
              RadioListTile<TonePreference>(
                value: t,
                title: Text(t.label),
                subtitle: Text(t.subtitle),
                dense: true,
              ),
          ],
        ),
      ),
      const Divider(height: 16),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text('Daily reminder cap', style: text.labelLarge),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Row(
          children: [
            Text(
              dailyBudget >= unlimitedBudget ? '∞' : '$dailyBudget',
              style: text.headlineSmall,
            ),
            const SizedBox(width: 6),
            Text(
              dailyBudget >= unlimitedBudget
                  ? 'no daily cap'
                  : dailyBudget == 1
                      ? 'reminder / day'
                      : 'reminders / day',
              style: text.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Slider(
          value: _budgetIndex(dailyBudget).toDouble(),
          min: 0,
          max: (_budgetStops.length - 1).toDouble(),
          divisions: _budgetStops.length - 1,
          label: dailyBudget >= unlimitedBudget ? 'Unlimited' : '$dailyBudget',
          onChanged: (v) => _writeBudget(_budgetStops[v.round()]),
        ),
      ),
      const Divider(height: 16),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text('Waking window', style: text.labelLarge),
      ),
      ListTile(
        leading: const Icon(Icons.wb_sunny_outlined),
        title: const Text('Wake up'),
        trailing: Text(wakeStart.format(context)),
        onTap: () async {
          final picked = await showTimePicker(
              context: context, initialTime: wakeStart);
          if (picked != null) await _writeWaking(start: picked);
        },
      ),
      ListTile(
        leading: const Icon(Icons.bedtime_outlined),
        title: const Text('Lights out'),
        trailing: Text(wakeEnd.format(context)),
        onTap: () async {
          final picked =
              await showTimePicker(context: context, initialTime: wakeEnd);
          if (picked != null) await _writeWaking(end: picked);
        },
      ),
      const Divider(height: 16),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text('Reminder lifespan', style: text.labelLarge),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: _TtlPicker(
          minutes: settings.ttlMinutes,
          onChanged: (v) => _updateBehavior(ttlMinutes: v),
        ),
      ),
      if (Platform.isAndroid) ...[
        const Divider(height: 16),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text('Reminder timing', style: text.labelLarge),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: _PresencePicker(
            mode: settings.presenceMode,
            onChanged: (v) => _updateBehavior(presenceMode: v),
          ),
        ),
      ],
      const Divider(height: 16),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text('Behavior', style: text.labelLarge),
      ),
      SwitchListTile(
        secondary: Icon(Icons.bolt_outlined, color: colors.primary),
        title: const Text('Heads-up popups'),
        subtitle: const Text(
            "Reminders peek over what you're doing. Off = silent shade-only."),
        value: settings.popupEnabled,
        onChanged: (v) => _updateBehavior(popupEnabled: v),
      ),
      SwitchListTile(
        secondary: Icon(Icons.vibration, color: colors.primary),
        title: const Text('Vibration'),
        subtitle: const Text('Buzz when a reminder lands.'),
        value: settings.vibrationEnabled,
        onChanged: (v) => _updateBehavior(vibrationEnabled: v),
      ),
      SwitchListTile(
        secondary: Icon(Icons.volume_up_outlined, color: colors.primary),
        title: const Text('Sound'),
        subtitle: const Text('Play your notification sound for reminders.'),
        value: settings.soundEnabled,
        onChanged: (v) => _updateBehavior(soundEnabled: v),
      ),
      SwitchListTile(
        secondary: Icon(Icons.pets_outlined, color: colors.primary),
        title: const Text('Buddy sounds'),
        subtitle: Text(
          settings.selectedBuddy == null
              ? "Reminders play your buddy's own animal sound. Pick a buddy to hear it."
              : "Reminders play ${settings.selectedBuddy!.label}'s own animal sound instead of the default.",
        ),
        // Only meaningful when Sound is on — dim it otherwise so the
        // dependency reads clearly.
        value: settings.customSoundsEnabled,
        onChanged: settings.soundEnabled
            ? (v) => _updateBehavior(customSoundsEnabled: v)
            : null,
      ),
      SwitchListTile(
        secondary: Icon(Icons.chat_bubble_outline, color: colors.primary),
        title: const Text('Buddy replies'),
        subtitle: const Text(
            'A warm follow-up after Yes or Not yet. Off = your tap is logged silently.'),
        value: settings.followUpEnabled,
        onChanged: (v) => _updateBehavior(followUpEnabled: v),
      ),
    ];
  }

  List<Widget> _data(BuildContext context) {
    return [
      ListTile(
        leading: const Icon(Icons.flag_outlined),
        title: const Text('Plan your goals'),
        subtitle: const Text('Add, rename, or archive goals and habits.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const PlanPage()),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.inventory_2_outlined),
        title: const Text('Archived'),
        subtitle: const Text('Goals you parked. Restore any time.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ArchivedPage()),
        ),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(0, 4, 0, 8),
        child: BackupSection(),
      ),
    ];
  }
}

/// Flat section: title header + children, no Card wrapper. Matches the
/// look of Plan / Wins where content sits directly on the page background.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Text(title, style: text.titleMedium),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _PresencePicker extends StatelessWidget {
  const _PresencePicker({required this.mode, required this.onChanged});
  final String mode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<String>(
      groupValue: mode,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      child: Column(
        children: [
          for (final m in PresenceMode.all)
            RadioListTile<String>(
              value: m,
              title: Text(PresenceMode.labels[m] ?? m),
              dense: true,
            ),
        ],
      ),
    );
  }
}

class _TtlPicker extends StatelessWidget {
  const _TtlPicker({required this.minutes, required this.onChanged});
  final int minutes;
  final ValueChanged<int> onChanged;

  static const _choices = <(int, String)>[
    (15, '15 min'),
    (60, '1 hour'),
    (240, '4 hours'),
    (0, 'Never'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final c in _choices)
          ChoiceChip(
            label: Text(c.$2),
            selected: c.$1 == minutes,
            onSelected: (_) => onChanged(c.$1),
          ),
      ],
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Card(
        color: colors.primaryContainer.withValues(alpha: 0.45),
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lock_outline,
                      size: 18, color: colors.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Text('About this app',
                      style: text.titleMedium?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Fully offline. No cloud, no account, no analytics, no third "
                "parties.\n\nYour habits, logs, buddy choice, theme — all of "
                "it lives on this device. Uninstall the app and it's gone "
                "with it.",
                style: text.bodyMedium?.copyWith(
                    color: colors.onPrimaryContainer, height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
