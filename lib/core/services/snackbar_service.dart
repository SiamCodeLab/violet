import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SNACKBAR SERVICE
/// Desktop → GetX snackbar (top-center, native top support)
/// Mobile  → ScaffoldMessenger (bottom)
/// ═══════════════════════════════════════════════════════════════════════════
class SnackbarService {
  // ─────────────────────────────────────────────────────────────────────────
  // Platform
  // ─────────────────────────────────────────────────────────────────────────

  static bool get _isDesktop =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  // ─────────────────────────────────────────────────────────────────────────
  // Responsive helpers
  // ─────────────────────────────────────────────────────────────────────────

  static double get _snackWidth {
    const preferred = 700.0;
    final screen = Get.width;
    return screen < preferred + 32 ? screen - 32 : preferred;
  }

  static EdgeInsets get _snackMargin {
    final w = _snackWidth;
    final hPad = (Get.width - w) / 2;
    return EdgeInsets.only(top: 60, left: hPad, right: hPad);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Colors — Apple HIG
  // ─────────────────────────────────────────────────────────────────────────

  static const _success = Color(0xFF34C759);
  static const _error = Color(0xFFFF3B30);
  static const _warning = Color(0xFFFF9500);
  static const _info = Color(0xFF007AFF);
  static const _neutral = Color(0xFF8E8E93);

  // ─────────────────────────────────────────────────────────────────────────
  // Core
  // ─────────────────────────────────────────────────────────────────────────

  static void _show(
    String message, {
    required Color accentColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
    bool isLoading = false,
  }) {
    if (_isDesktop) {
      _showGetX(
        message: message,
        icon: icon,
        accentColor: accentColor,
        duration: duration,
        isLoading: isLoading,
      );
    } else {
      _showScaffold(
        message: message,
        icon: icon,
        accentColor: accentColor,
        duration: duration,
        isLoading: isLoading,
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Desktop → GetX snackbar (SnackPosition.TOP)
  // ─────────────────────────────────────────────────────────────────────────

  static void _showGetX({
    required String message,
    required IconData icon,
    required Color accentColor,
    required Duration duration,
    bool isLoading = false,
  }) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.showSnackbar(
      GetSnackBar(
        messageText: _ToastCard(
          message: message,
          icon: icon,
          accentColor: accentColor,
          isLoading: isLoading,
          maxWidth: _snackWidth,
        ),
        snackPosition: SnackPosition.TOP,
        margin: _snackMargin,
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        boxShadows: const [],
        borderRadius: 0,
        duration: duration,
        animationDuration: const Duration(milliseconds: 380),
        forwardAnimationCurve: Curves.easeOutCubic,
        reverseAnimationCurve: Curves.easeInCubic,
        isDismissible: true,
        maxWidth: _snackWidth,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mobile → ScaffoldMessenger (bottom)
  // ─────────────────────────────────────────────────────────────────────────

  static void _showScaffold({
    required String message,
    required IconData icon,
    required Color accentColor,
    required Duration duration,
    bool isLoading = false,
  }) {
    final context = Get.context;
    if (context == null) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 0, 16, Get.height * 0.10),
        duration: duration,
        content: _AnimatedToast(
          message: message,
          icon: icon,
          accentColor: accentColor,
          isLoading: isLoading,
          maxWidth: Get.width - 32,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────────────────

  static void success(String message) =>
      _show(message, accentColor: _success, icon: Icons.check_circle_rounded);

  static void error(String message) => _show(
    message,
    accentColor: _error,
    icon: Icons.cancel_rounded,
    duration: const Duration(seconds: 4),
  );

  static void warning(String message) =>
      _show(message, accentColor: _warning, icon: Icons.error_rounded);

  static void info(String message) =>
      _show(message, accentColor: _info, icon: Icons.info_rounded);

  static void show(String message) =>
      _show(message, accentColor: _neutral, icon: Icons.notifications_rounded);

  // ─────────────────────────────────────────────────────────────────────────
  // Loading
  // ─────────────────────────────────────────────────────────────────────────

  static void loading(String message) => _show(
    message,
    accentColor: _neutral,
    icon: Icons.notifications_rounded,
    duration: const Duration(minutes: 5),
    isLoading: true,
  );

  static void hideLoading() {
    if (_isDesktop) {
      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    } else {
      final context = Get.context;
      if (context == null) return;
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // With context
  // ─────────────────────────────────────────────────────────────────────────

  static void showWithContext(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    _show(
      message,
      accentColor: isError ? _error : _success,
      icon: isError ? Icons.cancel_rounded : Icons.check_circle_rounded,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Confirm dialog
  // ─────────────────────────────────────────────────────────────────────────

  static Future<bool> confirm({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDanger = false,
  }) async {
    final result = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _isDesktop ? 380 : double.infinity,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: (isDanger ? _error : _info).withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDanger
                        ? Icons.delete_outline_rounded
                        : Icons.help_outline_rounded,
                    color: isDanger ? _error : _info,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
                    height: 1.5,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 24),
                Container(height: 0.5, color: const Color(0xFFE5E5EA)),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _SheetBtn(
                          label: cancelText,
                          onTap: () => Get.back(result: false),
                          color: const Color(0xFF007AFF),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Container(width: 0.5, color: const Color(0xFFE5E5EA)),
                      Expanded(
                        child: _SheetBtn(
                          label: confirmText,
                          onTap: () => Get.back(result: true),
                          color: isDanger ? _error : const Color(0xFF007AFF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.20),
    );
    return result ?? false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Loading dialog
  // ─────────────────────────────────────────────────────────────────────────

  static void showLoadingDialog({String? message}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF007AFF),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E8E93),
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.15),
    );
  }

  static void hideLoadingDialog() {
    if (Get.isDialogOpen ?? false) Get.back();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TOAST CARD — shared visual, used by both desktop and mobile
// Grows with text, capped at maxWidth, never overflows
// ═══════════════════════════════════════════════════════════════════════════

class _ToastCard extends StatelessWidget {
  const _ToastCard({
    required this.message,
    required this.icon,
    required this.accentColor,
    required this.isLoading,
    required this.maxWidth,
  });

  final String message;
  final IconData icon;
  final Color accentColor;
  final bool isLoading;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    // Outer Row centers the pill horizontally inside GetX's full-width slot
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ConstrainedBox(
          // Never wider than maxWidth, but shrinks to fit short text
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.09),
                  blurRadius: 28,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              // min = shrinks to hug text; Flexible below lets it wrap
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF007AFF),
                      strokeCap: StrokeCap.round,
                    ),
                  )
                else
                  Icon(icon, color: accentColor, size: 20),
                const SizedBox(width: 8),
                // Flexible allows text to wrap when it hits maxWidth
                Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.2,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATED TOAST — mobile only, slides up from bottom
// ═══════════════════════════════════════════════════════════════════════════

class _AnimatedToast extends StatefulWidget {
  const _AnimatedToast({
    required this.message,
    required this.icon,
    required this.accentColor,
    required this.isLoading,
    required this.maxWidth,
  });

  final String message;
  final IconData icon;
  final Color accentColor;
  final bool isLoading;
  final double maxWidth;

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: _ToastCard(
          message: widget.message,
          icon: widget.icon,
          accentColor: widget.accentColor,
          isLoading: widget.isLoading,
          maxWidth: widget.maxWidth,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHEET BUTTON
// ═══════════════════════════════════════════════════════════════════════════

class _SheetBtn extends StatelessWidget {
  const _SheetBtn({
    required this.label,
    required this.onTap,
    required this.color,
    required this.fontWeight,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 48,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: fontWeight,
              color: color,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
