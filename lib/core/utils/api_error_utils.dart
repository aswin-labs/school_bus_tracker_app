class ApiErrorUtils {
  static String getErrorMessage({
    required dynamic data,
    required String defaultMessage,
    int? statusCode,
  }) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];

      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (statusCode == null || statusCode == 0) {
      return defaultMessage;
    }

    return '$defaultMessage (status: $statusCode)';
  }

  static String getExceptionErrorMessage(
    dynamic error, {
    String defaultMessage = 'Something went wrong. Try again.',
  }) {
    final str = error.toString().toLowerCase();
    if (str.contains('socketexception') ||
        str.contains('connection error') ||
        str.contains('connection refused') ||
        str.contains('connection timeout') ||
        str.contains('network is unreachable') ||
        str.contains('failed host lookup') ||
        str.contains('handshakeexception') ||
        str.contains('clientexception')) {
      return 'No internet connection. Please check your network and try again.';
    }
    return defaultMessage;
  }
}
