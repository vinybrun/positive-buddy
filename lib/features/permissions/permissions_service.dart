import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permissions_service.g.dart';

@Riverpod(keepAlive: true)
PermissionsService permissionsService(Ref ref) => PermissionsService();

@Riverpod(keepAlive: true)
class PermissionsStatusController extends _$PermissionsStatusController {
  @override
  Future<PermissionsSnapshot> build() async {
    return ref.read(permissionsServiceProvider).snapshot();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => ref.read(permissionsServiceProvider).snapshot());
  }
}

class PermissionsSnapshot {
  const PermissionsSnapshot({
    required this.notificationsGranted,
    required this.batteryExempt,
    required this.oem,
  });

  final bool notificationsGranted;
  final bool batteryExempt;
  final DeviceOem oem;

  /// Standard Android permissions all good. OEM-specific stuff (Xiaomi
  /// Autostart, Samsung Sleeping Apps, etc.) is best-effort and shown
  /// as recommended-but-optional in the setup page.
  bool get coreGranted => notificationsGranted && batteryExempt;
}

enum DeviceOem { generic, xiaomi, samsung, huawei, oppo, vivo, oneplus }

class PermissionsService {
  Future<PermissionsSnapshot> snapshot() async {
    return PermissionsSnapshot(
      notificationsGranted: await Permission.notification.isGranted,
      batteryExempt: await Permission.ignoreBatteryOptimizations.isGranted,
      oem: await _detectOem(),
    );
  }

  Future<bool> requestNotifications() async {
    final s = await Permission.notification.request();
    return s.isGranted;
  }

  Future<bool> requestBatteryExemption() async {
    final s = await Permission.ignoreBatteryOptimizations.request();
    return s.isGranted;
  }

  /// Opens the per-app battery optimization page so user can pick
  /// "Don't optimize" / Xiaomi's "No restrictions" etc.
  Future<void> openBatterySettings() async {
    try {
      const intent = AndroidIntent(
        action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
      );
      await intent.launch();
    } catch (_) {
      await openAppSettings();
    }
  }

  /// Best-effort deep link to Xiaomi's Autostart manager.
  Future<bool> openXiaomiAutostart() async {
    const candidates = <(String pkg, String component)>[
      (
        'com.miui.securitycenter',
        'com.miui.permcenter.autostart.AutoStartManagementActivity',
      ),
      (
        'com.miui.securitycenter',
        'com.miui.appmanager.ApplicationsDetailsActivity',
      ),
    ];
    for (final c in candidates) {
      try {
        final intent = AndroidIntent(
          action: 'android.intent.action.MAIN',
          package: c.$1,
          componentName: c.$2,
        );
        await intent.launch();
        return true;
      } catch (_) {
        continue;
      }
    }
    return false;
  }

  Future<DeviceOem> _detectOem() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return DeviceOem.generic;
    }
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      final m = info.manufacturer.toLowerCase();
      return switch (m) {
        'xiaomi' || 'redmi' || 'poco' => DeviceOem.xiaomi,
        'samsung' => DeviceOem.samsung,
        'huawei' => DeviceOem.huawei,
        'oppo' => DeviceOem.oppo,
        'vivo' => DeviceOem.vivo,
        'oneplus' => DeviceOem.oneplus,
        _ => DeviceOem.generic,
      };
    } catch (_) {
      return DeviceOem.generic;
    }
  }
}
