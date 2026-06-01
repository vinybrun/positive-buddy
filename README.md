# Positive Buddy

A goal-anchored habit companion for Android. You adopt an animal **buddy** that
grows with your streaks, get gentle personalized reminders, and track progress
from the app or directly from home-screen widgets.

> Package name: `habit_buddy`. The project is currently **Android-only**.

## Features

- **Buddies that evolve** — pick from cat, dog, fox, snake, bird, and butterfly.
  Evolving species level up through stages as you keep your habits, with an
  evolution ring and a matching stage-aware launcher icon.
- **Habits & plans** — create habits, complete them, and review wins and
  archived items.
- **Home-screen widgets** — tiny, small, and big widgets render your active
  buddy and progress; the big widget has tappable "Done" buttons.
- **Personalized notifications** — a pure-Dart personalization engine tailors
  reminder timing and copy, with an optional unique notification sound per
  buddy.
- **Local-first** — all data lives on-device in a SQLite database (Drift); no
  account or backend required.

## Tech stack

- [Flutter](https://flutter.dev) (Dart SDK `^3.12.0`)
- [Riverpod](https://riverpod.dev) for state management
- [Drift](https://drift.simonbinder.eu) over `sqlite3` for local persistence
- `flutter_local_notifications` + `timezone` for scheduled reminders
- `home_widget` for the Android home-screen widgets

Source is organized under `lib/`:

- `lib/features/` — feature modules (today, habits, plan, profile, you,
  onboarding, widgets, notifications, buddy_progress, wins, …)
- `lib/data/` — Drift database and repositories
- `lib/personalization/` — the notification personalization engine and rules
- `lib/theme/` — theming

## Getting started

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install) and an
Android device or emulator.

```bash
# install dependencies
flutter pub get

# generate Riverpod + Drift code
dart run build_runner build --delete-conflicting-outputs

# run on a connected Android device
flutter run

# run the tests
flutter test
```

To build a debug APK:

```bash
flutter build apk --debug
```

## Project notes

`CLAUDE.md` contains device-specific deploy steps, build-toolchain gotchas, and
deep notes on the widgets, launcher-icon swap, and notification channels.
