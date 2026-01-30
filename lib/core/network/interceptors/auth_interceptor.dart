import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:school_bus_tracker/core/storage/storage_services.dart';

class AuthInterceptor extends Interceptor {
  final StorageService _storageService = StorageService.instance;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageService.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Content-Type'] =
        options.data is FormData ? 'multipart/form-data' : 'application/json';

    debugPrint('${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint('${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    debugPrint('${err.response?.statusCode} ${err.message}');
    handler.next(err);
  }
}
