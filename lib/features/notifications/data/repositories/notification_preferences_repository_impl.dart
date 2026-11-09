import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_preferences_repository.dart';
import '../datasource/notification_preferences_remote_datasource.dart';

class NotificationPreferencesRepositoryImpl
    implements NotificationPreferencesRepository {
  NotificationPreferencesRepositoryImpl(this._remote);

  final NotificationPreferencesRemoteDataSource _remote;

  @override
  Future<NotificationPreferences> getPreferences() =>
      _remote.getPreferences();

  @override
  Future<NotificationPreferences> updatePreferences({
    bool? dailyHealthTips,
    bool? weeklyWellnessReminders,
  }) =>
      _remote.updatePreferences(
        dailyHealthTips: dailyHealthTips,
        weeklyWellnessReminders: weeklyWellnessReminders,
      );
}
