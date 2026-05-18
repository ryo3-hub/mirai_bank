import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/database/database_provider.dart';
import '../infrastructure/work_session_repository.dart';
import '../infrastructure/work_session_repository_impl.dart';

part 'work_session_providers.g.dart';

@Riverpod(keepAlive: true)
WorkSessionRepository workSessionRepository(Ref ref) {
  return WorkSessionRepositoryImpl(ref.watch(appDatabaseProvider));
}
