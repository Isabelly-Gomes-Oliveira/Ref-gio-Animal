import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // <-- Import necessário para a conexão HTTP
import 'dart:convert'; // <-- Para converter JSON

class LoginApp extends StatefulWidget {
  const LoginApp({super.key});

  @override
  State<LoginApp> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<LoginApp> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool _carregando = false;

  // =========================
  // 🔗 FUNÇÃO DE LOGIN COM API
  // =========================
  Future<void> fazerLogin() async {
    setState(() {
      _carregando = true;
    });

    // ⚠️ Substitua pela URL da SUA API
    const String url = "http://177.220.18.3:8081/login";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "usuario": usuarioController.text,
          "senha": senhaController.text,
        }),
      );

      if (response.statusCode == 200) {
        // ✅ LOGIN BEM-SUCEDIDO
        final dados = json.decode(response.body);
        print("Usuário autenticado: $dados");

        // Aqui você pode salvar o token ou redirecionar para a próxima tela
        // Exemplo:
        // Navigator.pushReplacementNamed(context, '/home');

      } else {
        // ❌ ERRO DE LOGIN
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário ou senha inválidos')),
        );
      }
    } catch (e) {
      // 🚨 ERRO DE CONEXÃO
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar com o servidor: $e')),
      );
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8E9D2), // bege do fundo
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // =========================
              // 🐶 LOGO SUPERIOR
              // =========================
              Image.asset(
                'assets/logo.png', // <-- substitua pelo nome da sua imagem
                height: 120,
              ),
              const SizedBox(height: 40),

              // =========================
              // 📦 CARD DE LOGIN
              // =========================
              Container(
                width: 280,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // =========================
                    // 👤 CAMPO DE USUÁRIO
                    // =========================
                    TextField(
                      controller: usuarioController,
                      decoration: InputDecoration(
                        hintText: 'Digite seu usuário',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // =========================
                    // 🔒 CAMPO DE SENHA
                    // =========================
                    TextField(
                      controller: senhaController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Digite sua senha',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // =========================
                    // 🔘 BOTÃO DE ENTRAR
                    // =========================
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _carregando ? null : fazerLogin, // <-- chama API
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B5563),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _carregando
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // =========================
                    // 🔗 LINK PARA CADASTRO
                    // =========================
                    GestureDetector(
                      onTap: () {
                        // Aqui você coloca a navegação para a tela de cadastro
                        // Exemplo:
                        // Navigator.pushNamed(context, '/cadastro');
                      },
                      child: const Text(
                        'Não possui uma conta? Clique aqui',
                        style: TextStyle(
                          color: Colors.black87,
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
}
