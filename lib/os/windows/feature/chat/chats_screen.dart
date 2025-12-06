import 'package:flutter/material.dart';
import 'package:violet/core/const/string_cont/path_strings.dart';
import 'package:violet/core/theme/theme_color.dart';
import 'package:violet/os/windows/feature/auth/pages/login_screen.dart';
import 'package:violet/os/windows/feature/home/pages/home_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key, required initialQuery});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) {

    final chat = [
      {
        'sender': 'user',
        'message': 'Hello, how can I assist you today?',
      },
      {
        'sender': 'bot',
        'message': 'I need help with my account.',
      },
      {
        'sender': 'bot',
        'message': 'I need help with my account.',
      },
      {
        'sender': 'bot',
        'message': 'I need help with my account.',
      },
      {
        'sender': 'bot',
        'message': 'I need help with my account.',
      },
      {
        'sender': 'bot',
        'message': 'I need help with my account.',
      },
      {
        'sender': 'bot',
        'message': 'I need help with my account.',
      },
      {
        'sender': 'bot',
        'message': 'I need help with my account.',
      },
      {
        'sender': 'bot',
        'message': 'I need help with my account.',
      },
      {
        'sender': 'bot',
        'message': 'I need help with my account.',
      },
      {
        'sender': 'bot',
        'message': 'I need help with my account.',
      },
      {
        'sender': 'bot',
        'message': 'I need help with my account.',
      },
      {
        'sender': 'bot',
        'message': 'I need help with my account.',
      },
      {
        'sender': 'bot',
        'message': 'I need help with my account.',
      },
      {
        'sender': 'bot',
        'message': 'I need help with my account.',
      },
      {
        'sender': 'bot',
        'message': 'I need help with my account.',
      },
      {
        'sender': 'user',
        'message': 'Sure, what seems to be the problem?',
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: NavigationDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent ,
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
            )
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          // background image
          image: DecorationImage(
            image: AssetImage(PathStrings.phoneBg),
            fit: BoxFit.cover,
          )
        ),
        child: Padding(

          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 100, bottom: 20),
                  itemCount: chat.length,
                  itemBuilder: (context, index) {
                    final message = chat[index];
                    final isUser = message['sender'] == 'user';
                    return SizedBox(
                      width: 300,
                      child: Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Text(
                                isUser ? 'You' : 'Violet',
                                textAlign: isUser ? TextAlign.right : TextAlign.left,
                                style: TextStyle(
                                  color: Color(ThemeColor.borderColor),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white. withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                message['message']!,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        )
                      ),
                    );
                  },
                ),
              ),
              _buildFloatingInput(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Users are responsible for verifying the accuracy of advice Violet provides as AI may on occasion produce incorrect information.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(ThemeColor.hintColor),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        )
      ),
    );
  }

  Widget _buildFloatingInput() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Container(
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
                icon: Icon(Icons.add, color: Color(ThemeColor.primary), size: 26),
                onPressed: () {},
              ),

              Expanded(
                child: TextField(
                  // controller: _messageController,
                  // focusNode: _messageFocusNode,
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
                  // Handle send action
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}






class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final chatList = [
      'Chat 1',
      'Chat 2',
      'Chat 3',
    ];

    return Drawer(
      child: Container(
        color: Color(ThemeColor.primary),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top padding + menu icon
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewPadding.top,
                left: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(Icons.menu, color: Colors.white),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    leading: Image.asset(PathStrings.homeIcon),
                    title: Text('Home', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Image.asset(PathStrings.newIcon),
                    title: Text('New Chat', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(height: 20),
                  ListTile(
                    title: Text('Chats', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),

            // Chat list takes remaining space
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.only(left: 20),
                itemCount: chatList.length,
                separatorBuilder: (context, index) => SizedBox.shrink(),
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      chatList[index],
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      // Handle chat selection
                    },
                  );
                },
              ),
            ),

            // Logout button at bottom
            Container(
              margin: EdgeInsets.all(20),
              width: 160,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                   Image.asset(
                      PathStrings.logoutIcon,
                      width: 20,
                      color: Colors.black,
                   ),
                    SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
