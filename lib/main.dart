import 'dart:io';

import 'package:flutter/material.dart';
import 'package:violet/os/windows/feature/auth/pages/login_screen.dart';
import 'package:violet/os/windows/feature/chat/chats_screen.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Violet App');
    setWindowMinSize(const Size(800, 700)); // Set minimum size
    setWindowFrame(Rect.fromLTWH(100, 100, 1000, 700)); // Set initial position and size
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home:LoginScreen(),
    );
  }
}