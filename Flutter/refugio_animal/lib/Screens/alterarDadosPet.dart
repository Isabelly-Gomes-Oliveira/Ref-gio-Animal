import 'package:flutter/material.dart';
import 'package:refugio_animal/Network/conexaoAPI.dart';
import 'package:refugio_animal/Network/pet.dart';

// --- Cores Personalizadas ---
const Color kBackgroundColor = Color(0xFFF8E9D2);
const Color kPrimaryColor = Color(0xFF48526E);
const Color kInputFillColor = Color(0xFFFFFFFF);
const Color kDividerColor = Color(0xFFB0B0B0);
const Color kReturnButtonColor = Color(0xFFD91E18);

class AlterarDadosPet extends StatefulWidget {
  final Pet petToEdit;

  const AlterarDadosPet({super.key, required this.petToEdit});

  @override
  State<AlterarDadosPet> createState() => _AlterarDadosPetState();
}

class _AlterarDadosPetState extends State<AlterarDadosPet> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _racaController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _deficienciaController = TextEditingController();
  final TextEditingController _imagemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDadosPet();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _racaController.dispose();
    _idadeController.dispose();
    _descricaoController.dispose();
    _deficienciaController.dispose();
    _imagemController.dispose();
    super.dispose();
  }

  void _carregarDadosPet() {
    final pet = widget.petToEdit;
    // Garante que se o campo for null, a controller inicie com string vazia
    _nomeController.text = pet.nome ?? ''; 
    _racaController.text = pet.raca ?? '';
    _idadeController.text = pet.idade?.toString() ?? '';
    _descricaoController.text = pet.descricao ?? '';
    _deficienciaController.text = pet.deficiencia ?? '';
    _imagemController.text = pet.imagem ?? '';
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
          "Deseja salvar as alterações deste pet?",
          style: TextStyle(color: Colors.black87, fontSize: 15),
        ),
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

    // Mapeamento e validação de strings vazias para null para API
    String? getStringOrNull(String text) => text.trim().isEmpty ? null : text.trim();

    try {
      final sucesso = await ApiService.atualizarPet(
        widget.petToEdit.id,
        nome: getStringOrNull(_nomeController.text),
        raca: getStringOrNull(_racaController.text),
        idade: _idadeController.text.isEmpty
            ? null
            : int.tryParse(_idadeController.text.trim()),
        descricao: getStringOrNull(_descricaoController.text), // ATENÇÃO: Se for obrigatório, remova o getStringOrNull
        deficiencia: getStringOrNull(_deficienciaController.text),
        imagem: getStringOrNull(_imagemController.text),
      );

      if (!mounted) return;

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados do pet atualizados com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falha ao atualizar os dados do pet.'),
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

  Widget _buildCampo(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    String? Function(String?)? customValidator,
    // 🚨 NOVO: Flag para marcar campo como opcional.
    bool isOptional = false, 
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: isOptional ? "Opcional" : hint, // Ajusta o hint se for opcional
        filled: true,
        fillColor: kInputFillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (customValidator != null) {
          final validationResult = customValidator(value);
          if (validationResult != null) return validationResult;
        }

        // 🚨 CORREÇÃO: Verifica se o campo é obrigatório (e não está desabilitado) antes de validar.
        if (enabled && !isOptional && (value == null || value.isEmpty)) {
          return "Campo obrigatório";
        }
        return null;
      },
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // O valor 0.5 (50%) pode ser muito pequeno em telas grandes. Ajustei para um máximo razoável.
    final formWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9; 

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
                                  'Alterar Dados do Pet',
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
                                      // 🚨 ATENÇÃO: NOME e RAÇA são opcionais no Flutter mas seu backend pode exigir.
                                      _buildCampo("Nome", _nomeController,
                                          keyboardType: TextInputType.name),
                                      const SizedBox(height: 15),
                                      _buildCampo("Raça", _racaController, isOptional: true), // Tornando opcional no validador
                                      const SizedBox(height: 15),
                                      _buildCampo("Idade", _idadeController,
                                          isOptional: true, // Tornando opcional no validador
                                          keyboardType: TextInputType.number,
                                          customValidator: (value) {
                                            if (value != null &&
                                                value.isNotEmpty &&
                                                int.tryParse(value) == null) {
                                              return "Digite um número válido";
                                            }
                                            return null;
                                          }),
                                      const SizedBox(height: 15),
                                      _buildCampo("Descrição", _descricaoController), // Mantido como obrigatório (padrão)
                                      const SizedBox(height: 15),
                                      // 🎯 CAMPO DE DEFICIÊNCIA AGORA É OPCIONAL
                                      _buildCampo("Deficiência", _deficienciaController,
                                          isOptional: true), 
                                      const SizedBox(height: 15),
                                      // 🎯 CAMPO DE IMAGEM AGORA É OPCIONAL
                                      _buildCampo("URL da Imagem", _imagemController,
                                          keyboardType: TextInputType.url,
                                          isOptional: true), 
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