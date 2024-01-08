import 'package:flutter/material.dart';
import 'package:frontend_app/Welcome/welcome.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Logger',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const WelcomeScreen(),
    );
  }
}