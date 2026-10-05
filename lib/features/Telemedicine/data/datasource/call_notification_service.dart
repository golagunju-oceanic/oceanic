import 'package:flutter/material.dart';
import 'package:oceanic/features/Telemedicine/presentation/view/imacoming_call_dialog.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


class CallNotificationService {
  static IO.Socket? _socket;

  /// Initialize socket when Doctor logs in
  static void initDoctorSocket({
    required String baseUrl, // e.g. "http://10.0.2.2:5000" for Android emulator
    required int doctorId,
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint("🔌 Doctor connected to WebSocket");
      // Join doctor's specific notification room
      _socket!.emit("join_doctor_room", doctorId);
    });

    // Listen for incoming call event from backend
    _socket!.on("incoming_call", (data) {
      debugPrint("📞 Incoming Call Event received: $data");

      final context = navigatorKey.currentContext;
      if (context == null) return;

      final channel = data['channel'] as String;
      final callType = (data['callType'] ?? 'video') as String;
      final caller = data['caller'] as Map<String, dynamic>?;
      final callerName = caller?['name'] ?? "Enrollee";

      // Show incoming call dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => IncomingCallDialog(
          channelName: channel,
          callerName: callerName,
          callType: callType,
        ),
      );
    });

    _socket!.onDisconnect((_) {
      debugPrint("🔌 Doctor disconnected from WebSocket");
    });
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}