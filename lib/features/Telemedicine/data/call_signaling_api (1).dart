// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:oceanic/features/Telemedicine/data/models/telemedicine_model.dart';
// import 'package:oceanic/features/Telemedicine/presentation/provider/telemedicine_booking_provider.dart';

// import '../domain/entities/telemedicine_entities.dart';


// class OceanicCall {
//   const OceanicCall({
//     required this.id,
//     required this.appointmentId,
//     required this.type,
//     required this.status,
//     required this.expiresAt,
//   });
//   final String id;
//   final String appointmentId;
//   final String type;
//   final String status;
//   final DateTime expiresAt;

//   bool get isVideo => type.toUpperCase() == 'VIDEO';
//   bool get isRinging => status == 'RINGING' && DateTime.now().toUtc().isBefore(expiresAt);
//   bool get isAccepted => status == 'ACCEPTED';
//   bool get isTerminal => {'DECLINED', 'MISSED', 'CANCELLED', 'ENDED'}.contains(status);

//   factory OceanicCall.fromJson(Map<String, dynamic> json) => OceanicCall(
//     id: json['id'].toString(),
//     appointmentId: json['appointmentId'].toString(),
//     type: (json['type'] ?? 'VIDEO').toString(),
//     status: json['status'].toString(),
//     expiresAt: DateTime.parse(json['expiresAt'].toString()),
//   );
// }

// class CallSignalingApi {
//   const CallSignalingApi(this._dio);
//   final Dio _dio; // Same JWT-enabled Dio as bookings. Base URL ends in /api.
//   static const _root = '/telemedicine/calls';

//   Map<String, dynamic> _data(Response<dynamic> response) {
//     final envelope = response.data;
//     if (envelope is! Map || envelope['data'] is! Map) {
//       throw const FormatException('Invalid call server response');
//     }
//     return Map<String, dynamic>.from(envelope['data'] as Map);
//   }

//   Future<OceanicCall> ring(String appointmentId) async => OceanicCall.fromJson(
//     _data(await _dio.post('$_root/appointments/${Uri.encodeComponent(appointmentId)}/ring')),
//   );

//   Future<OceanicCall?> incoming() async {
//     final response = await _dio.get('$_root/incoming');
//     final body = response.data;
//     if (body is Map && body['data'] == null) return null;
//     return OceanicCall.fromJson(_data(response));
//   }

//   Future<OceanicCall> status(String id) async => OceanicCall.fromJson(
//     _data(await _dio.get('$_root/${Uri.encodeComponent(id)}')),
//   );

//   Future<OceanicCall> accept(String id) async => OceanicCall.fromJson(
//     _data(await _dio.post('$_root/${Uri.encodeComponent(id)}/accept')),
//   );
//   Future<OceanicCall> decline(String id) async => OceanicCall.fromJson(
//     _data(await _dio.post('$_root/${Uri.encodeComponent(id)}/decline')),
//   );
//   Future<OceanicCall> end(String id) async => OceanicCall.fromJson(
//     _data(await _dio.post('$_root/${Uri.encodeComponent(id)}/end')),
//   );

//   Future<TelemedicineAgoraSession> join(String id) async => TelemedicineAgoraSessionModel.fromJson(
//     _data(await _dio.post('$_root/${Uri.encodeComponent(id)}/join')),
//   );

//   Future<void> registerPush(String token, String platform) async {
//     await _dio.put('$_root/devices/fcm', data: {'token': token, 'platform': platform});
//   }

//   Future<void> unregisterPush(String token) async {
//     await _dio.delete('$_root/devices/fcm', data: {'token': token});
//   }
// }

// final callSignalingApiProvider = Provider<CallSignalingApi>((ref) =>
//   CallSignalingApi(ref.watch(telemedicineBookingDioProvider)));
