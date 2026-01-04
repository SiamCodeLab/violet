import 'package:flutter/material.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:violet/core/const/api_endpoint.dart';
import 'package:violet/core/services/api_service.dart';
import 'package:violet/core/services/snackbar_service.dart';
import 'package:violet/core/services/storage/storage_service.dart';
import 'package:violet/core/utils/console.dart';
import 'package:violet/os/windows/feature/home/pages/home_screen.dart';

class LoginController extends GetxService {
  //Login Controller
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  //Error Message
  final RxString errorMessageSignIn = ''.obs;

  //LOADING
  final RxBool isLoading = false.obs;

  RxBool rememberMe = false.obs;

  //Remember me
  void toggleRememberMe() => rememberMe.toggle();

  //login
  // Sign In
  Future<void> signIn() async {
    Console.info(loginEmailController.text);
    if (!_validateSignInForm()) return;

    try {
      Console.api('Sign In');
      isLoading.value = true;
      final response = await ApiService.postAuth(
        ApiEndpoint.login,
        body: {
          "email": loginEmailController.text.trim(),
          "password": loginPasswordController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        // User signed in successfully
        final data = response.data;
        // Save user data to SharedPreferences
        await StorageService.saveUserSession(
          accessToken: data['access'],
          refreshToken: data['refresh'],
        );
        Console.info(data['access']);
        Console.success('User signed in successfully');
        SnackbarService.success('User signed in successfully');
        // Navigate to Home
        Get.to(() => HomeScreen());
        isLoading.value = false;
      } else {
        isLoading.value = false;
        SnackbarService.error('Error: ${response.data['detail']}');
        Console.error('Error: ${response.data['detail']}');
      }
    } catch (e) {
      isLoading.value = false;
      Console.error('Sign In Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Validate Sign In Form
  bool _validateSignInForm() {
    if (loginEmailController.text.trim().isEmpty) {
      errorMessageSignIn.value = 'Please enter your email';
      Console.error('Please enter your email');
      SnackbarService.error('Please enter your email');
      return false;
    }
    if (!GetUtils.isEmail(loginEmailController.text.trim())) {
      errorMessageSignIn.value = 'Please enter a valid email';
      Console.error('Please enter a valid email');
      SnackbarService.error('Please enter a valid email');
      return false;
    }
    if (loginPasswordController.text.isEmpty) {
      errorMessageSignIn.value = 'Please enter your password';
      Console.error('Please enter your password');
      SnackbarService.error('Please enter your password');
      return false;
    }
    return true;
  }
}
