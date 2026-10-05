import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/app/app.dart';
import 'package:muevete/firebase_options.dart';

import 'package:muevete/features/training/domain/services/notification_scheduler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationScheduler.initialize();

  Object? firebaseError;
  StackTrace? firebaseStackTrace;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on Object catch (error, stackTrace) {
    // Keep the Flutter engine alive so startup errors are visible instead of
    // leaving a blank/black window. Firebase must still be configured for the
    // authentication and Firestore features to work.
    firebaseError = error;
    firebaseStackTrace = stackTrace;
  }

  runApp(
    ProviderScope(
      child: App(
        firebaseError: firebaseError,
        firebaseStackTrace: firebaseStackTrace,
      ),
    ),
  );
}
