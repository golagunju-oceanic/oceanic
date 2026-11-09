import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

typedef RegisterFcmDevice =
    Future<void> Function(String token, String platform);

typedef UnregisterFcmDevice = Future<void> Function(String token);

class NotificationDeviceService {
  NotificationDeviceService({
    required this.registerDevice,
    required this.unregisterDevice,
  });

  final RegisterFcmDevice registerDevice;
  final UnregisterFcmDevice unregisterDevice;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  StreamSubscription<String>? _tokenSubscription;

  Future<void> _pending = Future<void>.value();

  String? _memberId;
  String? _registeredToken;

  bool _active = false;

  String? get _platform {
    if (kIsWeb) return null;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => null,
    };
  }

  // Start registering notifications for the
  // currently authenticated enrollee.
  Future<void> start({required String memberId}) async {
    if (memberId.trim().isEmpty) return;

    if (_memberId != memberId) {
      _registeredToken = null;
    }

    _memberId = memberId;
    _active = true;

    _tokenSubscription ??= _messaging.onTokenRefresh.listen((token) {
      unawaited(_registerToken(token));
    });

    await syncDevice();
  }

  // Obtain and register the current FCM token.
  Future<void> syncDevice() async {
    if (!_active || _memberId == null) return;

    if (_platform == null) {
      debugPrint('FCM registration: unsupported platform.');
      return;
    }

    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        final apnsToken = await _messaging.getAPNSToken();

        if (apnsToken == null) {
          debugPrint('FCM registration waiting for APNs token.');
          return;
        }
      }

      final token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint('FCM registration token unavailable.');
        return;
      }

      await _registerToken(token);
    } catch (error) {
      debugPrint('Unable to synchronize FCM device: $error');
    }
  }

  Future<void> _registerToken(String token) {
    final owner = _memberId;

    _pending = _pending
        .then((_) async {
          if (!_active ||
              owner == null ||
              owner != _memberId ||
              token.isEmpty) {
            return;
          }

          if (_registeredToken == token) return;

          await registerDevice(token, _platform!);

          // Handle logout while registration was in progress.
          if (!_active || owner != _memberId) {
            await unregisterDevice(token);
            return;
          }

          final previousToken = _registeredToken;

          _registeredToken = token;

          debugPrint('FCM device registered with Oceanic backend.');

          // Remove the previous token after the new one
          // has been registered successfully.
          if (previousToken != null && previousToken != token) {
            try {
              await unregisterDevice(previousToken);
            } catch (error) {
              debugPrint('Previous FCM token cleanup failed: $error');
            }
          }
        })
        .catchError((Object error, StackTrace stackTrace) {
          debugPrint('FCM device registration error: $error');
        });

    return _pending;
  }

  // Call before removing the JWT from secure storage.
  Future<void> stop() async {
    if (_memberId == null && _registeredToken == null) {
      return;
    }

    _active = false;
    _memberId = null;

    await _tokenSubscription?.cancel();
    _tokenSubscription = null;

    // Wait for any registration already in progress.
    await _pending;

    try {
      final token = _registeredToken ?? await _messaging.getToken();

      if (token != null && token.isNotEmpty) {
        await unregisterDevice(token);

        debugPrint('FCM device unregistered from Oceanic backend.');
      }
    } finally {
      _registeredToken = null;
    }
  }

  void dispose() {
    _active = false;
    _memberId = null;

    final subscription = _tokenSubscription;
    _tokenSubscription = null;

    if (subscription != null) {
      unawaited(subscription.cancel());
    }
  }
}
