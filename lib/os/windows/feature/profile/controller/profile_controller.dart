import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:violet/core/const/api_endpoint.dart';
import 'package:violet/core/services/api_service.dart';
import 'package:violet/core/services/snackbar_service.dart';
import 'package:violet/core/utils/console.dart';
import 'package:violet/os/windows/feature/auth/controller/login_controller.dart';
import 'package:violet/os/windows/feature/auth/pages/login_screen.dart';

class ProfileController extends GetxController {
  //observables
  final isLoading = false.obs;
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  RxString orgaization = ''.obs;

  @override
  void onInit() {
    getUser();
    super.onInit();
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  //logout
  void signOut() {
    Get.put(LoginController()).logout();
    Console.info('User signed out');
  }

  //delete account

  Future<void> deleteAccouont() async {
    try {
      final response = await ApiService.deleteAuth(
        ApiEndpoint.deleteAccount,
        body: {
          'password': passwordController.text,
          'conform_password': confirmPasswordController.text,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Console.success('Account deleted');
        signOut();
        Get.to(() => LoginScreen());
      } else {
        Console.error('Delete failed: ${response.data}');
        SnackbarService.error('Failed to delete account');
      }
    } catch (e) {
      Console.error('Delete exception: $e');
      SnackbarService.error('Failed to delete account');
    } finally {
      isLoading.value = false;
    }
  }

  //get user details

  // Sign In
  Future<void> getUser() async {
    try {
      Console.api('Sign In');
      isLoading.value = true;
      final response = await ApiService.getAuth(ApiEndpoint.profile);

      if (response.statusCode == 200) {
        // User signed in successfully
        final data = response.data;
        // Save user data to SharedPreferences
        orgaization.value = data['organization_name'];
        Console.info(data['organization_name']);

        // Navigate to Home

        isLoading.value = false;
      } else {
        isLoading.value = false;

        Console.error('Error: ${response.data['detail']}');
      }
    } catch (e) {
      isLoading.value = false;
      Console.error('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
