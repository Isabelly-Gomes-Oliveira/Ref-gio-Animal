import 'package:flutter/material.dart';
import 'login.dart'; // <-- importa a tela de login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // remove o banner do canto
      title: 'Refúgio Animal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      // 🐾 Define a primeira tela do app
      home: const LoginApp(), // <-- troque o nome conforme a sua tela de login
    );
  }
}
