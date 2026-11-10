abstract class PrivacyConsentRepository {
  /// Records that the signed-in user accepted [currentPrivacyPolicyVersion]
  /// on an existing profile. Throws if no user is signed in.
  Future<void> acceptCurrentPolicy();
}
