import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  // The Flutter Gradle plugin only applies this file to release builds when
  // it sits at this exact path.
  final rules = File('android/app/proguard-rules.pro');

  test('release builds keep the generic types Gson needs', () {
    // Without these rules R8 strips the TypeToken signature that
    // flutter_local_notifications reads its scheduled reminders with, and
    // every schedule call on a release APK fails with "Missing type parameter".
    final content = rules.readAsStringSync();
    expect(content, contains('-keepattributes Signature'));
    expect(
      content,
      contains(
        '-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken',
      ),
    );
    expect(
      content,
      contains(
        '-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken',
      ),
    );
  });

  test('release builds keep the field names of stored reminders', () {
    expect(
      rules.readAsStringSync(),
      contains('-keep class com.dexterous.flutterlocalnotifications.models.** { *; }'),
    );
  });

  test('release builds do not turn shrinking off to hide the problem', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    expect(gradle, isNot(contains('isMinifyEnabled = false')));
  });
}
