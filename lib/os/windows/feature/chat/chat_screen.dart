import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isCollapsed = false;

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
            width: isCollapsed ? 80 : 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                // Collapse/Expand Button
                Align(
                  alignment: isCollapsed
                      ? Alignment.center
                      : Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      isCollapsed ? Icons.arrow_right : Icons.arrow_left,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() {
                        isCollapsed = !isCollapsed;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Profile Header (hide text when collapsed)
                ListTile(
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child:
                    Icon(Icons.person, color: Colors.deepPurple, size: 26),
                  ),
                  title: isCollapsed
                      ? null
                      : const Text(
                    "Soaib",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  subtitle: isCollapsed
                      ? null
                      : const Text(
                    "Active now",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),

                const SizedBox(height: 20),

                // NAVIGATION ITEMS
                _sidebarItem(Icons.home, "Home", collapsed: isCollapsed),
                _sidebarItem(Icons.chat_bubble_outline, "New Chat",
                    collapsed: isCollapsed),
                _sidebarItem(Icons.bookmark_border, "Saved Advice",
                    collapsed: isCollapsed),
                _sidebarItem(Icons.health_and_safety, "Care Plan",
                    collapsed: isCollapsed),
                _sidebarItem(Icons.calendar_month, "Appointments",
                    collapsed: isCollapsed),
                _sidebarItem(Icons.settings, "Settings",
                    collapsed: isCollapsed),

                const Spacer(),

                // Logout Button
                if (!isCollapsed)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.logout),
                      label: const Text("Sign out"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                  ),

                if (isCollapsed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () {},
                    ),
                  )
              ],
            ),
          ),

          // -------------------------------------
          // MAIN CONTENT (CENTER PANEL)
          // -------------------------------------
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF6F0FF),
                    Color(0xFFE8DFFF),
                    Color(0xFFD4C8FF),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 120),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 38,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.favorite,
                                size: 40, color: Colors.deepPurple),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Ask Violet",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  _floatingSuggestion("How to stay active?",
                      top: 260, left: 300),
                  _floatingSuggestion("Healthy meal ideas?",
                      top: 360, left: 650),
                  _floatingSuggestion("Reduce stress tips",
                      top: 450, left: 450),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 12, color: Colors.black12)
                                ],
                              ),
                              child: const TextField(
                                decoration: InputDecoration(
                                  hintText: "Ask me anything...",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.deepPurple,
                            child: const Icon(Icons.send, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------
  // Sidebar Item Widget
  // -------------------------------------
  Widget _sidebarItem(IconData icon, String label,
      {required bool collapsed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 26),
        title: collapsed
            ? null
            : Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  // -------------------------------------
  // Floating suggestion chip widget
  // -------------------------------------
  Widget _floatingSuggestion(String text,
      {required double top, required double left}) {
    return Positioned(
      top: top,
      left: left,
      child: AnimatedContainer(
        duration: const Duration(seconds: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(color: Colors.deepPurple.shade100, blurRadius: 10),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
