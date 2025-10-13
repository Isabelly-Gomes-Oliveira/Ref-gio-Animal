import 'package:flutter/material.dart';

class CadastrarPetPage extends StatelessWidget {
  const CadastrarPetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7E8D5), // fundo bege
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7E8D5),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Cadastrar pet para adoção 🐾",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _campoTexto("Nome do pet"),
              _campoTexto("Espécie"),
              _campoTexto("Raça"),
              _campoTexto("Idade do pet"),
              _campoTexto("Descrição do pet *", maxLines: 4),
              _campoTexto("Deficiência do pet"),
              _campoTexto("Imagem do pet *"),
              _campoTexto("Digite seu CPF *"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B2B5B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                ),
                child: const Text(
                  "Cadastrar pet para adoção ❤️",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
