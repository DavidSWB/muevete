import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muevete/features/training/domain/services/notification_scheduler.dart';

void main() {
  const res = 'android/app/src/main/res';
  const densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'];

  test('every density has the launcher and notification icons', () {
    for (final density in densities) {
      for (final path in [
        '$res/mipmap-$density/ic_launcher.png',
        '$res/mipmap-$density/ic_launcher_foreground.png',
        '$res/drawable-$density/${NotificationScheduler.androidIcon}.png',
      ]) {
        expect(File(path).existsSync(), isTrue, reason: path);
      }
    }
  });

  test('the adaptive icon points at its foreground and background', () {
    final adaptive = File(
      '$res/mipmap-anydpi-v26/ic_launcher.xml',
    ).readAsStringSync();
    expect(adaptive, contains('@mipmap/ic_launcher_foreground'));
    expect(adaptive, contains('@color/ic_launcher_background'));
    expect(
      File('$res/values/colors.xml').readAsStringSync(),
      contains('name="ic_launcher_background"'),
    );
  });

  test('release builds keep the notification icon', () {
    expect(
      File('$res/raw/keep.xml').readAsStringSync(),
      contains('@drawable/${NotificationScheduler.androidIcon}'),
    );
  });
}
