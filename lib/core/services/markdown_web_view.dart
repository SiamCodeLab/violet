import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:webview_flutter/webview_flutter.dart';

class MarkdownWebView extends StatefulWidget {
  final String markdownText;

  const MarkdownWebView({super.key, required this.markdownText});

  @override
  State<MarkdownWebView> createState() => _MarkdownWebViewState();
}

class _MarkdownWebViewState extends State<MarkdownWebView> {
  late final WebViewController _controller;
  double _height = 100;
  bool _isFirstLoadReady = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'HeightChannel',
        onMessageReceived: (msg) {
          final h = double.tryParse(msg.message);
          if (h != null && h > 0 && mounted) {
            if ((_height - h).abs() > 2) {
              setState(() => _height = h + 8);
            }
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!_isFirstLoadReady && mounted) {
              setState(() => _isFirstLoadReady = true);
            }
          },
        ),
      );

    if (!Platform.isMacOS) {
      _controller.setBackgroundColor(Colors.transparent);
    }

    _controller.loadHtmlString(_buildHtml(widget.markdownText));
  }

  @override
  void didUpdateWidget(MarkdownWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.markdownText != widget.markdownText) {
      _controller.loadHtmlString(_buildHtml(widget.markdownText));
    }
  }

  String _buildHtml(String markdownText) {
    final htmlBody = md.markdownToHtml(
      markdownText,
      extensionSet: md.ExtensionSet.gitHubWeb,
    );

    final bgColor = Platform.isMacOS ? '#FFFFFF' : 'transparent';

    return '''<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }

    html {
      background: $bgColor;
      width: 100%;
      overflow-x: hidden; /* ✅ PREVENTS HORIZONTAL OVERFLOW */
    }

    body {
      font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif;
      font-size: 15px;
      line-height: 1.6;
      color: #1a1a1a;
      background: $bgColor;
      padding: 0;
      width: 100%;
      max-width: 100%;
      overflow-x: hidden; /* ✅ PREVENTS HORIZONTAL OVERFLOW */
      word-wrap: break-word; /* ✅ FORCES LONG WORDS TO BREAK */
      overflow-wrap: break-word;
      user-select: text;
      -webkit-user-select: text;
    }

    p { margin-bottom: 10px; }
    p:last-child { margin-bottom: 0; }

    h1 { font-size: 24px; font-weight: 700; margin: 14px 0 8px; }
    h2 { font-size: 20px; font-weight: 700; margin: 12px 0 6px; }
    h3 { font-size: 18px; font-weight: 700; margin: 10px 0 6px; }
    h4 { font-size: 16px; font-weight: 700; margin: 8px 0 4px; }
    h5 { font-size: 15px; font-weight: 700; margin: 8px 0 4px; }
    h6 { font-size: 14px; font-weight: 700; color: #555; margin: 8px 0 4px; }

    strong { font-weight: 700; }
    em { font-style: italic; }

    ul, ol { padding-left: 24px; margin-bottom: 10px; }
    li { margin-bottom: 4px; }
    ul li { list-style-type: disc; }
    ol li { list-style-type: decimal; }

    code {
      background: #f0f0f0;
      color: #c0392b;
      padding: 2px 6px;
      border-radius: 4px;
      font-family: 'Consolas', 'Courier New', monospace;
      font-size: 13px;
      word-wrap: break-word; /* ✅ BREAKS LONG INLINE CODE */
    }

    pre {
      background: #f5f5f5;
      padding: 12px;
      border-radius: 8px;
      margin-bottom: 10px;
      max-width: 100%;
      overflow-x: auto; /* ✅ SCROLLS WIDE CODE INSTEAD OF BREAKING BOX */
    }
    pre code {
      background: none;
      padding: 0;
      color: #333;
    }

    blockquote {
      border-left: 4px solid #6c63ff;
      padding: 8px 0 8px 16px;
      color: #555;
      font-style: italic;
      margin-bottom: 10px;
    }

    /* ✅ TABLE FIX: Must be display:block for overflow to work */
    table {
      border-collapse: collapse;
      width: 100%;
      margin-bottom: 10px;
      display: block;
      max-width: 100%;
      overflow-x: auto; /* ✅ SCROLLS WIDE TABLES INSTEAD OF BREAKING BOX */
    }
    th, td {
      border: 1px solid #ddd;
      padding: 8px;
      text-align: left;
    }
    th { font-weight: 700; background: #f9f9f9; }

    a { color: #6c63ff; text-decoration: underline; }
    hr { border: none; border-top: 1px solid #e0e0e0; margin: 12px 0; }
    img { max-width: 100%; height: auto; }
  </style>
  <script>
    const ro = new ResizeObserver(() => {
      HeightChannel.postMessage(document.documentElement.scrollHeight.toString());
    });
    window.addEventListener('DOMContentLoaded', () => ro.observe(document.body));
  </script>
</head>
<body>
  $htmlBody
</body>
</html>''';
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX 1: LayoutBuilder strictly locks the native WebView width
    // so it can NEVER expand past the container, even if the HTML asks it to
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: _height,
          width: constraints.maxWidth, 
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (!_isFirstLoadReady)
                Positioned.fill(
                  child: Container(color: Colors.white),
                ),
            ],
          ),
        );
      },
    );
  }
}