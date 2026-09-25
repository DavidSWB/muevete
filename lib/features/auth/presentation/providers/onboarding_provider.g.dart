// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(onboardingStatus)
final onboardingStatusProvider = OnboardingStatusProvider._();

final class OnboardingStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<OnboardingStatus>,
          OnboardingStatus,
          Stream<OnboardingStatus>
        >
    with $FutureModifier<OnboardingStatus>, $StreamProvider<OnboardingStatus> {
  OnboardingStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingStatusHash();

  @$internal
  @override
  $StreamProviderElement<OnboardingStatus> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<OnboardingStatus> create(Ref ref) {
    return onboardingStatus(ref);
  }
}

String _$onboardingStatusHash() => r'99ab8a7dde64bd02b9dfe27b969d5daf0e875df3';
