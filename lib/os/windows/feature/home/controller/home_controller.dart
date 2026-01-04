import 'package:get/get.dart';
import 'package:violet/core/const/api_endpoint.dart';
import 'package:violet/core/services/api_service.dart';
import 'package:violet/core/services/snackbar_service.dart';
import 'package:violet/core/utils/console.dart';

class HomeController extends GetxController {
  RxBool isloading = false.obs;
  RxBool isLoaded = false.obs;
  RxList<Map<String, dynamic>> promptList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() async {
    getPromptList();
    Console.info('Prompt List: $promptList');
    super.onInit();
  }

  Future<void> getPromptList() async {
    try {
      isloading.value = true;
      final response = await ApiService.get(ApiEndpoint.getPromptList);
      if (response.statusCode == 200) {
        Console.success('Prompt list fetched successfully');
        final data = response.data;
        Console.info('Data: $data');
        promptList.assignAll(data.cast<Map<String, dynamic>>());

        isloading.value = false;
        isLoaded.value == true;
      } else {
        isloading.value = false;
        Console.error('Error: ${response.data['detail']}');
        SnackbarService.error('Error: ${response.data['detail']}');
      }
    } catch (e) {
      isloading.value = false;
      Console.error('Error: $e');
    } finally {
      isloading.value = false;
    }
  }
}
