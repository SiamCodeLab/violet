import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:markdown/markdown.dart' as md;
import 'package:super_clipboard/super_clipboard.dart';
import 'package:violet/core/services/api_service.dart';
import 'package:violet/core/services/snackbar_service.dart';
import 'package:violet/core/services/storage/storage_service.dart';
import 'package:violet/core/services/websocket_service.dart';
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
  late final WebSocketService _wsService; // Service Instance

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

    // GET SERVICE INSTANCE
    _wsService = WebSocketService.to;

    // BIND CALLBACKS
    _setupWebSocketListeners();
  }

  @override
  void onClose() {
    messageController.dispose();
    _scrollController?.dispose();
    messageFocusNode.dispose();
    // We do NOT close the service here, as it is global
    _clearListeners();
    super.onClose();
  }

  // ============================================
  // WEBSOCKET LISTENERS
  // ============================================

  void _setupWebSocketListeners() {
    _wsService.onMessage = _handleWSMessage;

    // Handle Stream Close (Server hung up or finished)
    _wsService.onDone = _handleWSDisconnect;

    // Handle Errors (Network issue, etc.)
    _wsService.onError = (error) {
      Console.error(' WS Stream Error: $error');

      // Only alert the user if we were actually waiting for a message
      if (isSending.value) {
        SnackbarService.error('Connection error');

        // IMPORTANT: Stop loading so user can try again
        _finalizeStreamingMessage();
      }
    };
  }

  void _handleWSDisconnect() {
    Console.error(' WS Stream Closed');

    // If we were expecting a message and the socket closed without "done",
    // assume the message is finished (or failed) and stop the loader.
    if (isSending.value) {
      _finalizeStreamingMessage();
    }
  }

  void _clearListeners() {
    _wsService.onMessage = null;
    _wsService.onDone = null;
    _wsService.onError = null;
  }

  // ============================================
  // ROBUST STREAM HANDLING (No Timer)
  // ============================================

  // ============================================
  // ROBUST STREAM HANDLING (No Timer)
  // ============================================

  // ============================================
  // ROBUST STREAM HANDLING (Handles Error Types)
  // ============================================

  void _handleWSMessage(String message) {
    // SAFETY WRAPPER
    try {
      Console.debug('WS Raw: $message');

      // 1. TRY TO PARSE JSON
      final dynamic json = jsonDecode(message);

      // 2. CHECK FOR "DONE" SIGNAL
      if (json is Map &&
          (json['type'] == 'done' ||
              json['status'] == 'done' ||
              json['done'] == true)) {
        Console.info('Server signal received: DONE');
        _finalizeStreamingMessage();
        return;
      }

      // 3. CHECK FOR "ERROR" SIGNAL (THE FIX)
      if (json is Map && json['type'] == 'error') {
        final errorMessage =
            json['message'] ?? json['error'] ?? 'An unknown error occurred';
        Console.error('Backend Error: $errorMessage');

        // Show error to user
        SnackbarService.error(errorMessage);

        // Stop loading because the bot won't reply
        _finalizeStreamingMessage();
        return;
      }

      // 4. HANDLE TEXT CHUNKS
      String? textChunk;

      if (json is Map) {
        textChunk =
            json['text'] ?? json['content'] ?? json['chunk'] ?? json['message'];
      } else if (json is String) {
        textChunk = json;
      }

      // 5. APPEND TEXT IF FOUND
      if (textChunk != null && textChunk.isNotEmpty) {
        streamingText.value = streamingText.value + textChunk;
        scrollToBottom();
      }
    } catch (e, stacktrace) {
      Console.error('Failed to parse WS message: $message');
      Console.debug('Stacktrace: $stacktrace');
      // Do nothing, keep connection alive
    }
  }

  // ============================================
  // SEND MESSAGE LOGIC
  // ============================================

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    final file = selectedFile.value;

    if ((text.isEmpty && file == null) || isSending.value) return;

    // 1. Add User Message to UI
    currentMessages.add({
      'id': DateTime.now().millisecondsSinceEpoch,
      'sender': 'user',
      'message': text.isNotEmpty ? text : 'Sent a file',
      'file_name': file?.name,
    });

    messageController.clear();
    scrollToBottom();
    isSending.value = true;
    isStreaming.value = true;
    streamingText.value = '';

    try {
      int? fileId;

      // 2. If File Exists, Upload First
      if (file != null) {
        fileId = await _uploadFile(file);
        if (fileId == null) {
          throw Exception('File upload failed');
        }
        clearFile();
      }

      // 3. Send Payload via Service
      final payload = {
        "bot_id": botId.value.toString(),
        "message": text,
        if (sessionId.value != null) "session_id": sessionId.value,
        if (fileId != null) "file_id": fileId,
      };

      Console.info('WS Sending: ${jsonEncode(payload)}');
      _wsService.sendMessage(payload);
    } catch (e) {
      Console.error('Send Message Error: $e');
      SnackbarService.error('Failed to send: $e');
      isSending.value = false;
      isStreaming.value = false;
    }
  }

  // ============================================
  // FILE UPLOAD LOGIC (REST API)
  // ============================================

  Future<int?> _uploadFile(PickedFileInfo file) async {
    try {
      final token = StorageService.getAccessToken();
      final uri = Uri.parse(ApiEndpoint.chatFileUpload);

      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token';

      final fileOnDisk = File(file.file.path);
      final fileBytes = await fileOnDisk.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: file.name),
      );

      Console.info('Uploading file: ${file.name}...');
      final response = await request.send().timeout(
        const Duration(seconds: 60),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final json = jsonDecode(responseBody);

        final fileId = json['file_details']?['id'];
        Console.success('File uploaded. ID: $fileId');
        return fileId;
      } else {
        Console.error('Upload Failed: ${response.statusCode}');
        SnackbarService.error('File upload failed');
        return null;
      }
    } catch (e) {
      Console.error('Upload Exception: $e');
      SnackbarService.error('File upload error');
      return null;
    }
  }

  void _finalizeStreamingMessage() {
    // Only run if we are in a sending state to avoid double-processing
    if (isSending.value || isStreaming.value) {
      // If we have accumulated text, save it to the chat history
      if (streamingText.value.isNotEmpty) {
        currentMessages.add({
          'id': DateTime.now().millisecondsSinceEpoch + 1,
          'sender': 'violet',
          'message': streamingText.value,
          'file_name': null,
        });
      }

      // Reset UI State
      streamingText.value = '';
      isStreaming.value = false;
      isSending.value = false;
      scrollToBottom();

      Console.info('🏁 Message Finalized');
    }
  }

  // ============================================
  // HELPERS (Keep as is)
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

  Future<void> copyAsRichText(String markdownText, BuildContext context) async {
    try {
      final html = md.markdownToHtml(
        markdownText,
        extensionSet: md.ExtensionSet.gitHubWeb,
      );

      final clipboard = SystemClipboard.instance;
      if (clipboard != null) {
        final item = DataWriterItem();
        item.add(Formats.htmlText(html));
        item.add(Formats.plainText(markdownText));
        await clipboard.write([item]);
      } else {
        await Clipboard.setData(ClipboardData(text: markdownText));
      }

      SnackbarService.success('Copied to clipboard');
    } catch (e) {
      Console.error('Copy error: $e');
      await Clipboard.setData(ClipboardData(text: markdownText));
      SnackbarService.success('Copied to clipboard');
    }
  }

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
