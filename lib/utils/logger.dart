import 'package:flutter/foundation.dart';

class Logger {
  static void debug(String message, [String? tag]) {
    _log('DEBUG', message, tag);
  }

  static void info(String message, [String? tag]) {
    _log('INFO', message, tag);
  }

  static void warning(String message, [String? tag]) {
    _log('WARNING', message, tag);
  }

  static void error(
    String message, [
    dynamic error,
    StackTrace? stackTrace,
    String? tag,
  ]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      final sanitized = _sanitize(message);
      print('[ERROR] $prefix$sanitized');
      if (error != null) {
        print('[ERROR] ${prefix}Error: $error');
      }
      if (stackTrace != null) {
        print('[ERROR] ${prefix}StackTrace: $stackTrace');
      }
    }
  }

  static void _log(String level, String message, String? tag) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      final sanitized = _sanitize(message);
      print('[$level] $prefix$sanitized');
    }
  }

  static String _sanitize(String message) {
    return message.replaceAll(
      RegExp(r'(password|token|key|secret|apiKey)=([^\s&]+)', caseSensitive: false),
      r'$1=***',
    );
  }
}
