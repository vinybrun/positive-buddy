// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completion_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Phase 5 — bridges the pure-Dart [completion_detector] with the
/// drift-backed log history. Used by the Today page to surface a
/// graduation prompt and by the Completed section to render throwback
/// stats.

@ProviderFor(completionService)
final completionServiceProvider = CompletionServiceProvider._();

/// Phase 5 — bridges the pure-Dart [completion_detector] with the
/// drift-backed log history. Used by the Today page to surface a
/// graduation prompt and by the Completed section to render throwback
/// stats.

final class CompletionServiceProvider
    extends
        $FunctionalProvider<
          CompletionService,
          CompletionService,
          CompletionService
        >
    with $Provider<CompletionService> {
  /// Phase 5 — bridges the pure-Dart [completion_detector] with the
  /// drift-backed log history. Used by the Today page to surface a
  /// graduation prompt and by the Completed section to render throwback
  /// stats.
  CompletionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completionServiceHash();

  @$internal
  @override
  $ProviderElement<CompletionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CompletionService create(Ref ref) {
    return completionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CompletionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CompletionService>(value),
    );
  }
}

String _$completionServiceHash() => r'89d118db71c3aded06511e7b31cdcb79266337e9';
