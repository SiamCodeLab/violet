import 'package:flutter/material.dart';
import 'package:violet/core/const/string_cont/path_strings.dart';
import 'package:violet/core/theme/theme_color.dart';

import '../../chat/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double maxWidth = constraints.maxWidth > 1200 ? 1200 : constraints.maxWidth;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    width: maxWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo
                        Image.asset(
                          PathStrings.logoPath,
                          width: 150,
                        ),
                        const SizedBox(height: 30),

                        // Main headline
                        Text(
                          'Violet supports person-centred care, making every moment truly count.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(ThemeColor.primary),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Sub-headline
                        Text(
                          'How would you like Violet to help you?',
                          style: TextStyle(
                            fontSize: 32,
                            color: Color(ThemeColor.primary),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'Choose one of the functions below or simply click Ask Violet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(ThemeColor.primary),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Functions grid (responsive)
                        SizedBox(
                          height: 300,
                          child: GridView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1,
                            ),
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ChatScreen(),
                                    ),
                                  );
                                },
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.android,
                                            size: 48, color: Color(ThemeColor.primary)),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Function ${index + 1}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(ThemeColor.primary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Footer notice
                        Text(
                          'Users are responsible for verifying the accuracy of advice Violet provides as AI may on occasion produce incorrect information.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
