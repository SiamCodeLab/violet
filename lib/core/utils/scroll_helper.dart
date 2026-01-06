import 'package:flutter/material.dart';
import 'dart:async';

/// ============================================
/// SCROLL HELPER - WORKS ON ALL PLATFORMS
/// ============================================

class ScrollHelper {
  /// Scroll to bottom with safety checks
  static void scrollToBottom(
    ScrollController controller, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeOut,
  }) {
    // Check if controller is attached
    if (!controller.hasClients) {
      debugPrint('[ScrollHelper] No clients attached');
      return;
    }

    // Use Timer instead of addPostFrameCallback for Windows compatibility
    Timer(const Duration(milliseconds: 100), () {
      if (!controller.hasClients) return;

      try {
        final maxExtent = controller.position.maxScrollExtent;

        if (maxExtent <= 0) {
          debugPrint('[ScrollHelper] Nothing to scroll');
          return;
        }

        controller.animateTo(maxExtent, duration: duration, curve: curve);
      } catch (e) {
        debugPrint('[ScrollHelper] Error: $e');
        // Fallback: try jumpTo
        _fallbackScroll(controller);
      }
    });
  }

  /// Instant scroll to bottom (no animation)
  static void jumpToBottom(ScrollController controller) {
    if (!controller.hasClients) return;

    Timer(const Duration(milliseconds: 50), () {
      if (!controller.hasClients) return;

      try {
        controller.jumpTo(controller.position.maxScrollExtent);
      } catch (e) {
        debugPrint('[ScrollHelper] Jump error: $e');
      }
    });
  }

  /// Fallback scroll method
  static void _fallbackScroll(ScrollController controller) {
    try {
      if (controller.hasClients && controller.position.hasContentDimensions) {
        controller.jumpTo(controller.position.maxScrollExtent);
      }
    } catch (e) {
      debugPrint('[ScrollHelper] Fallback also failed: $e');
    }
  }

  /// Safe scroll with multiple retries (for dynamic content)
  static void scrollToBottomWithRetry(
    ScrollController controller, {
    int retries = 3,
    Duration delay = const Duration(milliseconds: 150),
  }) {
    _scrollWithRetry(controller, retries, delay);
  }

  static void _scrollWithRetry(
    ScrollController controller,
    int remainingRetries,
    Duration delay,
  ) {
    if (remainingRetries <= 0) return;

    Timer(delay, () {
      if (!controller.hasClients) {
        _scrollWithRetry(controller, remainingRetries - 1, delay);
        return;
      }

      try {
        if (controller.position.hasContentDimensions) {
          controller.animateTo(
            controller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollWithRetry(controller, remainingRetries - 1, delay);
        }
      } catch (e) {
        _scrollWithRetry(controller, remainingRetries - 1, delay);
      }
    });
  }
}
