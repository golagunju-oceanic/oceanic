import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/core/provider/core_provider.dart';
import 'package:oceanic/features/notifications/data/datasource/notification_preferences_remote_datasource.dart';
import 'package:oceanic/features/notifications/data/repositories/notification_preferences_repository_impl.dart';
import 'package:oceanic/features/notifications/domain/repositories/notification_preferences_repository.dart';

final notificationPreferencesRemoteDataSourceProvider =
    Provider<NotificationPreferencesRemoteDataSource>((ref) {
  final api = ref.read(apiClientProvider);

  return NotificationPreferencesRemoteDataSource(
    get: (path) => api.get(path),
    patch: (path, body) => api.patch(path, body: body),
  );
});

final notificationPreferencesRepositoryProvider =
    Provider<NotificationPreferencesRepository>((ref) {
  return NotificationPreferencesRepositoryImpl(
    ref.read(notificationPreferencesRemoteDataSourceProvider),
  );
});
