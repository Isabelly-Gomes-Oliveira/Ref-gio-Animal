import 'package:flutter/material.dart';
import 'package:refugio_animal/Network/conexaoAPI.dart';
import 'dart:convert';

// --- Cores Personalizadas ---
const Color kBackgroundColor = Color(0xFFF8E9D2);
const Color kPrimaryColor = Color(0xFF48526E);
const Color kInputFillColor = Color(0xFFFFFFFF);
const Color kDividerColor = Color(0xFFB0B0B0);
const Color kReturnButtonColor = Color(0xFFD91E18);

class AlterarDadosUsuarioScreen extends StatefulWidget {
  final String cpfUsuario;

  const AlterarDadosUsuarioScreen({super.key, required this.cpfUsuario});

  @override
  State<AlterarDadosUsuarioScreen> createState() =>
      _AlterarDadosUsuarioScreenState();
}

class _AlterarDadosUsuarioScreenState
    extends State<AlterarDadosUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaAntigaController = TextEditingController();
  final TextEditingController _novaSenhaController = TextEditingController();

  bool _obscureSenhaAntiga = true;
  bool _obscureNovaSenha = true;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaAntigaController.dispose();
    _novaSenhaController.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosUsuario() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final usuario =
          await ApiService.getUsuarioByCpf(widget.cpfUsuario.trim());

      if (!mounted) return;
      setState(() {
        _cpfController.text = usuario.cpf ?? '';
        _nomeController.text = usuario.nome ?? '';
        _telefoneController.text = usuario.telefone ?? '';
        _emailController.text = usuario.email ?? '';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _mostrarConfirmacao() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFBF9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Confirmar alterações",
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Tem certeza de que deseja salvar as alterações feitas em seus dados?",
          style: TextStyle(color: Colors.black87, fontSize: 15),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancelar",
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.pets, color: Colors.white),
            label: const Text(
              "Confirmar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      _salvarAlteracoes();
    }
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      // Verifica se o login é válido antes da alteração
      final loginValido = await ApiService.loginUsuario(
        _cpfController.text.trim(),
        _senhaAntigaController.text.trim(),
      );

      if (!loginValido && _novaSenhaController.text.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Senha antiga incorreta. Verifique e tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Atualiza os dados
      final sucesso = await ApiService.atualizarUsuario(
        _cpfController.text.trim(),
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        telefone: _telefoneController.text.trim(),
        senha: _novaSenhaController.text.isEmpty
            ? null
            : _novaSenhaController.text.trim(),
      );

      if (!mounted) return;

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados atualizados com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retorna true para atualizar perfil
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falha ao atualizar os dados.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // ===================================================================
  // CAMPOS DE SENHA
  // ===================================================================
  Widget _buildCampoSenha(
    String label,
    TextEditingController controller, {
    required bool isNovaSenha,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isNovaSenha ? _obscureNovaSenha : _obscureSenhaAntiga,
      decoration: InputDecoration(
        labelText: label,
        hintText: isNovaSenha
            ? "Deixe em branco para manter a atual"
            : "Necessária para alterar senha/email",
        filled: true,
        fillColor: kInputFillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: IconButton(
          icon: Icon(
            (isNovaSenha ? _obscureNovaSenha : _obscureSenhaAntiga)
                ? Icons.visibility_off
                : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              if (isNovaSenha) {
                _obscureNovaSenha = !_obscureNovaSenha;
              } else {
                _obscureSenhaAntiga = !_obscureSenhaAntiga;
              }
            });
          },
        ),
      ),
      validator: (value) {
        if (isNovaSenha) {
          if (value != null && value.isNotEmpty && value.length < 6) {
            return 'A nova senha deve ter pelo menos 6 caracteres.';
          }
        } else {
          if (_novaSenhaController.text.isNotEmpty &&
              (value == null || value.isEmpty)) {
            return 'Informe a senha antiga para alterar a senha.';
          }
        }
        return null;
      },
    );
  }

  // ===================================================================
  // WIDGETS DE CONSTRUÇÃO DA TELA
  // ===================================================================
  Widget _buildReturnButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kReturnButtonColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: kReturnButtonColor.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
        onPressed: () => Navigator.pop(context),
        padding: const EdgeInsets.all(10),
        tooltip: 'Voltar',
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 70,
      height: 70,
      child: Center(
        child: Image.asset(
          'assets/imagens/logo.png',
          width: 70,
          height: 70,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildCampo(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    String? Function(String?)? customValidator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: kInputFillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (customValidator != null) {
          final validationResult = customValidator(value);
          if (validationResult != null) return validationResult;
        }

        if (enabled && (value == null || value.isEmpty)) {
          return "Campo obrigatório";
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth * 0.5;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 80.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFA7A6A6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: const Center(
                                child: Text(
                                  'Alterar Dados',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: formWidth),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: kInputFillColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _buildCampo("CPF", _cpfController,
                                          enabled: false),
                                      const SizedBox(height: 15),
                                      _buildCampo("Nome", _nomeController,
                                          keyboardType: TextInputType.name),
                                      const SizedBox(height: 15),
                                      _buildCampo("Telefone", _telefoneController,
                                          keyboardType: TextInputType.phone),
                                      const SizedBox(height: 15),
                                      _buildCampo("E-mail", _emailController,
                                          keyboardType: TextInputType.emailAddress),
                                      const SizedBox(height: 15),
                                      _buildCampoSenha("Senha Antiga",
                                          _senhaAntigaController,
                                          isNovaSenha: false),
                                      const SizedBox(height: 15),
                                      _buildCampoSenha(
                                          "Nova Senha", _novaSenhaController,
                                          isNovaSenha: true),
                                      const SizedBox(height: 25),
                                      SizedBox(
                                        height: 48,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kPrimaryColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: _isLoading
                                              ? null
                                              : _mostrarConfirmacao,
                                          icon: const Icon(Icons.pets,
                                              color: Colors.white),
                                          label: _isLoading
                                              ? const CircularProgressIndicator(
                                                  color: Colors.white,
                                                )
                                              : const Text(
                                                  "Salvar Alterações",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Container(
              color: kBackgroundColor,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(top: 15, left: 20, child: _buildReturnButton(context)),
                  Positioned(top: 5, right: 20, child: _buildAppLogo()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
