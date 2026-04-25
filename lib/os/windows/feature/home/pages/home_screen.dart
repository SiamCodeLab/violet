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

    final platform = Theme.of(context).platform;
    final shortestSide = MediaQuery.of(context).size.shortestSide;

    // Phone: Android or iOS with shortestSide < 600
    bool isMobilePhone() {
      return (platform == TargetPlatform.android ||
              platform == TargetPlatform.iOS) &&
          shortestSide < 600;
    }

    // Tablet: Android or iOS with shortestSide >= 600 (covers iPad too)
    bool isTablet() {
      return (platform == TargetPlatform.android ||
              platform == TargetPlatform.iOS) &&
          shortestSide >= 600;
    }

    // ========== MOBILE VERSION ==========
    if (isMobilePhone()) {
      return Scaffold(
        backgroundColor: Color(ThemeColor.backgroundColor),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double availableWidth = constraints.maxWidth;
              final double availableHeight = constraints.maxHeight;

              final double padding = 16.0;
              final double spacing = 12.0;

              final double totalSpacing = spacing * 2;
              final double cardSize =
                  (availableWidth - (padding * 2) - totalSpacing) / 3;

              final double cardsHeight = (cardSize * 2) + spacing;
              final double remainingHeight =
                  availableHeight - cardsHeight - (padding * 2);
              final double scale = (remainingHeight / 350).clamp(0.5, 1.0);

              return Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(PathStrings.logoPath, width: 120 * scale),
                    Text(
                      'Violet supports person-centred care, making every moment truly count.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (18 * scale).clamp(12.0, 20.0),
                        fontWeight: FontWeight.w400,
                        color: Color(ThemeColor.primary),
                      ),
                    ),
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
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCard(context, demoData[0], cardSize, true),
                            SizedBox(width: 20),
                            _buildCard(context, demoData[1], cardSize, true),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCard(context, demoData[2], cardSize, true),
                            SizedBox(width: 20),
                            _buildCard(context, demoData[3], cardSize, true),
                          ],
                        ),
                      ],
                    ),
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

    // ========== TABLET VERSION ==========
    // Covers iPad AND Android tablets (shortestSide >= 600)
    if (isTablet()) {
      return Scaffold(
        backgroundColor: Color(ThemeColor.backgroundColor),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double availableWidth = constraints.maxWidth;
              final double availableHeight = constraints.maxHeight;

              final double horizontalPadding = availableWidth * 0.06;
              final double verticalPadding = availableHeight * 0.03;

              final double contentWidth =
                  availableWidth - (horizontalPadding * 2);
              final double contentHeight =
                  availableHeight - (verticalPadding * 2);

              final double cardSpacing = contentWidth * 0.04;
              final double cardSize = (contentWidth - cardSpacing) / 2;
              final double cappedCardSize = cardSize.clamp(
                0.0,
                contentHeight * 0.28,
              );

              final double logoWidth = cappedCardSize * 0.55;
              final double titleFontSize = (cappedCardSize * 0.11).clamp(
                16.0,
                28.0,
              );
              final double subtitleFontSize = (cappedCardSize * 0.09).clamp(
                13.0,
                22.0,
              );
              final double descFontSize = (cappedCardSize * 0.07).clamp(
                11.0,
                16.0,
              );
              final double disclaimerFontSize = (cappedCardSize * 0.06).clamp(
                9.0,
                13.0,
              );

              final double sectionGap = contentHeight * 0.02;
              final double cardRowGap = cappedCardSize * 0.08;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(PathStrings.logoPath, width: logoWidth),
                        SizedBox(height: sectionGap),
                        Text(
                          'Violet supports person-centred care, making every moment truly count.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w400,
                            color: Color(ThemeColor.primary),
                          ),
                        ),
                        SizedBox(height: sectionGap * 1.5),
                        Text(
                          'How would you like Violet to help you?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w400,
                            color: Color(ThemeColor.primary),
                          ),
                        ),
                        SizedBox(height: sectionGap * 0.5),
                        Text(
                          'Choose one of the functions below or simply click Ask Violet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: descFontSize,
                            fontWeight: FontWeight.w500,
                            color: Color(ThemeColor.primary),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCard(
                              context,
                              demoData[0],
                              cardSize - 100,
                              true,
                            ),
                            SizedBox(width: cardSpacing),
                            _buildCard(
                              context,
                              demoData[1],
                              cardSize - 100,
                              true,
                            ),
                          ],
                        ),
                        SizedBox(height: cardRowGap),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCard(
                              context,
                              demoData[2],
                              cardSize - 100,
                              true,
                            ),
                            SizedBox(width: cardSpacing),
                            _buildCard(
                              context,
                              demoData[3],
                              cardSize - 100,
                              true,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      'Users are responsible for verifying the accuracy of advice Violet provides as AI may on occasion produce incorrect information.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: disclaimerFontSize,
                        color: const Color(
                          ThemeColor.hintColor,
                        ).withOpacity(0.5),
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
    return Scaffold(
      backgroundColor: Color(ThemeColor.backgroundColor),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;

            final double smallerDimension = screenWidth < screenHeight
                ? screenWidth
                : screenHeight;
            final double scale = (smallerDimension / 1000).clamp(0.5, 1.4);

            final double horizontalPadding = screenWidth * 0.03;
            final double verticalPadding = screenHeight * 0.02;

            final double availableWidth = screenWidth - (horizontalPadding * 2);
            final double availableHeight = screenHeight - (verticalPadding * 2);

            final double cardSpacing = availableWidth * 0.02;
            const int cardCount = 4;

            final double cardWidthBased =
                (availableWidth - (cardSpacing * (cardCount + 1))) / cardCount;
            final double cardHeightBased = availableHeight * 0.22;
            final double cardSize = cardWidthBased < cardHeightBased
                ? cardWidthBased
                : cardHeightBased;

            final double logoWidth = cardSize * 0.9;
            final double titleFontSize = cardSize * 0.18;
            final double subtitleFontSize = cardSize * 0.15;
            final double descFontSize = cardSize * 0.11;
            final double disclaimerFontSize = cardSize * 0.09;

            final double logoToTitle = availableHeight * 0.015;
            final double titleToSubtitle = availableHeight * 0.06;
            final double subtitleGap = availableHeight * 0.01;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(PathStrings.logoPath, width: logoWidth),
                        SizedBox(height: logoToTitle),
                        Text(
                          'Violet supports person-centred care, making every moment truly count.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w400,
                            color: Color(ThemeColor.primary),
                          ),
                        ),
                        SizedBox(height: titleToSubtitle),
                        Text(
                          'How would you like Violet to help you?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w400,
                            color: Color(ThemeColor.primary),
                          ),
                        ),
                        SizedBox(height: subtitleGap),
                        Text(
                          'Choose one of the functions below or simply click Ask Violet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: descFontSize,
                            fontWeight: FontWeight.w500,
                            color: Color(ThemeColor.primary),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: List.generate(demoData.length, (index) {
                        final item = demoData[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: cardSpacing / 2,
                          ),
                          child: _buildDesktopCard(
                            context,
                            item,
                            cardSize,
                            scale,
                          ),
                        );
                      }),
                    ),
                    Text(
                      'Users are responsible for verifying the accuracy of advice Violet provides as AI may on occasion produce incorrect information.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: disclaimerFontSize,
                        color: const Color(
                          ThemeColor.hintColor,
                        ).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

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

  Widget _buildDesktopCard(
    BuildContext context,
    Map<String, dynamic> item,
    double cardSize,
    double scale,
  ) {
    final double borderRadius = cardSize * 0.05;
    final double padding = cardSize * 0.1;

    return SizedBox(
      width: cardSize,
      height: cardSize,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
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
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: cardSize * 0.04,
                  offset: Offset(0, cardSize * 0.015),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Image.asset(item['image'], fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
