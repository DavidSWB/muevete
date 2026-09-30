import 'package:flutter/material.dart';
import 'package:muevete/app/router.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    this.firebaseError,
    this.firebaseStackTrace,
  });

  final Object? firebaseError;
  final StackTrace? firebaseStackTrace;

  @override
  Widget build(BuildContext context) {
    if (firebaseError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(title: const Text('Error de inicio')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SelectableText(
              'No se pudo inicializar Firebase.\n\n'
              '$firebaseError\n\n'
              'Configura Firebase para el dispositivo seleccionado y vuelve '
              'a ejecutar la app.\n\n'
              '${firebaseStackTrace ?? ''}',
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
