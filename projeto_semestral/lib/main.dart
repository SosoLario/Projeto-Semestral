import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const ClassManagerApp());
}

class ClassManagerApp extends StatelessWidget {
  const ClassManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClassManager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E2A47), // Azul escuro
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF1E2A47),
          secondary: const Color(0xFFFF7A59), // Laranja
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const LoginScreen(),
    );
  }
}
