import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:violet/core/theme/theme_color.dart';
import 'package:violet/os/windows/feature/auth/controller/otp_submit_controller.dart';

import '../../../../../core/universal_widgets/s_input_field.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_title.dart';
import 'change_password_screen.dart';

class OtpSubmitScreen extends StatelessWidget {
  OtpSubmitScreen({super.key});

  final OtpSubmitController _controller = Get.put(OtpSubmitController());

  @override
  Widget build(BuildContext context) {
    bool isAndroid = Theme.of(context).platform == TargetPlatform.android;

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
                  AuthTitle(
                    isAndroid: isAndroid,
                    title: 'Enter verification code',
                  ),
                  const SizedBox(height: 50),
                  SInputField(
                    controller: _controller.otp,
                    keyboardType: TextInputType.number,
                    labelText: 'OTP',
                    hintText: 'Enter the OTP sent to your email',
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _controller.verifyOtp(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(ThemeColor.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Send OTP',
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
    );
  }
}
