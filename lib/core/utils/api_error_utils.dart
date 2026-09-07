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

    return '$defaultMessage'
        '${statusCode != null ? ' (status: $statusCode)' : ''}';
  }
}
