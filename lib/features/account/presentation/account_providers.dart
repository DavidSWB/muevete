import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/core/firebase/firebase_providers.dart';
import 'package:muevete/features/account/data/device_account_data_cleaner.dart';
import 'package:muevete/features/account/data/firestore_account_data_repository.dart';
import 'package:muevete/features/account/domain/account_deletion_service.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/features/walkthrough/presentation/providers/walkthrough_controller.dart';

final accountDeletionServiceProvider = Provider<AccountDeletionService>(
  (ref) => AccountDeletionService(
    auth: ref.watch(authRepositoryProvider),
    data: FirestoreAccountDataRepository(
      firestore: ref.watch(firebaseFirestoreProvider),
    ),
    local: DeviceAccountDataCleaner(
      walkthroughStore: ref.watch(walkthroughStoreProvider),
    ),
  ),
);
