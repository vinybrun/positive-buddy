import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/theme/buddy.dart';
import 'package:habit_buddy/theme/launcher_icon.dart';

void main() {
  setUp(LauncherIconBridge.resetForTest);

  test('queueForBuddy records the buddy and stage but does not auto-fire', () {
    expect(LauncherIconBridge.pendingForTest.hasPending, isFalse);
    LauncherIconBridge.queueForBuddy(BuddyId.fox, stage: 3);
    final p = LauncherIconBridge.pendingForTest;
    expect(p.hasPending, isTrue);
    expect(p.buddy, BuddyId.fox);
    expect(p.stage, 3);
  });

  test('stage defaults to 0', () {
    LauncherIconBridge.queueForBuddy(BuddyId.cat);
    expect(LauncherIconBridge.pendingForTest.stage, 0);
  });

  test('applyPending clears the queue (no-op off Android)', () async {
    LauncherIconBridge.queueForBuddy(BuddyId.snake, stage: 2);
    await LauncherIconBridge.applyPending();
    expect(LauncherIconBridge.pendingForTest.hasPending, isFalse);
    // Second apply with nothing queued is harmless.
    await LauncherIconBridge.applyPending();
    expect(LauncherIconBridge.pendingForTest.hasPending, isFalse);
  });
}
