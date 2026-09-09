import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:school_bus_tracker/core/network/api_endpoints.dart';
import 'package:school_bus_tracker/core/storage/storage_services.dart';
import 'package:school_bus_tracker/routes/router_config.dart';
import 'package:school_bus_tracker/routes/router_constants.dart';

class _RefreshResult {
  final String? token;
  final bool isAuthError;

  const _RefreshResult({this.token, required this.isAuthError});
}

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final StorageService _storageService = StorageService.instance;

  Completer<_RefreshResult>? _refreshCompleter;

  AuthInterceptor(this.dio);

  bool _isRefreshApi(String path, Uri uri) {
    return path.contains(ApiEndpoints.refreshToken) ||
        uri.path.contains(ApiEndpoints.refreshToken);
  }

  bool _isNetworkException(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.unknown;
    }
    final str = error.toString().toLowerCase();
    return str.contains('socketexception') ||
        str.contains('connection refused') ||
        str.contains('connection error') ||
        str.contains('network is unreachable') ||
        str.contains('failed host lookup') ||
        str.contains('handshakeexception');
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageService.getToken();
    final isRefresh = _isRefreshApi(options.path, options.uri);

    log('================ REQUEST ================', name: 'API_SERVICE');
    log('URL => ${options.uri}', name: 'API_SERVICE');

    if (!isRefresh && token != null && token.isNotEmpty) {
      if (_isTokenExpired(token)) {
        log('ACCESS TOKEN EXPIRED, TRYING REFRESH PRE-EMPTIVELY', name: 'API_SERVICE');
        try {
          final result = await _refreshToken();
          if (result.token != null && result.token!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${result.token}';
          } else if (result.isAuthError) {
            await _handleForceLogout();
          } else {
            // Network failure / offline: keep existing token so request proceeds without wiping login
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } else {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    options.headers['Content-Type'] =
        options.data is FormData ? 'multipart/form-data' : 'application/json';

    log('HEADERS => ${options.headers}', name: 'API_SERVICE');
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    debugPrint('${response.statusCode} ${response.requestOptions.uri}');

    final isRefresh = _isRefreshApi(
      response.requestOptions.path,
      response.requestOptions.uri,
    );

    if (!isRefresh && response.statusCode == 401) {
      log('401 STATUS RECEIVED IN RESPONSE', name: 'API_SERVICE');
      try {
        final result = await _refreshToken();

        if (result.token != null && result.token!.isNotEmpty) {
          final request = response.requestOptions;
          request.headers['Authorization'] = 'Bearer ${result.token}';

          final retriedResponse = await dio.fetch(request);
          return handler.resolve(retriedResponse);
        } else if (result.isAuthError) {
          await _handleForceLogout();
          return handler.next(response);
        } else {
          return handler.next(response);
        }
      } catch (e, stack) {
        log('REFRESH FAILED IN ON_RESPONSE', error: e, stackTrace: stack, name: 'API_SERVICE');
        return handler.next(response);
      }
    }

    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isRefresh = _isRefreshApi(
      err.requestOptions.path,
      err.requestOptions.uri,
    );

    log('================ ERROR ================', name: 'API_SERVICE');
    log('URL => ${err.requestOptions.uri}', name: 'API_SERVICE');
    log('STATUS => ${err.response?.statusCode}', name: 'API_SERVICE');

    // Prevent infinite loop if refresh API itself fails
    if (isRefresh) {
      log('REFRESH API FAILED', name: 'API_SERVICE');
      final statusCode = err.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        await _handleForceLogout();
      }
      return handler.next(err);
    }

    if (err.response?.statusCode == 401) {
      try {
        final result = await _refreshToken();

        if (result.token != null && result.token!.isNotEmpty) {
          final request = err.requestOptions;
          request.headers['Authorization'] = 'Bearer ${result.token}';

          final retriedResponse = await dio.fetch(request);
          return handler.resolve(retriedResponse);
        } else if (result.isAuthError) {
          await _handleForceLogout();
          return handler.next(err);
        } else {
          return handler.next(err);
        }
      } catch (e, stack) {
        log('REFRESH FAILED IN ON_ERROR', error: e, stackTrace: stack, name: 'API_SERVICE');
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  Future<_RefreshResult> _refreshToken() async {
    // If a refresh is already in progress, wait for its completion
    if (_refreshCompleter != null) {
      return await _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<_RefreshResult>();

    try {
      final refreshToken = await _storageService.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        log('NO REFRESH TOKEN AVAILABLE', name: 'API_SERVICE');
        const res = _RefreshResult(token: null, isAuthError: true);
        _refreshCompleter!.complete(res);
        return res;
      }

      log('CALLING REFRESH TOKEN API', name: 'API_SERVICE');

      final response = await dio.post(
        ApiEndpoints.refreshToken,
        data: {"refreshToken": refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newAccessToken = response.data['token'] as String?;
        final newRefreshToken = response.data['refreshToken'] as String?;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await _storageService.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken ?? refreshToken,
          );

          log('REFRESH TOKEN SUCCESSFUL', name: 'API_SERVICE');
          final res = _RefreshResult(token: newAccessToken, isAuthError: false);
          _refreshCompleter!.complete(res);
          return res;
        }
      }

      final isAuthError = response.statusCode == 401 ||
          response.statusCode == 403 ||
          (response.statusCode != null && response.statusCode! >= 400 && response.statusCode! < 500);

      log('REFRESH API RETURNED STATUS: ${response.statusCode}, isAuthError: $isAuthError', name: 'API_SERVICE');
      final res = _RefreshResult(token: null, isAuthError: isAuthError);
      _refreshCompleter!.complete(res);
      return res;
    } catch (e, stack) {
      log('EXCEPTION DURING TOKEN REFRESH', error: e, stackTrace: stack, name: 'API_SERVICE');
      final isNetwork = _isNetworkException(e);
      final res = _RefreshResult(token: null, isAuthError: !isNetwork);
      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete(res);
      }
      return res;
    } finally {
      _refreshCompleter = null;
    }
  }

  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      String normalized = parts[1];
      switch (normalized.length % 4) {
        case 2:
          normalized += '==';
          break;
        case 3:
          normalized += '=';
          break;
      }

      final payloadString = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> payload = jsonDecode(payloadString);

      if (payload.containsKey('exp')) {
        final exp = payload['exp'];
        if (exp is int) {
          final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
          return DateTime.now().add(const Duration(seconds: 10)).isAfter(expiryDate);
        }
      }
    } catch (e) {
      debugPrint('Error decoding JWT: $e');
    }
    return false;
  }

  Future<void> _handleForceLogout() async {
    log('FORCE LOGOUT: Clearing storage and routing to login', name: 'API_SERVICE');
    await _storageService.clearAll();
    appRouter.goNamed(RouterConstants.loginScreen);
  }
}
