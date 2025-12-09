import 'package:flutter/material.dart';
import 'package:violet/core/const/string_cont/path_strings.dart';
import 'package:violet/core/theme/theme_color.dart';
import 'package:violet/os/windows/feature/chat/chats_screen.dart';
import '../../chat/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> demoData = [
      {
        'title': 'Ask Violet',
        'image': PathStrings.askViolet,
      },
      {
        'title': 'Care Planning',
        'image': PathStrings.carePlanning,
      },
      {
        'title': 'Training Resources',
        'image': PathStrings.training,
      },
      {
        'title': 'Activities Ideas',
        'image': PathStrings.activities,
      },
      {
        'title': 'Policy Guidance',
        'image': PathStrings.policy,
      },
    ];

    bool isAndroid(){
      return Theme.of(context).platform == TargetPlatform.android;
    }

    return Scaffold(
      backgroundColor: Color(ThemeColor.backgroundColor),
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(builder: (context, constraints) {
            double maxWidth = constraints.maxWidth > 1100
                ? 1100
                : constraints.maxWidth;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(50),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        PathStrings.logoPath,
                        width: isAndroid() ? 150 : 200,
                      ),
                      const SizedBox(height: 40),

                      Text(
                        'Violet supports person-centred care, making every moment truly count.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isAndroid() ? 20 : 32,
                          fontWeight: FontWeight.w400,
                          color: Color(ThemeColor.primary),
                        ),
                      ),
                      const SizedBox(height: 30),

                      Text(
                        'How would you like Violet to help you?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isAndroid() ? 16 : 28,
                          fontWeight: FontWeight.w400,
                          color: Color(ThemeColor.primary),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Choose one of the functions below or simply click Ask Violet ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isAndroid() ? 14 : 20,
                          fontWeight: FontWeight.w500,
                          color: Color(ThemeColor.primary),
                        ),
                      ),
                      const SizedBox(height: 50),
                  LayoutBuilder(builder: (context, subConstraints) {
                  final int crossCount;
                  if (subConstraints.maxWidth > 800) {
                    crossCount = 5;
                  } else if (subConstraints.maxWidth > 450) {
                    crossCount = 3;
                  } else {
                    // Phone view — use 2 columns to make tiles larger
                    crossCount = 2;
                  }
                  final double spacing = subConstraints.maxWidth <= 450 ? 25.0 : 20.0;
                  final double itemWidth =
                      (subConstraints.maxWidth - (crossCount - 1) * spacing) / crossCount;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: WrapAlignment.center,
                      children: List.generate(demoData.length, (index) {
                        final item = demoData[index];
                        return SizedBox(
                          width: itemWidth,
                          height: itemWidth, // keep square tiles
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => isAndroid() ? ChatsScreen(
                                    initialQuery: item['image'],

                                  ) : ChatScreen(
                                    initialQuery: item['image'],
                                    title: item['title'],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Image.asset(
                                  item['image'],
                                  fit: BoxFit.contain,
                                  width: 150,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                      const SizedBox(height: 50),

                      SizedBox(
                        width: 1000,
                        child: Text(
                          'Users are responsible for verifying the accuracy of advice Violet provides as AI may on occasion produce incorrect information.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isAndroid() ? 12 : 18,
                            color: const Color(ThemeColor.hintColor).withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
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
