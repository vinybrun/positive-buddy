// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One-stop JSON export/import of every user-owned table. Pre-launch
/// the schema is allowed to break, so we tag exports with the current
/// schemaVersion and refuse to import mismatched ones — a corrupt restore
/// is worse than a refused one.

@ProviderFor(backupRepository)
final backupRepositoryProvider = BackupRepositoryProvider._();

/// One-stop JSON export/import of every user-owned table. Pre-launch
/// the schema is allowed to break, so we tag exports with the current
/// schemaVersion and refuse to import mismatched ones — a corrupt restore
/// is worse than a refused one.

final class BackupRepositoryProvider
    extends
        $FunctionalProvider<
          BackupRepository,
          BackupRepository,
          BackupRepository
        >
    with $Provider<BackupRepository> {
  /// One-stop JSON export/import of every user-owned table. Pre-launch
  /// the schema is allowed to break, so we tag exports with the current
  /// schemaVersion and refuse to import mismatched ones — a corrupt restore
  /// is worse than a refused one.
  BackupRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupRepositoryHash();

  @$internal
  @override
  $ProviderElement<BackupRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackupRepository create(Ref ref) {
    return backupRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupRepository>(value),
    );
  }
}

String _$backupRepositoryHash() => r'ebabe95d7171523ef70fcce48849a07804bd2d1f';
