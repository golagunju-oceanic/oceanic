import 'package:dio/dio.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  

  Future<Response> get(
    String path,
  ) {
    return _dio.get(path);
  }

  Future<Response> post(
    String path, {
    dynamic body,
  }) {
    return _dio.post(
      path,
      data: body,
    );
  }

  Future<Response> put(
    String path, {
    dynamic body,
  }) {
    return _dio.put(
      path,
      data: body,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic body,
  }) {
    return _dio.patch(
      path,
      data: body,
    );
  }

  Future<Response> delete(
    String path,
  ) {
    return _dio.delete(path);
  }
}