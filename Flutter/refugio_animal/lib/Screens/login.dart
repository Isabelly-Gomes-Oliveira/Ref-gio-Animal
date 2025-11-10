import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // <-- Import necessário para a conexão HTTP
import 'dart:convert'; // <-- Para converter JSON
// Importação para usar TextInputFormatter
import 'package:flutter/services.dart';
// Importação da sua classe de serviço API
import 'package:refugio_animal/Network/conexaoAPI.dart';

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


// --- Cores Personalizadas (Mantidas) ---
const Color kBackgroundColor = Color(0xFFF8E9D2);
const Color kCardColorBase = Color(0xFF62739D);
const Color kPrimaryColor = Color(0xFF48526E);
const Color kBorderColor = Color(0xFF1A2A50);
const Color kLinkColor = Color(0xFF1A2A50);
const Color kInputFillColor = Color(0xFFD9D9D9);
const Color kInputTextColor = Color(0xFF48526E);
const Color kErrorTextColor = Color(0xFFD32F2F);
const Color kSuccessTextColor = Color(0xFF388E3C);

// Largura máxima solicitada (400.0)
const double kMaxWidthDesktop = 400.0;

// **********************************************
// * FORMATTER PERSONALIZADO PARA CPF           *
// **********************************************
class CpfInputFormatter extends TextInputFormatter {
    @override
    TextEditingValue formatEditUpdate(
        TextEditingValue oldValue,
        TextEditingValue newValue,
    ) {
        final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
        if (text.isEmpty) {
            return newValue.copyWith(text: '');
        }

        String newText = '';
        
        // Adiciona pontos e traço
        for (int i = 0; i < text.length; i++) {
            if (i == 3 || i == 6) {
                newText += '.';
            } else if (i == 9) {
                newText += '-';
            }
            newText += text[i];
        }
        
        // Limita o tamanho máximo (11 dígitos + 2 pontos + 1 traço = 14 caracteres)
        if (newText.length > 14) {
            newText = newText.substring(0, 14);
        }

        // Calcula a posição do cursor
        int cursorPosition = newText.length;

        return TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: cursorPosition),
        );
    }
}

// **********************************************
// * CLASSE PRINCIPAL (ESTADO PARA VISIBILIDADE) *
// **********************************************
class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key});

    @override
    State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    // Controladores para capturar o texto dos campos
    final TextEditingController _cpfController = TextEditingController();
    final TextEditingController _senhaController = TextEditingController();

    // VARIÁVEL DE ESTADO PARA O OLHO (VISIBILIDADE DA SENHA)
    bool _isPasswordVisible = false;
    
    // Variáveis de estado para feedback do usuário
    bool _isLoading = false;
    String? _errorMessage;
    bool _isSuccess = false;

    // Função que alterna o estado de visibilidade da senha
    void _togglePasswordVisibility() {
        setState(() {
            _isPasswordVisible = !_isPasswordVisible;
        });
    }

    // Função que chama a API de Login
    Future<void> _handleLogin() async {
        // Remove a formatação para enviar apenas os dígitos para a API
        final cpf = _cpfController.text.replaceAll(RegExp(r'[^\d]'), '').trim();
        final senha = _senhaController.text.trim();

        // 1. Validação de campos vazios
        if (cpf.isEmpty || senha.isEmpty) {
            setState(() {
                _errorMessage = 'Por favor, preencha todos os campos.';
                _isSuccess = false;
            });
            return;
        }
        
        // 2. Validação básica de tamanho do CPF (11 dígitos)
        if (cpf.length != 11) {
            setState(() {
                _errorMessage = 'O CPF deve conter 11 dígitos.';
                _isSuccess = false;
            });
            return;
        }
        
        // Fechar o teclado
        if (mounted) {
          FocusScope.of(context).unfocus();
        }

        setState(() {
            _isLoading = true;
            _errorMessage = null; // Limpa a mensagem anterior
            _isSuccess = false;
        });

        try {
            // Chama o método da sua classe real, importada de conexaoAPI.dart
            final success = await ApiService.loginUsuario(cpf, senha);

            // Verifique se o widget ainda está montado ANTES de usar
            // o setState ou o Navigator após o await.
            if (!mounted) return;

            if (success) {
                // Login bem-sucedido: Define a mensagem de sucesso
                setState(() {
                    _errorMessage = 'Login Bem-Sucedido!';
                    _isSuccess = true;
                });
                debugPrint('Login Bem-Sucedido! Navegando para /home com CPF: $cpf');
                
                // --- CORREÇÃO CRÍTICA DE NAVEGAÇÃO ---
                // Navega para a rota /home E passa o CPF como argumento.
                // Usamos 'pushNamedAndRemoveUntil' para que o usuário
                // não possa "voltar" para a tela de login.
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false, // Remove todas as telas anteriores
                  arguments: cpf,    // <--- CORREÇÃO: Passa o CPF para a rota /home
                );

            } 
            else {
                setState(() {
                    _errorMessage = 'Credenciais inválidas.';
                    _isSuccess = false;
                });
            }
        } catch (e) {
            String errorMsg;
            final errorText = e.toString();
            
            // Trata erros específicos
            if (errorText.contains('401') || errorText.contains('Credenciais inválidas')) {
                errorMsg = 'Credenciais inválidas.';
            } else {
                errorMsg = 'Erro de conexão ou servidor. Tente novamente.';
            }
            
            if (!mounted) return;
            setState(() {
                _errorMessage = errorMsg;
                _isSuccess = false;
            });
            debugPrint('Erro na API: ${e.toString()}');
        } finally {
            if (!mounted) return;
            setState(() {
                _isLoading = false;
            });
        }
    }


    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: kBackgroundColor,
            body: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        maxWidth: kMaxWidthDesktop,
                    ),
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0, bottom: 20.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                                // 1. Área da Logo
                                const LogoSection(),
                                
                                const SizedBox(height: 15),

                                // 2. Card do Formulário de Login
                                LoginFormCard(
                                    cpfController: _cpfController,
                                    senhaController: _senhaController,
                                    onLoginPressed: _handleLogin,
                                    isLoading: _isLoading,
                                    errorMessage: _errorMessage,
                                    isSuccess: _isSuccess,
                                    
                                    isPasswordVisible: _isPasswordVisible,
                                    toggleVisibility: _togglePasswordVisibility,
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }

    @override
    void dispose() {
        _cpfController.dispose();
        _senhaController.dispose();
        super.dispose();
    }
}

// --- Widget do Logo ---
class LogoSection extends StatelessWidget {
    const LogoSection({super.key});

    static const String logoAssetPath = 'assets/imagens/logo.png';

    @override
    Widget build(BuildContext context) {
        return Image.asset(
            logoAssetPath,
            width: 350,
            height: 350,
            fit: BoxFit.contain,
            // Adicionado um 'errorBuilder' para o caso da imagem não carregar
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 350,
                height: 350,
                color: kInputFillColor,
                child: const Center(
                  child: Text(
                    'Logo não encontrada', 
                    style: TextStyle(color: kErrorTextColor)
                  ),
                ),
              );
            },
        );
    }
}

// **********************************************
// * WIDGET PARA EXIBIR MENSAGEM DE FEEDBACK    *
// **********************************************
class FeedbackMessage extends StatelessWidget {
    final String message;
    final bool isSuccess;

    const FeedbackMessage({
        super.key,
        required this.message,
        required this.isSuccess,
    });

    @override
    Widget build(BuildContext context) {
        final color = isSuccess ? kSuccessTextColor : kErrorTextColor;

        return Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            margin: const EdgeInsets.only(bottom: 15.0),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: color, width: 1.5),
                boxShadow: [
                    BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                    ),
                ],
            ),
            child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                ),
            ),
        );
    }
}


// **********************************************
// * WIDGET DO CARD DO FORMULÁRIO (ATUALIZADO)  *
// **********************************************
class LoginFormCard extends StatelessWidget {
    final TextEditingController cpfController;
    final TextEditingController senhaController;
    final VoidCallback onLoginPressed;
    final bool isLoading;
    final String? errorMessage;
    final bool isSuccess;
    
    // NOVOS CAMPOS PARA VISIBILIDADE DA SENHA
    final bool isPasswordVisible;
    final VoidCallback toggleVisibility;

    const LoginFormCard({
        super.key,
        required this.cpfController,
        required this.senhaController,
        required this.onLoginPressed,
        required this.isLoading,
        this.errorMessage,
        this.isSuccess = false,
        required this.isPasswordVisible,
        required this.toggleVisibility,
    });

    @override
    Widget build(BuildContext context) {
        return Container(
            padding: const EdgeInsets.all(25.0),
            decoration: BoxDecoration(
                color: kCardColorBase.withOpacity(0.6),
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: kBorderColor, width: 2),
                boxShadow: [
                    BoxShadow(
                        color: kPrimaryColor.withOpacity(0.4),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, 5),
                    ),
                ],
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                    Text(
                        "Login",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: kInputTextColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                        ),
                    ),
                    const SizedBox(height: 20),

                    // CAMPO DE USUÁRIO (CPF)
                    _buildTextField(
                        "Digite seu usuário (CPF)",
                        controller: cpfController,
                        isCpf: true,
                    ),
                    const SizedBox(height: 15),

                    // CAMPO DE SENHA
                    _buildTextField(
                        "Digite sua senha",
                        controller: senhaController,
                        isPassword: true,
                        isPasswordVisible: isPasswordVisible,
                        toggleVisibility: toggleVisibility,
                    ),
                    const SizedBox(height: 30),
                    
                    // MENSAGEM DE FEEDBACK (Erro ou Sucesso)
                    if (errorMessage != null)
                        FeedbackMessage(
                            message: errorMessage!,
                            isSuccess: isSuccess,
                        ),

                    // BOTÃO ENTRAR
                    _buildElevatedButton(
                        isLoading ? 'Entrando...' : "Entrar",
                        isLoading ? null : onLoginPressed,
                        isLoading: isLoading,
                    ),
                    const SizedBox(height: 20),

                    // Link de Cadastro (Dentro do Card)
                    _buildRegisterLink(context),
                ],
            ),
        );
    }

    // --- Funções de Componentes ---
    Widget _buildTextField(
        String hintText,
        {
            required TextEditingController controller,
            bool isPassword = false,
            bool isCpf = false,
            bool isPasswordVisible = false,
            VoidCallback? toggleVisibility,
        }
    ) {
        // Lógica para obscurecer ou não a senha
        final shouldObscure = isPassword && !isPasswordVisible;
        
        // Lógica para o ícone de visibilidade (só para campo de senha)
        final suffixIcon = isPassword ? IconButton(
            icon: Icon(
                // Alterna entre o ícone de olho aberto e fechado
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: kInputTextColor.withOpacity(0.7),
            ),
            onPressed: toggleVisibility,
        ) : null;

        return TextField(
            controller: controller,
            obscureText: shouldObscure,
            cursorColor: kInputTextColor,
            keyboardType: isCpf ? TextInputType.number : TextInputType.text,
            inputFormatters: isCpf ? [
                FilteringTextInputFormatter.digitsOnly,
                CpfInputFormatter(),
            ] : null,
            
            decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                    color: kInputTextColor.withOpacity(0.7),
                    fontSize: 15,
                ),
                filled: true,
                fillColor: kInputFillColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
                suffixIcon: suffixIcon,
            ),
            style: const TextStyle(color: kInputTextColor, fontSize: 16),
        );
    }

    Widget _buildElevatedButton(String text, VoidCallback? onPressed, {required bool isLoading}) {
        return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kBorderColor, width: 2),
            ),
            child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                        ),
                    )
                    : Text(
                        text,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                        ),
                    ),
            ),
        );
    }
    
    Widget _buildRegisterLink(BuildContext context) {
        return Column(
            children: [
                Text(
                    "Não possui uma conta?",
                    style: TextStyle(
                        color: kLinkColor.withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                    ),
                ),
                TextButton(
                    onPressed: () {
                        // Navega para a rota de cadastro.
                        Navigator.pushNamed(context, '/cadastroUser');
                    },
                    child: Text(
                        "Clique Aqui",
                        style: TextStyle(
                            color: kLinkColor,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: kLinkColor,
                            fontSize: 15,
                        ),
                    ),
                ),
            ],
        );
    }
}
