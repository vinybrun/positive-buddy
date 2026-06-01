// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buddy_progress_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(buddyProgressRepository)
final buddyProgressRepositoryProvider = BuddyProgressRepositoryProvider._();

final class BuddyProgressRepositoryProvider
    extends
        $FunctionalProvider<
          BuddyProgressRepository,
          BuddyProgressRepository,
          BuddyProgressRepository
        >
    with $Provider<BuddyProgressRepository> {
  BuddyProgressRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'buddyProgressRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$buddyProgressRepositoryHash();

  @$internal
  @override
  $ProviderElement<BuddyProgressRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BuddyProgressRepository create(Ref ref) {
    return buddyProgressRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BuddyProgressRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BuddyProgressRepository>(value),
    );
  }
}

String _$buddyProgressRepositoryHash() =>
    r'eaafe0bc83409b5666a62474569b7c6e5f469e95';
