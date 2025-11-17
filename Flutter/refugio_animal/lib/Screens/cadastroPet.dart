import 'package:flutter/material.dart';
import 'package:refugio_animal/Network/conexaoAPI.dart';

class CadastrarPetPage extends StatefulWidget {
  final String cpfUsuario;

  const CadastrarPetPage({super.key, required this.cpfUsuario});

  @override
  State<CadastrarPetPage> createState() => _CadastrarPetPageState();
}

class _CadastrarPetPageState extends State<CadastrarPetPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para cada campo
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _especieController = TextEditingController();
  final TextEditingController _racaController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _deficienciaController = TextEditingController();
  final TextEditingController _imagemController = TextEditingController();

  bool _loading = false;

  // Função para cadastrar pet
  Future<void> _cadastrarPet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final sucesso = await ApiService.cadastrarPet(
          widget.cpfUsuario, // CPF vindo do argumento
          _nomeController.text.trim().isEmpty ? null : _nomeController.text.trim(),
          _racaController.text.trim().isEmpty ? null : _racaController.text.trim(),
          int.tryParse(_idadeController.text.trim()), // Passa null se não for número
          _descricaoController.text.trim(),
          _deficienciaController.text.trim().isEmpty ? null : _deficienciaController.text.trim(),
          _imagemController.text.trim(),
          _especieController.text.trim());

      if (sucesso) {
        // Mostra SnackBar de sucesso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet cadastrado com sucesso!')),
          );
          _formKey.currentState!.reset(); // Limpa o formulário
        }
      }
    } catch (e) {
      // Mostra SnackBar de erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar pet: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7E8D5),
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
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _campoTexto("Nome do pet", controller: _nomeController, obrigatorio: false),
                _campoTexto("Espécie *", controller: _especieController),
                _campoTexto("Raça", controller: _racaController, obrigatorio: false),
                _campoTexto("Idade do pet",
                    controller: _idadeController,
                    keyboardType: TextInputType.number,
                    obrigatorio: false), // Idade é opcional e deve ser número
                _campoTexto("Descrição do pet *", controller: _descricaoController, maxLines: 4),
                _campoTexto("Deficiência do pet",
                    controller: _deficienciaController, obrigatorio: false),
                _campoTexto("Imagem do pet *", controller: _imagemController),
                const SizedBox(height: 20),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _cadastrarPet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B2B5B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
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
      ),
    );
  }

  // Função de campo de texto, com opção de ser obrigatório ou não
  Widget _campoTexto(String label,
      {TextEditingController? controller,
      int maxLines = 1,
      TextInputType keyboardType = TextInputType.text,
      bool obrigatorio = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (value) {
          // 1. Validação de obrigatoriedade
          if (obrigatorio && (value == null || value.isEmpty)) {
            return '$label é obrigatório';
          }
          // 2. Validação numérica (apenas se for campo numérico e não estiver vazio)
          if (keyboardType == TextInputType.number && value != null && value.isNotEmpty) {
            if (int.tryParse(value) == null) {
              return '$label deve ser um número inteiro.';
            }
          }
          return null;
        },
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