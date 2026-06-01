import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/data/db/app_db.dart';
import 'package:habit_buddy/data/repositories/habit_repository.dart';
import 'package:habit_buddy/features/profile/buddy_picker_widget.dart';
import 'package:habit_buddy/theme/buddy.dart';

void main() {
  testWidgets(
      'BuddyPickerRow(compact: true) shows featured buddies + More tile',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        appDbProvider
            .overrideWithValue(AppDb.forTesting(NativeDatabase.memory())),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8),
            child: BuddyPickerRow(
              selected: null,
              onSelected: (_) {},
              compact: true,
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    // Featured (evolving) buddies are visible by default.
    for (final b in BuddyId.values.where((b) => b.hasStages)) {
      expect(find.text(b.label), findsOneWidget,
          reason: '${b.label} (featured) should be visible by default');
    }
    expect(find.text('More'), findsOneWidget,
        reason: 'More tile reveals the rest');
    // Non-stage buddies are hidden until More is tapped.
    for (final b in BuddyId.values.where((b) => !b.hasStages)) {
      expect(find.text(b.label), findsNothing,
          reason: '${b.label} should be hidden behind More');
    }

    // Tap More — extras appear.
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    for (final b in BuddyId.values) {
      expect(find.text(b.label), findsOneWidget,
          reason: '${b.label} should be visible after expanding');
    }
  });
}
