// NOVO ARQUIVO: tela_perfil.dart

import 'package:flutter/material.dart';

class TelaPerfil extends StatelessWidget {
  // Cores personalizadas (opcional, mas bom para manter a consistência)
  static const Color kPrimaryColor = Color(0xFF48526E); 
  static const Color kBackgroundColor = Color(0xFFF8E9D2);

  const TelaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Meu Perfil',
          style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: kPrimaryColor), // Cor do ícone de voltar
        elevation: 0,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_pin,
                size: 80,
                color: kPrimaryColor,
              ),
              SizedBox(height: 20),
              Text(
                'TELA DE PERFIL',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: kPrimaryColor,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Aqui serão exibidas as informações do usuário logado.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}