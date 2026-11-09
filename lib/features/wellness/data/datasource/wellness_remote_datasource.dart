import 'package:dio/dio.dart';

import '../models/wellness_benefit_model.dart';

typedef WellnessGetRequest = Future<Response<dynamic>> Function(String path);

class WellnessRemoteDatasource {
  final WellnessGetRequest _get;

  const WellnessRemoteDatasource({required WellnessGetRequest get})
    : _get = get;

  Future<WellnessBenefitsResponse> getWellnessBenefits() async {
    try {
      final response = await _get('/wellness/benefits');

      final responseData = response.data;

      if (responseData is! Map) {
        throw const FormatException(
          'Invalid response received from the wellness server.',
        );
      }

      final json = Map<String, dynamic>.from(responseData);

      return WellnessBenefitsResponse.fromJson(json);
    } on DioException catch (error) {
      final responseData = error.response?.data;

      if (responseData is Map) {
        final message =
            responseData['message'] ??
            responseData['detail'] ??
            responseData['error'];

        if (message is String && message.trim().isNotEmpty) {
          throw WellnessRemoteException(message);
        }
      }

      final statusCode = error.response?.statusCode;

      if (statusCode == 401) {
        throw const WellnessRemoteException(
          'Your session has expired. Please log in again.',
        );
      }

      if (statusCode == 403) {
        throw const WellnessRemoteException(
          'You do not have permission to access wellness benefits.',
        );
      }

      if (statusCode == 404) {
        throw const WellnessRemoteException(
          'Your wellness information could not be found.',
        );
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        throw const WellnessRemoteException(
          'Connection timed out. Please try again.',
        );
      }

      if (error.type == DioExceptionType.connectionError) {
        throw const WellnessRemoteException(
          'Unable to connect to the server. Check your internet connection.',
        );
      }

      throw const WellnessRemoteException(
        'Unable to load wellness benefits. Please try again.',
      );
    }
  }
}

class WellnessRemoteException implements Exception {
  final String message;

  const WellnessRemoteException(this.message);

  @override
  String toString() => message;
}
