// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permissions_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(permissionsService)
final permissionsServiceProvider = PermissionsServiceProvider._();

final class PermissionsServiceProvider
    extends
        $FunctionalProvider<
          PermissionsService,
          PermissionsService,
          PermissionsService
        >
    with $Provider<PermissionsService> {
  PermissionsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'permissionsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$permissionsServiceHash();

  @$internal
  @override
  $ProviderElement<PermissionsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PermissionsService create(Ref ref) {
    return permissionsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PermissionsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PermissionsService>(value),
    );
  }
}

String _$permissionsServiceHash() =>
    r'77fd4d4b662d3f6632dad742e73da3b9da270df0';

@ProviderFor(PermissionsStatusController)
final permissionsStatusControllerProvider =
    PermissionsStatusControllerProvider._();

final class PermissionsStatusControllerProvider
    extends
        $AsyncNotifierProvider<
          PermissionsStatusController,
          PermissionsSnapshot
        > {
  PermissionsStatusControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'permissionsStatusControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$permissionsStatusControllerHash();

  @$internal
  @override
  PermissionsStatusController create() => PermissionsStatusController();
}

String _$permissionsStatusControllerHash() =>
    r'824efd690869736732775e0bd790f20c347df7d3';

abstract class _$PermissionsStatusController
    extends $AsyncNotifier<PermissionsSnapshot> {
  FutureOr<PermissionsSnapshot> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PermissionsSnapshot>, PermissionsSnapshot>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PermissionsSnapshot>, PermissionsSnapshot>,
              AsyncValue<PermissionsSnapshot>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
