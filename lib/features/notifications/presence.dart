import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// Presence-mode values stored on `user_profile.presenceMode`. Kept as raw
/// strings (matching the persisted column) so the value can flow through
/// the pure copy/scheduling layers without needing an enum import.
class PresenceMode {
  static const active = 'active';
  static const away = 'away';
  static const both = 'both';
  static const all = [active, away, both];
  static const labels = {
    active: "While I'm using my phone",
    away: 'When I\'m away from my phone',
    both: 'Both',
  };
}

/// Thin platform-channel wrapper around the device-presence query. Returns
/// `true` if the device screen is on / the user is interacting; `false` if
/// the screen is off. On iOS or any non-Android platform this returns null
/// (the feature is intentionally Android-only — see [[project_hyperos_notification_quirks]]).
class PresenceBridge {
  static const _channel = MethodChannel('habit_buddy/presence');

  static Future<bool?> isInteractive() async {
    if (!Platform.isAndroid) return null;
    try {
      final result = await _channel.invokeMethod<bool>('isInteractive');
      return result;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      // The channel isn't registered (e.g. unit tests). Treat as unknown.
      return null;
    }
  }

  /// Returns true iff the user wants this notification *to fire* given
  /// their stored [presenceMode] and the current device state. When
  /// presence can't be read (iOS, test env), the policy is to always fire
  /// — being missed is worse than firing one extra time.
  static Future<bool> shouldFire(String presenceMode) async {
    if (presenceMode == PresenceMode.both) return true;
    final interactive = await isInteractive();
    if (interactive == null) return true; // unknown → fire
    if (presenceMode == PresenceMode.active) return interactive;
    if (presenceMode == PresenceMode.away) return !interactive;
    return true;
  }
}
