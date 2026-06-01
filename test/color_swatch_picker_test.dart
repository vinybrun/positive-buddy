import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/features/profile/color_swatch_picker.dart';

void main() {
  group('ColorSwatchPicker', () {
    testWidgets('renders the primary swatch set by default', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ColorSwatchPicker(
            label: 'Primary',
            current: ColorSwatchPicker.primarySwatches.first,
            overridden: false,
            onChanged: (_) {},
            onCleared: () {},
          ),
        ),
      ));
      // One InkWell per swatch.
      expect(find.byType(InkWell),
          findsNWidgets(ColorSwatchPicker.primarySwatches.length + 1)); // +1 for "Mix a custom color" tile
    });

    testWidgets('renders the tint swatch set when provided',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ColorSwatchPicker(
            label: 'Tint',
            swatches: ColorSwatchPicker.tintSwatches,
            current: ColorSwatchPicker.tintSwatches.first,
            overridden: false,
            onChanged: (_) {},
            onCleared: () {},
          ),
        ),
      ));
      expect(
          find.byType(InkWell),
          findsNWidgets(ColorSwatchPicker.tintSwatches.length + 1));
    });

    test('primarySwatches is compact (one row, ≤ 8)', () {
      expect(ColorSwatchPicker.primarySwatches.length, lessThanOrEqualTo(8));
    });

    testWidgets('Reset button only appears when overridden is true',
        (tester) async {
      Color picked = const Color(0xFF000000);
      await tester.pumpWidget(StatefulBuilder(builder: (ctx, setState) {
        return MaterialApp(
          home: Scaffold(
            body: ColorSwatchPicker(
              label: 'Primary',
              current: picked,
              overridden: false, // not overridden → no reset
              onChanged: (c) => setState(() => picked = c),
              onCleared: () {},
            ),
          ),
        );
      }));
      expect(find.text('Reset'), findsNothing);
    });

    testWidgets('Reset appears when overridden is true', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ColorSwatchPicker(
            label: 'Primary',
            current: const Color(0xFFCC6B49),
            overridden: true,
            onChanged: (_) {},
            onCleared: () {},
          ),
        ),
      ));
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('tapping a swatch fires onChanged with that color',
        (tester) async {
      Color? tapped;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ColorSwatchPicker(
            label: 'Primary',
            current: const Color(0xFF000000),
            overridden: false,
            onChanged: (c) => tapped = c,
            onCleared: () {},
          ),
        ),
      ));
      // First swatch InkWell is the first one rendered (the "Mix a custom
      // color" toggle comes after the swatches in tree order).
      final inkwells =
          find.byType(InkWell).evaluate().take(1).map((e) => e.widget).toList();
      expect(inkwells.length, 1);
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();
      expect(tapped, ColorSwatchPicker.primarySwatches.first);
    });
  });
}
