import 'package:flutter/material.dart';
import 'package:refugio_animal/Screens/cadastroUsuario.dart';
import 'package:refugio_animal/Screens/login.dart';
import 'package:refugio_animal/Screens/principal.dart'; 
import 'package:refugio_animal/Screens/cadastropet.dart'; 
import 'package:refugio_animal/Screens/perfil.dart';       

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
            debugShowCheckedModeBanner: false, // Adicionando para remover a faixa vermelha
            initialRoute: '/login', // Tela inicial ainda é o Login
            routes: {
                '/login': (context) => const LoginScreen(), // Rota de login
                '/cadastroUser': (context) => const CadastroUsuario(), // Rota de cadastro
                '/home': (context) => const TelaPrincipal(), // NOVA ROTA: Tela Principal/Home
                '/cadastroPet': (context) => const CadastrarPetPage(), // NOVA ROTA: Tela Principal/Home
                '/Perfil': (context) => const TelaPerfil(), // NOVA ROTA: Tela Principal/Home
            },
        );
    }
}