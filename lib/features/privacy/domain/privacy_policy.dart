/// Effective date of the privacy policy the app shows. Changing it asks
/// every user to accept the policy again before using the app.
const String currentPrivacyPolicyVersion = '2026-11-10';

/// Fields of `users/{uid}` that record the accepted policy.
const String privacyPolicyVersionField = 'privacyPolicyVersion';
const String privacyAcceptedAtField = 'privacyAcceptedAt';

/// True when [userData] records acceptance of [currentPrivacyPolicyVersion].
bool hasAcceptedCurrentPrivacyPolicy(Map<String, dynamic> userData) =>
    userData[privacyPolicyVersionField] == currentPrivacyPolicyVersion;
