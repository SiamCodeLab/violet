import 'package:flutter/material.dart';
import 'package:violet/core/const/string_cont/path_strings.dart';
import 'package:violet/core/theme/theme_color.dart';

import '../../chat/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideUp = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(builder: (context, constraints) {
            double maxWidth =
            constraints.maxWidth > 1100 ? 1100 : constraints.maxWidth;

            int gridColumns =
            (maxWidth ~/ 220).clamp(2, 5); // Responsive columns (2→5)

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return AnimatedOpacity(
                        opacity: _fadeIn.value,
                        duration: const Duration(milliseconds: 800),
                        child: AnimatedSlide(
                          offset: _slideUp.value,
                          duration: const Duration(milliseconds: 800),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Logo
                              Image.asset(
                                PathStrings.logoPath,
                                width: 150,
                              ),
                              const SizedBox(height: 40),

                              // Main headline
                              Text(
                                'Violet supports person-centred care, making every moment truly count.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Color(ThemeColor.primary),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Sub-headline
                              Text(
                                'How would you like Violet to help you?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Color(ThemeColor.primary),
                                ),
                              ),
                              const SizedBox(height: 16),

                              Text(
                                'Choose one of the functions below or simply click Ask Violet',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color(ThemeColor.primary),
                                ),
                              ),
                              const SizedBox(height: 50),

                              // Responsive Grid
                              LayoutBuilder(
                                  builder: (context, subConstraints) {
                                    return GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: gridColumns,
                                        crossAxisSpacing: 20,
                                        mainAxisSpacing: 20,
                                        childAspectRatio: 1,
                                      ),
                                      itemCount: 5,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                  const ChatScreen()),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.extension,
                                                  size: 48,
                                                  color: Color(ThemeColor.primary),
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'Function ${index + 1}',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(ThemeColor.primary),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }),

                              const SizedBox(height: 50),

                              // Footer
                              Text(
                                'Users are responsible for verifying the accuracy of advice Violet provides as AI may on occasion produce incorrect information.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
