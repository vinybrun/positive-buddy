import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/data/repositories/profile_repository.dart';
import 'package:habit_buddy/features/notifications/local_notification_service.dart';
import 'package:habit_buddy/theme/buddy.dart';

/// Build settings off the defaults with only the sound-relevant knobs changed.
UserSettings _s({
  bool soundEnabled = false,
  bool customSoundsEnabled = true,
  BuddyId? buddy,
}) {
  const d = UserSettings.defaults;
  return UserSettings(
    followUpEnabled: d.followUpEnabled,
    popupEnabled: d.popupEnabled,
    vibrationEnabled: d.vibrationEnabled,
    soundEnabled: soundEnabled,
    customSoundsEnabled: customSoundsEnabled,
    ttlMinutes: d.ttlMinutes,
    selectedBuddy: buddy,
    themeId: d.themeId,
    customPrimaryColor: d.customPrimaryColor,
    customAccentColor: d.customAccentColor,
    customBackgroundColor: d.customBackgroundColor,
    bgBase: d.bgBase,
    bgTintColor: d.bgTintColor,
    bgTintStrength: d.bgTintStrength,
    darkMode: d.darkMode,
    presenceMode: d.presenceMode,
    widgetColorMode: d.widgetColorMode,
    widgetShowCount: d.widgetShowCount,
    buddyOrder: d.buddyOrder,
  );
}

void main() {
  group('resolveReminderChannel', () {
    test('sound off → default channel, silent, no custom sound', () {
      final c = resolveReminderChannel(_s(soundEnabled: false, buddy: BuddyId.fox));
      expect(c.channelId, defaultChannelId);
      expect(c.playSound, isFalse);
      expect(c.rawSoundName, isNull);
      expect(c.usesBuddySound, isFalse);
    });

    test('sound on + no buddy → default channel with system sound', () {
      final c = resolveReminderChannel(_s(soundEnabled: true, buddy: null));
      expect(c.channelId, defaultChannelId);
      expect(c.playSound, isTrue);
      expect(c.rawSoundName, isNull);
    });

    test('sound on + custom off + buddy → default channel, no buddy sound', () {
      final c = resolveReminderChannel(
          _s(soundEnabled: true, customSoundsEnabled: false, buddy: BuddyId.cat));
      expect(c.channelId, defaultChannelId);
      expect(c.playSound, isTrue);
      expect(c.usesBuddySound, isFalse);
    });

    test('sound on + custom on + buddy → per-buddy channel with its sound', () {
      for (final b in BuddyId.values) {
        final c = resolveReminderChannel(
            _s(soundEnabled: true, customSoundsEnabled: true, buddy: b));
        expect(c.usesBuddySound, isTrue);
        expect(c.channelId, buddyReminderChannelId(b));
        expect(c.channelId, contains(b.id));
        expect(c.channelId, contains(buddySoundVersion));
        expect(c.rawSoundName, 'buddy_${b.id}');
        expect(c.playSound, isTrue);
      }
    });

    test('each buddy maps to a distinct channel id', () {
      final ids = {
        for (final b in BuddyId.values) buddyReminderChannelId(b),
      };
      expect(ids.length, BuddyId.values.length);
    });
  });
}
