import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'buddy.dart';

/// Thin platform-channel wrapper around the per-buddy launcher icon swap.
/// On iOS this is a no-op for now (alternate icons deferred to a later
/// phase). On Android it toggles the relevant `<activity-alias>` enabled
/// state, which causes the launcher to refresh and show the new icon.
///
/// v15: the queued icon now carries the buddy's **evolution stage** as well
/// as its species, so a buddy that levels up swaps to its grown-up icon.
/// Static species (cat/dog/butterfly) ignore the stage and keep one icon.
///
/// **Why the swap is deferred** — toggling the alias also disables the
/// previously-enabled component, and when that component is the one
/// currently hosting the running task, the OS terminates the task as soon
/// as the swap fires. That would yank the user out of the app mid-tap.
/// Instead we *queue* the requested icon and apply it when the app reaches
/// `AppLifecycleState.paused` — i.e. the user has already left the app, so
/// the task tear-down is invisible.
class LauncherIconBridge {
  static const _channel = MethodChannel('habit_buddy/launcher_icon');

  // In-memory queue of the buddy + stage whose icon should be applied next
  // time the app is backgrounded. `_hasPending` distinguishes "queued
  // buddy is null because user cleared" from "no change has happened" — the
  // latter must NOT fire a swap on every background (would flicker the
  // launcher needlessly).
  static BuddyId? _pendingBuddy;
  static int _pendingStage = 0;
  static bool _hasPending = false;

  /// Record the buddy (and its current evolution [stage]) whose launcher
  /// icon should be shown. Does NOT fire the platform call — that waits
  /// until [applyPending] runs from the app's lifecycle observer when the
  /// user leaves the app.
  static void queueForBuddy(BuddyId? buddy, {int stage = 0}) {
    _pendingBuddy = buddy;
    _pendingStage = stage;
    _hasPending = true;
  }

  /// Fire the queued swap, if any. Safe to call repeatedly — does
  /// nothing when there's no pending change.
  static Future<void> applyPending() async {
    if (!_hasPending) return;
    final buddy = _pendingBuddy;
    final stage = _pendingStage;
    _hasPending = false;
    await _setForBuddy(buddy, stage);
  }

  /// Direct, immediate swap. Internal use only — Dart UI code should
  /// queue via [queueForBuddy] so the swap happens off-screen.
  static Future<void> _setForBuddy(BuddyId? buddy, int stage) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('setIcon', {
        'buddyId': buddy?.id,
        'stage': stage,
      });
    } on PlatformException catch (e) {
      // Some OEM launchers (including parts of HyperOS) may refuse the
      // swap. Failing here would block the *settings save* which is way
      // worse UX than a non-swapped launcher icon, so we swallow + log.
      if (kDebugMode) {
        debugPrint('launcher icon swap failed: ${e.code} ${e.message}');
      }
    }
  }

  /// Visible-for-test reset — clears any queued change so unit tests
  /// don't carry state between cases.
  @visibleForTesting
  static void resetForTest() {
    _pendingBuddy = null;
    _pendingStage = 0;
    _hasPending = false;
  }

  /// Visible-for-test inspection of the currently queued swap.
  @visibleForTesting
  static ({BuddyId? buddy, int stage, bool hasPending}) get pendingForTest =>
      (buddy: _pendingBuddy, stage: _pendingStage, hasPending: _hasPending);
}
