import 'package:flutter/material.dart';
import 'package:refugio_animal/Screens/cadastroUsuario.dart';
import 'package:refugio_animal/Screens/login.dart';
import 'package:refugio_animal/Screens/principal.dart';
import 'package:refugio_animal/Screens/cadastropet.dart';
import 'package:refugio_animal/Screens/perfil.dart';
import 'package:refugio_animal/Screens/alterarDadosPet.dart'; 
import 'package:refugio_animal/Network/pet.dart'; 
import 'package:refugio_animal/Screens/alterarDadosUsuario.dart';

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
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',

      // Rotas que NÃO precisam de argumentos
      routes: {
        '/login': (context) => const LoginScreen(),
        '/cadastroUser': (context) => const CadastroUsuario(),
      },

      // onGenerateRoute lida com rotas que PRECISAM de argumentos
      onGenerateRoute: (settings) {
        final args = settings.arguments;

        switch (settings.name) {

          case '/home':
            if (args is String) {
              return MaterialPageRoute(
                builder: (context) => TelaPrincipal(cpfUsuario: args),
              );
            }
            return _errorRoute("CPF não fornecido para a tela Home.");

          case '/perfil':
            if (args is String) {
              return MaterialPageRoute(
                builder: (context) => TelaPerfil(cpfUsuario: args),
              );
            }
            return _errorRoute("CPF não fornecido para a tela de Perfil.");

          case '/alterarDadosUsuario':
            if (args is String) {
              return MaterialPageRoute(
                builder: (context) => AlterarDadosUsuarioScreen(cpfUsuario: args),
              );
            }
            return _errorRoute("CPF não fornecido para a alteração de dados do usuário.");

          case '/cadastroPet':
            debugPrint('args recebidos: $args');
            if (args is String && args.isNotEmpty) {
              return MaterialPageRoute(
                builder: (context) => CadastrarPetPage(cpfUsuario: args),
              );
            }
            return _errorRoute("CPF não fornecido para o cadastro de pet.");


          case '/alterarPet': 
            if (args is Pet) {
              return MaterialPageRoute(
                builder: (context) => AlterarDadosPet(petToEdit: args),
              );
            }
            return _errorRoute("Objeto Pet não fornecido para a alteração.");

          default:
            return _errorRoute("Rota desconhecida: ${settings.name}");
        }
      },
    );
  }

  // Rota de erro genérica
  static MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }
}