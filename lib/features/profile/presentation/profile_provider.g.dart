// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Profile)
final profileProvider = ProfileProvider._();

final class ProfileProvider extends $AsyncNotifierProvider<Profile, UserModel> {
  ProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileHash();

  @$internal
  @override
  Profile create() => Profile();
}

String _$profileHash() => r'1dee608d5513142157cc06d710e90b95825ee252';

abstract class _$Profile extends $AsyncNotifier<UserModel> {
  FutureOr<UserModel> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserModel>, UserModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserModel>, UserModel>,
              AsyncValue<UserModel>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
