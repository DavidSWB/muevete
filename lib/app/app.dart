import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/app/router.dart';
import 'package:muevete/features/localization/presentation/locale_provider.dart';
import 'package:muevete/features/profile/presentation/profile_provider.dart';
import 'package:muevete/features/training/domain/services/notification_scheduler.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/shared/theme/app_theme.dart';

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
      final currentLocale = ref.read(localeProvider);
      await NotificationScheduler.rescheduleAll(
        user,
        force: true,
        locale: currentLocale,
      );
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
    final activeLocale = ref.watch(localeProvider);

    if (widget.firebaseError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: activeLocale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: _FirebaseStartupErrorScreen(
          error: widget.firebaseError!,
          stackTrace: widget.firebaseStackTrace,
        ),
      );
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      locale: activeLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}

class _FirebaseStartupErrorScreen extends StatelessWidget {
  const _FirebaseStartupErrorScreen({
    required this.error,
    this.stackTrace,
  });

  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error de inicio')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No se pudo inicializar Firebase. Configura Firebase para el dispositivo seleccionado y vuelve a ejecutar la app.',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SelectableText(
                '$error\n\n${stackTrace ?? ''}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
