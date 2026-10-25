import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:muevete/features/profile/domain/entities/activity_kind.dart';
import 'package:muevete/features/profile/domain/services/streak_calculator.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/profile/presentation/profile_repository_provider.dart';

/// The device's IANA time zone, or null when it cannot be read.
final deviceTimeZoneProvider = Provider<Future<String?> Function()>(
  (ref) => () async {
    try {
      return (await FlutterTimezone.getLocalTimezone()).identifier;
    } catch (error) {
      debugPrint('Could not read the device time zone: $error');
      return null;
    }
  },
);

final activityRecorderProvider = Provider<ActivityRecorder>(
  ActivityRecorder.new,
);

/// Records a completed workout or active break and refreshes the streak.
class ActivityRecorder {
  ActivityRecorder(this._ref);

  final Ref _ref;

  /// [completedAt] identifies the completion: recording the same value again,
  /// such as on a retry, does not add a second entry.
  Future<void> record(ActivityKind kind, DateTime completedAt) async {
    final user = await _ref.read(profileProvider.future);
    final timeZone = await _ref.read(deviceTimeZoneProvider)();

    final streak = const StreakCalculator().fromHistory(
      [...user.completedWorkouts, ...user.completedActiveBreaks, completedAt],
      today: DateTime.now(),
      timeZone: timeZone,
    );

    await _ref
        .read(profileRepositoryProvider)
        .recordCompletion(kind: kind, completedAt: completedAt, streak: streak);

    _ref.invalidate(profileProvider);
  }
}
