import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('WinsPage source exists and renders Active + Graduated sections', () {
    final src = File('lib/features/wins/wins_page.dart').readAsStringSync();
    expect(src.contains("Text('Active'"), isTrue);
    expect(src.contains("Text('Graduated'"), isTrue);
    expect(src.contains('CompletedHabitDetailPage'), isTrue);
  });

  test('Old Insights/Completed routes are gone', () {
    // Hard cut, pre-launch — no re-exports, no backwards-compat shims.
    expect(File('lib/features/insights/insights_page.dart').existsSync(),
        isFalse);
    expect(File('lib/features/completion/completed_page.dart').existsSync(),
        isFalse);
  });
}
