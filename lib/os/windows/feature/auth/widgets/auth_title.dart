import 'package:flutter/material.dart';

class AuthTitle extends StatelessWidget {
  String title;
  AuthTitle({
    super.key,
    required this.isAndroid,
    required this.title,
  });

  final bool isAndroid;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isAndroid ? 24 : 32,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}


