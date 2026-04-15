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
  // API: SEND MESSAGE WITH STREAMING
  // ============================================

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    final file = selectedFile.value;

    if ((text.isEmpty && file == null) || isSending.value) return;

    if (file != null) {
      await _sendWithFileStreaming(text, file);
      return;
    }

    await _sendStreaming(text);
  }

  // ── STREAMING (text only) ──────────────────

  Future<void> _sendStreaming(String text) async {
    // Add user message immediately
    currentMessages.add({
      'id': DateTime.now().millisecondsSinceEpoch,
      'sender': 'user',
      'message': text,
      'file_name': null,
    });
    messageController.clear();
    scrollToBottom();

    isSending.value = true;
    isStreaming.value = true;
    streamingText.value = '';

    final StringBuffer fullText = StringBuffer();

    try {
      // Build the access token header same way your ApiService does
      final token = StorageService.getAccessToken();

      final request = http.Request('POST', Uri.parse(ApiEndpoint.chatbot));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'application/x-www-form-urlencoded';

      final Map<String, String> fields = {
        'bot_id': botId.value.toString(),
        'message': text,
      };
      if (sessionId.value != null) {
        fields['session_id'] = sessionId.value.toString();
      }
      request.bodyFields = fields;

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 100),
        onTimeout: () => throw TimeoutException('Connection timed out'),
      );

      if (streamedResponse.statusCode == 200) {
        await for (final line
            in streamedResponse.stream
                .transform(utf8.decoder)
                .transform(const LineSplitter())) {
          if (line.trim().isEmpty) continue;

          try {
            final json = jsonDecode(line);

            if (json['type'] == 'chunk') {
              fullText.write(json['text']);
              streamingText.value = fullText.toString(); // live update UI
              scrollToBottom();
            } else if (json['type'] == 'done') {
              // Stream complete — check if new session was created
              if (json['session_id'] != null) {
                final newId = json['session_id'] as int;
                if (sessionId.value == null || sessionId.value != newId) {
                  sessionId.value = newId;
                  fetchSessionsForBot();
                }
              }
              break;
            }
          } catch (_) {
            continue; // skip malformed lines
          }
        }

        // Move streamed text into messages list
        if (fullText.isNotEmpty) {
          currentMessages.add({
            'id': DateTime.now().millisecondsSinceEpoch + 1,
            'sender': 'violet',
            'message': fullText.toString(),
            'file_name': null,
          });
        }
      } else {
        SnackbarService.error('Failed to send message');
      }
    } on TimeoutException {
      Console.error('Streaming timeout');
      SnackbarService.error('Request timed out, please try again');
    } catch (e) {
      Console.error('Streaming error: $e');
      SnackbarService.error('Unexpected error, please try again');
    } finally {
      streamingText.value = '';
      isStreaming.value = false;
      isSending.value = false;
      scrollToBottom();
    }
  }

  // ── MULTIPART (with file) ──────────────────

  Future<void> _sendWithFileStreaming(String text, PickedFileInfo file) async {
    // Add user message to UI immediately
    currentMessages.add({
      'id': DateTime.now().millisecondsSinceEpoch,
      'sender': 'user',
      'message': text.isNotEmpty ? text : 'Sent a file',
      'file_name': file.name,
    });

    messageController.clear();
    clearFile();
    scrollToBottom();

    isSending.value = true;
    isStreaming.value = true;
    streamingText.value = '';

    final StringBuffer fullText = StringBuffer();

    try {
      Console.info('[Upload] Starting upload process for ${file.name}');

      if (botId.value == 0) {
        throw Exception('Bot ID is not set.');
      }

      final token = StorageService.getAccessToken();
      if (token.isEmpty) {
        throw Exception('Access token is missing.');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoint.chatbot),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Fields
      request.fields['bot_id'] = botId.value.toString();

      if (text.isNotEmpty) {
        request.fields['message'] = text;
      }

      if (sessionId.value != null) {
        request.fields['session_id'] = sessionId.value.toString();
      }

      Console.info('[Upload] Reading file bytes...');

      // FIX: Read file to bytes manually to avoid MultipartFile.fromPath hanging on Windows
      // Ensure you have 'import "dart:io";' at the top of your file
      final filePath = file.file.path;
      final fileOnDisk = File(filePath);

      if (!await fileOnDisk.exists()) {
        throw Exception('File does not exist at path: $filePath');
      }

      // Read file into memory
      final fileBytes = await fileOnDisk.readAsBytes();
      Console.info(
        '[Upload] File read successfully (${fileBytes.length} bytes).',
      );

      // Add bytes to request
      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: file.name),
      );

      Console.info('[Upload] File attached to request.');

      Console.info('[Upload] Sending HTTP Request...');

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 120),
        onTimeout: () {
          Console.error('[Upload] Request timed out');
          throw TimeoutException('Connection timed out');
        },
      );

      Console.info(
        '[Upload] Response Status Code: ${streamedResponse.statusCode}',
      );

      if (streamedResponse.statusCode == 200) {
        await for (final line
            in streamedResponse.stream
                .transform(utf8.decoder)
                .transform(const LineSplitter())) {
          if (line.trim().isEmpty) continue;

          try {
            final json = jsonDecode(line);

            if (json['type'] == 'chunk') {
              fullText.write(json['text']);
              streamingText.value = fullText.toString();
              scrollToBottom();
            } else if (json['type'] == 'done') {
              if (json['session_id'] != null) {
                final newId = json['session_id'] as int;
                if (sessionId.value == null || sessionId.value != newId) {
                  sessionId.value = newId;
                  fetchSessionsForBot();
                }
              }
              break;
            }
          } catch (e) {
            Console.error('[Upload] Skipping invalid stream line: $line');
            continue;
          }
        }

        if (fullText.isNotEmpty) {
          currentMessages.add({
            'id': DateTime.now().millisecondsSinceEpoch + 1,
            'sender': 'violet',
            'message': fullText.toString(),
            'file_name': null,
          });
        }
      } else {
        String errorBody = '';
        try {
          errorBody = await streamedResponse.stream.bytesToString();
        } catch (_) {}
        Console.error(
          '[Upload] Server Error ${streamedResponse.statusCode}: $errorBody',
        );
        SnackbarService.error('Server error: ${streamedResponse.statusCode}');
      }
    } on TimeoutException {
      SnackbarService.error('Request timed out');
    } catch (e) {
      Console.error('[Upload] Critical Error: $e');
      SnackbarService.error('Failed to send file: ${e.toString()}');
    } finally {
      streamingText.value = '';
      isStreaming.value = false;
      isSending.value = false;
      scrollToBottom();
    }
  }

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
