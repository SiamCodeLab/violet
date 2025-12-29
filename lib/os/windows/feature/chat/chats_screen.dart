import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:violet/core/const/string_cont/path_strings.dart';
import 'package:violet/core/theme/theme_color.dart';
import 'package:violet/os/windows/feature/auth/pages/login_screen.dart';
import 'package:violet/os/windows/feature/chat/widgets/animated_thinking_text.dart';
import 'package:violet/os/windows/feature/home/pages/home_screen.dart';

class ChatsScreen extends StatefulWidget {
  final dynamic initialQuery;
  final String loadingIcon;

  const ChatsScreen({
    super.key,
    required this.initialQuery,
    required this.loadingIcon,
  });

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  // chat data
  List<Map<String, dynamic>> chatSessions = [];
  int? currentChatIndex;
  List<Map<String, String>> currentMessages = [];
  bool isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _chatScrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!mounted || !_chatScrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isChatEmpty = currentMessages.isEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: _buildNavigationDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
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
              // chat area
              Expanded(
                child: isChatEmpty
                    ? _buildEmptyState(widget.initialQuery)
                    : _buildChatMessages(),
              ),
              // input + disclaimer
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= EMPTY STATE =================

  Widget _buildEmptyState(dynamic initialQuery) {
    return Column(
      children: [
        SizedBox(height: 80),
        Image(image: AssetImage(initialQuery), width: 150),
      ],
    );
  }

  // ================= CHAT MESSAGES =================

  Widget _buildChatMessages() {
    return ListView.builder(
      controller: _chatScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: currentMessages.length + (isLoading ? 1 : 0),
      itemBuilder: (_, index) {
        // loading bubble at the end
        if (index == currentMessages.length && isLoading) {
          return _loadingBubble();
        }

        final chat = currentMessages[index];
        final isUser = chat['sender'] == 'user';

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // sender label
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

              // message bubble
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
                  chat['message']!,
                  style: TextStyle(color: Colors.black, fontSize: 15),
                ),
              ),

              // copy button for violet messages
              if (!isUser)
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: chat['message'].toString()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _loadingBubble() {
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
            Image.asset(widget.loadingIcon, width: 15),
            const SizedBox(width: 10),
            AnimatedThinkingText(),
          ],
        ),
      ),
    );
  }

  // ================= BOTTOM SECTION =================

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFloatingInput(),
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

  Widget _buildFloatingInput() {
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
          IconButton(
            icon: Icon(Icons.add, color: Color(ThemeColor.primary), size: 24),
            onPressed: () {
              // attachment action
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _messageFocusNode,
              decoration: const InputDecoration(
                hintText: "Type your message...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send_rounded, color: Color(ThemeColor.hintColor)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  // ================= MESSAGE LOGIC =================

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || isLoading) return;

    final userMessage = _messageController.text.trim();

    setState(() {
      currentMessages.add({'sender': 'user', 'message': userMessage});
      isLoading = true;
      _messageController.clear();
    });

    _scrollToBottom();

    // fake delay for AI response
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        currentMessages.add({
          'sender': 'violet',
          'message': _generateAIResponse(userMessage),
        });
        isLoading = false;
        _updateChatSession();
      });

      _scrollToBottom();
      _messageFocusNode.requestFocus();
    });
  }

  String _generateAIResponse(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('fitness'))
      return "Try mixing cardio and strength training for best results.";
    if (m.contains('diet'))
      return "Focus on whole foods and stay hydrated throughout the day.";
    if (m.contains('sleep'))
      return "Aim for 7–9 hours of quality sleep each night.";
    if (m.contains('stress'))
      return "Try meditation, deep breathing, or a short walk.";
    if (m.contains('hello') || m.contains('hi'))
      return "Hello! I'm Violet. How can I help you today?";
    if (m.contains('care'))
      return "Person-centred care focuses on individual needs and preferences.";
    if (m.contains('training'))
      return "We have various training resources available for care staff.";
    if (m.contains('activity') || m.contains('activities'))
      return "Activities should be tailored to each resident's interests and abilities.";
    if (m.contains('policy'))
      return "I can help you understand care home policies and regulations.";
    return "I'm here to help with care-related questions!";
  }

  void _startNewChat() {
    if (isLoading) return;
    setState(() {
      currentMessages = [];
      currentChatIndex = null;
    });
    Navigator.pop(context); // close drawer
    _messageFocusNode.requestFocus();
  }

  void _updateChatSession() {
    if (currentMessages.isEmpty) return;

    final firstUserMsg = currentMessages.firstWhere(
      (msg) => msg['sender'] == 'user',
      orElse: () => {'message': 'New Chat'},
    );

    String title = firstUserMsg['message']!;
    if (title.length > 25) title = "${title.substring(0, 25)}...";

    if (currentChatIndex != null) {
      chatSessions[currentChatIndex!] = {
        'title': title,
        'messages': List.from(currentMessages),
      };
    } else {
      chatSessions.insert(0, {
        'title': title,
        'messages': List.from(currentMessages),
      });
      currentChatIndex = 0;
    }
  }

  void _loadChatSession(int index) {
    setState(() {
      currentChatIndex = index;
      currentMessages = List.from(chatSessions[index]['messages']);
    });
    Navigator.pop(context); // close drawer
    _scrollToBottom();
  }

  void _deleteChatSession(int index) {
    setState(() {
      chatSessions.removeAt(index);
      if (currentChatIndex == index) {
        currentMessages = [];
        currentChatIndex = null;
      } else if (currentChatIndex != null && currentChatIndex! > index) {
        currentChatIndex = currentChatIndex! - 1;
      }
    });
  }

  // ================= NAVIGATION DRAWER =================

  Widget _buildNavigationDrawer() {
    return Drawer(
      child: Container(
        color: Color(ThemeColor.primary),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // safe area + menu button
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewPadding.top + 10,
                left: 16,
                right: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // close drawer
                  IconButton(
                    icon: Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 16),

                  // home button
                  _drawerItem(
                    icon: PathStrings.homeIcon,
                    label: 'Home',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                  ),

                  // new chat button
                  _drawerItem(
                    icon: PathStrings.newIcon,
                    label: 'New Chat',
                    onTap: _startNewChat,
                  ),

                  const SizedBox(height: 20),

                  // chat history header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'Chat History',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // chat history list
            Expanded(
              child: chatSessions.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No chats yet',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: chatSessions.length,
                      itemBuilder: (_, index) {
                        final session = chatSessions[index];
                        final isActive = currentChatIndex == index;

                        return _chatHistoryItem(
                          title: session['title'],
                          isActive: isActive,
                          onTap: () => _loadChatSession(index),
                          onDelete: () => _deleteChatSession(index),
                        );
                      },
                    ),
            ),

            // logout button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
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

  Widget _drawerItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Image.asset(icon, width: 22, height: 22),
      title: Text(label, style: TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
    );
  }

  Widget _chatHistoryItem({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
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
