enum WalkthroughStatus {
  /// The tour is running.
  active,

  /// The user closed the tour; it can resume from [WalkthroughProgress.stepId].
  dismissed,

  /// The user reached the last step.
  completed,

  /// The user chose "Never ask again" on the invitation.
  declined,
}

/// What is saved on the device for one user.
class WalkthroughProgress {
  const WalkthroughProgress({required this.status, required this.stepId});

  static const int version = 1;

  final WalkthroughStatus status;
  final String stepId;

  Map<String, Object?> toJson() => {
    'version': version,
    'status': status.name,
    'stepId': stepId,
  };

  /// Null for anything that is not a progress record of this version.
  static WalkthroughProgress? fromJson(Object? json) {
    if (json is! Map) return null;
    if (json['version'] != version) return null;
    final statusName = json['status'];
    final stepId = json['stepId'];
    if (statusName is! String || stepId is! String) return null;
    for (final status in WalkthroughStatus.values) {
      if (status.name == statusName) {
        return WalkthroughProgress(status: status, stepId: stepId);
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is WalkthroughProgress &&
      other.status == status &&
      other.stepId == stepId;

  @override
  int get hashCode => Object.hash(status, stepId);

  @override
  String toString() => 'WalkthroughProgress(${status.name}, $stepId)';
}
