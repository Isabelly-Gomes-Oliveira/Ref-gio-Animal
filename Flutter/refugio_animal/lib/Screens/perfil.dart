import 'package:flutter/material.dart';
import 'package:refugio_animal/Network/conexaoAPI.dart'; 
import 'package:refugio_animal/Network/pet.dart';
import 'package:refugio_animal/Network/usuario.dart'; 
import 'package:refugio_animal/Screens/cadastropet.dart'; 
import 'package:refugio_animal/Screens/perfil.dart';    
import 'dart:io';

// --- Cores Personalizadas ---
const Color kBackgroundColor = Color(0xFFF8E9D2); // Cor de fundo do corpo
const Color kCardColor = Color(0xFF848B94); // Cor de fundo do painel principal (cinza/roxo claro)
const Color kPrimaryColor = Color(0xFF48526E); // Roxo escuro para textos e botões principais
const Color kReturnButtonColor = Color(0xFFD91E18); // Vermelho para o botão de retorno
const Color kPetCardBgColor = Color(0xFFAAB2BC); // Cor de fundo dos mini-cards de pet
const Color kFilterButtonColor = Color(0xFF62739D); // Cor para botões e rodapé

// ===================================================================
// TELA PERFIL
// ===================================================================

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({super.key});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  // CPF de demonstração. Em um app real, este valor viria da tela de login/autenticação.
  static const String _cpfUsuarioLogado = '81767286678'; 
  
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

  // --- Função para buscar dados do usuário e seus pets (COM FILTRO LOCAL) ---
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Buscar dados do usuário
      final user = await ApiService.getUsuarioByCpf(_cpfUsuarioLogado);
      
      // 2. Buscar TODOS os pets disponíveis na API
      final allPets = await ApiService.getPets();

      // 3. Filtrar os pets localmente onde o cpfDoador é igual ao cpf do usuário logado
      final filteredPets = allPets
          .where((pet) => pet.cpfDoador == _cpfUsuarioLogado)
          .toList();

      setState(() {
        _usuarioLogado = user;
        _meusPets = filteredPets;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar dados do perfil: $e');
      setState(() {
        _error = 'Erro ao carregar dados. Tente novamente mais tarde.';
        _isLoading = false;
      });
    }
  }


  // --- Função para exibir o modal de confirmação de desconexão ---
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
                Navigator.of(context).pop(); // Fechar o modal
                // TODO: Implementar a lógica de logout (ApiService.logout)
                // Exemplo de navegação após logout
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: const Text('Sair', style: TextStyle(color: kReturnButtonColor, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // 1. Área central de conteúdo
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(25.0),
              decoration: BoxDecoration(
                color: kCardColor.withOpacity(0.7), // Cor base da imagem
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kPrimaryColor.withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: _buildContent(), // Conteúdo principal (Loading, Erro ou Dados)
            ),
          ),

          // 2. Elementos Fixos (Topo)
          Positioned(
            top: 40,
            left: 20,
            child: _buildReturnButton(context),
          ),
          Positioned(
            top: 30,
            right: 20,
            child: _buildAppLogo(),
          ),
        ],
      ),
      // 3. Rodapé (BottomNavigationBar)
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

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
            Text(_error!, style: const TextStyle(color: kReturnButtonColor, fontSize: 18)),
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
    
    // Se não está carregando e não tem erro, exibe os dados (que podem ser nulos)
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

    // Conteúdo com os dados reais
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50), // Espaço para a logo/retorno
          
          // --- Imagem/Ícone do Usuário ---
          _buildUserImage(),
          const SizedBox(height: 20),

          // --- Informações do Usuário ---
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
          _buildInfoRow('Telefone:', user.telefone ?? 'Não Informado', isRequired: true),
          _buildInfoRow('Email:', user.email ?? 'Não Informado', isRequired: true),
          const SizedBox(height: 30),

          // --- Seção "Meus Pets" ---
          _buildMyPetsSection(),
          const SizedBox(height: 40),

          // --- Botões de Ação ---
          _buildActionButton(
            'Alterar Dados do Usuário',
            () {
              // TODO: Implementar navegação para a tela de edição
              debugPrint('Navegar para Alterar Dados (CPF: ${user.cpf})');
            },
            kPrimaryColor,
          ),
          const SizedBox(height: 15),
          _buildActionButton(
            'Desconectar',
            () => _showLogoutConfirmation(context),
            kReturnButtonColor,
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // WIDGETS AUXILIARES
  // ===================================================================

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
            text: isRequired ? '* ' : '',
            style: const TextStyle(
              fontSize: 18,
              color: kReturnButtonColor,
              fontWeight: FontWeight.bold,
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
        
        // Linha divisória roxo escuro
        Container(
          height: 1,
          width: 150,
          color: kPrimaryColor,
          margin: const EdgeInsets.only(bottom: 20),
        ),

        // Lista Horizontal de Pets
        SizedBox(
          height: 110, // Altura para o card e o nome
          child: _meusPets.isEmpty
            ? Center(
                child: Text(
                  'Você ainda não cadastrou nenhum pet.',
                  style: TextStyle(color: kPrimaryColor.withOpacity(0.8)),
                ),
              )
            : ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: _meusPets.length,
              itemBuilder: (context, index) {
                return _buildPetMiniCard(_meusPets[index]);
              },
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
                    // Se você tivesse o widget Image.network ou Image.memory, usaria aqui.
                    ? const Icon(Icons.photo, size: 40, color: Colors.grey)
                    : const Center(
                      child: Icon(
                        Icons.pets, // Ícone de pet placeholder
                        size: 40,
                        color: kPrimaryColor,
                      ),
                    ),
              ),
              // Ícone de Engrenagem (Canto Superior Esquerdo)
              Positioned(
                top: -8,
                left: -8,
                child: GestureDetector(
                  onTap: () {
                    // TODO: Implementar navegação para a edição do pet
                    debugPrint('Editar Pet: ${pet.nome} (ID: ${pet.id})');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: kPrimaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings,
                      size: 15,
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kPrimaryColor.withOpacity(0.5)),
      ),
      child: const Center(
        // Ícone corrigido!
        child: Icon(Icons.house_rounded, size: 40, color: kPrimaryColor), 
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      color: kCardColor, // Cor de fundo do rodapé conforme o tema visual
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Ícone Adicionar
          IconButton(
            onPressed: () {
              setState(() => _selectedIndex = 0);
              // TODO: Implementar navegação
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
              // TODO: Implementar navegação
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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
              // Já estamos na tela de perfil
            },
            icon: Icon(
              Icons.person,
              size: 30,
              color: _selectedIndex == 2 ? kPrimaryColor : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}