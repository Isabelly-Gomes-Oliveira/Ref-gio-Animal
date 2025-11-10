import 'package:flutter/material.dart';
// Importação para usar TextInputFormatter
import 'package:flutter/services.dart'; 
// Importação da sua classe de serviço API
import 'package:refugio_animal/Network/conexaoAPI.dart'; 

class CadastroUsuario extends StatefulWidget {
  const CadastroUsuario({super.key});

  @override
  State<CadastroUsuario> createState() => _CadastroUsuarioState();
}

class _CadastroUsuarioState extends State<CadastroUsuario> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF8E9D2), // fundo da tela

      body: Center(
        child: SingleChildScrollView(

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagem acima do formulário
              Image.asset(
                'assets/imagens/logo.png',
                width: 350,
                height: 350,
              ),
              const SizedBox(height: 20),



              // Retângulo do formulário
              Container(
                width: 350,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF62739D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'CADASTRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),

                    //  Campo CPF
                    _buildCampo('Digite seu CPF*'),
                    const SizedBox(height: 15),

                    //  Campo Nome
                    _buildCampo('Digite seu nome*'),
                    const SizedBox(height: 15),

                    //  Campo Telefone
                    _buildCampo('Digite seu telefone*'),
                    const SizedBox(height: 15),

                    //  Campo E-mail
                    _buildCampo('Digite seu e-mail'),
                    const SizedBox(height: 15),

                    //  Campo Senha
                    _buildCampo('Digite sua senha*', obscure: true),
                    const SizedBox(height: 25),

                    //  Botão Cadastrar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF48526E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          // lógica do cadastro
                        },
                        child: const Text(
                          'CADASTRAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Texto pequeno
                    const Text(
                      'Possui uma conta?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),

                    // "Clique aqui"
                    TextButton(
                      onPressed: () {
                        // Aqui você pode redirecionar para a tela de login
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        'Clique aqui',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Função para criar os campos de texto
  Widget _buildCampo(String hint, {bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFD9D9D9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}