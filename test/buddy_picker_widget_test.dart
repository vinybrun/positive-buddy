import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/data/db/app_db.dart';
import 'package:habit_buddy/data/repositories/habit_repository.dart';
import 'package:habit_buddy/features/profile/buddy_picker_widget.dart';
import 'package:habit_buddy/features/profile/theme_picker_widget.dart';
import 'package:habit_buddy/theme/app_theme.dart';
import 'package:habit_buddy/theme/buddy.dart';

Widget _wrap(Widget child, {AppDb? db}) {
  return ProviderScope(
    overrides: [
      appDbProvider.overrideWithValue(
          db ?? AppDb.forTesting(NativeDatabase.memory())),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  group('BuddyPickerRow', () {
    testWidgets('renders one card per buddy with its label', (tester) async {
      final db = AppDb.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      await tester.pumpWidget(_wrap(
        BuddyPickerRow(
          selected: null,
          onSelected: (_) {},
        ),
        db: db,
      ));
      await tester.pump();
      for (final b in BuddyId.values) {
        expect(find.text(b.label), findsOneWidget);
      }
      // Tear down the widget tree so any active drift stream
      // subscriptions are cancelled before the binding asserts no
      // pending timers.
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });

    testWidgets('tapping a buddy fires onSelected with that id',
        (tester) async {
      final db = AppDb.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      BuddyId? tapped;
      await tester.pumpWidget(_wrap(
        BuddyPickerRow(
          selected: null,
          onSelected: (b) => tapped = b,
        ),
        db: db,
      ));
      await tester.pump();
      await tester.tap(find.text(BuddyId.fox.label));
      await tester.pump();
      expect(tapped, BuddyId.fox);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });

  group('BuddyThemePackRow', () {
    testWidgets('renders one swatch per buddy pack (5 total, no animal names)',
        (tester) async {
      await tester.pumpWidget(_wrap(
        BuddyThemePackRow(
          selectedThemeId: 'auto',
          selectedBuddy: null,
          onPackSelected: (_) {},
        ),
      ));
      // 5 swatches = 5 InkWells inside the row.
      expect(find.byType(InkWell), findsNWidgets(BuddyId.values.length));
      // Crucially, NO animal labels — the picker hides which buddy each
      // pack belongs to.
      for (final b in BuddyId.values) {
        expect(find.text(b.label), findsNothing);
      }
      // Not in custom mode → no Custom chip.
      expect(find.text('Custom'), findsNothing);
    });

    testWidgets('shows Custom chip when themeId == custom', (tester) async {
      await tester.pumpWidget(_wrap(
        BuddyThemePackRow(
          selectedThemeId: customThemeId,
          selectedBuddy: BuddyId.fox,
          onPackSelected: (_) {},
        ),
      ));
      expect(find.text('Custom'), findsOneWidget);
    });
  });
}
