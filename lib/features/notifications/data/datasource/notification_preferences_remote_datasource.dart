import 'package:dio/dio.dart';

import '../../domain/entities/notification_preferences.dart';

typedef NotificationGet = Future<Response<dynamic>> Function(String path);
typedef NotificationPatch = Future<Response<dynamic>> Function(
  String path,
  Map<String, dynamic> body,
);

class NotificationPreferencesRemoteDataSource {
  NotificationPreferencesRemoteDataSource({
    required NotificationGet get,
    required NotificationPatch patch,
  })  : _get = get,
        _patch = patch;

  final NotificationGet _get;
  final NotificationPatch _patch;

  // Dio baseUrl already includes /api.
  static const String _path = '/notifications/preferences';

  Future<NotificationPreferences> getPreferences() async {
    final response = await _get(_path);
    return _parseResponse(response);
  }

  Future<NotificationPreferences> updatePreferences({
    bool? dailyHealthTips,
    bool? weeklyWellnessReminders,
  }) async {
    if (dailyHealthTips == null && weeklyWellnessReminders == null) {
      throw ArgumentError('At least one preference must be supplied.');
    }

    final body = <String, dynamic>{
      if (dailyHealthTips != null) 'dailyHealthTips': dailyHealthTips,
      if (weeklyWellnessReminders != null)
        'weeklyWellnessReminders': weeklyWellnessReminders,
    };

    final response = await _patch(_path, body);
    return _parseResponse(response);
  }

  NotificationPreferences _parseResponse(Response<dynamic> response) {
    final envelope = response.data;
    if (envelope is! Map || envelope['success'] != true) {
      throw const FormatException('Notification preferences request failed.');
    }

    final rawData = envelope['data'];
    if (rawData is! Map) {
      throw const FormatException('Missing notification preferences data.');
    }

    return NotificationPreferences.fromJson(
      Map<String, dynamic>.from(rawData),
    );
  }
}
