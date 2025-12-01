import 'package:flutter/material.dart';
import 'package:violet/core/theme/theme_color.dart';

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

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: EdgeInsets.only(right: isCollapsed ? 8 : 16),
                  child: Align(
                    alignment: isCollapsed ? Alignment.center : Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        isCollapsed ? Icons.menu : Icons.close,
                        color: Colors.white,
                        size: 28,
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
                _sidebarItem(Icons.home, "Home", "home", collapsed: isCollapsed),
                _sidebarItem(Icons.chat_bubble_outline, "New Chat", "new_chat", collapsed: isCollapsed),

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
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 8, top: 4),
                      itemCount: 20,
                      itemBuilder: (context, index) {
                        final historyItems = [
                          "How to stay active?",
                          "Healthy meal ideas?",
                          "Reduce stress tips",
                          "Morning workout routine",
                          "Best sleep schedule",
                        ];
                        final label = historyItems[index % historyItems.length];
                        return _sidebarHistoryItem(
                          "history_$index",
                          Icons.history,
                          label,
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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 100),

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

                        const Spacer(),

                        // Bottom Input Section
                        Column(
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxWidth: 700),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 20,
                                    color: Colors.black.withOpacity(0.1),
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.add_circle_outline,
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
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                "Users are responsible for verifying the accuracy of advice Violet provides as AI may on occasion produce incorrect information.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(ThemeColor.primary).withOpacity(0.6),
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
    if (_messageController.text.trim().isNotEmpty) {
      // Add message sending logic here
      print("Sending: ${_messageController.text}");
      _messageController.clear();
    }
  }

  // -------------------------------------
  // Sidebar Item with Hover
  // -------------------------------------
  Widget _sidebarItem(IconData icon, String label, String id, {required bool collapsed}) {
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
          leading: Icon(
            icon,
            color: isHovered ? Colors.white : Colors.white.withOpacity(0.9),
            size: 26,
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
          onTap: () {
            // Add navigation logic here
            print("Tapped: $label");
          },
        ),
      ),
    );
  }

  // -------------------------------------
  // Chat History Item with Hover Effect
  // -------------------------------------
  Widget _sidebarHistoryItem(String id, IconData icon, String label) {
    final isHovered = hoveredItem == id;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredItem = id),
      onExit: (_) => setState(() => hoveredItem = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isHovered ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          minLeadingWidth: 20,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          leading: Icon(
            icon,
            color: isHovered ? Colors.white : Colors.white70,
            size: 20,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: isHovered ? Colors.white : Colors.white70,
              fontSize: 14,
              fontWeight: isHovered ? FontWeight.w500 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: isHovered
              ? Icon(
            Icons.more_horiz,
            color: Colors.white70,
            size: 18,
          )
              : null,
          onTap: () {
            // Add chat history navigation logic here
            print("Opened chat: $label");
          },
        ),
      ),
    );
  }
}