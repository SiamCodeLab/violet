import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:violet/core/theme/theme_color.dart';
import 'package:violet/core/utils/console.dart';
import 'package:violet/os/windows/feature/auth/controller/login_controller.dart';

import '../../../../../core/universal_widgets/s_input_field.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_title.dart';
import 'email_submit_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final LoginController _controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    bool isAndroid = Theme.of(context).platform == TargetPlatform.android;

    return Scaffold(
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
                  AuthTitle(isAndroid: isAndroid, title: 'Log in to continue '),
                  const SizedBox(height: 50),
                  SInputField(
                    controller: _controller.loginEmailController,
                    keyboardType: TextInputType.emailAddress,
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                  ),
                  const SizedBox(height: 20),
                  SInputField(
                    controller: _controller.loginPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    isSuffixIcon: true,
                    labelText: 'Password',
                    hintText: 'Enter your password',
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Obx(
                        () => Checkbox(
                          activeColor: Color(ThemeColor.primary),
                          value: _controller.rememberMe.value,
                          onChanged: (value) => _controller.toggleRememberMe(),
                        ),
                      ),
                      const Text(
                        'Remember me',
                        style: TextStyle(
                          color: Color(ThemeColor.primary),
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmailSubmitScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Color(ThemeColor.primary),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Console.info(_controller.loginEmailController.text);
                        _controller.signIn();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(ThemeColor.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Login',
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
