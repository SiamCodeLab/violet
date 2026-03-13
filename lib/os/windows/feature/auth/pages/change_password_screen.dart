import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:violet/core/theme/theme_color.dart';
import 'package:violet/os/windows/feature/auth/controller/change_password_controller.dart';

import '../../../../../core/universal_widgets/s_input_field.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_title.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});

  final ChangePasswordController _controller = Get.put(
    ChangePasswordController(),
  );

  @override
  Widget build(BuildContext context) {
    // Detect mobile platform to apply responsive layout adjustments
    bool isAndroid =
        Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Color(ThemeColor.backgroundColor),
      body: SafeArea(
        // Intercepts keyboard events at the screen level to support
        // Enter key submission without requiring explicit button click
        child: KeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.enter) {
              _controller.changePassword();
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isAndroid ? 20 : 100,
              vertical: isAndroid ? 20 : 50,
            ),
            child: Align(
              alignment: isAndroid ? Alignment.topCenter : Alignment.center,
              child: SizedBox(
                width: 650,
                child: Column(
                  mainAxisAlignment: isAndroid
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AuthLogo(isAndroid: isAndroid),
                    AuthTitle(isAndroid: isAndroid, title: 'Enter New Password'),
                    const SizedBox(height: 50),
                    SInputField(
                      controller: _controller.password,
                      keyboardType: TextInputType.visiblePassword,
                      isSuffixIcon: true,
                      labelText: 'Password',
                      hintText: 'Enter your new password',
                    ),
                    const SizedBox(height: 20),
                    SInputField(
                      controller: _controller.confirmPassword,
                      keyboardType: TextInputType.visiblePassword,
                      isSuffixIcon: true,
                      labelText: 'Confirm',
                      hintText: 'Re-enter your new password',
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _controller.changePassword(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(ThemeColor.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Update Password',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}