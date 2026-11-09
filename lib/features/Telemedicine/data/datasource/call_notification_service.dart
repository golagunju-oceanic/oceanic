import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/Telemedicine/presentation/provider/telemedicine_provider.dart';
import 'package:oceanic/features/Telemedicine/presentation/screens/incoming_call_screen%20(1)%20(3).dart';
import 'package:oceanic/features/Telemedicine/presentation/viewmodel/telemedicine_viewmodel.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class CallNotificationService {
  static io.Socket? _socket;

  static void initDoctorSocket({
    required String baseUrl,
    required dynamic doctorId,
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    if (_socket != null && _socket!.connected) return;

    final uri = baseUrl.replaceAll(RegExp(r'/+$'), '');

    _socket = io.io(
      uri,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('Doctor socket connected. Joining room: doctor_$doctorId');
      _socket!.emit('join', 'doctor_$doctorId');
    });

    _socket!.on('incoming_call', (data) {
      debugPrint('Incoming consultation event received: $data');

      final context = navigatorKey.currentContext;
      if (context == null || data == null) return;

      final callId = data['callId']?.toString() ?? data['channel']?.toString();
      final callType = data['callType']?.toString().toUpperCase() ?? 'VIDEO';

      // 1. Read the ViewModel from Riverpod container using context
      final container = ProviderScope.containerOf(context);
      // NOTE: replace 'telemedicineProvider' with your provider variable name if named differently
      final viewModel = container.read(telemedicineViewModelProvider);

      if (callId != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => IncomingCallScreen(
              viewModel: viewModel, // <-- Pass the required viewModel here
              callId: callId,
              isVideo: callType == 'VIDEO',
            ),
          ),
        );
      }
    });

    _socket!.onDisconnect((_) {
      debugPrint('Doctor socket disconnected');
    });

    _socket!.onError((err) {
      debugPrint('Doctor socket error: $err');
    });
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
