import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/habit_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../theme/buddy.dart';
import '../notifications/local_notification_service.dart';
import '../plan/goal_creator_page.dart';
import '../profile/buddy_picker_widget.dart';
import 'onboarding_model.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key, this.onDone});

  /// Called once the user finishes the flow + writes the profile. Used by the
  /// root navigator to transition to the Today page.
  final VoidCallback? onDone;

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  final _data = OnboardingData();
  int _page = 0;
  bool _saving = false;

  // v11: goals + first-habit collection moved out of onboarding into the
  // GoalCreatorPage (which we push at the end of _finish). The wizard now
  // captures only buddy + tone + budget + waking window.
  static const _totalPages = 5;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      // Persist the captured prefs WITHOUT flipping onboarded=true. The
      // home tree rebuilds the second the stream sees onboarded=true,
      // which would unmount the pushed goal wizard.
      final repo = ref.read(profileRepositoryProvider);
      await repo.writeOnboarding(
        tonePreference: _data.tone.id,
        dailyNotifBudget: _data.dailyBudget,
        wakingWindowJson: _data.wakingWindowJson(),
        goalsJson: '[]',
        selectedBuddyId: _data.buddy?.id,
        markOnboarded: false,
      );
      // Reconcile so nothing scheduled outside the new waking window
      // survives. Habits will be created in the goal wizard next.
      final notif = ref.read(localNotificationServiceProvider);
      final db = ref.read(appDbProvider);
      await notif.reconcile(db);
      if (!mounted) return;
      // Hand off to the proper goal creator. Whether the user creates a
      // goal or backs out, we still land them on Today via onDone().
      await Navigator.of(context).push<String?>(
        MaterialPageRoute<String?>(
          builder: (_) => const GoalCreatorPage(),
        ),
      );
      if (!mounted) return;
      // Goal wizard popped — NOW flip the gate so the home tree swaps
      // to Today.
      await repo.setOnboarded(true);
      if (!mounted) return;
      widget.onDone?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not finish setup: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Persist the buddy live so the theme previews immediately as the user
  /// scrolls through the picker. We don't flip `onboarded` yet — that still
  /// happens at `_finish`.
  Future<void> _previewBuddy(BuddyId b) async {
    setState(() => _data.buddy = b);
    await ref
        .read(profileRepositoryProvider)
        .updateSettings(selectedBuddy: b);
  }

  void _next() {
    if (_page < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    if (_page > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_page + 1) / _totalPages,
                      backgroundColor:
                          colors.primaryContainer.withValues(alpha: 0.4),
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${_page + 1}/$_totalPages',
                      style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  _WelcomeStep(),
                  _BuddyStep(
                    value: _data.buddy,
                    onChanged: _previewBuddy,
                  ),
                  _TonePrefStep(
                    value: _data.tone,
                    onChanged: (t) => setState(() => _data.tone = t),
                  ),
                  _BudgetStep(
                    value: _data.dailyBudget,
                    onChanged: (n) => setState(() => _data.dailyBudget = n),
                  ),
                  _WakingWindowStep(
                    start: _data.wakeStart,
                    end: _data.wakeEnd,
                    onChanged: (s, e) => setState(() {
                      _data.wakeStart = s;
                      _data.wakeEnd = e;
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _page == 0 ? null : _back,
                    child: const Text('Back'),
                  ),
                  const Spacer(),
                  Builder(builder: (context) {
                    final onLastPage = _page == _totalPages - 1;
                    return FilledButton(
                      onPressed: _saving ? null : _next,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(onLastPage ? "Let's go" : 'Next'),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(title, style: text.headlineMedium),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: text.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant, height: 1.45),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return _StepScaffold(
      title: 'Hey — quick hello.',
      subtitle:
          "I'm gonna ask 3 quick questions so I can be useful instead of annoying. Maybe a minute, tops. Then you'll set up your first goal.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bullet(
              text:
                  'How you like to be talked to (warm vs. just-the-facts).'),
          _Bullet(
              text:
                  "How many nudges per day is too many — I'll cap it there."),
          _Bullet(text: "When you're awake. No pings at 3am."),
          const SizedBox(height: 20),
          // Promote the offline / no-tracking promise from a footer note
          // into a callout card — it's the differentiator, treat it like one.
          Card(
            color: colors.primaryContainer.withValues(alpha: 0.45),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_outline,
                          size: 18, color: colors.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Text(
                        "Fully offline. No tracking.",
                        style: text.titleSmall?.copyWith(
                            color: colors.onPrimaryContainer,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "I wanted a habit buddy that didn't track my personal "
                    "information, so I built one. Everything stays on your "
                    "phone — no cloud, no account, no analytics, no third "
                    "parties. You own your data, full stop.",
                    style: text.bodyMedium?.copyWith(
                        color: colors.onPrimaryContainer, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _BuddyStep extends StatelessWidget {
  const _BuddyStep({required this.value, required this.onChanged});
  final BuddyId? value;
  final ValueChanged<BuddyId> onChanged;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Pick your buddy.',
      subtitle:
          "They'll keep you company in here. The app's colors shift to match — but you can override that later if you want.",
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: BuddyPickerRow(
          selected: value,
          onSelected: onChanged,
        ),
      ),
    );
  }
}

class _TonePrefStep extends StatelessWidget {
  const _TonePrefStep({required this.value, required this.onChanged});
  final TonePreference value;
  final ValueChanged<TonePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'How should I talk to you?',
      subtitle:
          "There's no right answer. You can change this later in Settings.",
      child: RadioGroup<TonePreference>(
        groupValue: value,
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        child: Column(
          children: [
            for (final t in TonePreference.values)
              Card(
                clipBehavior: Clip.antiAlias,
                color: value == t
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: RadioListTile<TonePreference>(
                  value: t,
                  title: Text(t.label),
                  subtitle: Text(t.subtitle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BudgetStep extends StatelessWidget {
  const _BudgetStep({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return _StepScaffold(
      title: "Hard cap — how many nudges is too many?",
      subtitle:
          "I won't fire more than this many reminders per day, even if you set up more habits than that.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$value', style: text.displaySmall),
              const SizedBox(width: 8),
              Text(
                value == 1 ? 'reminder / day' : 'reminders / day',
                style:
                    text.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
          const SizedBox(height: 8),
          Text(
            _budgetHint(value),
            style: text.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant, height: 1.4),
          ),
        ],
      ),
    );
  }

  String _budgetHint(int n) {
    if (n <= 2) return "Minimal mode — I'll only ping for the most important.";
    if (n <= 4) return 'A reasonable rhythm. Most people land here.';
    if (n <= 6) return "Active reminder use — you'll hear from me a lot.";
    return "Heavy mode — I'll only hold back in extremes.";
  }
}

class _WakingWindowStep extends StatefulWidget {
  const _WakingWindowStep({
    required this.start,
    required this.end,
    required this.onChanged,
  });
  final TimeOfDay start;
  final TimeOfDay end;
  final void Function(TimeOfDay, TimeOfDay) onChanged;

  @override
  State<_WakingWindowStep> createState() => _WakingWindowStepState();
}

class _WakingWindowStepState extends State<_WakingWindowStep> {
  Future<void> _pick(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? widget.start : widget.end,
    );
    if (picked != null) {
      widget.onChanged(
        isStart ? picked : widget.start,
        isStart ? widget.end : picked,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: "When are you awake?",
      subtitle:
          "I won't fire reminders outside this window. If you're a night owl, set 'wake up' to like 10am — it's fine.",
      child: Column(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: const Text('Wake up'),
              trailing: Text(widget.start.format(context),
                  style: Theme.of(context).textTheme.titleLarge),
              onTap: () => _pick(true),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bedtime_outlined),
              title: const Text('Lights out'),
              trailing: Text(widget.end.format(context),
                  style: Theme.of(context).textTheme.titleLarge),
              onTap: () => _pick(false),
            ),
          ),
        ],
      ),
    );
  }
}
