import 'package:flutter/material.dart';

class AnimatedThinkingText extends StatefulWidget {
  const AnimatedThinkingText({super.key});

  @override
  State<AnimatedThinkingText> createState() => _AnimatedThinkingTextState();
}

class _AnimatedThinkingTextState extends State<AnimatedThinkingText> {
  int _dotCount = 1;
  late final _timer;

  @override
  void initState() {
    super.initState();
    // cycle dots every 500ms: . -> .. -> ... -> . -> ...
    _timer = Stream.periodic(const Duration(milliseconds: 500)).listen((_) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount % 3) + 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;
    return Text(
      "Violet is thinking$dots",
      style: TextStyle(color: Colors.grey[600], fontSize: 14),
    );
  }
}
