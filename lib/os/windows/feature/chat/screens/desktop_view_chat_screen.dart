import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:violet/core/const/path_strings.dart';
import 'package:violet/core/theme/theme_color.dart';
import 'package:violet/os/windows/feature/chat/controller/chat_controller.dart';
import 'package:violet/os/windows/feature/chat/widgets/animated_thinking_text.dart';
import 'package:violet/os/windows/feature/home/pages/home_screen.dart';

class DesktopViewChatScreen extends StatefulWidget {
  final String initialQuery;
  final String loadingIcon;
  final String title;
  final int botid;

  const DesktopViewChatScreen({
    super.key,
    required this.initialQuery,
    required this.title,
    required this.loadingIcon,
    required this.botid,
  });

  @override
  State<DesktopViewChatScreen> createState() => _DesktopViewChatScreenState();
}

class _DesktopViewChatScreenState extends State<DesktopViewChatScreen> {
  late final ChatController controller;

  @override
  void initState() {
    super.initState();

    // ⭐ FIX: Use Get.put with tag OR delete existing and recreate
    // Option 1: Delete existing controller and create new one for each bot
    if (Get.isRegistered<ChatController>()) {
      Get.delete<ChatController>();
    }
    controller = Get.put(ChatController());

    // ⭐ FIX: Initialize bot AFTER build using addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setBotId(widget.botid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          _DesktopSidebar(controller: controller, botTitle: widget.title),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
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
                          ? _DesktopEmptyState(image: widget.initialQuery)
                          : _DesktopChatMessages(
                              controller: controller,
                              loadingIcon: widget.loadingIcon,
                            );
                    }),
                  ),
                  _DesktopFloatingInput(controller: controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// SIDEBAR WIDGET
// ============================================

class _DesktopSidebar extends StatefulWidget {
  final ChatController controller;
  final String botTitle;

  const _DesktopSidebar({required this.controller, required this.botTitle});

  @override
  State<_DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends State<_DesktopSidebar> {
  bool isCollapsed = false;
  String? hoveredItem;
  String? hoveredSidebarItem;
  final ScrollController _sidebarScrollController = ScrollController();

  @override
  void dispose() {
    _sidebarScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 70 : 250,
      color: Color(ThemeColor.primary),
      child: ClipRect(
        child: OverflowBox(
          maxWidth: 250,
          minWidth: 70,
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: isCollapsed ? 70 : 250,
            child: Column(
              children: [
                const SizedBox(height: 25),
                Padding(
                  padding: EdgeInsets.only(left: isCollapsed ? 10 : 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Image.asset(
                        PathStrings.menuIcon,
                        width: 20,
                        height: 20,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          setState(() => isCollapsed = !isCollapsed),
                    ),
                  ),
                ),

                // Current Bot Info
                if (!isCollapsed)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.smart_toy, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.botTitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                _buildSidebarItem(PathStrings.homeIcon, "Home", "home", () {
                  // ⭐ Clean up before going home
                  widget.controller.resetController();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
                }),

                _buildSidebarItem(
                  PathStrings.newIcon,
                  "New Chat",
                  "new_chat",
                  () {
                    widget.controller.startNewChat();
                    widget.controller.requestFocus();
                  },
                ),

                const SizedBox(height: 8),

                if (!isCollapsed)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Obx(
                        () => Text(
                          "Chat History (${widget.controller.currentBotSessions.length})",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                if (!isCollapsed)
                  Expanded(
                    child: Obx(() {
                      if (widget.controller.isSessionLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      if (widget.controller.currentBotSessions.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No chats yet',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _sidebarScrollController,
                        itemCount: widget.controller.currentBotSessions.length,
                        itemBuilder: (_, index) {
                          final session =
                              widget.controller.currentBotSessions[index];
                          final isActive =
                              widget.controller.sessionId.value ==
                              session['id'];

                          return _buildHistoryItem(
                            "history_$index",
                            Icons.chat_bubble_outline,
                            session['title'] ?? 'Untitled',
                            isActive,
                            () => widget.controller.loadSessionMessages(
                              session['id'],
                            ),
                            () => widget.controller.confirmDeleteSession(
                              index,
                              context,
                            ),
                          );
                        },
                      );
                    }),
                  )
                else
                  Expanded(child: SizedBox()),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () => widget.controller.signOut(),
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(PathStrings.logoutIcon, width: 18),
                          if (!isCollapsed) ...[
                            const SizedBox(width: 8),
                            Text(
                              "Sign out",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
    String iconPath,
    String label,
    String id,
    VoidCallback onTap,
  ) {
    final isHovered = hoveredSidebarItem == id;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredSidebarItem = id),
      onExit: (_) => setState(() => hoveredSidebarItem = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isHovered
              ? Colors.white.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          minLeadingWidth: 20,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 8 : 16,
          ),
          leading: Image.asset(
            iconPath,
            width: 20,
            height: 20,
            color: Colors.white.withOpacity(isHovered ? 1 : 0.8),
          ),
          title: isCollapsed
              ? null
              : Text(
                  label,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    String id,
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
    VoidCallback onDelete,
  ) {
    final isHovered = hoveredItem == id;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredItem = id),
      onExit: (_) => setState(() => hoveredItem = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white24
              : (isHovered ? Colors.white12 : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          title: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          trailing: isHovered
              ? IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white70),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                )
              : null,
          onTap: onTap,
        ),
      ),
    );
  }
}

// ============================================
// EMPTY STATE
// ============================================

class _DesktopEmptyState extends StatelessWidget {
  final String image;

  const _DesktopEmptyState({required this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 120),
        Image(image: AssetImage(image), width: 150),
      ],
    );
  }
}

// ============================================
// CHAT MESSAGES
// ============================================

class _DesktopChatMessages extends StatelessWidget {
  final ChatController controller;
  final String loadingIcon;

  const _DesktopChatMessages({
    required this.controller,
    required this.loadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final messages = controller.currentMessages;
      final isSending = controller.isSending.value;

      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: ListView.builder(
            controller: controller.scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: messages.length + (isSending ? 1 : 0),
            itemBuilder: (_, index) {
              if (index == messages.length && isSending) {
                return _DesktopLoadingBubble(loadingIcon: loadingIcon);
              }

              final chat = messages[index];
              final isUser = chat['sender'] == 'user';

              return _DesktopMessageBubble(
                message: chat['message'] ?? '',
                isUser: isUser,
              );
            },
          ),
        ),
      );
    });
  }
}

// ============================================
// MESSAGE BUBBLE
// ============================================

class _DesktopMessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const _DesktopMessageBubble({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              isUser ? "You" : "Violet",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.80,
                minWidth: 100,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SelectableText(
                message,
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
            if (!isUser)
              IconButton(
                icon: Icon(Icons.copy_rounded, size: 20, color: Colors.black),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: message));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// LOADING BUBBLE
// ============================================

class _DesktopLoadingBubble extends StatelessWidget {
  final String loadingIcon;

  const _DesktopLoadingBubble({required this.loadingIcon});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(loadingIcon, width: 15),
            const SizedBox(width: 8),
            AnimatedThinkingText(),
          ],
        ),
      ),
    );
  }
}

// ============================================
// FLOATING INPUT
// ============================================

class _DesktopFloatingInput extends StatelessWidget {
  final ChatController controller;

  const _DesktopFloatingInput({required this.controller});

  void _handleSend() {
    controller.sendMessage();
    controller.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
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
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Color(ThemeColor.borderColor),
                          size: 26,
                        ),
                        onPressed: () {},
                      ),
                      Expanded(
                        child: Focus(
                          onKeyEvent: (FocusNode node, KeyEvent event) {
                            if (event is KeyDownEvent &&
                                event.logicalKey == LogicalKeyboardKey.enter &&
                                !HardwareKeyboard.instance.isShiftPressed) {
                              _handleSend();
                              return KeyEventResult.handled;
                            }
                            return KeyEventResult.ignored;
                          },
                          child: TextField(
                            controller: controller.messageController,
                            focusNode: controller.messageFocusNode,
                            decoration: const InputDecoration(
                              hintText: "Type your message...",
                              border: InputBorder.none,
                            ),
                            maxLines: null,
                          ),
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
                          onPressed: controller.isSending.value
                              ? null
                              : _handleSend,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    'Users are responsible for verifying the accuracy of advice Violet provides as AI may on occasion produce incorrect information.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (MediaQuery.of(context).size.width * 0.016)
                          .clamp(12.0, 18.0),
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
