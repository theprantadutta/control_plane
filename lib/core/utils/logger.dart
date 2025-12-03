import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Log levels
enum LogLevel { debug, info, warning, error }

/// Simple logging utility
class AppLogger {
  static const String _tag = 'ControlPlane';

  static void debug(String message, [String? tag]) {
    _log(LogLevel.debug, message, tag);
  }

  static void info(String message, [String? tag]) {
    _log(LogLevel.info, message, tag);
  }

  static void warning(String message, [String? tag]) {
    _log(LogLevel.warning, message, tag);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    _log(LogLevel.error, message, tag);
    if (error != null) {
      _log(LogLevel.error, 'Error: $error', tag);
    }
    if (stackTrace != null && kDebugMode) {
      _log(LogLevel.error, 'StackTrace: $stackTrace', tag);
    }
  }

  static void _log(LogLevel level, String message, String? tag) {
    final prefix = _levelPrefix(level);
    final logTag = tag ?? _tag;
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final logMessage = '[$timestamp] $prefix [$logTag] $message';

    if (kDebugMode) {
      developer.log(logMessage, name: _tag);
    }

    // Also print to console for easier debugging
    // ignore: avoid_print
    print(logMessage);
  }

  static String _levelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }
}
