import 'package:flutter/material.dart';
import 'package:refugio_animal/Network/pet.dart';

// --- Cores Personalizadas ---
const Color kBackgroundColor = Color(0xFFF8E9D2); // Cor de fundo do corpo
const Color kPrimaryColor = Color(0xFF48526E); // Roxo escuro

class AlterarDadosPet extends StatelessWidget {
  final Pet petToEdit;

  const AlterarDadosPet({
    super.key,
    required this.petToEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Editar Pet: ${petToEdit.nome}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: Colors.white), // Ícone de voltar branco
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pets, size: 80, color: kPrimaryColor),
              const SizedBox(height: 20),
              Text(
                'Esta é a tela de Alteração de Dados para o pet: ${petToEdit.nome}.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: kPrimaryColor),
              ),
              const SizedBox(height: 10),
              Text(
                'ID: ${petToEdit.id}',
                style: const TextStyle(fontSize: 16, color: kPrimaryColor),
              ),
              const SizedBox(height: 40),
              // Aqui entrariam os formulários para alterar nome, raça, etc.
              ElevatedButton(
                onPressed: () {
                  // Lógica de salvar ou mock de salvar
                  Navigator.pop(context); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Salvar Alterações (Mock)', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}