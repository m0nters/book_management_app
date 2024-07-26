import 'package:flutter/material.dart';
import 'controllers/overall_screen_context_controller.dart';
import 'debug_screen.dart';

void main() {
  runApp(const BookstoreManagementApp());
}

class BookstoreManagementApp extends StatelessWidget {
  const BookstoreManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Archivo",
        // splashColor: Colors.transparent, // Disable splash for taps
        // highlightColor: Colors.transparent, // Disable highlight for long presses
      ),
      home: const SafeArea(child: MainScreenContextController()),
      // home: const DebugScreen(),
    );
  }
}
