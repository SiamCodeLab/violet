import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:violet/core/services/api_service.dart';
import 'package:violet/core/services/snackbar_service.dart';
import 'package:violet/core/utils/console.dart';
import 'package:violet/core/const/api_endpoint.dart';
import 'package:violet/os/windows/feature/auth/controller/login_controller.dart';
import 'package:violet/os/windows/feature/chat/widgets/delete_confirmation_widget.dart';

class ChatController extends GetxController {
  // ============================================
  // CONTROLLERS
  // ============================================
  final messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode messageFocusNode = FocusNode();

  // ============================================
  // STATE VARIABLES
  // ============================================
  RxBool isSessionLoading = false.obs;
  RxBool isMessagesLoading = false.obs;
  RxBool isSending = false.obs;
  RxBool isDeleting = false.obs;

  // ============================================
  // DATA VARIABLES
  // ============================================
  RxnInt sessionId = RxnInt(null);
  int botId = 0;
  RxList<Map<String, dynamic>> allSessions = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> currentMessages = <Map<String, dynamic>>[].obs;

  // ============================================
  // LIFECYCLE
  // ============================================

  @override
  void onInit() {
    super.onInit();
    fetchAllSessions();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    messageFocusNode.dispose();
    super.onClose();
  }

  void setBotId(int id) {
    botId = id;
    Console.info('Bot ID: $botId');
  }

  // ============================================
  // GET ALL SESSIONS
  // ============================================

  Future<void> fetchAllSessions() async {
    try {
      isSessionLoading(true);

      final response = await ApiService.getAuth(ApiEndpoint.chatSession);

      if (response.statusCode == 200) {
        Console.success('Sessions fetched');
        allSessions.value = List<Map<String, dynamic>>.from(
          response.data.map((item) => Map<String, dynamic>.from(item)),
        );
      } else {
        Console.error('Error: ${response.data}');
      }
    } catch (e) {
      Console.error('Exception: $e');
    } finally {
      isSessionLoading(false);
    }
  }

  // ============================================
  // GET SESSION MESSAGES
  // ============================================

  Future<void> loadSessionMessages(int id) async {
    try {
      isMessagesLoading(true);

      final response = await ApiService.getAuth(
        "${ApiEndpoint.chatSession}$id",
      );

      if (response.statusCode == 200) {
        Console.success('Messages loaded: $id');

        final List messages = response.data['messages'] ?? [];

        currentMessages.value = messages.map<Map<String, dynamic>>((msg) {
          return {
            'id': msg['id'],
            'sender': msg['role'] == 'user' ? 'user' : 'violet',
            'message': msg['content'] ?? '',
            'created_at': msg['created_at'],
          };
        }).toList();

        sessionId.value = id;
        scrollToBottom();
      } else {
        Console.error('Error: ${response.data}');
        SnackbarService.error('Failed to load messages');
      }
    } catch (e) {
      Console.error('Exception: $e');
    } finally {
      isMessagesLoading(false);
    }
  }

  // ============================================
  // SEND MESSAGE
  // ============================================

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || isSending.value) return;

    // Optimistic UI
    final userMessage = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'sender': 'user',
      'message': text,
    };
    currentMessages.add(userMessage);
    messageController.clear();
    scrollToBottom();

    try {
      isSending(true);

      final Map<String, String> fields = {
        "bot_id": botId.toString(),
        "message": text,
      };

      if (sessionId.value != null) {
        fields["session_id"] = sessionId.value.toString();
      }

      final response = await ApiService.uploadMultipart(
        url: ApiEndpoint.chatbot,
        method: 'POST',
        fields: fields,
      );

      if (response.statusCode == 200) {
        Console.success('Message sent');

        final data = response.data;

        // Update session ID
        if (data['session_id'] != null) {
          final newSessionId = data['session_id'];
          if (sessionId.value == null || sessionId.value != newSessionId) {
            sessionId.value = newSessionId;
            fetchAllSessions();
          }
        }

        // Add AI response
        final aiResponse = data['ai_response'];
        if (aiResponse != null && aiResponse['success'] == true) {
          final aiMessage = {
            'id': DateTime.now().millisecondsSinceEpoch + 1,
            'sender': 'violet',
            'message': aiResponse['response'] ?? '',
          };
          currentMessages.add(aiMessage);
        }

        scrollToBottom();
      } else {
        Console.error('Error: ${response.data}');
        SnackbarService.error('Failed to send message');
      }
    } catch (e) {
      Console.error('Exception: $e');
      SnackbarService.error('Something went wrong');
    } finally {
      isSending(false);
    }
  }

  void signOut() async {
    Get.put(LoginController()).logout();
  }

  // ============================================
  //  DELETE SESSION
  // ============================================

  Future<void> deleteSession(int index) async {
    try {
      final session = allSessions[index];
      final id = session['id'];

      Console.info('Deleting session: $id');
      isDeleting(true);

      final response = await ApiService.deleteAuth(
        "${ApiEndpoint.chatSession}$id/delete/",
      );

      // Success check (200 or 204)
      if (response.statusCode == 200 || response.statusCode == 204) {
        Console.success('Session deleted: $id');

        // Remove from local list
        allSessions.removeAt(index);

        // If deleted session was active, clear chat
        if (sessionId.value == id) {
          startNewChat();
        }

        SnackbarService.success('Chat deleted');
      } else {
        Console.error('Delete failed: ${response.data}');
        SnackbarService.error('Failed to delete chat');
      }
    } catch (e) {
      Console.error('Delete exception: $e');
      SnackbarService.error('Failed to delete chat');
    } finally {
      isDeleting(false);
    }
  }

  // ============================================
  // HELPER: Confirm Delete Dialog
  // ============================================
  void confirmDeleteSession(int index, BuildContext context) {
    final session = allSessions[index];
    final title = session['title'] ?? 'Untitled';

    DeleteConfirmationDialog.showSmart(
      context: context,
      title: 'Delete Chat',
      itemName: title,
      onConfirm: () => deleteSession(index),
    );
  }

  /// Force dialog style (good for desktop)
  void confirmDeleteSessionDialog(int index) {
    final session = allSessions[index];
    final title = session['title'] ?? 'Untitled';

    DeleteConfirmationDialog.show(
      title: 'Delete Chat',
      itemName: title,
      onConfirm: () => deleteSession(index),
    );
  }

  /// Force bottom sheet style (good for mobile)
  void confirmDeleteSessionBottomSheet(int index) {
    final session = allSessions[index];
    final title = session['title'] ?? 'Untitled';

    DeleteConfirmationDialog.showBottomSheet(
      title: 'Delete Chat',
      itemName: title,
      onConfirm: () => deleteSession(index),
    );
  }

  /// Minimal style dialog
  void confirmDeleteSessionMinimal(int index) {
    final session = allSessions[index];
    final title = session['title'] ?? 'Untitled';

    DeleteConfirmationDialog.showMinimal(
      title: 'Delete Chat',
      message:
          'Are you sure you want to delete "$title"? This action cannot be undone.',
      onConfirm: () => deleteSession(index),
    );
  }
  // ============================================
  // HELPERS
  // ============================================

  void startNewChat() {
    currentMessages.clear();
    sessionId.value = null;
    messageController.clear();
  }

  void scrollToBottom() {
    if (!scrollController.hasClients) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void requestFocus() {
    messageFocusNode.requestFocus();
  }
}
