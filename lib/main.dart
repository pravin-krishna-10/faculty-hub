import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const FacultyHubApp());
}

class FacultyHubApp extends StatelessWidget {
  const FacultyHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FacultyHub',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
