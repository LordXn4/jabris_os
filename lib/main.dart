import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const OdasApp());
}

class OdasApp extends StatelessWidget {
  const OdasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ODAS',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

