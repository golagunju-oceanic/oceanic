import 'package:dio/dio.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic body}) {
    return _dio.post(path, data: body);
  }

  Future<Response> postme(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic body}) {
    return _dio.put(path, data: body);
  }

  Future<Response> patch(String path, {dynamic body}) {
    return _dio.patch(path, data: body);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }

  Future<Response> postFormData(String path, {required FormData body}) {
    return _dio.post(
      path,
      data: body,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
  }
}
