/// Remembers, on this device, the newest minor policy update each user
/// already dismissed, so the notice does not come back on every launch.
abstract class PolicyNoticeStore {
  Future<int?> dismissedVersion(String uid);

  Future<void> dismiss(String uid, int version);
}
