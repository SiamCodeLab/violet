import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:violet/core/const/string_cont/path_strings.dart';
import 'package:violet/core/theme/theme_color.dart';
import 'package:violet/os/windows/feature/auth/pages/login_screen.dart';
import 'package:violet/os/windows/feature/home/pages/home_screen.dart';

class ChatScreen extends StatefulWidget {
  String initialQuery;
  String title;
  ChatScreen({super.key, required this.initialQuery, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isCollapsed = false;
  String? hoveredItem;
  String? hoveredSidebarItem;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final ScrollController _sidebarScrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  List<Map<String, dynamic>> chatSessions = [];
  int? currentChatIndex;
  List<Map<String, String>> currentMessages = [];
  bool isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _chatScrollController.dispose();
    _sidebarScrollController.dispose();
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
      backgroundColor: Colors.white,
      body: Row(
        children: [
          _buildSideBar(),

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
                    child: isChatEmpty ? _buildEmptyState() : _buildChatMessages(),
                  ),
                  _buildFloatingInput(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SIDEBAR =================

  Widget _buildSideBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 70 : 250,
      color: Color(ThemeColor.primary),

      // Prevent internal widgets from reflowing during animation
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
                      onPressed: () => setState(() => isCollapsed = !isCollapsed),
                    ),
                  ),
                ),

                _sidebarItem(PathStrings.homeIcon, "Home", "home", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                }, collapsed: isCollapsed),

                _sidebarItem(PathStrings.newIcon, "New Chat", "new_chat", () {
                  _startNewChat();
                }, collapsed: isCollapsed),

                const SizedBox(height: 8),

                // Chat History Title
                if (!isCollapsed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Chat History",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Chat List
                if (!isCollapsed)
                  Expanded(
                    child: ListView.builder(
                      controller: _sidebarScrollController,
                      itemCount: chatSessions.length,
                      itemBuilder: (_, index) {
                        final session = chatSessions[index];
                        final isActive = currentChatIndex == index;

                        return _sidebarHistoryItem(
                          "history_$index",
                          Icons.chat_bubble_outline,
                          session['title'],
                          isActive,
                              () => _loadChatSession(index),
                              () => _deleteChatSession(index),
                        );
                      },
                    ),
                  )
                else
                  Expanded(child: SizedBox()),

                // 🔥 Logout Button (Stable, No Wrapping, No Jumps)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            PathStrings.logoutIcon,
                            width: 18,
                          ),
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



  // ================= EMPTY STATE =================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: AssetImage(widget.initialQuery),
            width: 150,
          ),
          Text('Ask Violet',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.normal, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // ================= CHAT LIST =================

  Widget _buildChatMessages() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: ListView.builder(
          controller: _chatScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: currentMessages.length + (isLoading ? 1 : 0),
          itemBuilder: (_, index) {
            if (index == currentMessages.length && isLoading) {
              return _loadingBubble();
            }

            final chat = currentMessages[index];
            final isUser = chat['sender'] == 'user';

            return Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(isUser ? "You" : "Violet",
                        style: TextStyle(color: Colors.grey, fontSize: 12)),

                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),

                      // 🔥 80% message bubble
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
                        chat['message']!,
                        style: TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ),
                    ?isUser ? null : IconButton(
                      icon: Icon(Icons.copy_rounded, size: 20, color: Colors.black),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: chat['message'].toString()));
                      },
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _loadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/ai_loading.png',
              width: 20,
            ),
            const SizedBox(width: 8),
            Text("Violet is thinking...",
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // ================= FLOATING INPUT =================

  Widget _buildFloatingInput() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                        icon: Icon(Icons.add, color: Color(ThemeColor.borderColor), size: 26),
                        onPressed: () {},
                      ),
                
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          focusNode: _messageFocusNode,
                          decoration: const InputDecoration(
                            hintText: "Type your message...",
                            border: InputBorder.none,
                          ),
                          maxLines: null,
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: Color(ThemeColor.hintColor)),
                        onPressed: () {
                          _sendMessage();
                        },
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
                      fontSize: (MediaQuery.of(context).size.width * 0.016).clamp(12.0, 18.0),
                      color: Colors.grey[600],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
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

    Future.delayed(const Duration(milliseconds: 800), () {
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
    if (m.contains('fitness')) return "Try mixing cardio and strength.";
    if (m.contains('diet')) return "Eat whole foods and stay hydrated.";
    if (m.contains('sleep')) return "Aim for 7–9 hours of sleep.";
    if (m.contains('stress')) return "Try meditation and deep breathing.";
    if (m.contains('hello') || m.contains('hi')) return "Hello! I'm Violet.";
    return "I'm here to help!";
  }

  void _startNewChat() {
    if (isLoading) return;
    setState(() {
      currentMessages = [];
      currentChatIndex = null;
    });
    _messageFocusNode.requestFocus();
  }

  void _updateChatSession() {
    if (currentMessages.isEmpty) return;

    final firstUserMsg = currentMessages.firstWhere(
          (msg) => msg['sender'] == 'user',
      orElse: () => {'message': 'New Chat'},
    );

    String title = firstUserMsg['message']!;
    if (title.length > 30) title = "${title.substring(0, 30)}...";

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
    _scrollToBottom();
  }

  void _deleteChatSession(int index) {
    setState(() {
      chatSessions.removeAt(index);
      if (currentChatIndex == index) {
        currentMessages = [];
        currentChatIndex = null;
      }
    });
  }

  // ================= ITEM BUILDER =================

  Widget _sidebarItem(String iconPath, String label, String id, VoidCallback onTap,
      {required bool collapsed}) {
    final isHovered = hoveredSidebarItem == id;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredSidebarItem = id),
      onExit: (_) => setState(() => hoveredSidebarItem = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isHovered ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          minLeadingWidth: 20,
          contentPadding: EdgeInsets.symmetric(horizontal: collapsed ? 8 : 16),
          leading: Image.asset(iconPath,
              width: 20, height: 20, color: Colors.white.withOpacity(isHovered ? 1 : 0.8)),
          title: collapsed
              ? null
              : Text(label, style: TextStyle(color: Colors.white, fontSize: 15)),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _sidebarHistoryItem(
      String id, IconData icon, String label, bool isActive, VoidCallback onTap, VoidCallback onDelete) {
    final isHovered = hoveredItem == id;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredItem = id),
      onExit: (_) => setState(() => hoveredItem = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? Colors.white24 : (isHovered ? Colors.white12 : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          title: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 14)),
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
