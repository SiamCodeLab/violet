import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:violet/core/const/api_endpoint.dart';
import 'package:violet/core/const/app_colors.dart';
import 'package:violet/core/const/path_strings.dart';
import 'package:violet/core/services/storage/storage_service.dart';
import 'package:violet/core/theme/theme_color.dart';
import 'package:violet/os/windows/feature/profile/controller/profile_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class DesktopProfilePopup {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => const _DesktopProfileDialog(),
    );
  }
}

class _DesktopProfileDialog extends StatelessWidget {
  const _DesktopProfileDialog();

  @override
  Widget build(BuildContext context) {
    // Use existing controller if registered, else put a new one
    final controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Center(
        child: Container(
          width: 420,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Color(ThemeColor.primary),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Info card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.textWhite,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          // Email row
                          ListTile(
                            leading: Image.asset(
                              PathStrings.userIcon,
                              width: 20,
                            ),
                            title: Text(
                              StorageService.getUserEmail(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const Divider(height: 1, indent: 16, endIndent: 16),

                          // Organization row
                          Obx(
                            () => ListTile(
                              leading: Image.asset(
                                PathStrings.organisation,
                                width: 20,
                              ),
                              title: RichText(
                                text: TextSpan(
                                  text: 'Organization: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textBlack,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: controller.orgaization.value,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const Divider(height: 1, indent: 16, endIndent: 16),

                          // Privacy policy row
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => _launchUrl(context),
                              child: ListTile(
                                leading: Image.asset(
                                  PathStrings.privacy,
                                  width: 20,
                                ),
                                title: const Text(
                                  'Terms and privacy policy',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),

                          const Divider(height: 1, indent: 16, endIndent: 16),

                          // Log out row
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () =>
                                  _showLogOutDialog(context, controller),
                              child: ListTile(
                                leading: Image.asset(
                                  PathStrings.logoutIcon,
                                  width: 20,
                                ),
                                title: const Text(
                                  'Sign out',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Delete account button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showDeleteDialog(context, controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Obx(
                          () => Text(
                            controller.isLoading.value
                                ? 'Deleting...'
                                : 'Delete Account',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _launchUrl(BuildContext context) async {
    final Uri url = Uri.parse(ApiEndpoint.privacyPolicy);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open the link')));
    }
  }

  void _showLogOutDialog(BuildContext context, ProfileController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => controller.signOut(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ProfileController controller) {
    final formKey = GlobalKey<FormState>();
    bool obscurePassword = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Delete Account'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Are you sure you want to delete your account?'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => obscurePassword = !obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 4) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller.confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != controller.passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.passwordController.clear();
                controller.confirmPasswordController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  controller.deleteAccouont();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
