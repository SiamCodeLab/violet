import 'package:flutter/foundation.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CONSOLE
/// Enhanced console logging utility with colors
/// Usage: Console.info('message'), Console.error('message'), etc.
/// ═══════════════════════════════════════════════════════════════════════════
class Console {
  // ANSI Color Codes
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _white = '\x1B[37m';
  static const String _grey = '\x1B[90m';

  // ─────────────────────────────────────────────────────────────────────────
  // Standard Logs
  // ─────────────────────────────────────────────────────────────────────────

  /// Info log (Cyan) - General information
  static void info(String message) {
    _log('INFO', _cyan, message);
  }

  /// Success log (Green) - Successful operations
  static void success(String message) {
    _log('SUCCESS', _green, message);
  }

  /// Warning log (Yellow) - Warnings
  static void warning(String message) {
    _log('WARNING', _yellow, message);
  }

  /// Error log (Red) - Errors
  static void error(String message) {
    _log('ERROR', _red, message);
  }

  /// Debug log (Blue) - Debug information
  static void debug(String message) {
    _log('DEBUG', _blue, message);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Category-specific Logs
  // ─────────────────────────────────────────────────────────────────────────

  /// API request/response log (Magenta)
  static void api(String message) {
    _log('API', _magenta, message);
  }

  /// Network log (Blue)
  static void network(String message) {
    _log('NETWORK', _blue, message);
  }

  /// Auth related log (Cyan)
  static void auth(String message) {
    _log('AUTH', _cyan, message);
  }

  /// Storage related log (White)
  static void storage(String message) {
    _log('STORAGE', _white, message);
  }

  /// Navigation log (Magenta)
  static void nav(String message) {
    _log('NAV', _magenta, message);
  }

  /// UI related log (Grey)
  static void ui(String message) {
    _log('UI', _grey, message);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Legacy Support (Backward Compatibility)
  // ─────────────────────────────────────────────────────────────────────────

  static void red(String text) => error(text);
  static void green(String text) => success(text);
  static void yellow(String text) => warning(text);
  static void blue(String text) => debug(text);
  static void magenta(String text) => api(text);
  static void cyan(String text) => info(text);

  // ─────────────────────────────────────────────────────────────────────────
  // Visual Dividers
  // ─────────────────────────────────────────────────────────────────────────

  /// Print divider line
  static void divider({String? label}) {
    if (kDebugMode) {
      if (label != null) {
        debugPrint('$_cyan══════════════ $label ══════════════$_reset');
      } else {
        debugPrint('$_cyan════════════════════════════════════════$_reset');
      }
    }
  }

  /// Print section start
  static void sectionStart(String name) {
    if (kDebugMode) {
      debugPrint('$_cyan┌───────────── $name ─────────────┐$_reset');
    }
  }

  /// Print section end
  static void sectionEnd(String name) {
    if (kDebugMode) {
      debugPrint('$_cyan└───────────── $name ─────────────┘$_reset');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Object Logging
  // ─────────────────────────────────────────────────────────────────────────

  /// Log object/map with formatting
  static void object(String label, dynamic obj) {
    if (kDebugMode) {
      debugPrint('$_cyan[$label]$_reset');
      debugPrint('$obj');
    }
  }

  /// Log list items
  static void list(String label, List items) {
    if (kDebugMode) {
      debugPrint('$_cyan[$label] (${items.length} items)$_reset');
      for (var i = 0; i < items.length; i++) {
        debugPrint('  [$i] ${items[i]}');
      }
    }
  }

  /// Log map with key-value pairs
  static void map(String label, Map<String, dynamic> data) {
    if (kDebugMode) {
      debugPrint('$_cyan[$label]$_reset');
      data.forEach((key, value) {
        debugPrint('  $key: $value');
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Helper
  // ─────────────────────────────────────────────────────────────────────────

  static void _log(String tag, String color, String message) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toString().substring(11, 23);
      debugPrint('$color[$tag] $timestamp | $message$_reset');
    }
  }
}