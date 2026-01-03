import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:violet/core/const/api_endpoint.dart';
import 'package:violet/core/services/api_service.dart';
import 'package:violet/core/services/snackbar_service.dart';
import 'package:violet/core/utils/console.dart';
import 'package:violet/os/windows/feature/auth/pages/otp_submit_screen.dart';

class EmailSubmitController extends GetxService {
  final email = TextEditingController();
  RxString errorMessage = ''.obs;
  RxBool isLoading = false.obs;

  Future<void> sendOtp() async {
    Console.info(email.text);
    if (!_validateEmail()) return;

    try {
      isLoading.value = true;

      // Make API call to
      final response = await ApiService.postAuth(
        ApiEndpoint.forgetPassword,
        body: {"email": email.text},
      );
      if (response.statusCode == 200) {
        isLoading.value = false;
        Console.success('Email sent successfully');
        SnackbarService.success('Email sent successfully');
        Get.to(() => OtpSubmitScreen(), arguments: email.text.trim());
      } else if (response.statusCode == 400) {
        isLoading.value = false;
        SnackbarService.error('Error: ${response.data['email']}');
        errorMessage.value = response.data['email'];
        Console.error('Error: ${response.data['email']}');
      }
    } catch (e) {
      isLoading.value = false;
      Console.error(' Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Validate Sign In Form
  bool _validateEmail() {
    if (email.text.trim().isEmpty) {
      errorMessage.value = 'Please enter your email';
      Console.error('Please enter your email');
      SnackbarService.error('Please enter your email');
      return false;
    }
    if (!GetUtils.isEmail(email.text.trim())) {
      errorMessage.value = 'Please enter a valid email';
      SnackbarService.error('Please enter a valid email');
      Console.error('Please enter a valid email');
      return false;
    }

    return true;
  }
}
