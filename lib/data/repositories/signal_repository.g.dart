// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signal_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Phase 3 — the only writer to the `profile_signals` table. The engine
/// reads from it during reconcile to figure out when the user is most
/// active; that drives smart scheduling and (Phase 4) tone choice.

@ProviderFor(signalRepository)
final signalRepositoryProvider = SignalRepositoryProvider._();

/// Phase 3 — the only writer to the `profile_signals` table. The engine
/// reads from it during reconcile to figure out when the user is most
/// active; that drives smart scheduling and (Phase 4) tone choice.

final class SignalRepositoryProvider
    extends
        $FunctionalProvider<
          SignalRepository,
          SignalRepository,
          SignalRepository
        >
    with $Provider<SignalRepository> {
  /// Phase 3 — the only writer to the `profile_signals` table. The engine
  /// reads from it during reconcile to figure out when the user is most
  /// active; that drives smart scheduling and (Phase 4) tone choice.
  SignalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signalRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signalRepositoryHash();

  @$internal
  @override
  $ProviderElement<SignalRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignalRepository create(Ref ref) {
    return signalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignalRepository>(value),
    );
  }
}

String _$signalRepositoryHash() => r'bd7bbe3a446edad02d81dc4fd044beabc95b527f';
