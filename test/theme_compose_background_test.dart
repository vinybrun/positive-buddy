import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_buddy/data/repositories/profile_repository.dart';
import 'package:habit_buddy/theme/app_theme.dart';

void main() {
  group('composeBackground', () {
    test('Light base at 0% strength is pure white', () {
      final c = composeBackground(
        base: BackgroundBase.light,
        tint: const Color(0xFFFF0000),
        strength: 0,
      );
      expect(c.toARGB32(), 0xFFFFFFFF);
    });

    test('Light base at 100% is the tint exactly', () {
      const tint = Color(0xFFCC6B49);
      final c = composeBackground(
        base: BackgroundBase.light,
        tint: tint,
        strength: 100,
      );
      expect(c.toARGB32(), tint.toARGB32());
    });

    test('Light base at 10% with red tint is a pale pink', () {
      final c = composeBackground(
        base: BackgroundBase.light,
        tint: const Color(0xFFFF0000),
        strength: 10,
      );
      // 0.9 * 255 + 0.1 * 255 = 255 on R
      // 0.9 * 255 + 0.1 *   0 = 230 on G & B → 0xFFFFE6E6
      expect(c.toARGB32(), 0xFFFFE6E6);
    });

    test('Dark base at 0% is pure black', () {
      final c = composeBackground(
        base: BackgroundBase.dark,
        tint: const Color(0xFFFF0000),
        strength: 0,
      );
      expect(c.toARGB32(), 0xFF000000);
    });

    test('Dark base at 100% is the tint exactly', () {
      const tint = Color(0xFFCC6B49);
      final c = composeBackground(
        base: BackgroundBase.dark,
        tint: tint,
        strength: 100,
      );
      expect(c.toARGB32(), tint.toARGB32());
    });

    test('Colorful ignores strength — always returns the tint', () {
      const tint = Color(0xFF7A8F5C);
      for (final s in [0, 25, 50, 75, 100]) {
        final c = composeBackground(
          base: BackgroundBase.colorful,
          tint: tint,
          strength: s,
        );
        expect(c.toARGB32(), tint.toARGB32(),
            reason: 'strength=$s should not change colorful output');
      }
    });

    test('Auto base in light brightness resolves to white', () {
      final c = composeBackground(
        base: BackgroundBase.auto,
        tint: const Color(0xFFFF0000),
        strength: 0,
        systemBrightness: Brightness.light,
      );
      expect(c.toARGB32(), 0xFFFFFFFF);
    });

    test('Auto base in dark brightness resolves to black', () {
      final c = composeBackground(
        base: BackgroundBase.auto,
        tint: const Color(0xFFFF0000),
        strength: 0,
        systemBrightness: Brightness.dark,
      );
      expect(c.toARGB32(), 0xFF000000);
    });

    test('Auto base at 100% is the tint regardless of brightness', () {
      const tint = Color(0xFFCC6B49);
      for (final b in [Brightness.light, Brightness.dark]) {
        final c = composeBackground(
          base: BackgroundBase.auto,
          tint: tint,
          strength: 100,
          systemBrightness: b,
        );
        expect(c.toARGB32(), tint.toARGB32());
      }
    });

    test('Out-of-range strength clamps to [0,100]', () {
      const tint = Color(0xFFFF0000);
      final negative = composeBackground(
        base: BackgroundBase.light,
        tint: tint,
        strength: -50,
      );
      expect(negative.toARGB32(), 0xFFFFFFFF);
      final over = composeBackground(
        base: BackgroundBase.light,
        tint: tint,
        strength: 150,
      );
      expect(over.toARGB32(), tint.toARGB32());
    });
  });
}
