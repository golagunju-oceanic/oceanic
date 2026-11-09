import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Preserved for compatibility with your current main.dart.
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'oceanic_health_updates_v1',
    'Oceanic Health Updates',
    description: 'Health tips and wellness reminders',
    importance: Importance.high,
    playSound: true,
  );

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenSubscription;

  bool _initialized = false;

  // ======================================================
  // INITIALIZATION
  // ======================================================

  Future<void> sendLocalTestNotification() async {
    try {
      debugPrint('Starting local notification test...');

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      final permissionGranted = await androidPlugin
          ?.requestNotificationsPermission();

      debugPrint('Android notification permission: $permissionGranted');

      if (permissionGranted == false) {
        debugPrint(
          'Notifications are disabled. Enable them in Android Settings.',
        );
        return;
      }

      await _localNotifications.show(
        1001,
        'Oceanic Health Test',
        'This is a test system notification from Oceanic.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'oceanic_health_updates_v1',
            'Oceanic Health Updates',
            channelDescription: 'Health tips and wellness reminders',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
      );

      debugPrint('Local notification show() completed.');
    } catch (error, stackTrace) {
      debugPrint('LOCAL NOTIFICATION ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;

    _initialized = true;

    try {
      if (!kIsWeb) {
        const initializationSettings = InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        );

        await _localNotifications.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: (response) {
            debugPrint('Local notification opened: ${response.payload}');

            // Notification navigation will be implemented
            // after checking the authenticated enrollee.
          },
        );

        // Android notification channel.
        if (defaultTargetPlatform == TargetPlatform.android) {
          await _localNotifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.createNotificationChannel(_channel);
        }

        // On iOS, Firebase itself displays foreground
        // notifications using these presentation options.
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          await _messaging.setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
        }
      }

      // Request push notification permission.
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('Notification permission: ${settings.authorizationStatus}');

      // Listen for messages when Oceanic is open.
      _foregroundSubscription = FirebaseMessaging.onMessage.listen((message) {
        unawaited(_handleForegroundMessage(message));
      });

      // Listen for FCM notification taps.
      _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        _handleNotificationTap,
      );

      // Listen for refreshed FCM registration tokens.
      _tokenSubscription = _messaging.onTokenRefresh.listen((token) {
        debugPrint('FCM registration token refreshed.');

        // Later: register the updated token with Node.js.
      });

      final initialMessage = await _messaging.getInitialMessage();

      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      final authorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      if (authorized) {
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
          final apnsToken = await _messaging.getAPNSToken();

          if (apnsToken != null) {
            await getDeviceToken();
          } else {
            debugPrint('APNs token is not ready yet.');
          }
        } else if (!kIsWeb) {
          await getDeviceToken();
        }
      }

      debugPrint('Oceanic notification service initialized.');
    } catch (error) {
      _initialized = false;
      debugPrint('Notification initialization error: $error');
    }
  }

  // ======================================================
  // FOREGROUND SYSTEM NOTIFICATION
  // ======================================================

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground FCM message received: ${message.messageId}');

    final notification = message.notification;

    // Don't display silent/data-only messages as visible alerts.
    if (notification == null) {
      debugPrint('Data-only FCM message received.');
      return;
    }

    // iOS foreground alerts are handled by Firebase's
    // notification presentation options.
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
        notification.title ?? 'Oceanic Health',
        notification.body ?? 'You have a new notification.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'oceanic_health_updates_v1',
            'Oceanic Health Updates',
            channelDescription: 'Health tips and wellness reminders',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        payload: message.data['type']?.toString(),
      );

      debugPrint('System notification displayed.');
    } catch (error) {
      debugPrint('Unable to display notification: $error');
    }
  }

  // ======================================================
  // FCM TOKEN
  // ======================================================

  Future<String?> getDeviceToken() async {
    try {
      final token = await _messaging.getToken();

      if (token != null && kDebugMode) {
        debugPrint('OCEANIC FCM TEST TOKEN: $token');
      }

      return token;
    } catch (error) {
      debugPrint('FCM token error: $error');
      return null;
    }
  }

  // ======================================================
  // NOTIFICATION TAP
  // ======================================================

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('FCM notification opened: ${message.messageId}');

    final type = message.data['type'];

    if (type == 'health_tip') {
      // Future: navigate to Health Tips.
    } else if (type == 'wellness_reminder') {
      // Future: navigate to Wellness.
    }
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _tokenSubscription?.cancel();

    _initialized = false;
  }
}
