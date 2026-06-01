import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:home_widget/home_widget.dart';

import 'data/repositories/habit_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/signal_repository.dart';
import 'features/buddy_progress/buddy_progress_repository.dart';
import 'features/notifications/local_notification_service.dart';
import 'features/widgets/home_widget_service.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/permissions/permissions_service.dart';
import 'features/permissions/setup_page.dart';
import 'features/today/today_page.dart';
import 'theme/app_theme.dart';
import 'theme/launcher_icon.dart';

/// Bumped each time a notification handler in any isolate finishes writing,
/// so the foreground UI re-queries drift (otherwise the BG isolate's writes
/// don't reach the foreground's stream subscriptions).
final notificationRefreshTickProvider = StateProvider<int>((_) => 0);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge — let the user's BG color paint behind the system nav and
  // status bars instead of getting a hard white strip. The bar foregrounds
  // (icons, text) flip automatically with the theme's Brightness.
  //
  // `systemNavigationBarContrastEnforced: false` is the magic bit on Android
  // 10+ — without it the OS forces a translucent scrim under the gesture
  // pill / nav buttons even when we set the BG color to transparent.
  // Portrait-only. The whole UI is designed for a single vertical column;
  // landscape would just stretch it awkwardly. Lock it at the engine level
  // (the manifest also pins screenOrientation as a belt-and-suspenders so
  // the lock holds during the native splash before Flutter boots).
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
  ));

  final notifications = LocalNotificationService();
  await notifications.init();

  final container = ProviderContainer(
    overrides: [
      localNotificationServiceProvider.overrideWithValue(notifications),
    ],
  );
  final db = container.read(appDbProvider);
  bindForegroundDb(db);

  // Home-screen widgets: register the Done-button background handler and
  // start syncing today's habit state to the launcher widgets.
  await HomeWidget.registerInteractivityCallback(widgetInteractivityCallback);
  // The stream subscriptions inside the service capture it, keeping it
  // alive for the app lifetime alongside the long-lived db.
  final widgetService = HomeWidgetService(db)..start();
  // Re-reconcile pending alarms on every cold start so habits keep firing
  // through device reboots, app updates, and long idle periods.
  // Fire-and-forget — UI doesn't block on this.
  unawaited(notifications.reconcile(db));

  IsolateNameServer.removePortNameMapping(notificationRefreshPortName);
  final port = ReceivePort();
  IsolateNameServer.registerPortWithName(
      port.sendPort, notificationRefreshPortName);
  port.listen((_) {
    // The BG Done handler already rendered the widgets before pinging; tell
    // the widget service so it drops the duplicate render the Drift streams
    // are about to trigger (avoids the second launcher blink).
    widgetService.notifyExternalRender();
    container.read(notificationRefreshTickProvider.notifier).state++;
  });

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const HabitBuddyApp(),
    ),
  );
}

class HabitBuddyApp extends ConsumerWidget {
  const HabitBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSet = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Positive Buddy',
      debugShowCheckedModeBanner: false,
      theme: themeSet.light,
      darkTheme: themeSet.dark,
      themeMode: themeSet.mode,
      home: const Root(),
    );
  }
}

class Root extends ConsumerStatefulWidget {
  const Root({super.key});

  @override
  ConsumerState<Root> createState() => _RootState();
}

class _RootState extends ConsumerState<Root> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Clean shade on app cold start too — there's no point keeping stale
    // reminder notifications around once the user has the app open.
    ref.read(localNotificationServiceProvider).cancelActiveReminders();
    // Phase 3: log the cold-start as an app_open signal so the engine's
    // active-hour histogram can pick the user's "I'm awake and reaching
    // for my phone" moments. Fire-and-forget.
    unawaited(
        ref.read(signalRepositoryProvider).record(kind: SignalRepository.kindAppOpen));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final notif = ref.read(localNotificationServiceProvider);
      notif.cancelActiveReminders();
      // Phase 3: warm-resume app_open signal feeds the smart scheduler.
      unawaited(ref
          .read(signalRepositoryProvider)
          .record(kind: SignalRepository.kindAppOpen));
      // Reconcile again on resume — covers the "user opened the app for the
      // first time in days, catch up scheduling" case.
      unawaited(notif.reconcile(ref.read(appDbProvider)));
      // v12: same trick for the per-buddy evolution. The reconciler
      // walks unscored days up to yesterday and bumps the cumulative
      // total. Bounded by days-since-last-run so it's cheap.
      final selected = UserSettings.fromRow(
        ref.read(userProfileProvider).value,
      ).selectedBuddy;
      if (selected != null) {
        unawaited(
          ref.read(buddyProgressRepositoryProvider).reconcile(selected),
        );
      }
    } else if (state == AppLifecycleState.paused) {
      // User left the app — now's the safe moment to swap the launcher
      // icon if a buddy change is queued. Doing this while the app is in
      // the foreground would terminate the running task.
      unawaited(LauncherIconBridge.applyPending());
    }
  }

  @override
  Widget build(BuildContext context) {
    final snap = ref.watch(permissionsStatusControllerProvider);
    final profileAsync = ref.watch(userProfileProvider);
    return snap.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (s) {
        if (!s.coreGranted) {
          return SetupPage(
            onComplete: () => ref
                .read(permissionsStatusControllerProvider.notifier)
                .refresh(),
          );
        }
        // Onboarding gate. Show the flow if the profile row hasn't been
        // written yet OR was written but never completed.
        return profileAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
          data: (profile) {
            final onboarded = profile?.onboarded ?? false;
            if (!onboarded) {
              return OnboardingPage(
                // The user_profile stream tick will swap us to the Today
                // page automatically once onboarded=true is written, so
                // this callback is just an extra nudge in case the
                // stream debounce is slow.
                onDone: () => setState(() {}),
              );
            }
            return const TodayPage();
          },
        );
      },
    );
  }
}
