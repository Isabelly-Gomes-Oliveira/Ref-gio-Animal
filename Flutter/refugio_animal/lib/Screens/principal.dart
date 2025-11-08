import 'package:flutter/material.dart';
import 'package:refugio_animal/Network/conexaoAPI.dart'; 
import 'package:refugio_animal/Network/pet.dart';
import 'package:refugio_animal/Network/usuario.dart'; 
import 'package:refugio_animal/Screens/cadastropet.dart'; 
import 'package:refugio_animal/Screens/perfil.dart';    
import 'dart:io';

// --- Cores Personalizadas ---
const Color kBackgroundColor = Color(0xFFF8E9D2);
const Color kPetCardColor = Color(0xFF848B94); 
const Color kPrimaryColor = Color(0xFF48526E); 
const Color kFilterButtonColor = Color(0xFF62739D); 
const Color kIconColor = Color(0xFF62739D);
const Color kActiveIconColor = Color(0xFF1A2A50);
const Color kInputFillColor = Color(0xFFD9D9D9);
const Color kInputTextColor = Color(0xFF48526E); 

// ===================================================================
// CARD DE PET
// ===================================================================

class PetCard extends StatefulWidget {
  final Pet pet;
  const PetCard({super.key, required this.pet});

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  String telefoneDono = 'Carregando...';
  String emailDono = 'Carregando...';

  @override
  void initState() {
    super.initState();
    _loadDono();
  }

  Future<void> _loadDono() async {
  debugPrint('Buscando dono do pet com CPF: ${widget.pet.cpfDoador}');
  try {
    final usuario = await ApiService.getUsuarioByCpf(widget.pet.cpfDoador.trim());
    setState(() {
      telefoneDono = usuario.telefone;
      emailDono = usuario.email ?? 'Email não informado';
    });
  } catch (e) {
    setState(() {
      telefoneDono = 'Telefone não informado';
      emailDono = 'Email não informado';
    });
    debugPrint('Erro ao carregar dono do pet: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth / 2) - 20; 
    const double paddingCard = 22.0; 
    final imageSize = (cardWidth - (paddingCard * 2) - 8) * 0.4; 

    return Center(
      child: Container(
        width: cardWidth, 
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(paddingCard),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: kFilterButtonColor.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGEM: URL ou FILE
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _buildPetImage(widget.pet.imagem, imageSize),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        widget.pet.nome,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 50),
                      _buildInfoText('Espécie:', widget.pet.especie),
                      const SizedBox(height: 50),
                      _buildInfoText('Raça:', widget.pet.raca),
                      const SizedBox(height: 50),
                      _buildInfoText(
                        'Idade:', 
                        widget.pet.idade != null ? '${widget.pet.idade} anos' : 'N/A'
                      ),
                      const SizedBox(height: 50),
                      _buildInfoText(
                        'Deficiência:', 
                        widget.pet.deficiencia != null ? '${widget.pet.deficiencia}' : 'Não Possui'
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Descrição:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold, 
                color: kPrimaryColor
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.pet.descricao.isNotEmpty ? widget.pet.descricao : 'N/A',
              style: const TextStyle(fontSize: 20, color: kInputTextColor),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            const Text(
              'Contato:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold, 
                color: kPrimaryColor
              ),
            ),
            const SizedBox(height: 4),
            _buildContactRow(Icons.phone, telefoneDono, iconSize: 20, fontSize: 20),
            _buildContactRow(Icons.email, emailDono, iconSize: 20, fontSize: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPetImage(String path, double size) {
  if (path.startsWith('http')) {
    return Image.network(
      path,
      width: size,
      height: size,
      fit: BoxFit.cover,
      // O 'errorBuilder' é uma FUNÇÃO. O debugPrint deve estar DENTRO dela.
      errorBuilder: (context, error, stackTrace) {
        // Esta linha só é executada se houver falha na rede
        debugPrint('FALHA AO CARREGAR REDE para: $path. Erro: $error');
        return _buildImagePlaceholder(size, size);
      },
    );
  } else {
    final file = File(path);
    return Image.file(
      file,
      width: size,
      height: size,
      fit: BoxFit.cover,
      // Adicionado debugPrint para falha de arquivo local
      errorBuilder: (context, error, stackTrace) {
        debugPrint('FALHA AO CARREGAR ARQUIVO LOCAL para: $path. Erro: $error');
        return _buildImagePlaceholder(size, size);
      },
    );
  }
}

  Widget _buildInfoText(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            value ?? 'N/A',
            style: const TextStyle(fontSize: 20, color: kInputTextColor),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text, {double iconSize = 14, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, color: kFilterButtonColor, size: iconSize),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: fontSize, color: kInputTextColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(double width, double height) => Container(
        width: width,
        height: height,
        color: kInputFillColor,
        child: Center(
          child: Icon(Icons.pets, size: 28, color: kPrimaryColor.withOpacity(0.7)),
        ),
      );
}

// ===================================================================
// TELA PRINCIPAL
// ===================================================================
class TelaPrincipal extends StatefulWidget {
  final String cpfUsuario;

  const TelaPrincipal({
    super.key,
    required this.cpfUsuario,
  });
  
  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _selectedIndex = 1; 
  List<Pet> _allPets = [];
  List<Pet> _filteredPets = [];
  bool _isLoading = true;

  String _especie = '';
  String _raca = '';
  String _deficiencia = '';
  String _idade = '';

  bool _showEspecieInput = false;
  bool _showRacaInput = false;

  final TextEditingController _especieController = TextEditingController();
  final TextEditingController _racaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _especieController.addListener(() {
      setState(() {
        _especie = _especieController.text;
        _applyFilters();
      });
    });
    _racaController.addListener(() {
      setState(() {
        _raca = _racaController.text;
        _applyFilters();
      });
    });
    _loadPets();
  }

  @override
  void dispose() {
    _especieController.dispose();
    _racaController.dispose();
    super.dispose();
  }

  Future<void> _loadPets() async {
  try {
    final pets = await ApiService.getPets();
    
    // NOVO FILTRO: Filtrar APENAS os pets com status_adotado 'Disponível'
    final availablePets = pets.where((pet) => 
        (pet.statusAdotado).toLowerCase() == 'disponível'
    ).toList();
    
    setState(() {
      _allPets = availablePets; // Armazena apenas os disponíveis
      _filteredPets = availablePets; // Exibe os disponíveis inicialmente
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
    debugPrint('Erro ao carregar pets: $e');
  }
}

  void _applyFilters() {
  setState(() {
    _filteredPets = _allPets.where((pet) {
      // FILTRO FIXO: Apenas pets com status_adotado 'Disponível'
      final isAvailable = (pet.statusAdotado).toLowerCase() == 'disponível';
      
      // Filtros existentes
      final petEspecie = (pet.especie ?? '').toLowerCase();
      final petRaca = (pet.raca ?? '').toLowerCase();
      final petDef = (pet.deficiencia ?? '').toLowerCase();
      final petIdade = pet.idade ?? 0;

      final matchEspecie =
          _especie.isEmpty || petEspecie.contains(_especie.toLowerCase());
      final matchRaca =
          _raca.isEmpty || petRaca.contains(_raca.toLowerCase());
      final matchDeficiencia = _deficiencia.isEmpty ||
          (_deficiencia == 'Possui' ? petDef.isNotEmpty : petDef.isEmpty);
      final matchIdade = _idade.isEmpty ||
          (_idade == 'Filhote' && petIdade >= 0 && petIdade <= 2) ||
          (_idade == 'Adulto' && petIdade >= 3 && petIdade <= 6) ||
          (_idade == 'Idoso' && petIdade >= 7);

      // NOVO: Adicione a condição isAvailable
      return isAvailable && matchEspecie && matchRaca && matchDeficiencia && matchIdade;
    }).toList();
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildFilterAndInputSection(),
                    const SizedBox(height: 30),
                    _filteredPets.isEmpty
                        ? const Center(
                            child: Text(
                              "Nenhum pet encontrado 😿",
                              style: TextStyle(fontSize: 18, color: kPrimaryColor),
                            ),
                          )
                        : ListView.builder( // Alterado de Wrap para ListView.builder
                            shrinkWrap: true, // Importante para usar dentro de SingleChildScrollView
                            physics: const NeverScrollableScrollPhysics(), // Evita scroll duplo
                            itemCount: _filteredPets.length,
                            itemBuilder: (context, index) {
                              // Os Cards agora ocuparão 100% da largura do Padding, centralizando o conteúdo interno
                              return PetCard(pet: _filteredPets[index]);
                            },
                          ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

Widget _buildHeader() {
  return SizedBox(
    height: 70,
    width: double.infinity,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          top: 10,
          child: Text(
            "Seja bem-vindo(a)!",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
        ),
        Positioned(
          top: -40,
          right: 0,
          child: Image.asset(
            'assets/imagens/logo.png', 
            height: 140,
            width: 150,
            fit: BoxFit.contain,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildFilterAndInputSection() {
    return Column(
      children: [
        _buildFilterSection(),
        if (_showEspecieInput)
          _buildTypingField(_especieController, "Buscar por Espécie...", (value) {
            setState(() {
              _especie = value;
              _showEspecieInput = false;
              _applyFilters();
            });
          }),
        if (_showRacaInput)
          _buildTypingField(_racaController, "Buscar por Raça...", (value) {
            setState(() {
              _raca = value;
              _showRacaInput = false;
              _applyFilters();
            });
          }),
      ],
    );
  }

Widget _buildFilterSection() {
  const double spacing = 15.0;

  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: kPrimaryColor.withOpacity(0.2),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        const Text(
          "Filtros:",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildFilterButton(
                  title: "Espécie",
                  value: _showEspecieInput ? _especieController.text : _especie,
                  onTap: () {
                    setState(() {
                      _showRacaInput = false;
                      _showEspecieInput = !_showEspecieInput;
                      if (_showEspecieInput) _especieController.text = _especie;
                      else if (_especieController.text.isEmpty) _especie = '';
                    });
                  },
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: _buildFilterButton(
                  title: "Raça",
                  value: _showRacaInput ? _racaController.text : _raca,
                  onTap: () {
                    setState(() {
                      _showEspecieInput = false;
                      _showRacaInput = !_showRacaInput;
                      if (_showRacaInput) _racaController.text = _raca;
                      else if (_racaController.text.isEmpty) _raca = '';
                    });
                  },
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: _buildDropdownFilter(
                  "Deficiência",
                  ["", "Possui"],
                  _deficiencia,
                  (v) {
                    setState(() {
                      _deficiencia = v ?? '';
                      _showEspecieInput = false;
                      _showRacaInput = false;
                      _applyFilters();
                    });
                  },
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                child: _buildDropdownFilter(
                  "Idade",
                  ["", "Filhote", "Adulto", "Idoso"],
                  _idade,
                  (v) {
                    setState(() {
                      _idade = v ?? '';
                      _showEspecieInput = false;
                      _showRacaInput = false;
                      _applyFilters();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

static const double filterHeight = 50; // Altura fixa para todos os filtros

Widget _buildFilterButton({
  required String title,
  required String value,
  required Function() onTap,
}) {
  final isActive = value.isNotEmpty;
  final isInputActive = (_showEspecieInput && title == "Espécie") || (_showRacaInput && title == "Raça");
  final buttonText = value.isNotEmpty ? value : title;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: filterHeight, // Altura fixa
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center, // Centraliza verticalmente
      decoration: BoxDecoration(
        color: isActive || isInputActive ? Colors.green[400] : kFilterButtonColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              buttonText,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildTypingField(TextEditingController controller, String placeholder,
      Function(String) onSubmitted) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(color: kPrimaryColor, fontSize: 16),
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        onSubmitted: (value) => onSubmitted(value),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: kPrimaryColor),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, color: kPrimaryColor),
            onPressed: () => controller.clear(),
          ),
          hintText: placeholder,
          hintStyle: TextStyle(color: kPrimaryColor.withOpacity(0.6)),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(
    String label, List<String> options, String selected, Function(String?) onChanged) {
  return Container(
    height: filterHeight, // Altura fixa
    padding: const EdgeInsets.symmetric(horizontal: 12),
    alignment: Alignment.center, // Centraliza verticalmente
    decoration: BoxDecoration(
      color: selected.isNotEmpty ? Colors.green[400] : kFilterButtonColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        dropdownColor: kFilterButtonColor,
        value: selected.isEmpty ? null : selected,
        hint: Text(label, style: const TextStyle(color: Colors.white70)),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        isExpanded: true,
        items: options
            .map((o) => DropdownMenuItem(
                  value: o,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(o, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

 // NO ARQUIVO DA TELA PRINCIPAL (APENAS O MÉTODO _buildBottomNavigationBar)

Widget _buildBottomNavigationBar() {
  return Container(
    color: const Color.fromARGB(255, 127, 135, 155),
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Ícone Adicionar (Redireciona para /cadastroPet)
        IconButton(
          onPressed: () {
            setState(() => _selectedIndex = 0);
            // USANDO ROTAS NOMEADAS
            Navigator.pushNamed(context, '/cadastroPet');
          },
          icon: Icon(
            Icons.add_circle_outline,
            size: 30,
            color: _selectedIndex == 0 ? Colors.black : Colors.black54,
          ),
        ),
        // Ícone Home (Recarrega a tela principal)
        IconButton(
          onPressed: () {
            setState(() {
              _selectedIndex = 1;
              // A rota '/home' já é esta tela, então apenas recarregamos os dados
              _loadPets(); 
            });
          },
          icon: Icon(
            Icons.home,
            size: 30,
            color: _selectedIndex == 1 ? Colors.black : Colors.black54,
          ),
        ),
        // Ícone Perfil (Redireciona para /Perfil)
        IconButton(
        onPressed: () {
          setState(() => _selectedIndex = 2);

          Navigator.pushNamed(
            context, 
            '/perfil',
            arguments: widget.cpfUsuario,
          );
        },
          icon: Icon(
            Icons.person,
            size: 30,
            color: _selectedIndex == 2 ? Colors.black : Colors.black54,
          ),
        ),
      ],
    ),
  );
}
}