import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// v8 You-page structure guards. The full widget tree isn't pumped here
/// (it sits on top of a StreamProvider and debounce timers); the on-device
/// walkthrough is what catches runtime issues. This file just locks in
/// the structural decisions so they don't regress silently.
void main() {
  final src = File('lib/features/you/you_page.dart').readAsStringSync();

  test('Theme pack row is gone (background picker subsumes it)', () {
    expect(src.contains('BuddyThemePackRow'), isFalse);
    expect(src.contains('theme_picker_widget.dart'), isFalse);
  });

  test('Appearance segmented button is gone (brightness inferred from BG)',
      () {
    // The old light/dark appearance control is gone (brightness now derives
    // from the background). The page does still use a SegmentedButton for the
    // widget color-mode picker, so we no longer assert on ButtonSegment.
    expect(src.contains('DarkModePref'), isFalse);
  });

  test('Accent picker is gone (derived from primary)', () {
    expect(src.contains("'Accent color'"), isFalse);
  });

  test('Background picker is the composition picker (v9 base+tint+strength)',
      () {
    expect(src.contains('BackgroundPicker'), isTrue);
    expect(src.contains('_writeBase'), isTrue);
    expect(src.contains('_writeTint'), isTrue);
    expect(src.contains('_writeTintStrength'), isTrue);
    // The old direct-swatch BG picker is gone.
    expect(src.contains('backgroundSwatches'), isFalse);
  });

  test('Buddy switch updates primary + tint to the buddy\'s color', () {
    expect(src.contains('_writeBuddy'), isTrue);
    expect(src.contains('customPrimaryColor: seed.toARGB32()'), isTrue);
    expect(src.contains('bgTintColor: seed.toARGB32()'), isTrue);
  });

  test('_Section no longer wraps children in a Card', () {
    // The _Section helper used to wrap content in a Card; the flattened
    // version matches the rest of the app (Plan/Wins/Today put cards
    // around items, not around the whole page section).
    final sectionBlock = RegExp(
            r'class _Section extends StatelessWidget \{[\s\S]*?(?=\n})')
        .stringMatch(src);
    expect(sectionBlock, isNotNull);
    expect(sectionBlock!.contains('Card('), isFalse);
  });
}
