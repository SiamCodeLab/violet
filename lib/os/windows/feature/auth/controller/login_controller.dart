import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:violet/core/const/api_endpoint.dart';
import 'package:violet/core/services/api_service.dart';
import 'package:violet/core/services/snackbar_service.dart';
import 'package:violet/core/services/storage/storage_service.dart';
import 'package:violet/core/utils/console.dart';
import 'package:violet/os/windows/feature/auth/pages/login_screen.dart';
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
    ).timeout(
      const Duration(seconds: 5),         // ← cancel after 5s
      onTimeout: () {
        throw TimeoutException('Request timed out');
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      await StorageService.saveUserSession(
        accessToken: data['access'],
        refreshToken: data['refresh'],
      );
      await StorageService.setUserEmail(loginEmailController.text.trim());
      Console.info(data['access']);
      Console.success('User signed in successfully');
      SnackbarService.success('User signed in successfully');
      loginEmailController.clear();
      loginPasswordController.clear();
      Get.to(() => HomeScreen());
    } else {
      var error = response.data['detail'];
      error == 'No active account found with the given credentials'
          ? error = 'No account found'
          : error;
      SnackbarService.error(error);
      Console.error('Error: ${response.data['detail']}');
    }
  } on TimeoutException {                  // ← catch timeout specifically
    Console.error('Sign In Timeout: Request exceeded 5 seconds');
    SnackbarService.error('Unexpected error, please try again');
  } catch (e) {
    Console.error('Sign In Error: $e');
    SnackbarService.error('Unexpected error, please try again');
  } finally {
    isLoading.value = false;               // ← always runs, no need to repeat
  }
}

  void logout() async {
    StorageService.clearUserSession();
    Get.offAll(() => LoginScreen());
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
