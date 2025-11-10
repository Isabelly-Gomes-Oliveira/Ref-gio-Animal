import 'package:flutter/material.dart';
import 'package:refugio_animal/Network/conexaoAPI.dart';
import 'package:refugio_animal/Network/pet.dart';
import 'package:refugio_animal/Network/usuario.dart';
// import 'package:refugio_animal/Screens/cadastropet.dart'; // Removido por não ser usado
// import 'package:refugio_animal/Screens/perfil.dart'; // Removido (auto-importação)
// import 'dart:io'; // Removido por não ser usado

// --- Cores Personalizadas ---
const Color kBackgroundColor = Color(0xFFF8E9D2); // Cor de fundo do corpo
const Color kCardColor = Color(0xFF848B94); // Cor de fundo do painel principal (cinza/roxo claro)
const Color kPrimaryColor = Color(0xFF48526E); // Roxo escuro para textos e botões principais
const Color kReturnButtonColor = Color(0xFFD91E18); // Vermelho para o botão de retorno
const Color kPetCardBgColor = Color(0xFFD9D9D9); // Cor de fundo dos mini-cards de pet
const Color kFilterButtonColor = Color(0xFF62739D); // Cor para botões e rodapé

// ===================================================================
// TELA PERFIL
// ===================================================================

class TelaPerfil extends StatefulWidget {
  final String cpfUsuario;

  const TelaPerfil({
    super.key,
    required this.cpfUsuario,
  });

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  Usuario? _usuarioLogado;
  List<Pet> _meusPets = [];
  bool _isLoading = true;
  String? _error;
  int _selectedIndex = 2; // Índice padrão para o Perfil

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String cpf = widget.cpfUsuario;
      final results = await Future.wait([
        ApiService.getUsuarioByCpf(cpf),
        ApiService.getPetsByCpf(cpf),
      ]);

      final user = results[0] as Usuario;
      final filteredPets = results[1] as List<Pet>;

      // Verificação de 'mounted' para evitar erros após o await
      if (!mounted) return;
      setState(() {
        _usuarioLogado = user;
        _meusPets = filteredPets;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar dados do perfil: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Erro ao carregar dados. Tente novamente mais tarde.';
        _isLoading = false;
      });
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.white,
          title: const Text('Desconectar', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
          content: const Text('Tem certeza de que deseja sair da sua conta?', style: TextStyle(color: kPrimaryColor)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Fechar
              child: const Text('Cancelar', style: TextStyle(color: kPrimaryColor)),
            ),
            TextButton(
              onPressed: () {
                // Navega para o login e remove todas as telas anteriores
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: const Text('Sair', style: TextStyle(color: kReturnButtonColor, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ===================================================================
  // BUILD METHOD (PRINCIPAL)
  // ===================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // 1. FUNDO ROXO (TELA CHEIA)
          Container(
            color: kCardColor.withOpacity(0.7), // A "parte roxa"
          ),

          // 2. CONTEÚDO (COM SAFEAREA)
          SafeArea(
            bottom: false,
            child: _buildContent(),
          ),

          // 3. BARRA BEGE DO TOPO COM BOTÕES
          SafeArea(
            bottom: false,
            child: Container(
              color: kBackgroundColor,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 15,
                    left: 20,
                    child: _buildReturnButton(context),
                  ),
                  Positioned(
                    top: 5,
                    right: 20,
                    child: _buildAppLogo(), // Logo sem fundo/contorno branco
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }
  // ===================================================================
  // FIM DO BUILD METHOD
  // ===================================================================


  // --- Lógica de exibição de conteúdo ---
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                _error!,
                style: const TextStyle(color: kReturnButtonColor, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchUserData,
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              child: const Text('Tentar Novamente', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final user = _usuarioLogado;

    if (user == null) {
      return const Center(
        child: Text(
          'Dados do usuário não disponíveis.',
          style: TextStyle(color: kPrimaryColor, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 105),

          _buildUserImage(),
          const SizedBox(height: 20),

          Text(
            user.nome ?? 'Usuário sem Nome',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          _buildInfoRow(
            'Telefone:',
            _formatarTelefone(user.telefone ?? 'Não Informado'),
          ),
          _buildInfoRow(
            'Email:',
            user.email ?? 'Não Informado',
          ),
          _buildInfoRow(
            'CPF:',
            _formatarCPF(user.cpf ?? widget.cpfUsuario)
          ),
          const SizedBox(height: 30),

          _buildMyPetsSection(),
          const SizedBox(height: 40),

          _buildActionButton(
              'Alterar Dados do Usuário',
              () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/alterarDadosUsuario', 
                  arguments: user.cpf ?? widget.cpfUsuario,
                );

                // Se algo mudou, recarrega os dados
                if (result == true) {
                  _fetchUserData();
                }
              },
              kPrimaryColor,
            ),
          const SizedBox(height: 15),
          _buildActionButton(
            'Desconectar',
            () => _showLogoutConfirmation(context),
            kReturnButtonColor,
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ===================================================================
  // WIDGETS AUXILIARES E FORMATAÇÃO
  // ===================================================================

  String _formatarCPF(String cpf) {
    final digits = cpf.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length != 11) {
      return cpf;
    }
    return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9, 11)}';
  }

  String _formatarTelefone(String telefone) {
    final digits = telefone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length == 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7, 11)}';
    } else if (digits.length == 10) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6, 10)}';
    }
    return telefone;
  }

  Widget _buildUserImage() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: kPrimaryColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.person,
        size: 80,
        color: kCardColor,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isRequired = false}) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(
              fontSize: 18,
              color: kPrimaryColor,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMyPetsSection() {
    return Column(
      children: [
        const Text(
          'Meus Pets',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 1,
          width: 150,
          color: kPrimaryColor,
          margin: const EdgeInsets.only(bottom: 20),
        ),
        SizedBox(
          height: 110, // Altura para o card e o nome
          child: _meusPets.isEmpty
              ? Center(
                  child: Text(
                    'Você ainda não cadastrou nenhum pet.',
                    style: TextStyle(color: kPrimaryColor.withOpacity(0.8)),
                    textAlign: TextAlign.center,
                  ),
                )
              : Center(
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: _meusPets.length,
                    itemBuilder: (context, index) {
                      return _buildPetMiniCard(_meusPets[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPetMiniCard(Pet pet) {
    return Container(
      width: 85,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kPetCardBgColor, // Cor de fundo do mini-card
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kPrimaryColor.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: pet.imagem != null && pet.imagem!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(9.0),
                        child: Image.network(
                          pet.imagem!,
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: kPrimaryColor,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.pets,
                                size: 40,
                                color: kPrimaryColor,
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.pets,
                          size: 40,
                          color: kPrimaryColor,
                        ),
                      ),
              ),
              // Ícone de Engrenagem (Canto Superior Esquerdo)
              Positioned(
                top: 0,
                left: 55,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/alterarPet',
                      arguments: pet, 
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: kPrimaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            pet.nome,
            style: const TextStyle(fontSize: 14, color: kPrimaryColor),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
      ),
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
        onPressed: () => Navigator.pop(context), // Retorna à tela anterior
        padding: const EdgeInsets.all(10),
        tooltip: 'Voltar',
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 70,
      height: 70,
      // Removendo o BoxDecoration para tirar o fundo branco
      child: Center(
        child: Image.asset(
          'assets/imagens/logo.png',
          width: 70, // Tamanho ajustado
          height: 70, // Tamanho ajustado
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      color: kCardColor, // Cor de fundo do rodapé conforme o tema visual
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Ícone Adicionar
            IconButton(
              onPressed: () {
                setState(() => _selectedIndex = 0);
                Navigator.pushNamed(context, '/cadastroPet');
              },
              icon: Icon(
                Icons.add_circle_outline,
                size: 30,
                color: _selectedIndex == 0 ? kPrimaryColor : Colors.black54,
              ),
            ),
            // Ícone Home
            IconButton(
              onPressed: () {
                setState(() => _selectedIndex = 1);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                  arguments: widget.cpfUsuario,
                );
              },
              icon: Icon(
                Icons.home,
                size: 30,
                color: _selectedIndex == 1 ? kPrimaryColor : Colors.black54,
              ),
            ),
            // Ícone Perfil (Ativo)
            IconButton(
              onPressed: () {
                setState(() => _selectedIndex = 2);
                // Já estamos na tela de perfil, não faz nada
              },
              icon: Icon(
                Icons.person,
                size: 30,
                color: _selectedIndex == 2 ? kPrimaryColor : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}