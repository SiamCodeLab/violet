import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:violet/core/services/api_service.dart';
import 'package:violet/core/services/snackbar_service.dart';
import 'package:violet/core/utils/console.dart';

import '../../../../../core/const/api_endpoint.dart';

class ChatController extends GetxController {
  RxBool isLoading = false.obs;
  final messageController = TextEditingController();
  int sessionId = 16;
  int botid = 0;
  RxList allMessagesSession = <dynamic>[].obs;
  RxList currentMessages = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();

    getSession();
  }

  Future<void> getSession() async {
    // TODO: implement getMessages
    try {
      isLoading(true);
      // Make API call to get messages
      final response = await ApiService.getAuth(ApiEndpoint.chatSession);

      if (response.statusCode == 200) {
        Console.success('Messages fetched successfully');
        Console.info('Data: ${response.data}');
        allMessagesSession.value = response.data;
        isLoading(false);
      } else {
        Console.error('Error: ${response.data['detail']}');
        SnackbarService.error('Error: ${response.data['detail']}');
        isLoading(false);
      }
    } catch (e) {
      isLoading(false);
      Console.error('Error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> getMessages(int id) async {
    Get.back();
    // TODO: implement getMessages
    try {
      isLoading(true);
      // Make API call to get messages
      final response = await ApiService.getAuth(
        "${ApiEndpoint.chatSession}$id",
      );

      if (response.statusCode == 200) {
        Console.success('Messages fetched successfully');
        Console.info('Data: ${response.data}');
        currentMessages.value = response.data['messages'];
        sessionId = id;
        isLoading(false);
      } else {
        Console.error('Error: ${response.data['detail']}');
        SnackbarService.error('Error: ${response.data['detail']}');
        isLoading(false);
      }
    } catch (e) {
      isLoading(false);
      Console.error('Error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> sendMessage() async {
    // TODO: implement sendMessage
    try {
      isLoading(true);
      // Make API call to send message
      final response = await ApiService.uploadMultipart(
        url: ApiEndpoint.chatbot,
        method: 'POST',
        fields: {
          "bot_id": Get.arguments.toString(),
          "message": messageController.text,
          "session_id": sessionId.toString(),
        },
      );
      if (response.statusCode == 200) {
        isLoading(false);
        Console.success('Message sent successfully');
        messageController.clear();
      } else {
        isLoading(false);
        Console.error('Error: ${response.data['detail']}');
        SnackbarService.error('Error: ${response.data['detail']}');
      }
    } catch (e) {
      isLoading(false);
      Console.error('Error: $e');
      SnackbarService.error('Error: $e');
    } finally {
      isLoading(false);
    }
  }
}
