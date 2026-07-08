import 'package:dio/dio.dart';

import '../constants/storage_keys.dart';
import '../services/secure_storage_service.dart';

class AuthInterceptor
    extends Interceptor {
  AuthInterceptor(this.storage);

  final SecureStorageService storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token =
        await storage.read(
      StorageKeys.token,
    );

    if (token != null) {
      options.headers["Authorization"] =
          "Bearer $token";
    }

    handler.next(options);
  }
}