import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/app/router.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/training/domain/services/notification_scheduler.dart';

class App extends ConsumerStatefulWidget {
  const App({
    super.key,
    this.firebaseError,
    this.firebaseStackTrace,
  });

  final Object? firebaseError;
  final StackTrace? firebaseStackTrace;

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.firebaseError == null) {
      _refreshNotificationWindow();
    }
  }

  Future<void> _refreshNotificationWindow() async {
    try {
      final user = await ref.read(profileProvider.future);
      await NotificationScheduler.rescheduleAll(user, force: true);
    } catch (error, stackTrace) {
      developer.log(
        'Failed to refresh notifications after app resume',
        name: 'muevete.notifications',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.firebaseError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(title: const Text('Error de inicio')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SelectableText(
              'No se pudo inicializar Firebase.\n\n'
              '${widget.firebaseError}\n\n'
              'Configura Firebase para el dispositivo seleccionado y vuelve '
              'a ejecutar la app.\n\n'
              '${widget.firebaseStackTrace ?? ''}',
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      routerConfig: router,
    );
  }
}
