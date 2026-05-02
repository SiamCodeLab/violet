import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ← added for KeyEvent
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:violet/core/const/api_endpoint.dart';
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

  Future<void> _launchUrl(BuildContext context) async {
    final Uri url = Uri.parse(ApiEndpoint.privacyPolicy);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // ignore: use_build_context_synchronously
      Console.info('Could not open the link');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAndroid =
        Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      backgroundColor: Color(ThemeColor.backgroundColor),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
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
                      title: 'Log in to continue ',
                    ),
                    const SizedBox(height: 50),

                    // Email field
                    SInputField(
                      controller: _controller.loginEmailController,
                      keyboardType: TextInputType.emailAddress,
                      labelText: 'Email',
                      hintText: 'Enter your email address',
                    ),
                    const SizedBox(height: 20),

                    // Password field — Enter key triggers signIn on desktop
                    Focus(
                      onKeyEvent: (node, event) {
                        if (!isAndroid &&
                            event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.enter) {
                          _controller.signIn();
                          return KeyEventResult.handled;
                        }
                        return KeyEventResult.ignored;
                      },
                      child: SInputField(
                        controller: _controller.loginPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        isSuffixIcon: true,
                        obscureText: true, // ← password hidden by default
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        onSubmitted: (_) =>
                            _controller.signIn(), // ← mobile "Done"
                      ),
                    ),

                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Obx(
                          () => Checkbox(
                            activeColor: Color(ThemeColor.primary),
                            value: _controller.rememberMe.value,
                            onChanged: (value) =>
                                _controller.toggleRememberMe(),
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
                        child: Obx(
                          () => _controller.isLoading.value
                              ? const CircularProgressIndicator.adaptive(
                                  backgroundColor: Colors.white,
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    // Privacy policy
                    const SizedBox(height: 12),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text:
                            'By clicking the "Login" button, you accept the terms of the ',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: Color(ThemeColor.primary),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _launchUrl(context),
                          ),
                        ],
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
