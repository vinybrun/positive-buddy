import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/data/db/app_db.dart';
import 'package:habit_buddy/data/repositories/habit_repository.dart';
import 'package:habit_buddy/data/repositories/profile_repository.dart';
import 'package:habit_buddy/features/profile/buddy_picker_widget.dart';
import 'package:habit_buddy/theme/buddy.dart';

/// Live wrapper: feeds the picker its `selected` + `order` straight from the
/// user_profile stream and writes the selection back, exactly like YouPage.
class _Harness extends ConsumerWidget {
  const _Harness();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        UserSettings.fromRow(ref.watch(userProfileProvider).value);
    return BuddyPickerRow(
      compact: true,
      selected: settings.selectedBuddy,
      order: settings.effectiveBuddyOrder,
      onSelected: (b) =>
          ref.read(profileRepositoryProvider).updateSettings(selectedBuddy: b),
    );
  }
}

void main() {
  testWidgets(
      'choosing a hidden buddy floats it to front only after settling',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    final db = AppDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = ProfileRepository(db);

    await tester.pumpWidget(ProviderScope(
      overrides: [appDbProvider.overrideWithValue(db)],
      child: const MaterialApp(home: Scaffold(body: _Harness())),
    ));
    await tester.pumpAndSettle();

    // Cat (an "extra") starts hidden behind More.
    expect(find.text(BuddyId.cat.label), findsNothing);

    // Open More, pick Cat.
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(BuddyId.cat.label));
    await tester.pumpAndSettle();

    // Still poking around with the tray open → order NOT yet rewritten.
    var stored = (await repo.read())?.buddyOrderJson ?? '';
    expect(stored, isEmpty, reason: 'no settle has happened yet');

    // Close the tray — that's a settle point.
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();

    stored = (await repo.read())?.buddyOrderJson ?? '';
    expect(stored, isNotEmpty, reason: 'closing More should persist order');
    expect(UserSettings.parseBuddyOrder(stored).first, BuddyId.cat);

    // And Cat is now visible in the featured row with the tray collapsed.
    expect(find.text(BuddyId.cat.label), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('leaving the page settles a pending float', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    final db = AppDb.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = ProfileRepository(db);
    // Pre-seed Dog (an extra) as the selection.
    await repo.updateSettings(selectedBuddy: BuddyId.dog);

    await tester.pumpWidget(ProviderScope(
      overrides: [appDbProvider.overrideWithValue(db)],
      child: const MaterialApp(home: Scaffold(body: _Harness())),
    ));
    await tester.pumpAndSettle();

    // No settle yet — order still default/empty.
    expect((await repo.read())?.buddyOrderJson ?? '', isEmpty);

    // Tear down the page (dispose) → settle fires.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();

    final stored = (await repo.read())?.buddyOrderJson ?? '';
    expect(stored, isNotEmpty);
    expect(UserSettings.parseBuddyOrder(stored).first, BuddyId.dog);
  });
}
