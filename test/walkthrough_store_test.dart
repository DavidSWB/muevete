import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/walkthrough/data/shared_preferences_walkthrough_store.dart';
import 'package:muevete/features/walkthrough/domain/walkthrough_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _progress = WalkthroughProgress(
  status: WalkthroughStatus.dismissed,
  stepId: 'exercise.completeSet',
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('saves, loads and clears one user', () async {
    final store = SharedPreferencesWalkthroughStore();

    expect(await store.load('a'), isNull);
    await store.save('a', _progress);
    expect(await store.load('a'), _progress);

    await store.clear('a');
    expect(await store.load('a'), isNull);
  });

  test('keeps users apart', () async {
    final store = SharedPreferencesWalkthroughStore();

    await store.save('a', _progress);

    expect(await store.load('b'), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), {'walkthrough_v1_a'});
  });

  test('ignores corrupt or unknown data', () async {
    SharedPreferences.setMockInitialValues({
      'walkthrough_v1_a': 'not json',
      'walkthrough_v1_b': '{"version":2,"status":"active","stepId":"x"}',
      'walkthrough_v1_c': '{"version":1,"status":"paused","stepId":"x"}',
      'walkthrough_v1_d': '[1, 2]',
    });
    final store = SharedPreferencesWalkthroughStore();

    for (final uid in ['a', 'b', 'c', 'd']) {
      expect(await store.load(uid), isNull, reason: uid);
    }
  });

  test('storage failures do not throw', () async {
    final store = SharedPreferencesWalkthroughStore(
      Future<SharedPreferences>.error(StateError('no storage')),
    );

    expect(await store.load('a'), isNull);
    await expectLater(store.save('a', _progress), completes);
    await expectLater(store.clear('a'), completes);
  });
}
