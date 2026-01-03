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
    Console.info('OTP: ${otp.value}');
    if (otp.text.trim().isEmpty) return;
    try {
      isLoading(true);
      final response = await ApiService.postAuth(
        ApiEndpoint.verifyOtp,
        body: {"code": otp.text.trim(), "email": Get.arguments},
      );
      if (response.statusCode == 200) {
        isLoading(false);
        Console.success('OTP verified successfully');
        SnackbarService.success('OTP verified successfully');
        Get.to(
          () => ChangePasswordScreen(),
          arguments: {'email': Get.arguments, 'otp': otp.text.trim()},
        );
      } else if (response.statusCode == 400) {
        SnackbarService.error('Error: ${response.data['otp']}');
        Console.error('Error: ${response.data['otp']}');
        isLoading(false);
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
