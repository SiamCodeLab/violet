import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:violet/core/const/string_cont/path_strings.dart';
import 'package:violet/core/theme/theme_color.dart';
import 'package:violet/os/windows/feature/home/pages/home_screen.dart';

import '../../../../../core/universal_widgets/s_input_field.dart';
import '../widgets/auth_logo.dart';
import '../widgets/auth_title.dart';
import 'email_submit_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
          child: Center(
            child: SizedBox(
              width: 650,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AuthLogo(isAndroid: isAndroid),
                  AuthTitle(
                      isAndroid: isAndroid,
                      title: 'Log in to continue ',
                  ),
                  const SizedBox(height: 50),
                  SInputField(
                    keyboardType: TextInputType.emailAddress,
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                  ),
                  const SizedBox(height: 20),
                  SInputField(
                    keyboardType: TextInputType.visiblePassword,
                    isSuffixIcon: true,
                    labelText: 'Password',
                    hintText: 'Enter your password',
                  ),
                  const SizedBox(height: 10  ),
                  Row(
                    children: [
                      Checkbox(
                        activeColor: Color(ThemeColor.primary),
                        value: true,
                        onChanged: (value) {},
                      ),
                      const Text('Remember me',
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
                              builder: (context) => const EmailSubmitScreen(),
                            ),
                          );
                        },
                        child: const Text('Forgot Password?',
                        style: TextStyle(
                            color: Color(ThemeColor.primary),
                            fontSize: 16,
                          ),
                        )
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(ThemeColor.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
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
