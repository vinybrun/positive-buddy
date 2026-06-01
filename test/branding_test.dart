import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards against an accidental revert of the user-facing app name back to
/// "Habit Buddy". Internal slugs (package name, DB filename, method channel)
/// stay habit_buddy on purpose, so they aren't asserted here.
void main() {
  test('MaterialApp title is Positive Buddy', () {
    final src = File('lib/main.dart').readAsStringSync();
    expect(src, contains("title: 'Positive Buddy'"));
    expect(src, isNot(contains("title: 'Habit Buddy'")));
  });

  test('AndroidManifest top-level label is Positive Buddy', () {
    final src =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(src, contains('android:label="Positive Buddy"'));
    // Internal lowercase package label "habit_buddy" must be gone from the
    // <application> tag. There can still be no leftover user-visible
    // "Habit Buddy" strings on any activity-alias.
    expect(src, isNot(contains('android:label="Habit Buddy"')));
    expect(src, isNot(contains('android:label="habit_buddy"')));
  });

  test('iOS CFBundleDisplayName is Positive Buddy', () {
    final src = File('ios/Runner/Info.plist').readAsStringSync();
    expect(
      src,
      matches(
        RegExp(
          r'<key>CFBundleDisplayName</key>\s*<string>Positive Buddy</string>',
        ),
      ),
    );
  });

  test('Setup page copy uses Positive Buddy, not Habit Buddy', () {
    final src =
        File('lib/features/permissions/setup_page.dart').readAsStringSync();
    expect(src, isNot(contains('Habit Buddy')));
    expect(src, contains('Positive Buddy'));
  });

  test('AndroidManifest enables Android auto-backup', () {
    final src =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(src, contains('android:allowBackup="true"'));
    expect(src, contains('android:fullBackupContent="@xml/backup_rules"'));
    expect(
      src,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );
  });
}
