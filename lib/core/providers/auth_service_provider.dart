import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/core/auth/auth_service.dart';
import 'package:muevete/core/firebase/firebase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service_provider.g.dart';

@riverpod
AuthService authService(Ref ref){

    return AuthService(

        ref.watch(firebaseAuthProvider),

    );

}