abstract class PrivacyConsentRepository {
  /// Records on the signed-in user's existing profile that they accepted
  /// policy [version] and authorized health data under it, each with the
  /// server time. Throws if no user is signed in.
  Future<void> acceptPolicy(int version);
}
