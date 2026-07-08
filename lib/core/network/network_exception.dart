import 'package:dio/dio.dart';

class NetworkException
    implements Exception {
  final String message;

  NetworkException(this.message);

  factory NetworkException.fromDio(
      DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException(
          "Connection timeout",
        );

      case DioExceptionType.receiveTimeout:
        return NetworkException(
          "Request timeout",
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          "No internet connection",
        );

      case DioExceptionType.badResponse:
        return NetworkException(
          e.response?.data["message"] ??
              "Server error",
        );

      default:
        return NetworkException(
          "Something went wrong",
        );
    }
  }

  @override
  String toString() => message;
}