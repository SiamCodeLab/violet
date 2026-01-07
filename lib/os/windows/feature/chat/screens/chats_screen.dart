import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:violet/core/const/path_strings.dart';
import 'package:violet/core/theme/theme_color.dart';
import 'package:violet/os/windows/feature/chat/widgets/animated_thinking_text.dart';
import 'package:violet/os/windows/feature/home/pages/home_screen.dart';

import '../controller/chat_controller.dart';

// Changed to StatefulWidget to properly handle controller lifecycle
class ChatsScreen extends StatefulWidget {
  final dynamic initialQuery;
  final String loadingIcon;
  final int botid;

  const ChatsScreen({
    super.key,
    required this.initialQuery,
    required this.loadingIcon,
    required this.botid,
  });

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  late final ChatController controller;

  @override
  void initState() {
    super.initState();

    //  FIX: Delete existing controller and create new one for each bot
    if (Get.isRegistered<ChatController>()) {
      Get.delete<ChatController>();
    }
    controller = Get.put(ChatController());

    //  FIX: Initialize bot AFTER build using addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setBotId(widget.botid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: _NavigationDrawer(controller: controller),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  PathStrings.mobileMenuIcon,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(PathStrings.phoneBg),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Chat Area
              Expanded(
                child: Obx(() {
                  if (controller.isMessagesLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Color(ThemeColor.primary),
                      ),
                    );
                  }

                  return controller.currentMessages.isEmpty
                      ? _EmptyState(image: widget.initialQuery)
                      : _ChatMessages(
                          controller: controller,
                          loadingIcon: widget.loadingIcon,
                        );
                }),
              ),
              // Input Section
              _BottomSection(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// EMPTY STATE WIDGET
// ============================================

class _EmptyState extends StatelessWidget {
  final dynamic image;

  const _EmptyState({required this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 80),
        Image(image: AssetImage(image), width: 150),
      ],
    );
  }
}

// ============================================
// CHAT MESSAGES WIDGET
// ============================================

class _ChatMessages extends StatelessWidget {
  final ChatController controller;
  final String loadingIcon;

  const _ChatMessages({required this.controller, required this.loadingIcon});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final messages = controller.currentMessages;
      final isSending = controller.isSending.value;

      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: messages.length + (isSending ? 1 : 0),
        itemBuilder: (_, index) {
          // Thinking bubble
          if (index == messages.length && isSending) {
            return _ThinkingBubble(loadingIcon: loadingIcon);
          }

          final chat = messages[index];
          final isUser = chat['sender'] == 'user';

          return _MessageBubble(
            message: chat['message'] ?? '',
            isUser: isUser,
            fileName: chat['file_name'], //  Pass file name if exists
          );
        },
      );
    });
  }
}

// ============================================
// MESSAGE BUBBLE WIDGET
// ============================================

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String? fileName; //  Optional file name

  const _MessageBubble({
    required this.message,
    required this.isUser,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Sender label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              isUser ? 'You' : 'Violet',
              style: TextStyle(
                color: Color(ThemeColor.borderColor),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          //  File attachment display (if file exists)
          if (fileName != null && fileName!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Color(ThemeColor.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color(ThemeColor.primary).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getFileIcon(fileName!),
                    size: 16,
                    color: Color(ThemeColor.primary),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      fileName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(ThemeColor.primary),
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Message bubble
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
          ),

          // Copy button for Violet
          if (!isUser)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: message));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Icon(Icons.copy_rounded, size: 18, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  //  Get icon based on file extension
  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }
}

// ============================================
// THINKING BUBBLE WIDGET
// ============================================

class _ThinkingBubble extends StatelessWidget {
  final String loadingIcon;

  const _ThinkingBubble({required this.loadingIcon});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(loadingIcon, width: 15),
            const SizedBox(width: 10),
            AnimatedThinkingText(),
          ],
        ),
      ),
    );
  }
}

// ============================================
// BOTTOM SECTION WIDGET
// ============================================

class _BottomSection extends StatelessWidget {
  final ChatController controller;

  const _BottomSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ⭐ File Attachment Preview
          _FileAttachmentPreview(controller: controller),

          // Input Field
          _FloatingInput(controller: controller),

          const SizedBox(height: 10),
          Text(
            'Users are responsible for verifying the accuracy of advice Violet provides as AI may on occasion produce incorrect information.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(ThemeColor.hintColor), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ============================================
// ⭐ FILE ATTACHMENT PREVIEW WIDGET
// ============================================

class _FileAttachmentPreview extends StatelessWidget {
  final ChatController controller;

  const _FileAttachmentPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final file = controller.selectedFile.value;

      // Don't show if no file selected
      if (file == null) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(ThemeColor.primary).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // File Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(ThemeColor.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getFileIcon(file.extension),
                color: Color(ThemeColor.primary),
                size: 20,
              ),
            ),

            const SizedBox(width: 10),

            // File Name & Size
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    file.sizeFormatted,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // ⭐ Remove Button (Cross)
            GestureDetector(
              onTap: () => controller.clearFile(),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    });
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }
}

// ============================================
// FLOATING INPUT WIDGET
// ============================================

class _FloatingInput extends StatelessWidget {
  final ChatController controller;

  const _FloatingInput({required this.controller});

  void _handleSend() {
    controller.sendMessage();
    controller.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          //  File Pick Button
          IconButton(
            icon: Icon(Icons.add, color: Color(ThemeColor.primary), size: 24),
            onPressed: () => controller.pickFile(),
          ),
          Expanded(
            child: TextField(
              controller: controller.messageController,
              focusNode: controller.messageFocusNode,
              decoration: const InputDecoration(
                hintText: "Type your message...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          Obx(
            () => IconButton(
              icon: controller.isSending.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(ThemeColor.hintColor),
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: Color(ThemeColor.hintColor),
                    ),
              onPressed: controller.isSending.value ? null : _handleSend,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// NAVIGATION DRAWER WIDGET
// ============================================

class _NavigationDrawer extends StatelessWidget {
  final ChatController controller;

  const _NavigationDrawer({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(ThemeColor.primary),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewPadding.top + 10,
                left: 16,
                right: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 16),
                  _DrawerItem(
                    icon: PathStrings.homeIcon,
                    label: 'Home',
                    onTap: () {
                      //  Clean up before going home
                      controller.resetController();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: PathStrings.newIcon,
                    label: 'New Chat',
                    onTap: () {
                      controller.startNewChat();
                      Navigator.pop(context);
                      controller.requestFocus();
                    },
                  ),
                  const SizedBox(height: 20),

                  //  Chat History Title with count
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Obx(
                      () => Text(
                        'Chat History (${controller.currentBotSessions.length})',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ⭐ Chat History List - Uses currentBotSessions
            Expanded(
              child: Obx(() {
                if (controller.isSessionLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                //  Use currentBotSessions instead of allSessions
                if (controller.currentBotSessions.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No chats yet',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.currentBotSessions.length,
                  itemBuilder: (_, index) {
                    //  Use currentBotSessions
                    final session = controller.currentBotSessions[index];
                    final isActive =
                        controller.sessionId.value == session['id'];

                    return _ChatHistoryItem(
                      title: session['title'] ?? 'Untitled',
                      isActive: isActive,
                      onTap: () {
                        Navigator.pop(context);
                        controller.loadSessionMessages(session['id']);
                      },
                      onDelete: () {
                        controller.confirmDeleteSession(index, context);
                      },
                    );
                  },
                );
              }),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    controller.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        PathStrings.logoutIcon,
                        width: 20,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Sign out',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// DRAWER ITEM WIDGET
// ============================================

class _DrawerItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(icon, width: 22, height: 22),
      title: Text(label, style: TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
    );
  }
}

// ============================================
// CHAT HISTORY ITEM WIDGET
// ============================================

class _ChatHistoryItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ChatHistoryItem({
    required this.title,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.white24 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.white54, size: 20),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
