import 'dart:convert'; // para converter entre objetos Dart e JSON (string)        
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http; 
import 'usuario.dart';         
import 'package:flutter/foundation.dart';
import 'pet.dart';         

class ApiService {
  static const String baseUrl = 'http://localhost:8081';


  // GET /pets
  static Future<List<Pet>> getPets() async {   // retorna uma lista de Pet
    final response = await http.get(Uri.parse('$baseUrl/pets'));  // faz uma requisião GET

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);       // decodifica o JSON recebido para estruturas Dart
      return data.map((e) => Pet.fromJson(e)).toList();  // converte cada item JSON em uma instância Pet
    } else {
      throw Exception('Erro ao carregar pets');
    }
  }




  // GET /pets/raca/:raca
  static Future<List<Pet>> getPetsByRaca(String raca) async { // retorna lista de pets dessa raça
    final encoded = Uri.encodeComponent(raca);   // codifica o nome da raça para não dar problema com espaços/caracteres especiais na URL    
    final response = await http.get(Uri.parse('$baseUrl/pets/raca/$encoded'));  // requisição GET

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body); // decodifica o JSON recebido para estruturas Dart
      return data.map((e) => Pet.fromJson(e)).toList();  // converte cada item JSON em uma instância Pet
    } else {
      throw Exception('Erro ao carregar pets por raça');
    }
  }




  // GET /pets/especie/:especie
  static Future<List<Pet>> getPetsByEspecie(String especie) async { // retorna lista de pets dessa espécie
    final encoded = Uri.encodeComponent(especie);   // codifica o nome da espécie para não dar problema com espaços/caracteres especiais na URL    
    final response = await http.get(Uri.parse('$baseUrl/pets/especie/$encoded'));  // requisição GET

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body); // decodifica o JSON recebido para estruturas Dart
      return data.map((e) => Pet.fromJson(e)).toList();  // converte cada item JSON em uma instância Pet
    } else {
      throw Exception('Erro ao carregar pets por espécie');
    }
  }




  // GET /pets/idade/:idade
  static Future<List<Pet>> getPetsByIdade(String idade) async { // retorna lista de pets nessa idade
    final response = await http.get(Uri.parse('$baseUrl/pets/idade/$idade'));  // requisição GET

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body); // decodifica o JSON recebido para estruturas Dart
      return data.map((e) => Pet.fromJson(e)).toList();  // converte cada item JSON em uma instância Pet
    } else {
      throw Exception('Erro ao carregar pets por idade');
    }
  }

  // GET /pets/deficiencia/:deficiencia
  static Future<List<Pet>> getPetsByDeficiencia(String deficiencia) async { // retorna lista de pets com a deficiência
    final encoded = Uri.encodeComponent(deficiencia);   // codifica o nome da deficiência para não dar problema com espaços/caracteres especiais na URL    
    final response = await http.get(Uri.parse('$baseUrl/pets/deficiencia/$encoded'));  // requisição GET

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body); // decodifica o JSON recebido para estruturas Dart
      return data.map((e) => Pet.fromJson(e)).toList();  // converte cada item JSON em uma instância Pet
    } else {
      throw Exception('Erro ao carregar pets por deficiência');
    }
  }

static Future<List<Pet>> getPetsByCpf(String cpf) async {
    final response = await http.get(Uri.parse('$baseUrl/pets/cpf/$cpf'));

    if (response.statusCode == 200) {
      // O endpoint /pets/cpf/:cpf retorna uma LISTA de objetos
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Pet.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar pets do usuário: ${response.statusCode}');
    }
  }

// GET /usuarios/cpf/:cpf
  static Future<Usuario> getUsuarioByCpf(String cpf) async {
    try {
      // Remove espaços extras
      final cleanedCpf = cpf.trim();
      if (cleanedCpf.isEmpty) {
        throw Exception('CPF vazio fornecido.');
      }

      final encodedCpf = Uri.encodeComponent(cleanedCpf);
      final url = Uri.parse('$baseUrl/usuarios/$encodedCpf');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Usuario.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Usuário com CPF $cleanedCpf não encontrado.');
      } else {
        throw Exception(
            'Erro desconhecido ao buscar usuário pelo CPF $cleanedCpf. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro em getUsuarioByCpf: $e');
      rethrow; // mantém o erro pra ser tratado na UI
    }
  }


  // POST /cadastro/usuario
  static Future<bool> cadastrarUsuario(Usuario user, String senha) async {
    final body = jsonEncode({                        
      'cpf': user.cpf,
      'nome': user.nome,
      'email': user.email,
      'senha': senha,
      'telefone': user.telefone,
    }); // monta o corpo da requisição em JSON

    final response = await http.post(
      Uri.parse('$baseUrl/cadastro/usuario'),              
      headers: {'Content-Type': 'application/json'},      
      body: body,                                        
    );  // requisição POST

    if(response.statusCode == 201){
      return response.statusCode == 201;
    }
    else{
      throw Exception('Erro ao realizar cadastro!');
    }

               
  }



    // POST /cadastro/pets
  static Future<bool> cadastrarPet(cpfDoador, nomePet, racaPet, idadePet, descricaoPet, deficienciaPet, imgPet, especiePet, statusPet) async {
    final body = jsonEncode({                        
      'cpfDoador': cpfDoador,
      'nome': nomePet,
      'raca': racaPet,
      'idade': idadePet,
      'descricao': descricaoPet,
      'deficiencia': deficienciaPet,
      'imagem': imgPet,
      'especie': especiePet,
      'status': statusPet
    }); // monta o corpo da requisição em JSON

    final response = await http.post(
      Uri.parse('$baseUrl/cadastro/pets'),              
      headers: {'Content-Type': 'application/json'},      
      body: body,                                        
    );  // requisição POST

    if(response.statusCode == 201){
      return response.statusCode == 201;
    }
    else{
      throw Exception('Erro ao realizar cadastro!');
    }

               
  }




  // POST /login
  static Future<bool> loginUsuario(String cpf, String senha) async { 
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'usuario': cpf, 'senha': senha}), 
    ); // requisição post

    if(response.statusCode == 201){
      return response.statusCode == 201;
    }
    else{
      throw Exception('Credenciais inválidas');
    }                  
  }
  



  // DELETE /deletar/usuario/:cpf
  static Future<bool> deletarUsuario(String cpf) async {
    final response = await http.delete(Uri.parse('$baseUrl/deletar/usuario/$cpf'));  // requisição DELETE
    
    if(response.statusCode == 200){
      return response.statusCode == 200;
    }
    else{
      throw Exception('Erro ao deletar usuário!');
    }
  }




  // DELETE /deletar/pets/:id
  Future<bool> marcarComoAdotado(int idPet) async {
    final url = Uri.parse("$baseUrl/deletar/pets/$idPet");
      
    final response = await http.delete(url);  // requisição DELETE

    if(response.statusCode == 201){
      return response.statusCode == 201;
    }
    else{
      throw Exception('Erro ao deletar pet!');
    }
  }




  // PUT /atualizar/usuario/:cpf
  static Future<bool> atualizarUsuario(
  String cpf, {
  String? nome,
  String? email,
  String? telefone,
  String? senha,
}) async {
  final body = jsonEncode({
    'nomeAtualizar': nome,
    'emailAtualizar': email,
    'telefoneAtualizar': telefone,
    'senhaAtualizar': senha,
  });

  final response = await http.put(
    Uri.parse('$baseUrl/atualizar/usuario/$cpf'),
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Erro ao atualizar dados: ${response.body}');
  }
}




  // PUT /atualizar/pets/:id
  static Future<bool> atualizarPet(int id, {String? nome, String? raca, int? idade, String? descricao, String? deficiencia, String? imagem}) async {
    final body = jsonEncode({
      'nomePetAtualizar': nome,
      'racaPetAtualizar': raca,
      'idadePetAtualizar': idade,
      'descPetAtualizar': descricao,
      'deficienciaPetAtualizar': deficiencia,
      'imgPetAtualizar': imagem,
    }); // monta o corpo da requisição JSON

    final response = await http.put(
      Uri.parse('$baseUrl/atualizar/pets/$id'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    ); // requisição PUT

    if(response.statusCode == 200){
      return response.statusCode == 200;
    }
    else{
      throw Exception('Erro ao atualizar dados do pet!');
    }
  }
}
