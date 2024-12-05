import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gif_creator/providers/video_state.dart';
import 'package:gif_creator/home.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => VideoState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GIF Creator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}
