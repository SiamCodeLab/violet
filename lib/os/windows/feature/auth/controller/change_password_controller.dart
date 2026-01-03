import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:violet/core/const/api_endpoint.dart';
import 'package:violet/core/services/api_service.dart';
import 'package:violet/core/services/snackbar_service.dart';
import 'package:violet/core/utils/console.dart';
import 'package:violet/os/windows/feature/auth/pages/login_screen.dart';

class ChangePasswordController extends GetxController {
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  RxBool isLoading = false.obs;

  final argument = Get.arguments;

  Future<void> changePassword() async {
    if (password.text.trim() == confirmPassword.text.trim() &&
        password.text.isNotEmpty) {
      // Passwords match, perform password change logic here
      try {
        isLoading.value = true;
        final response = await ApiService.postAuth(
          ApiEndpoint.changePassword,
          body: {
            "email": argument['email'],
            "code": argument['code'],
            "new_password": password.text.trim(),
            "new_password2": confirmPassword.text.trim(),
          },
        );

        if (response.statusCode == 200) {
          isLoading.value = false;
          SnackbarService.success('Password changed successfully');
          Get.to(() => LoginScreen());
        } else {
          isLoading.value = false;
          SnackbarService.error('Error: ${response.data['detail']}');
        }
      } catch (e) {
        Console.error('Error: $e');
        SnackbarService.error('Error: $e');
      }
    } else {
      Console.error('Passwords do not match');
      SnackbarService.error('Passwords do not match');
    }
  }
}
