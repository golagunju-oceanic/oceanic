class NotificationPreferences {
  const NotificationPreferences({
    required this.dailyHealthTips,
    required this.weeklyWellnessReminders,
  });

  final bool dailyHealthTips;
  final bool weeklyWellnessReminders;

  /// Controls both types of health-related push notification.
  /// It is NOT a device-wide notification permission switch.
  bool get healthNotificationsEnabled =>
      dailyHealthTips || weeklyWellnessReminders;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    final daily = json['dailyHealthTips'];
    final weekly = json['weeklyWellnessReminders'];

    if (daily is! bool || weekly is! bool) {
      throw const FormatException('Invalid notification preferences response.');
    }

    return NotificationPreferences(
      dailyHealthTips: daily,
      weeklyWellnessReminders: weekly,
    );
  }
}
