import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:violet/core/const/path_strings.dart';
import 'package:violet/core/theme/theme_color.dart';
import 'package:violet/os/windows/feature/chat/screens/chats_screen.dart';
import '../../chat/screens/desktop_view_chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // menu items - each card has title, bg image, and icon for loading state
    final List<Map<String, dynamic>> demoData = [
      {
        'bot_id': 1,
        'title': 'Ask Violet',
        'image': PathStrings.askViolet,
        'icon': PathStrings.askVioletIcon,
      },
      {
        'bot_id': 2,
        'title': 'Care Planning',
        'image': PathStrings.carePlanning,
        'icon': PathStrings.chatIcon,
      },
      {
        'bot_id': 3,
        'title': 'Training Resources',
        'image': PathStrings.training,
        'icon': PathStrings.trainginIcon,
      },
      {
        'bot_id': 4,
        'title': 'Activities Ideas',
        'image': PathStrings.activities,
        'icon': PathStrings.activitiesIcon,
      },
      {
        'bot_id': 5,
        'title': 'Policy Guidance',
        'image': PathStrings.policy,
        'icon': PathStrings.policyIcon,
      },
    ];

    // quick check for mobile layout
    bool isAndroid() {
      return Theme.of(context).platform == TargetPlatform.android;
    }

    // ========== MOBILE VERSION ==========
    // 3x2 grid, no scroll, everything fits on screen
    if (isAndroid()) {
      return Scaffold(
        backgroundColor: Color(ThemeColor.backgroundColor),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double availableWidth = constraints.maxWidth;
              final double availableHeight = constraints.maxHeight;

              final double padding = 16.0;
              final double spacing = 12.0;

              // card width calc: screen - padding - gaps / 3 columns
              final double totalSpacing = spacing * 2;
              final double cardSize =
                  (availableWidth - (padding * 2) - totalSpacing) / 3;

              // 2 rows of cards + gap between them
              final double cardsHeight = (cardSize * 2) + spacing;

              // whatever space left goes to logo/text area
              final double remainingHeight =
                  availableHeight - cardsHeight - (padding * 2);

              // scale everything based on available space (min 0.5, max 1.0)
              final double scale = (remainingHeight / 350).clamp(0.5, 1.0);

              return Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // logo
                    Image.asset(PathStrings.logoPath, width: 120 * scale),

                    // main title
                    Text(
                      'Violet supports person-centred care, making every moment truly count.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (18 * scale).clamp(12.0, 20.0),
                        fontWeight: FontWeight.w400,
                        color: Color(ThemeColor.primary),
                      ),
                    ),

                    // subtitle section
                    Column(
                      children: [
                        Text(
                          'How would you like Violet to help you?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: (14 * scale).clamp(10.0, 16.0),
                            fontWeight: FontWeight.w400,
                            color: Color(ThemeColor.primary),
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                        Text(
                          'Choose one of the functions below or simply click Ask Violet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: (12 * scale).clamp(9.0, 14.0),
                            fontWeight: FontWeight.w500,
                            color: Color(ThemeColor.primary),
                          ),
                        ),
                      ],
                    ),

                    // cards grid - row 1: 3 cards, row 2: 2 cards centered
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(3, (index) {
                            final item = demoData[index];
                            return _buildCard(context, item, cardSize, true);
                          }),
                        ),
                        SizedBox(height: spacing),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCard(context, demoData[3], cardSize, true),
                            SizedBox(width: spacing),
                            _buildCard(context, demoData[4], cardSize, true),
                          ],
                        ),
                      ],
                    ),

                    // disclaimer at bottom
                    Text(
                      'Users are responsible for verifying the accuracy of advice Violet provides as AI may on occasion produce incorrect information.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (14 * scale).clamp(8.0, 12.0),
                        color: const Color(ThemeColor.hintColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }

    // ========== DESKTOP VERSION ==========
    // responsive grid, scrollable if needed
    return Scaffold(
      backgroundColor: Color(ThemeColor.backgroundColor),
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double availableWidth = constraints.maxWidth;
              final double availableHeight = constraints.maxHeight;

              // cap max width at 1100 for readability
              double maxWidth = availableWidth > 1100 ? 1100 : availableWidth;

              // rough height estimates for scroll check
              final double logoHeight = 200;
              final double textHeight = 200;

              // figure out how many cards per row based on screen width
              final int crossCount;
              if (availableWidth > 800) {
                crossCount = 5;
              } else if (availableWidth > 450) {
                crossCount = 3;
              } else {
                crossCount = 2;
              }

              final double spacing = availableWidth <= 450 ? 25.0 : 20.0;
              final double itemWidth =
                  (maxWidth - 100 - (crossCount - 1) * spacing) / crossCount;
              final int rowCount = (demoData.length / crossCount).ceil();
              final double cardsHeight =
                  (itemWidth * rowCount) + (spacing * (rowCount - 1));

              final double disclaimerHeight = 60;
              final double paddingHeight = 100;
              final double spacingHeight = 180;

              // check if everything fits without scrolling
              final double totalContentHeight =
                  logoHeight +
                  textHeight +
                  cardsHeight +
                  disclaimerHeight +
                  paddingHeight +
                  spacingHeight;

              final bool contentFits = totalContentHeight <= availableHeight;

              // main content column
              Widget content = ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  mainAxisAlignment: contentFits
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!contentFits) const SizedBox(height: 40),

                    // logo
                    Image.asset(PathStrings.logoPath, width: 200),

                    // spacing: logo -> title = 15
                    const SizedBox(height: 15),

                    // main title
                    Text(
                      'Violet supports person-centred care, making every moment truly count.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        color: Color(ThemeColor.primary),
                      ),
                    ),

                    // spacing: title -> subhead = 86
                    const SizedBox(height: 86),

                    // subtitle section
                    Column(
                      children: [
                        Text(
                          'How would you like Violet to help you?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                            color: Color(ThemeColor.primary),
                          ),
                        ),
                        // spacing: subhead -> subhead = 10
                        const SizedBox(height: 10),
                        Text(
                          'Choose one of the functions below or simply click Ask Violet ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(ThemeColor.primary),
                          ),
                        ),
                      ],
                    ),

                    if (!contentFits) const SizedBox(height: 50),
                    if (contentFits) const SizedBox(height: 50),

                    // cards grid - adapts columns based on width
                    LayoutBuilder(
                      builder: (context, subConstraints) {
                        final int crossCount;
                        if (subConstraints.maxWidth > 800) {
                          crossCount = 5;
                        } else if (subConstraints.maxWidth > 450) {
                          crossCount = 3;
                        } else {
                          crossCount = 2;
                        }
                        final double spacing = subConstraints.maxWidth <= 450
                            ? 25.0
                            : 20.0;
                        final double itemWidth =
                            (subConstraints.maxWidth -
                                (crossCount - 1) * spacing) /
                            crossCount;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          alignment: WrapAlignment.center,
                          children: List.generate(demoData.length, (index) {
                            final item = demoData[index];
                            return SizedBox(
                              width: subConstraints.maxWidth > 800
                                  ? itemWidth
                                  : subConstraints.maxWidth > 450
                                  ? itemWidth - 48
                                  : itemWidth - 48,
                              height: subConstraints.maxWidth > 800
                                  ? itemWidth
                                  : subConstraints.maxWidth > 450
                                  ? itemWidth - 48
                                  : itemWidth - 48,
                              child: InkWell(
                                onTap: () => Get.to(
                                  () => DesktopViewChatScreen(
                                    initialQuery: item['image'],
                                    title: item['title'],
                                    loadingIcon: item['icon'],
                                    botid: item['bot_id'],
                                  ),
                                  arguments: item['bot_id'],
                                ),
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
                      },
                    ),

                    if (!contentFits) const SizedBox(height: 50),
                    if (contentFits) const SizedBox(height: 50),

                    // disclaimer
                    SizedBox(
                      width: 1000,
                      child: Text(
                        'Users are responsible for verifying the accuracy of advice Violet provides as AI may on occasion produce incorrect information.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: const Color(
                            ThemeColor.hintColor,
                          ).withOpacity(0.5),
                        ),
                      ),
                    ),

                    if (!contentFits) const SizedBox(height: 40),
                  ],
                ),
              );

              // no scroll if fits, otherwise wrap in scrollview
              if (contentFits) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Center(child: content),
                );
              } else {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Center(child: content),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // builds individual card widget
  Widget _buildCard(
    BuildContext context,
    Map<String, dynamic> item,
    double cardSize,
    bool isAndroid,
  ) {
    return SizedBox(
      width: cardSize,
      height: cardSize,
      child: InkWell(
        onTap: () => Get.to(
          () => ChatsScreen(
            initialQuery: item['image'],
            loadingIcon: item['icon'],
            botid: item['bot_id'],
          ),
          arguments: item['bot_id'],
        ),
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
            padding: const EdgeInsets.all(10.0),
            child: Image.asset(item['image'], fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
