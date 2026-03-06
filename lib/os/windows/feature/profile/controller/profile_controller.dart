import 'package:get/get.dart';
import 'package:violet/core/utils/console.dart';
import 'package:violet/os/windows/feature/auth/controller/login_controller.dart';

class ProfileController extends GetxController {
  //logout
  void signOut() {
    Get.put(LoginController()).logout();
    Console.info('User signed out');
  }

  //delete account
}
