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
      return Theme.of(context).platform == TargetPlatform.android ||
          Theme.of(context).platform == TargetPlatform.iOS;
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
    // Fully responsive - no scroll, everything scales with screen
    return Scaffold(
      backgroundColor: Color(ThemeColor.backgroundColor),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;

            // Use smaller dimension to ensure everything fits
            final double smallerDimension = screenWidth < screenHeight
                ? screenWidth
                : screenHeight;

            // Scale based on screen size - reference 1000px = 1.0
            final double scale = (smallerDimension / 1000).clamp(0.5, 1.4);

            // Fixed padding ratio to screen
            final double horizontalPadding = screenWidth * 0.03;
            final double verticalPadding = screenHeight * 0.02;

            // Available space after padding
            final double availableWidth = screenWidth - (horizontalPadding * 2);
            final double availableHeight = screenHeight - (verticalPadding * 2);

            // Card calculation - cards take ~25% of screen height
            final double cardSpacing = availableWidth * 0.02;
            final int cardCount = 4;

            // Card size based on width (fit 4 cards with spacing)
            final double cardWidthBased =
                (availableWidth - (cardSpacing * (cardCount + 1))) / cardCount;

            // Card size based on height (cards should be ~25% of height)
            final double cardHeightBased = availableHeight * 0.22;

            // Use smaller to ensure fit
            final double cardSize = cardWidthBased < cardHeightBased
                ? cardWidthBased
                : cardHeightBased;

            // All sizes relative to card size for consistent proportions
            final double logoWidth = cardSize * 0.9;

            // Text sizes relative to card
            final double titleFontSize = cardSize * 0.18;
            final double subtitleFontSize = cardSize * 0.15;
            final double descFontSize = cardSize * 0.11;
            final double disclaimerFontSize = cardSize * 0.09;

            // Spacing relative to available height for consistent gaps
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
                    // Top section - Logo and titles
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo
                        Image.asset(PathStrings.logoPath, width: logoWidth),

                        SizedBox(height: logoToTitle),

                        // Main title
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

                        // Subtitle section
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

                    // Cards row - centered
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

                    // Disclaimer
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

  // builds individual card widget for mobile
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

  // builds individual card widget for desktop - with hover effect
  Widget _buildDesktopCard(
    BuildContext context,
    Map<String, dynamic> item,
    double cardSize,
    double scale,
  ) {
    // Border radius and padding proportional to card size
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
