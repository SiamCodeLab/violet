import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:violet/core/theme/theme_color.dart';
import 'package:violet/os/windows/feature/auth/controller/email_submit_controller.dart';

import '../../../../../core/universal_widgets/s_input_field.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_title.dart';

class EmailSubmitScreen extends StatelessWidget {
  EmailSubmitScreen({super.key});

  final EmailSubmitController _controller = Get.put(EmailSubmitController());

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
                  AuthTitle(isAndroid: isAndroid, title: 'Reset your password'),
                  const SizedBox(height: 10),
                  Text(
                    'OTP will be send to your mail',
                    style: TextStyle(
                      fontSize: isAndroid ? 16 : 20,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 50),
                  SInputField(
                    controller: _controller.email,
                    keyboardType: TextInputType.emailAddress,
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _controller.sendOtp(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(ThemeColor.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _controller.isLoading.value
                            ? CircularProgressIndicator.adaptive(
                                backgroundColor: Colors.white,
                              )
                            : Text(
                                'Send OTP',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
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
