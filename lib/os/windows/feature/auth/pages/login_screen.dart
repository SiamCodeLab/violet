import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:violet/core/const/string_cont/path_strings.dart';
import 'package:violet/core/theme/theme_color.dart';

import '../../../../../core/universal_widgets/s_input_field.dart';
import 'email_submit_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(ThemeColor.backgroundColor),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 650,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  PathStrings.logoPath,
                  width: 200,
                ),
                const Text(
                  'Log in to continue',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                SInputField(
                  labelText: 'Email',
                  hintText: 'Enter your email address',
                ),
                const SizedBox(height: 20),
                SInputField(
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
                    onPressed: () {},
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
    );
  }
}

