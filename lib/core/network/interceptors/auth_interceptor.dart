import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:school_bus_tracker/core/network/api_endpoints.dart';
import 'package:school_bus_tracker/core/storage/storage_services.dart';
import 'package:school_bus_tracker/routes/router_config.dart';
import 'package:school_bus_tracker/routes/router_constants.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final StorageService _storageService = StorageService.instance;

  Completer<String?>? _refreshCompleter;

  AuthInterceptor(this.dio);

  bool _isRefreshApi(String path, Uri uri) {
    return path.contains(ApiEndpoints.refreshToken) ||
        uri.path.contains(ApiEndpoints.refreshToken);
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
          final newToken = await _refreshToken();
          if (newToken != null && newToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $newToken';
          } else {
            await _handleForceLogout();
          }
        } catch (e) {
          await _handleForceLogout();
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
        final newToken = await _refreshToken();

        if (newToken == null) {
          await _handleForceLogout();
          return handler.next(response);
        }

        final request = response.requestOptions;
        request.headers['Authorization'] = 'Bearer $newToken';

        final retriedResponse = await dio.fetch(request);
        return handler.resolve(retriedResponse);
      } catch (e, stack) {
        log('REFRESH FAILED IN ON_RESPONSE', error: e, stackTrace: stack, name: 'API_SERVICE');
        await _handleForceLogout();
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
      await _handleForceLogout();
      return handler.next(err);
    }

    if (err.response?.statusCode == 401) {
      try {
        final newToken = await _refreshToken();

        if (newToken == null) {
          await _handleForceLogout();
          return handler.next(err);
        }

        final request = err.requestOptions;
        request.headers['Authorization'] = 'Bearer $newToken';

        final retriedResponse = await dio.fetch(request);
        return handler.resolve(retriedResponse);
      } catch (e, stack) {
        log('REFRESH FAILED IN ON_ERROR', error: e, stackTrace: stack, name: 'API_SERVICE');
        await _handleForceLogout();
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  Future<String?> _refreshToken() async {
    // If a refresh is already in progress, wait for its completion
    if (_refreshCompleter != null) {
      return await _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<String?>();

    try {
      final refreshToken = await _storageService.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        log('NO REFRESH TOKEN AVAILABLE', name: 'API_SERVICE');
        _refreshCompleter!.complete(null);
        return null;
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
          _refreshCompleter!.complete(newAccessToken);
          return newAccessToken;
        }
      }

      log('REFRESH API RETURNED NON-OK STATUS', name: 'API_SERVICE');
      _refreshCompleter!.complete(null);
      return null;
    } catch (e, stack) {
      log('EXCEPTION DURING TOKEN REFRESH', error: e, stackTrace: stack, name: 'API_SERVICE');
      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete(null);
      }
      return null;
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
