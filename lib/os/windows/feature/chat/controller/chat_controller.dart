import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:markdown/markdown.dart' as md;
import 'package:super_clipboard/super_clipboard.dart';
import 'package:violet/core/services/api_service.dart';
import 'package:violet/core/services/snackbar_service.dart';
import 'package:violet/core/services/storage/storage_service.dart';
import 'package:violet/core/utils/console.dart';
import 'package:violet/core/const/api_endpoint.dart';
import 'package:violet/core/utils/file_picker_helper.dart';
import 'package:violet/os/windows/feature/auth/controller/login_controller.dart';
import 'package:violet/os/windows/feature/chat/widgets/delete_confirmation_widget.dart';

class ChatController extends GetxController {
  // ============================================
  // CONTROLLERS
  // ============================================
  final messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();

  ScrollController? _scrollController;

  ScrollController get scrollController {
    if (_scrollController == null ||
        !_scrollController!.hasClients ||
        _scrollController!.positions.length > 1) {
      _scrollController?.dispose();
      _scrollController = ScrollController();
    }
    return _scrollController!;
  }

  // ============================================
  // STATE VARIABLES
  // ============================================
  RxBool isSessionLoading = false.obs;
  RxBool isMessagesLoading = false.obs;
  RxBool isSending = false.obs;
  RxBool isDeleting = false.obs;
  RxBool isStreaming = false.obs;
  RxString streamingText = ''.obs;
  Rx<PickedFileInfo?> selectedFile = Rx<PickedFileInfo?>(null);

  bool _isInitialized = false;

  // ============================================
  // DATA VARIABLES
  // ============================================
  RxnInt sessionId = RxnInt(null);
  RxInt botId = 0.obs;
  RxList<Map<String, dynamic>> currentBotSessions =
      <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> allSessions = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> currentMessages = <Map<String, dynamic>>[].obs;
  RxString email = ''.obs;

  // ============================================
  // LIFECYCLE
  // ============================================

  @override
  void onInit() async {
    super.onInit();
    email.value = StorageService.getUserEmail();
    _scrollController = ScrollController();
  }

  @override
  void onClose() {
    messageController.dispose();
    _scrollController?.dispose();
    messageFocusNode.dispose();
    super.onClose();
  }

  // ============================================
  // SET BOT ID
  // ============================================

  void setBotId(int id) {
    if (_isInitialized && botId.value == id) {
      Console.info('Same bot, skipping reload');
      return;
    }
    botId.value = id;
    Console.info('Bot ID set: $id');
    _clearDataSync();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchSessionsForBot();
      _isInitialized = true;
    });
  }

  void _clearDataSync() {
    currentMessages.clear();
    sessionId.value = null;
    messageController.clear();
    currentBotSessions.clear();
    streamingText.value = '';
  }

  void initializeForBot(int id) {
    if (_isInitialized && botId.value == id) return;
    botId.value = id;
    _clearDataSync();
    Future.microtask(() {
      fetchSessionsForBot();
      _isInitialized = true;
    });
  }

  void resetController() {
    _isInitialized = false;
    _clearDataSync();
    currentBotSessions.clear();
    Console.info('Controller reset');
  }

  // ============================================
  // API: GET SESSIONS FOR SPECIFIC BOT
  // ============================================

  Future<void> fetchSessionsForBot() async {
    if (botId.value == 0) {
      Console.info('Bot ID not set, skipping fetch');
      return;
    }
    try {
      isSessionLoading(true);
      final response = await ApiService.getAuth(
        "${ApiEndpoint.chatSession}?bot_id=${botId.value}",
      );
      if (response.statusCode == 200) {
        Console.success('Sessions fetched for bot: ${botId.value}');
        final List<dynamic> data = response.data;
        final filteredSessions = data
            .where((session) => session['bot_id'] == botId.value)
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        currentBotSessions.value = filteredSessions;
        Console.info('Found ${currentBotSessions.length} sessions');
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
  // FILE PICKER
  // ============================================

  Future<void> pickFile() async {
    final file = await FilePickerHelper.pickFile();
    if (file != null) {
      selectedFile.value = file;
      Console.info('File selected: ${file.name} (${file.sizeFormatted})');
    }
  }

  void clearFile() {
    selectedFile.value = null;
    Console.info('File cleared');
  }

  // ============================================
  // SCROLL TO BOTTOM
  // ============================================

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      _tryScroll();
    });
  }

  void _tryScroll() {
    try {
      if (_scrollController == null) return;
      if (!_scrollController!.hasClients) return;
      if (_scrollController!.positions.length != 1) {
        _scrollUsingPosition();
        return;
      }
      if (!_scrollController!.position.hasContentDimensions) {
        Future.delayed(const Duration(milliseconds: 100), () => _tryScroll());
        return;
      }
      final maxExtent = _scrollController!.position.maxScrollExtent;
      if (maxExtent > 0) {
        _scrollController!.animateTo(
          maxExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      Console.error('[Scroll] Error: $e');
      _scrollUsingPosition();
    }
  }

  void _scrollUsingPosition() {
    try {
      if (_scrollController == null) return;
      if (_scrollController!.positions.isEmpty) return;
      final position = _scrollController!.positions.last;
      if (position.hasContentDimensions) {
        position.animateTo(
          position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      Console.error('[Scroll] Fallback error: $e');
    }
  }

  // ============================================
  // API: GET SESSION MESSAGES
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
            'file_name': msg['file_name'],
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
  // API: SEND MESSAGE
  // ============================================
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    final file = selectedFile.value;

    // Allow send if text OR file exists
    if ((text.isEmpty && file == null) || isSending.value) return;

    // Optimistic UI - include file name if exists
    final userMessage = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'sender': 'user',
      'message': text.isNotEmpty ? text : 'Sent a file',
      'file_name': file?.name,
    };
    currentMessages.add(userMessage);
    messageController.clear();
    clearFile();

    // Keep reference before clearing
    final fileToSend = file?.file; // Get the actual File object
    scrollToBottom();

    try {
      isSending(true);

      final Map<String, String> fields = {
        "bot_id": botId.value.toString(),
        "message": text,
      };

      if (sessionId.value != null) {
        fields["session_id"] = sessionId.value.toString();
      }

      // Send with or without file
      final response = await ApiService.uploadMultipart(
        url: ApiEndpoint.chatbot,
        method: 'POST',
        fields: fields,
        files: fileToSend != null ? {'file': fileToSend} : null,
      );

      if (response.statusCode == 200) {
        Console.success('Message sent');

        final data = response.data;

        if (data['session_id'] != null) {
          final newSessionId = data['session_id'];
          if (sessionId.value == null || sessionId.value != newSessionId) {
            sessionId.value = newSessionId;
            fetchSessionsForBot();
          }
        }

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

  // ============================================
  // API: SEND MESSAGE WITH STREAMING
  // ============================================

  // Future<void> sendMessage() async {
  //   final text = messageController.text.trim();
  //   final file = selectedFile.value;

  //   if ((text.isEmpty && file == null) || isSending.value) return;

  //   // If file attached → use old multipart method
  //   if (file != null) {
  //     await _sendWithFile(text, file);
  //     return;
  //   }

  //   // Text only → use streaming
  //   await _sendStreaming(text);
  // }

  // // ── STREAMING (text only) ──────────────────

  // Future<void> _sendStreaming(String text) async {
  //   // Add user message immediately
  //   currentMessages.add({
  //     'id': DateTime.now().millisecondsSinceEpoch,
  //     'sender': 'user',
  //     'message': text,
  //     'file_name': null,
  //   });
  //   messageController.clear();
  //   scrollToBottom();

  //   isSending.value = true;
  //   isStreaming.value = true;
  //   streamingText.value = '';

  //   final StringBuffer fullText = StringBuffer();

  //   try {
  //     // Build the access token header same way your ApiService does
  //     final token = StorageService.getAccessToken();
  //     const streamChatbot = 'http://10.10.7.76:14090/';

  //     final request = http.Request('POST', Uri.parse(streamChatbot));
  //     request.headers['Authorization'] = 'Bearer $token';
  //     request.headers['Content-Type'] = 'application/x-www-form-urlencoded';

  //     final Map<String, String> fields = {
  //       'bot_id': botId.value.toString(),
  //       'message': text,
  //     };
  //     if (sessionId.value != null) {
  //       fields['session_id'] = sessionId.value.toString();
  //     }
  //     request.bodyFields = fields;

  //     final streamedResponse = await request.send().timeout(
  //       const Duration(seconds: 100),
  //       onTimeout: () => throw TimeoutException('Connection timed out'),
  //     );

  //     if (streamedResponse.statusCode == 200) {
  //       await for (final line
  //           in streamedResponse.stream
  //               .transform(utf8.decoder)
  //               .transform(const LineSplitter())) {
  //         if (line.trim().isEmpty) continue;

  //         try {
  //           final json = jsonDecode(line);

  //           if (json['type'] == 'chunk') {
  //             fullText.write(json['text']);
  //             streamingText.value = fullText.toString(); // live update UI
  //             scrollToBottom();
  //           } else if (json['type'] == 'done') {
  //             // Stream complete — check if new session was created
  //             if (json['session_id'] != null) {
  //               final newId = json['session_id'] as int;
  //               if (sessionId.value == null || sessionId.value != newId) {
  //                 sessionId.value = newId;
  //                 fetchSessionsForBot();
  //               }
  //             }
  //             break;
  //           }
  //         } catch (_) {
  //           continue; // skip malformed lines
  //         }
  //       }

  //       // Move streamed text into messages list
  //       if (fullText.isNotEmpty) {
  //         currentMessages.add({
  //           'id': DateTime.now().millisecondsSinceEpoch + 1,
  //           'sender': 'violet',
  //           'message': fullText.toString(),
  //           'file_name': null,
  //         });
  //       }
  //     } else {
  //       SnackbarService.error('Failed to send message');
  //     }
  //   } on TimeoutException {
  //     Console.error('Streaming timeout');
  //     SnackbarService.error('Request timed out, please try again');
  //   } catch (e) {
  //     Console.error('Streaming error: $e');
  //     SnackbarService.error('Unexpected error, please try again');
  //   } finally {
  //     streamingText.value = '';
  //     isStreaming.value = false;
  //     isSending.value = false;
  //     scrollToBottom();
  //   }
  // }

  // // ── MULTIPART (with file) ──────────────────

  // Future<void> _sendWithFile(String text, PickedFileInfo file) async {
  //   final userMessage = {
  //     'id': DateTime.now().millisecondsSinceEpoch,
  //     'sender': 'user',
  //     'message': text.isNotEmpty ? text : 'Sent a file',
  //     'file_name': file.name,
  //   };
  //   currentMessages.add(userMessage);
  //   messageController.clear();
  //   clearFile();

  //   final fileToSend = file.file;
  //   scrollToBottom();

  //   try {
  //     isSending(true);

  //     final Map<String, String> fields = {
  //       "bot_id": botId.value.toString(),
  //       "message": text,
  //     };
  //     if (sessionId.value != null) {
  //       fields["session_id"] = sessionId.value.toString();
  //     }

  //     final response = await ApiService.uploadMultipart(
  //       url: ApiEndpoint.chatbot,
  //       method: 'POST',
  //       fields: fields,
  //       files: {'file': fileToSend},
  //     );

  //     if (response.statusCode == 200) {
  //       Console.success('Message sent with file');
  //       final data = response.data;

  //       if (data['session_id'] != null) {
  //         final newSessionId = data['session_id'];
  //         if (sessionId.value == null || sessionId.value != newSessionId) {
  //           sessionId.value = newSessionId;
  //           fetchSessionsForBot();
  //         }
  //       }

  //       final aiResponse = data['ai_response'];
  //       if (aiResponse != null && aiResponse['success'] == true) {
  //         currentMessages.add({
  //           'id': DateTime.now().millisecondsSinceEpoch + 1,
  //           'sender': 'violet',
  //           'message': aiResponse['response'] ?? '',
  //           'file_name': null,
  //         });
  //       }
  //       scrollToBottom();
  //     } else {
  //       Console.error('Error: ${response.data}');
  //       SnackbarService.error('Failed to send message');
  //     }
  //   } catch (e) {
  //     Console.error('Exception: $e');
  //     SnackbarService.error('Something went wrong');
  //   } finally {
  //     isSending(false);
  //   }
  // }

  // ============================================
  // RICH TEXT COPY (bold, bullets preserved)
  // ============================================

  Future<void> copyAsRichText(String markdownText, BuildContext context) async {
    try {
      // Convert markdown → HTML so Word/Docs gets formatting
      final html = md.markdownToHtml(
        markdownText,
        extensionSet: md.ExtensionSet.gitHubWeb,
      );

      final clipboard = SystemClipboard.instance;
      if (clipboard != null) {
        final item = DataWriterItem();
        item.add(Formats.htmlText(html)); // rich text for Word/Docs
        item.add(Formats.plainText(markdownText)); // plain fallback
        await clipboard.write([item]);
      } else {
        // Fallback if super_clipboard not available
        await Clipboard.setData(ClipboardData(text: markdownText));
      }

      SnackbarService.success('Copied to clipboard');
    } catch (e) {
      Console.error('Copy error: $e');
      // Last resort fallback
      await Clipboard.setData(ClipboardData(text: markdownText));
      SnackbarService.success('Copied to clipboard');
    }
  }

  // ============================================
  // API: DELETE SESSION
  // ============================================

  Future<void> deleteSession(int index) async {
    try {
      final session = currentBotSessions[index];
      final id = session['id'];
      Console.info('Deleting session: $id');
      isDeleting(true);

      final response = await ApiService.deleteAuth(
        "${ApiEndpoint.chatSession}$id/delete/",
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Console.success('Session deleted: $id');
        currentBotSessions.removeAt(index);
        if (sessionId.value == id) startNewChat();
        Get.back();
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
  // DELETE CONFIRMATION
  // ============================================

  void confirmDeleteSession(int index, BuildContext context) {
    final session = currentBotSessions[index];
    final title = session['title'] ?? 'Untitled';
    DeleteConfirmationDialog.showSmart(
      context: context,
      title: 'Delete Chat',
      itemName: title,
      onConfirm: () => deleteSession(index),
    );
    Console.info('Confirm delete session: $title');
  }

  // ============================================
  // HELPERS
  // ============================================

  void startNewChat() {
    currentMessages.clear();
    sessionId.value = null;
    messageController.clear();
    streamingText.value = '';
    clearFile();
    Console.info('New chat started');
  }

  void requestFocus() => messageFocusNode.requestFocus();

  void signOut() {
    Get.put(LoginController()).logout();
    Console.info('User signed out');
  }

  void resetScrollController() {
    _scrollController?.dispose();
    _scrollController = ScrollController();
    clearFile();
    Console.info('Controller reset');
  }
}
