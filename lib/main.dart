import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'title_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
