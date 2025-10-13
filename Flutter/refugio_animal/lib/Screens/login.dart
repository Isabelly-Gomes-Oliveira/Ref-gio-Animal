import 'package:flutter/material.dart';
// Importação da sua classe de serviço API
import 'package:refugio_animal/Network/conexaoAPI.dart'; 

// --- Cores Personalizadas (Mantidas) ---
const Color kBackgroundColor = Color(0xFFF8E9D2); 
const Color kCardColorBase = Color(0xFF62739D);     
const Color kPrimaryColor = Color(0xFF48526E);  
const Color kBorderColor = Color(0xFF1A2A50);      
const Color kLinkColor = Color(0xFF1A2A50);      
const Color kInputFillColor = Color(0xFFD9D9D9); 
const Color kInputTextColor = Color(0xFF48526E); 

// Largura máxima recomendada para o formulário em desktop
const double kMaxWidthDesktop = 400.0;


// **********************************************
// * CLASSE PRINCIPAL AGORA É STATEFUL           *
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
  
  // Variáveis de estado para feedback do usuário
  bool _isLoading = false;
  String? _errorMessage;

  // Função que chama a API de Login
  Future<void> _handleLogin() async {
    // No seu design, o campo é "usuário", mas a API espera "cpf"
    final cpf = _cpfController.text.trim();
    final senha = _senhaController.text.trim();

    if (cpf.isEmpty || senha.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, preencha todos os campos.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Limpa a mensagem anterior
    });

    try {
      // Chama o método de login na ApiService
      final success = await ApiService.loginUsuario(cpf, senha);

      if (success) {
        // Login bem-sucedido: Navegar para a próxima tela
        // EXEMPLO: Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
        debugPrint('Login Bem-Sucedido! Navegar para a Home.');
        _showSuccessDialog();

      } else {
        // Teoricamente, ApiService já lança Exception, mas tratamos por segurança
         setState(() {
          _errorMessage = 'Credenciais inválidas. Tente novamente.';
        });
      }
    } catch (e) {
      // Captura a exceção lançada pela ApiService
      setState(() {
        _errorMessage = 'Erro de conexão ou credenciais inválidas. Erro: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
     showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Bem-Sucedido'),
          content: const Text('Você foi logado com sucesso!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // ... [Scaffold e Center]
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: kMaxWidthDesktop,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // 1. Área da Logo (IMAGEM DO ASSET)
                const LogoSection(),
                
                // ESPAÇAMENTO
                const SizedBox(height: 30), 

                // 2. Card do Formulário de Login (com os controladores e feedback)
                LoginFormCard(
                  cpfController: _cpfController,
                  senhaController: _senhaController,
                  onLoginPressed: _handleLogin,
                  isLoading: _isLoading,
                  errorMessage: _errorMessage,
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

// --- Widget do Logo (IMAGEM DO ASSET) ---
class LogoSection extends StatelessWidget {
  const LogoSection({super.key});

  static const String logoAssetPath = 'assets/Logo - Refugio Animal.png'; 

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      logoAssetPath,
      width: 280, 
      height: 280,
      fit: BoxFit.contain, 
    );
  }
}

// **********************************************
// * WIDGET DO CARD AGORA RECEBE PARÂMETROS      *
// **********************************************
class LoginFormCard extends StatelessWidget {
  final TextEditingController cpfController;
  final TextEditingController senhaController;
  final VoidCallback onLoginPressed;
  final bool isLoading;
  final String? errorMessage;

  const LoginFormCard({
    super.key,
    required this.cpfController,
    required this.senhaController,
    required this.onLoginPressed,
    required this.isLoading,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30.0), 
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
              fontSize: 24, 
              fontWeight: FontWeight.w700, 
            ),
          ),
          const SizedBox(height: 30),

          // CAMPO DE USUÁRIO (CPF)
          buildTextField("Digite seu usuário (CPF)", controller: cpfController),
          const SizedBox(height: 20),

          // CAMPO DE SENHA
          buildTextField("Digite sua senha", controller: senhaController, isPassword: true),
          const SizedBox(height: 40),
          
          // MENSAGEM DE ERRO (se houver)
          if (errorMessage != null) 
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),

          // BOTÃO ENTRAR
          buildElevatedButton(
            isLoading ? 'Entrando...' : "Entrar",
            isLoading ? null : onLoginPressed, // Desabilita o botão enquanto carrega
            isLoading: isLoading,
          ),
          const SizedBox(height: 30), 

          // Link de Cadastro (Dentro do Card)
          buildRegisterLink(context),
        ],
      ),
    );
  }

  // --- Funções de Componentes (Ajustadas para usar Controller) ---
  Widget buildTextField(
    String hintText, 
    {
      required TextEditingController controller, // Adicionado o controller
      bool isPassword = false
    }
  ) {
    return TextField(
      controller: controller, // Usando o controller
      obscureText: isPassword,
      cursorColor: kInputTextColor,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: kInputTextColor.withOpacity(0.7),
          fontSize: 16, 
        ),
        filled: true,
        fillColor: kInputFillColor, 
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0), 
          borderSide: BorderSide.none, 
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0), 
      ),
      style: const TextStyle(color: kInputTextColor, fontSize: 16),
    );
  }

  Widget buildElevatedButton(String text, VoidCallback? onPressed, {required bool isLoading}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorderColor, width: 2),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor, 
          padding: const EdgeInsets.symmetric(vertical: 18), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), 
          ),
          elevation: 0, 
        ),
        child: isLoading
            ? const SizedBox( // Se estiver carregando, mostra um loader
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text( // Se não estiver carregando, mostra o texto
                text,
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 20, 
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
  
  Widget buildRegisterLink(BuildContext context) {
    return Column(
      children: [
        Text(
          "Não possui uma conta?",
          style: TextStyle(
            color: kLinkColor.withOpacity(0.9), 
            fontSize: 16, 
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: () {
            debugPrint("Navegar para a tela de Cadastro");
            // Se você tiver uma tela de cadastro, pode navegar aqui
            // Exemplo: Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CadastroScreen()));
          },
          child: Text(
            "Clique Aqui",
            style: TextStyle(
              color: kLinkColor, 
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: kLinkColor,
              fontSize: 16, 
            ),
          ),
        ),
      ],
    );
  }
}