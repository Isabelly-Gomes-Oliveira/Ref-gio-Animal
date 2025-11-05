import 'package:flutter/material.dart';
import 'package:refugio_animal/Screens/cadastroUsuario.dart';
import 'package:refugio_animal/Screens/login.dart';

//void main() {
//  runApp(const MyApp());
//}

//class MyApp extends StatelessWidget {
//  const MyApp({super.key});

//  @override
//  Widget build(BuildContext context) {
//    return const MaterialApp(
//      debugShowCheckedModeBanner: false,
//      home: CadastroUsuario(),
//   );
//  }
//}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Refúgio Animal',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8E9D2),
      ),
      initialRoute: '/login', // tela inicial
      routes: {
        '/login': (context) => const LoginScreen(), // aqui registra a rota de login
        '/cadastroUser': (context) => const CadastroUsuario(), // rota de cadastro de usuário
      },
    );
  }
}