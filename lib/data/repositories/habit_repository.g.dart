// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDb)
final appDbProvider = AppDbProvider._();

final class AppDbProvider extends $FunctionalProvider<AppDb, AppDb, AppDb>
    with $Provider<AppDb> {
  AppDbProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDbProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDbHash();

  @$internal
  @override
  $ProviderElement<AppDb> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDb create(Ref ref) {
    return appDb(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDb value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDb>(value),
    );
  }
}

String _$appDbHash() => r'4e64307d1b33e9f4bf49383b1da01c84803d1651';

@ProviderFor(habitRepository)
final habitRepositoryProvider = HabitRepositoryProvider._();

final class HabitRepositoryProvider
    extends
        $FunctionalProvider<HabitRepository, HabitRepository, HabitRepository>
    with $Provider<HabitRepository> {
  HabitRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitRepositoryHash();

  @$internal
  @override
  $ProviderElement<HabitRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HabitRepository create(Ref ref) {
    return habitRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HabitRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HabitRepository>(value),
    );
  }
}

String _$habitRepositoryHash() => r'678fb57bd7cd83e2f1865bce11dd9989c745b833';
