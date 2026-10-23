import 'package:muevete/features/walkthrough/domain/walkthrough_progress.dart';

/// Keeps each user's tour progress on this device.
abstract interface class WalkthroughStore {
  /// Null when nothing usable is stored.
  Future<WalkthroughProgress?> load(String uid);

  Future<void> save(String uid, WalkthroughProgress progress);

  Future<void> clear(String uid);
}
