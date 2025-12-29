import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:violet/core/const/app_colors.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SNACKBAR SERVICE
/// Centralized service for showing snackbars using ScaffoldMessenger
/// ═══════════════════════════════════════════════════════════════════════════
class SnackbarService {
  // ─────────────────────────────────────────────────────────────────────────
  // Private Helper - Show SnackBar
  // ─────────────────────────────────────────────────────────────────────────

  static void _showSnackBar(
    String message, {
    Color backgroundColor = AppColors.success,
    Color textColor = Colors.white,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    final context = Get.context;
    if (context == null) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: duration,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Success Snackbar
  // ─────────────────────────────────────────────────────────────────────────

  /// Show success snackbar (green)
  static void success(String message) {
    _showSnackBar(
      message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Error Snackbar
  // ─────────────────────────────────────────────────────────────────────────

  /// Show error snackbar (red)
  static void error(String message) {
    _showSnackBar(
      message,
      backgroundColor: AppColors.error,
      icon: Icons.error,
      duration: const Duration(seconds: 3),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Warning Snackbar
  // ─────────────────────────────────────────────────────────────────────────

  /// Show warning snackbar (orange)
  static void warning(String message) {
    _showSnackBar(
      message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Info Snackbar
  // ─────────────────────────────────────────────────────────────────────────

  /// Show info snackbar (blue)
  static void info(String message) {
    _showSnackBar(message, backgroundColor: AppColors.info, icon: Icons.info);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Simple Message
  // ─────────────────────────────────────────────────────────────────────────

  /// Show simple message (dark)
  static void show(String message) {
    _showSnackBar(message, backgroundColor: AppColors.textPrimary);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Loading Snackbar
  // ─────────────────────────────────────────────────────────────────────────

  /// Show loading snackbar
  static void loading(String message) {
    final context = Get.context;
    if (context == null) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(minutes: 5),
      ),
    );
  }

  /// Hide loading snackbar
  static void hideLoading() {
    final context = Get.context;
    if (context == null) return;
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // With Context (when Get.context not available)
  // ─────────────────────────────────────────────────────────────────────────

  /// Show snackbar with explicit context
  static void showWithContext(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Confirmation Dialog
  // ─────────────────────────────────────────────────────────────────────────

  /// Show confirmation dialog
  static Future<bool> confirm({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDanger = false,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              cancelText,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              confirmText,
              style: TextStyle(
                color: isDanger ? AppColors.error : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Loading Dialog
  // ─────────────────────────────────────────────────────────────────────────

  /// Show loading dialog
  static void showLoadingDialog({String? message}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}