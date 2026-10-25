/// What happens when the user marks an active break as completed, from a
/// routine or from the personal timer.
abstract interface class ActiveBreakCompletionPort {
  /// [completedAt] identifies the completion, so a retry keeps one entry.
  Future<void> complete(DateTime completedAt);
}
