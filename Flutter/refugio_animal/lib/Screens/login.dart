import 'package:flutter/material.dart';
// Importação para usar TextInputFormatter
import 'package:flutter/services.dart'; 
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
const Color kErrorTextColor = Color(0xFFD32F2F); 
const Color kSuccessTextColor = Color(0xFF388E3C); 

// Largura máxima solicitada (400.0)
const double kMaxWidthDesktop = 400.0;

// **********************************************
// * FORMATTER PERSONALIZADO PARA CPF           *
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
        
        // Limita o tamanho máximo (11 dígitos + 3 pontos + 1 traço = 14 caracteres)
        if (newText.length > 14) {
            newText = newText.substring(0, 14);
        }

        // Calcula a posição do cursor para que ele fique no final ou após o último caractere digitado
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

        setState(() {
            _isLoading = true;
            _errorMessage = null; // Limpa a mensagem anterior
            _isSuccess = false;
        });

        try {
            // Chama o método da sua classe real, importada de conexaoAPI.dart
            final success = await ApiService.loginUsuario(cpf, senha); 

            if (success) {
                // Login bem-sucedido: Define a mensagem de sucesso
                setState(() {
                    _errorMessage = 'Login Bem-Sucedido!';
                    _isSuccess = true;
                });
                debugPrint('Login Bem-Sucedido!');
                // TODO: Adicionar navegação para a tela principal aqui.
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
            
            if (errorText.contains('401') || errorText.contains('Credenciais inválidas')) {
                errorMsg = 'Credenciais inválidas.';
            } else {
                errorMsg = 'Erro de conexão ou servidor.';
            }
            
            setState(() {
                _errorMessage = errorMsg;
                _isSuccess = false;
            });
            debugPrint('Erro na API: ${e.toString()}');
        } finally {
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

                                // 2. Card do Formulário de Login (PASSANDO O NOVO ESTADO E FUNÇÃO)
                                LoginFormCard(
                                    cpfController: _cpfController,
                                    senhaController: _senhaController,
                                    onLoginPressed: _handleLogin,
                                    isLoading: _isLoading,
                                    errorMessage: _errorMessage,
                                    isSuccess: _isSuccess,
                                    
                                    // NOVO: Passando o estado e a função para o card
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
        );
    }
}

// **********************************************
// * WIDGET PARA EXIBIR MENSAGEM DE FEEDBACK    *
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
// * WIDGET DO CARD DO FORMULÁRIO (ATUALIZADO)  *
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
        required this.isPasswordVisible, // REQUERIDO
        required this.toggleVisibility, // REQUERIDO
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

                    // CAMPO DE SENHA (AGORA PASSANDO ESTADO E FUNÇÃO)
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

    // --- Funções de Componentes (Renomeadas para _private) ---
    Widget _buildTextField(
        String hintText, 
        {
            required TextEditingController controller, 
            bool isPassword = false,
            bool isCpf = false,
            // NOVOS PARÂMETROS
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
            // Usa o estado calculado
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
                // Adiciona o ícone de visibilidade
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
                        //debugPrint("Navegar para a tela de Cadastro");
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
