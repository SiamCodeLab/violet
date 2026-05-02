import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:violet/core/services/storage/storage_service.dart';
import 'package:violet/core/services/websocket_service.dart';
import 'package:violet/os/windows/feature/auth/pages/login_screen.dart';
import 'package:violet/os/windows/feature/home/pages/home_screen.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Enable edge-to-edge for Flutter
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await StorageService.init();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Violet App');
    setWindowMinSize(const Size(800, 700));

    // Get screen info and maximize window
    final screens = await getScreenList();
    if (screens.isNotEmpty) {
      final screen = screens.first;
      final frame = screen.visibleFrame;

      // Set window to fill entire screen (maximized)
      setWindowFrame(
        Rect.fromLTWH(frame.left, frame.top, frame.width, frame.height),
      );
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget get initialRoute =>
      StorageService.hasValidToken() ? HomeScreen() : LoginScreen();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Violet App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: initialRoute,
      initialBinding: BindingsBuilder(() {
        Get.put(WebSocketService(), permanent: true);
      }),
    );
  }
}
