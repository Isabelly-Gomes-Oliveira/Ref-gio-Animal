import 'package:flutter/material.dart';
import 'package:refugio_animal/Network/conexaoAPI.dart'; 
import 'package:refugio_animal/Network/pet.dart';

// --- Cores Personalizadas (Baseadas no seu código) ---
const Color kBackgroundColor = Color(0xFFF8E9D2); 
const Color kPetCardColor = Color(0xFFF8F8F8); // Cor do card de detalhes do pet
const Color kPrimaryColor = Color(0xFF48526E); // Azul/Cinza escuro
const Color kFilterButtonColor = Color(0xFF62739D); // Azul/Cinza dos botões de filtro
const Color kBorderColor = Color(0xFF1A2A50); // Borda e acento
const Color kIconColor = Color(0xFF62739D); // Cor padrão dos ícones
const Color kActiveIconColor = Color(0xFF1A2A50); // Cor do ícone ativo
const Color kInputFillColor = Color(0xFFD9D9D9); 
const Color kInputTextColor = Color(0xFF48526E); 


// ===================================================================
// 1. WIDGET DE CARD INDIVIDUAL DO PET
// ===================================================================
class PetCard extends StatelessWidget {
  final Pet pet;

  const PetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      // Card principal com o design especificado
      decoration: BoxDecoration(
        color: kPetCardColor,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: kBorderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Placeholder/Imagem do Pet (Lado esquerdo)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(13),
              bottomLeft: Radius.circular(13),
            ),
            child: pet.imagem.startsWith('http') 
                ? Image.network(
                    pet.imagem,
                    width: 120,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(120, 160),
                  )
                : _buildImagePlaceholder(120, 160),
          ),
          
          // Detalhes do Pet (Lado direito)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Nome
                  Text(
                    pet.nome ?? 'Sem Nome',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // Raça e Espécie
                  _buildDataRow(
                    label: pet.raca ?? 'Raça Desconhecida',
                    value: pet.especie,
                  ),
                  const SizedBox(height: 5),

                  // Idade e Deficiência
                  _buildDataRow(
                    label: pet.idade != null ? '${pet.idade} anos' : 'Idade N/A',
                    value: pet.deficiencia ?? 'Sem deficiência',
                    icon1: Icons.cake,
                    icon2: pet.deficiencia != null ? Icons.accessible_forward : Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 10),

                  // Botão de Detalhes
                  SizedBox(
                    height: 35,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implementar navegação para a tela de detalhes
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Detalhes de ${pet.nome}...')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kFilterButtonColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                      ),
                      child: const Text(
                        'Adotar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: kInputFillColor,
      child: Center(
        child: Icon(Icons.pets, size: 50, color: kPrimaryColor.withOpacity(0.7)),
      ),
    );
  }

  Widget _buildDataRow({
    required String label, 
    required String value,
    IconData icon1 = Icons.category,
    IconData icon2 = Icons.pets_outlined,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon1, size: 16, color: kFilterButtonColor),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 14, color: kInputTextColor)),
          ],
        ),
        Row(
          children: [
            Icon(icon2, size: 16, color: kFilterButtonColor),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontSize: 14, color: kInputTextColor)),
          ],
        ),
      ],
    );
  }
}

// ===================================================================
// 2. TELA PRINCIPAL (WIDGET COMPLETO)
// ===================================================================
class TelaPrincipal extends StatefulWidget {
    const TelaPrincipal({super.key});

    @override
    State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
    int _selectedIndex = 0; // Índice para a BottomNavigationBar
    late Future<List<Pet>> _petsFuture;

    @override
    void initState() {
      super.initState();
      // Inicia a busca dos pets
      _petsFuture = ApiService.getPets();
    }

    void _onItemTapped(int index) {
        setState(() {
            _selectedIndex = index;
        });
        // TODO: Adicionar lógica de navegação para as rotas da Bottom Bar
        // Ex: if (index == 2) Navigator.pushNamed(context, '/perfil');
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: kBackgroundColor,
            body: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            // Cabeçalho e Logo de Exemplo (Topo Direita)
                            _buildHeader(),
                            const SizedBox(height: 30),
                            
                            // Área de Filtros
                            _buildFilterSection(),
                            const SizedBox(height: 30),

                            // NOVO: Lista de Cards de Pets (Substituindo o PetDetailCard)
                            const Text(
                              "Animais em Destaque",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 15),
                            
                            _buildPetList(),

                            // Deixa um espaço extra no final
                            const SizedBox(height: 100), 
                        ],
                    ),
                ),
            ),
            
            // Bottom Navigation Bar
            bottomNavigationBar: _buildBottomNavigationBar(),
        );
    }

    // ===================================================================
    // FUNÇÃO QUE CONSTRÓI A LISTA DE PETS USANDO FUTUREBUILDER
    // ===================================================================
    Widget _buildPetList() {
      return FutureBuilder<List<Pet>>(
        future: _petsFuture,
        builder: (context, snapshot) {
          // Estado de Carregamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 50.0),
                child: CircularProgressIndicator(color: kPrimaryColor),
              ),
            );
          }

          // Estado de Erro
          if (snapshot.hasError) {
            // Em produção, você pode ter uma UI mais elaborada para erros.
            return Center(
              child: Text('Erro ao carregar pets: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          }

          // Estado de Dados Recebidos
          if (snapshot.hasData) {
            final pets = snapshot.data!;
            if (pets.isEmpty) {
              return const Center(
                child: Text('Nenhum pet encontrado.', style: TextStyle(color: kPrimaryColor, fontStyle: FontStyle.italic)),
              );
            }
            
            // Retorna uma coluna com todos os cards gerados
            // Usa Column pois já estamos dentro de um SingleChildScrollView
            return Column(
              children: pets.map((pet) => PetCard(pet: pet)).toList(),
            );
          }

          return const SizedBox.shrink(); // Widget vazio por padrão
        },
      );
    }

    // ===================================================================
    // WIDGETS AUXILIARES (Mantidos do seu código base)
    // ===================================================================
    Widget _buildHeader() {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Text(
                    "Seja bem-vindo(a)!",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                    ),
                ),
                // Exemplo de Placeholder de Logo no Canto Superior Direito
                Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: kFilterButtonColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kBorderColor, width: 2),
                    ),
                    child: const Icon(Icons.shield, color: Colors.white, size: 24),
                ),
            ],
        );
    }

    Widget _buildFilterSection() {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Text(
                    "Filtros:",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryColor,
                    ),
                ),
                const SizedBox(height: 10),
                Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: [
                        _buildFilterButton("Espécie"),
                        _buildFilterButton("Raça"),
                        _buildFilterButton("Deficiência"),
                        _buildFilterButton("Idade"),
                        _buildFilterButton("Vacinas", isActive: true), 
                    ],
                ),
            ],
        );
    }

    Widget _buildFilterButton(String text, {bool isActive = false}) {
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
                color: isActive ? kBorderColor : kFilterButtonColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorderColor.withOpacity(0.5), width: 1),
            ),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Text(
                        text,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                        ),
                    ),
                    if (!isActive)
                        Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                ),
                            ),
                        ),
                ],
            ),
        );
    }

    Widget _buildBottomNavigationBar() {
        return BottomNavigationBar(
            backgroundColor: kPetCardColor, // Alterado para uma cor mais clara para contraste
            type: BottomNavigationBarType.fixed,
            selectedItemColor: kActiveIconColor,
            unselectedItemColor: kIconColor,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                    icon: Icon(Icons.home, size: 30, color: _selectedIndex == 0 ? kActiveIconColor : kIconColor),
                    label: 'Home',
                ),
                BottomNavigationBarItem(
                    icon: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: kActiveIconColor, width: 2),
                        ),
                        child: Icon(Icons.add, size: 30, color: kActiveIconColor),
                    ),
                    label: 'Adicionar',
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person, size: 30, color: _selectedIndex == 2 ? kActiveIconColor : kIconColor),
                    label: 'Perfil',
                ),
            ],
        );
    }
}