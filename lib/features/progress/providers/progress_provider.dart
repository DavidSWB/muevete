import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muevete/features/progress/repositories/fake_progress_repository.dart';

final progressRepositoryProvider = Provider((ref)=>
  FakeProgressRepository(),
);

final progressProvider = FutureProvider((ref) async{
  final repo = ref.read(progressRepositoryProvider);
  return repo.getProgress();
});