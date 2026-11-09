import '../entities/notification_preferences.dart';

abstract class NotificationPreferencesRepository {
  Future<NotificationPreferences> getPreferences();

  Future<NotificationPreferences> updatePreferences({
    bool? dailyHealthTips,
    bool? weeklyWellnessReminders,
  });
}
