import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'title_screen.dart';

void main() {
  runApp(const SacheonseongApp());
}

class SacheonseongApp extends StatelessWidget {
  const SacheonseongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '사천성',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8D6E63)),
        useMaterial3: true,
      ),
      home: const TitleScreen(),
    );
  }
}
