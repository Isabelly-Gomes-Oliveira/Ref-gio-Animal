import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Network/conexaoAPI.dart';
import '../Network/usuario.dart';

class CadastroUsuario extends StatefulWidget {
  const CadastroUsuario({super.key});

  @override
  State<CadastroUsuario> createState() => _CadastroUsuarioState();
}

class _CadastroUsuarioState extends State<CadastroUsuario> {
  // Controllers dos campos:
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  // 👉 Controle do olho do campo de senha
  bool _mostrarSenha = false;

  // Para exibir mensagens:
  void mostrarMensagem(String msg, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: erro ? Colors.red : Colors.green,
      ),
    );
  }

  // Função de cadastro real:
  Future<void> cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final novoUsuario = Usuario(
        cpf: cpfController.text.trim(),
        nome: nomeController.text.trim(),
        email: emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        telefone: telefoneController.text.trim(),
      );

      bool sucesso = await ApiService.cadastrarUsuario(
        novoUsuario,
        senhaController.text.trim(),
      );

      if (sucesso) {
        mostrarMensagem("Cadastro realizado com sucesso!");
        Navigator.pushNamed(context, "/login");
      }
    } catch (e) {
      mostrarMensagem("Erro ao cadastrar: $e", erro: true);
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8E9D2),

      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/imagens/logo.png',
                width: 300,
                height: 300,
              ),

              const SizedBox(height: 20),

              Container(
                width: 350,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF62739D),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Form(
                  key: _formKey,
                  child: Column(
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

                      campo("Digite seu CPF*", cpfController,
                          validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Informe seu CPF";
                        }
                        if (value.length < 11) {
                          return "CPF incompleto";
                        }
                        return null;
                      }, formatterNum: true),

                      const SizedBox(height: 15),

                      campo("Digite seu nome*", nomeController,
                          validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Informe seu nome";
                        }
                        return null;
                      }),

                      const SizedBox(height: 15),

                      campo("Digite seu telefone*", telefoneController,
                          validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Informe seu telefone";
                        }
                        if (value.length < 11) {
                          return "Telefone incompleto";
                        }
                        return null;
                      }, formatterNum: true),

                      const SizedBox(height: 15),

                      campo("Digite seu e-mail", emailController,
                          validator: (value) {
                        if (value!.isNotEmpty &&
                            !value.contains("@")) {
                          return "E-mail inválido";
                        }
                        return null;
                      }),

                      const SizedBox(height: 15),

                      // ====================================================
                      // ⚠️ CAMPO DE SENHA COM OLHINHO (VISUALIZAR SENHA)
                      // ====================================================
                      TextFormField(
                        controller: senhaController,
                        obscureText: !_mostrarSenha,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Informe sua senha";
                          }
                          if (value.length < 4) {
                            return "A senha deve ter pelo menos 4 caracteres";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Digite sua senha*",
                          filled: true,
                          fillColor: const Color(0xFFD9D9D9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),

                          // 👉 Ícone do olho
                          suffixIcon: IconButton(
                            icon: Icon(
                              _mostrarSenha
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _mostrarSenha = !_mostrarSenha;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

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
                          onPressed: loading ? null : cadastrar,
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
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

                      const Text(
                        'Possui uma conta?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),

                      TextButton(
                        onPressed: () {
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Função geradora de campos
  Widget campo(String hint, TextEditingController controller,
      {bool obscure = false,
      bool formatterNum = false,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType:
          formatterNum ? TextInputType.number : TextInputType.text,
      inputFormatters: formatterNum
          ? [FilteringTextInputFormatter.digitsOnly]
          : [],
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFD9D9D9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }
}
