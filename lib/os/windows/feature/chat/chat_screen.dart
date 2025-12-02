import 'package:flutter/material.dart';
import 'package:violet/core/const/string_cont/path_strings.dart';
import 'package:violet/core/theme/theme_color.dart';
import 'package:violet/os/windows/feature/home/pages/home_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isCollapsed = false;
  String? hoveredItem;
  String? hoveredSidebarItem;
  final TextEditingController _messageController = TextEditingController();

  // Store all chat sessions
  List<Map<String, dynamic>> chatSessions = [];
  int? currentChatIndex;

  // Current chat messages
  List<Map<String, String>> currentMessages = [];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isChatEmpty = currentMessages.isEmpty;

    return Scaffold(
      body: Row(
        children: [
          // ----------------------------------------
          // COLLAPSIBLE SIDEBAR
          // ----------------------------------------

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isCollapsed ? 70 : 250,
            decoration: BoxDecoration(
              color: Color(ThemeColor.primary),
            ),
            child: Column(
              children: [
                const SizedBox(height: 25),

                // Collapse Button
                Padding(
                  padding: EdgeInsets.only(left: isCollapsed ? 10 : 16,),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Image.asset(
                        PathStrings.menuIcon,
                        width: 20,
                        height: 20,
                        color: Colors.white,
                      ),
                      tooltip: isCollapsed ? 'Expand menu' : 'Collapse menu',
                      onPressed: () {
                        setState(() => isCollapsed = !isCollapsed);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Sidebar Items
                _sidebarItem(
                    PathStrings.homeIcon,
                    "Home", "home",
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    collapsed: isCollapsed
                ),
                _sidebarItem(
                    PathStrings.newIcon,
                    "New Chat", "new_chat",
                        () {
                      _startNewChat();
                    },
                    collapsed: isCollapsed),

                const SizedBox(height: 8),

                // Chat history title
                if (!isCollapsed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Chat History",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                // Chat history list
                if (!isCollapsed)
                  Expanded(
                    child: chatSessions.isEmpty
                        ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "No chat history yet",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                        : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 8, top: 4),
                      itemCount: chatSessions.length,
                      itemBuilder: (context, index) {
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
                  const Spacer(),

                const SizedBox(height: 10),

                // Logout Button
                if (!isCollapsed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Add sign out logic here
                      },
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text(
                        "Sign out",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(ThemeColor.primary),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white, size: 26),
                      tooltip: 'Sign out',
                      onPressed: () {
                        // Add sign out logic here
                      },
                    ),
                  ),
              ],
            ),
          ),

          // ----------------------------------------
          // MAIN CONTENT AREA
          // ----------------------------------------
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  // Chat messages area
                  Expanded(
                    child: isChatEmpty
                        ? Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo and Title
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepPurple.withOpacity(0.2),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 38,
                                      backgroundColor: Color(ThemeColor.primary),
                                      child: Icon(
                                        Icons.favorite,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Ask Violet",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(ThemeColor.primary),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Your AI health companion",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(ThemeColor.primary).withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                        : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: currentMessages.length,
                      itemBuilder: (context, index) {
                        final chat = currentMessages[index];
                        final isUser = chat['sender'] == 'user';
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(16),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.6,
                            ),
                            decoration: BoxDecoration(
                              color: isUser ? Color(ThemeColor.primary) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isUser)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          size: 16,
                                          color: Color(ThemeColor.primary),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Violet",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(ThemeColor.primary),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Text(
                                  chat['message']!,
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.black87,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom Input Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    color: Color(ThemeColor.primary),
                                    size: 26,
                                  ),
                                  tooltip: 'Add attachment',
                                  onPressed: () {
                                    // Add attachment logic here
                                  },
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: const InputDecoration(
                                      hintText: "Type your message...",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                    style: const TextStyle(fontSize: 15),
                                    maxLines: null,
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (_) => _sendMessage(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(ThemeColor.primary),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    tooltip: 'Send message',
                                    onPressed: _sendMessage,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Users are responsible for verifying the accuracy of advice Violet provides as AI may on occasion produce incorrect information.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------
  // Send Message Handler
  // -------------------------------------
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();

    setState(() {
      // Add user message
      currentMessages.add({
        'sender': 'user',
        'message': userMessage,
      });

      _messageController.clear();
    });

    // Simulate AI response after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        currentMessages.add({
          'sender': 'violet',
          'message': _generateAIResponse(userMessage),
        });

        // Update or create chat session
        _updateChatSession();
      });
    });
  }

  // -------------------------------------
  // Generate AI Response (Simulated)
  // -------------------------------------
  String _generateAIResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains('fitness') || lowerMessage.contains('exercise') || lowerMessage.contains('workout')) {
      return 'To improve your fitness routine, consider incorporating a mix of cardio and strength training, setting realistic goals, and maintaining a balanced diet. Would you like specific workout recommendations?';
    } else if (lowerMessage.contains('diet') || lowerMessage.contains('food') || lowerMessage.contains('eat')) {
      return 'A balanced diet is key to good health! Focus on whole foods, plenty of fruits and vegetables, lean proteins, and stay hydrated. What are your specific dietary goals?';
    } else if (lowerMessage.contains('sleep') || lowerMessage.contains('rest')) {
      return 'Quality sleep is essential for health. Aim for 7-9 hours per night, maintain a consistent schedule, avoid screens before bed, and create a relaxing bedtime routine.';
    } else if (lowerMessage.contains('stress') || lowerMessage.contains('anxiety')) {
      return 'Managing stress is important for overall wellbeing. Try meditation, deep breathing exercises, regular physical activity, and ensure you have time for activities you enjoy.';
    } else if (lowerMessage.contains('hello') || lowerMessage.contains('hi')) {
      return 'Hello! I\'m Violet, your AI health companion. How can I help you with your health and wellness today?';
    } else {
      return 'I understand your question about health and wellness. As your AI companion, I\'m here to provide general guidance. For specific medical advice, please consult with a healthcare professional. How else can I assist you?';
    }
  }

  // -------------------------------------
  // Start New Chat
  // -------------------------------------
  void _startNewChat() {
    setState(() {
      // Save current chat if it has messages
      if (currentMessages.isNotEmpty && currentChatIndex == null) {
        _updateChatSession();
      }

      currentMessages = [];
      currentChatIndex = null;
    });
  }

  // -------------------------------------
  // Update Chat Session
  // -------------------------------------
  void _updateChatSession() {
    if (currentMessages.isEmpty) return;

    // Get title from first user message
    final firstUserMessage = currentMessages.firstWhere(
          (msg) => msg['sender'] == 'user',
      orElse: () => {'message': 'New Chat'},
    );

    String title = firstUserMessage['message']!;
    if (title.length > 30) {
      title = '${title.substring(0, 30)}...';
    }

    if (currentChatIndex != null) {
      // Update existing session
      chatSessions[currentChatIndex!] = {
        'title': title,
        'messages': List.from(currentMessages),
        'timestamp': DateTime.now(),
      };
    } else {
      // Create new session
      chatSessions.insert(0, {
        'title': title,
        'messages': List.from(currentMessages),
        'timestamp': DateTime.now(),
      });
      currentChatIndex = 0;
    }
  }

  // -------------------------------------
  // Load Chat Session
  // -------------------------------------
  void _loadChatSession(int index) {
    setState(() {
      currentChatIndex = index;
      currentMessages = List.from(chatSessions[index]['messages']);
    });
  }

  // -------------------------------------
  // Delete Chat Session
  // -------------------------------------
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

  // -------------------------------------
  // Sidebar Item with Hover
  // -------------------------------------
  Widget _sidebarItem(String iconPath, String label, String id, VoidCallback onTap, {required bool collapsed}) {
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
          contentPadding: EdgeInsets.symmetric(
            horizontal: collapsed ? 8 : 16,
            vertical: 4,
          ),
          leading: Image.asset(
            iconPath,
            width: 20,
            height: 20,
            color: isHovered ? Colors.white : Colors.white70,
          ),
          title: collapsed
              ? null
              : Text(
            label,
            style: TextStyle(
              color: isHovered ? Colors.white : Colors.white.withOpacity(0.9),
              fontSize: 15,
              fontWeight: isHovered ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  // -------------------------------------
  // Chat History Item with Hover Effect
  // -------------------------------------
  Widget _sidebarHistoryItem(
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
              ? Colors.white.withOpacity(0.2)
              : (isHovered ? Colors.white.withOpacity(0.15) : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          minLeadingWidth: 20,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          title: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : (isHovered ? Colors.white : Colors.white70),
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : (isHovered ? FontWeight.w500 : FontWeight.normal),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: isHovered
              ? IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.white70,
              size: 18,
            ),
            onPressed: onDelete,
            tooltip: 'Delete chat',
          )
              : null,
          onTap: onTap,
        ),
      ),
    );
  }
}