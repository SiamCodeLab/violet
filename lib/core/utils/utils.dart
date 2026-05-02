import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
//uncomment if you build for windows or macOS
// import 'package:super_clipboard/super_clipboard.dart';
import 'package:flutter/services.dart';
import 'package:violet/core/services/snackbar_service.dart';
import 'package:violet/core/utils/console.dart';

class ClipboardService {
  static Future<void> copyAsRichText(
    String markdownText,
    BuildContext context,
  ) async {
    try {
      final html = md.markdownToHtml(
        markdownText,
        extensionSet: md.ExtensionSet.gitHubWeb,
      );
      //uncomment if you build for windows or macOS

      // final clipboard = SystemClipboard.instance;
      // if (clipboard != null) {
      //   final item = DataWriterItem();
      //   item.add(Formats.htmlText(html));
      //   item.add(Formats.plainText(markdownText));
      //   await clipboard.write([item]);
      // } else {
      //   await Clipboard.setData(ClipboardData(text: markdownText));
      // }

      SnackbarService.success('Copied to clipboard');
    } catch (e) {
      Console.error('Copy error: $e');
      await Clipboard.setData(ClipboardData(text: markdownText));
      SnackbarService.success('Copied to clipboard');
    }
  }

  static Future<void> copyToClipboardAndroid(
    BuildContext context,
    String markdownText,
  ) async {
    // Simple plain text extraction
    String plainText = markdownText
        .replaceAll(RegExp(r'[*_`~#]'), '') // Remove markdown symbols
        .replaceAll(
          RegExp(r'\[([^\]]+)\]\([^)]+\)'),
          r'$1',
        ) // Convert [text](url) to text
        .replaceAll(RegExp(r'\n{3,}'), '\n\n') // Remove excess newlines
        .trim();

    try {
      await Clipboard.setData(ClipboardData(text: plainText));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied to clipboard'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }
}
