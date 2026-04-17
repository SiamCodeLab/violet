import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class FlutterMarkdownView extends StatelessWidget {
  final String markdownText;

  const FlutterMarkdownView({super.key, required this.markdownText});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: markdownText,
      selectable: false,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF1a1a1a)),
        h1: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1a1a1a),
        ),
        h2: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1a1a1a),
        ),
        h3: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1a1a1a),
        ),
        h4: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1a1a1a),
        ),
        h5: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1a1a1a),
        ),
        h6: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF555555),
        ),

        code: const TextStyle(
          backgroundColor: Color(0xFFF0F0F0),
          color: Color(0xFFC0392B),
          fontSize: 13,
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        codeblockPadding: const EdgeInsets.all(12),

        blockquote: const TextStyle(
          color: Color(0xFF555555),
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: Color(0xFF6C63FF), width: 4)),
        ),
        blockquotePadding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),

        listIndent: 24,
        tableHead: const TextStyle(fontWeight: FontWeight.w700),
        tableBorder: TableBorder.all(color: const Color(0xFFDDDDDD)),

        h1Padding: const EdgeInsets.only(top: 14, bottom: 8),
        h2Padding: const EdgeInsets.only(top: 12, bottom: 6),
        h3Padding: const EdgeInsets.only(top: 10, bottom: 6),
      ),
    );
  }
}
