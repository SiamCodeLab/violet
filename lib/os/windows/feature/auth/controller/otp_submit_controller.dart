import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:violet/core/const/api_endpoint.dart';
import 'package:violet/core/services/api_service.dart';
import 'package:violet/core/services/snackbar_service.dart';
import 'package:violet/core/utils/console.dart';
import 'package:violet/os/windows/feature/auth/pages/change_password_screen.dart';

class OtpSubmitController extends GetxController {
  final otp = TextEditingController();
  RxBool isLoading = false.obs;

  Future<void> verifyOtp() async {
    Console.info('OTP: ${otp.text.trim()} Email: ${Get.arguments}');
    if (otp.text.trim().isEmpty) return;
    try {
      isLoading(true);
      final response = await ApiService.post(
        ApiEndpoint.verifyOtp,
        body: {"code": otp.text.trim(), "email": Get.arguments},
      );
      if (response.statusCode == 200) {
        isLoading(false);
        Console.success('OTP verified successfully');
        SnackbarService.success('OTP verified successfully');
        Get.to(
          () => ChangePasswordScreen(),
          arguments: {'email': Get.arguments, 'code': otp.text.trim()},
        );
        otp.clear();
      } else if (response.statusCode == 400) {
        isLoading(false);
        if (response.data['non_field_errors'][0] ==
            'Invalid or expired verification code.') {
          SnackbarService.error('Invalid verification code.');
          Console.error('Invalid or expired verification code.');
        }
      } else {
        isLoading(false);
        SnackbarService.error('Verification code has expired.');
        Console.error('Verification code has expired.');
      }
    } catch (e) {
      SnackbarService.error('Error: $e');
      Console.error('Error: $e');
      isLoading(false);
    } finally {
      isLoading(false);
    }
  }
}
