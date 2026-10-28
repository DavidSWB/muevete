import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/core/firebase/firebase_providers.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/education/data/firebase_educational_message_repository.dart';
import 'package:muevete/features/education/data/shared_preferences_tip_preferences_store.dart';
import 'package:muevete/features/education/domain/educational_message.dart';
import 'package:muevete/features/education/domain/educational_message_repository.dart';
import 'package:muevete/features/education/domain/tip_preferences.dart';
import 'package:muevete/features/education/domain/tip_selector.dart';

final educationalMessageRepositoryProvider =
    Provider<EducationalMessageRepository>((ref) {
      return FirebaseEducationalMessageRepository(
        firestore: ref.read(firebaseFirestoreProvider),
      );
    });

final tipPreferencesStoreProvider = Provider<TipPreferencesStore>(
  (ref) => SharedPreferencesTipPreferencesStore(),
);

/// Today's date and time; replaced in tests.
final tipClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// The signed-in user whose tips are shown, or null when nobody is signed in.
final tipUserIdProvider = Provider<String?>(
  (ref) => ref.watch(authStateProvider).value?.uid,
);

/// Active messages, loaded once per signed-in user and app launch.
final educationalMessagesProvider = FutureProvider<List<EducationalMessage>>((
  ref,
) async {
  if (ref.watch(tipUserIdProvider) == null) return const [];
  return ref.read(educationalMessageRepositoryProvider).getActiveMessages();
});

final tipPreferencesProvider =
    AsyncNotifierProvider<TipPreferencesNotifier, TipPreferences>(
      TipPreferencesNotifier.new,
    );

class TipPreferencesNotifier extends AsyncNotifier<TipPreferences> {
  @override
  Future<TipPreferences> build() async {
    final uid = ref.watch(tipUserIdProvider);
    if (uid == null) return TipPreferences.defaults;
    return ref.read(tipPreferencesStoreProvider).load(uid);
  }

  Future<void> setFrequency(TipFrequency frequency) async {
    final current = await future;
    await _save(current.copyWith(frequency: frequency));
  }

  /// The rotation continues after [messageId]; with
  /// [TipFrequency.daily] no other tip shows until tomorrow.
  Future<void> recordDismissal(String messageId, DateTime now) async {
    final current = await future;
    await _save(
      current.copyWith(
        lastDismissedId: messageId,
        lastDismissedOn: DateTime(now.year, now.month, now.day),
      ),
    );
  }

  Future<void> _save(TipPreferences preferences) async {
    state = AsyncData(preferences);
    final uid = ref.read(tipUserIdProvider);
    if (uid != null) {
      await ref.read(tipPreferencesStoreProvider).save(uid, preferences);
    }
  }
}

/// Whether the user closed a tip since the app opened. A closed tip stays
/// closed until the next launch, whatever the frequency.
final tipDismissedThisSessionProvider =
    NotifierProvider<TipSessionNotifier, bool>(TipSessionNotifier.new);

class TipSessionNotifier extends Notifier<bool> {
  @override
  bool build() {
    ref.watch(tipUserIdProvider);
    return false;
  }

  Future<void> dismiss(EducationalMessage message) async {
    state = true;
    await ref
        .read(tipPreferencesProvider.notifier)
        .recordDismissal(message.messageId, ref.read(tipClockProvider)());
  }
}

/// The tip to show on Home, or null. Errors are left to the caller, which
/// hides the card: tips are optional.
final dailyTipProvider = FutureProvider<EducationalMessage?>((ref) async {
  if (ref.watch(tipDismissedThisSessionProvider)) return null;
  final preferences = await ref.watch(tipPreferencesProvider.future);
  if (preferences.frequency == TipFrequency.off) return null;
  final messages = await ref.watch(educationalMessagesProvider.future);
  return selectTip(
    messages: messages,
    preferences: preferences,
    now: ref.read(tipClockProvider)(),
  );
});
