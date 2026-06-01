// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localNotificationService)
final localNotificationServiceProvider = LocalNotificationServiceProvider._();

final class LocalNotificationServiceProvider
    extends
        $FunctionalProvider<
          LocalNotificationService,
          LocalNotificationService,
          LocalNotificationService
        >
    with $Provider<LocalNotificationService> {
  LocalNotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localNotificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localNotificationServiceHash();

  @$internal
  @override
  $ProviderElement<LocalNotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalNotificationService create(Ref ref) {
    return localNotificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalNotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalNotificationService>(value),
    );
  }
}

String _$localNotificationServiceHash() =>
    r'75d10e0179b3f7d36b86238bb229647ac1797977';
