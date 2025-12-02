import 'package:flutter/material.dart';
import 'package:violet/core/const/string_cont/path_strings.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({
    super.key,
    required this.isAndroid,
  });

  final bool isAndroid;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      PathStrings.logoPath,
      width: isAndroid ? 100 : 200,
    );
  }
}
