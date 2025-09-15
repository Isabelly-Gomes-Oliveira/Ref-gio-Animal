import 'dart:convert';               
import 'package:http/http.dart' as http; 
import 'usuario.dart';         
import 'pet.dart';         

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000'; 

  // GET /pets
  static Future<List<Pet>> getPets() async {        
    final response = await http.get(Uri.parse('$baseUrl/pets')); // 7

    if (response.statusCode == 200) {                    // 8
      final List data = jsonDecode(response.body);       // 9
      return data.map((e) => Pet.fromJson(e)).toList();  // 10
    } else {
      throw Exception('Erro ao carregar pets');          // 11
    }
  }

  // GET /pets/raca/:raca
  static Future<List<Pet>> getPetsByRaca(String raca) async { // 12
    final encoded = Uri.encodeComponent(raca);           // 13
    final response = await http.get(Uri.parse('$baseUrl/pets/raca/$encoded')); // 14

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Pet.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar pets por raça');
    }
  }

  // POST /cadastroUsuario
  static Future<bool> cadastrarUsuario(Usuario user, String senha) async { // 15
    final body = jsonEncode({                              // 16
      'cpfUser': user.cpf,
      'nomeUser': user.nome,
      'emailUser': user.email,
      'senhaUser': senha,
      'telefoneUser': user.telefone,
    });

    final response = await http.post(
      Uri.parse('$baseUrl/cadastroUsuario'),               // 17
      headers: {'Content-Type': 'application/json'},      // 18
      body: body,                                         // 19
    );

    return response.statusCode == 201;                    // 20
  }

  // POST /login
  static Future<bool> loginUsuario(String cpf, String senha) async { // 21
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'usuario': cpf, 'senha': senha}), // 22
    );

    return response.statusCode == 200;                   // 23
  }
  

  // DELETE /deletarUsuario/:cpf
  static Future<bool> deletarUsuario(String cpf) async { // 27
    final response = await http.delete(Uri.parse('$baseUrl/deletarUsuario/$cpf'));
    return response.statusCode == 200;
  }

  // PUT /atualizarDadosUser/:cpf
  static Future<bool> atualizarUsuario(String cpf, {String? email, String? senha, String? telefone}) async { // 28
    final body = jsonEncode({
      'emailAtualizar': email,
      'senhaAtualizar': senha,
      'telefoneAtualizar': telefone,
    });

    final response = await http.put(
      Uri.parse('$baseUrl/atualizarDadosUser/$cpf'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response.statusCode == 200;
  }

  // PUT /atualizarDadosPet/:id
  static Future<bool> atualizarPet(int id, {String? nome, String? raca, int? idade, String? descricao, String? deficiencia, String? imagem}) async {
    final body = jsonEncode({
      'nomePetAtualizar': nome,
      'racaPetAtualizar': raca,
      'idadePetAtualizar': idade,
      'descPetAtualizar': descricao,
      'deficienciaPetAtualizar': deficiencia,
      'imgPetAtualizar': imagem,
    });

    final response = await http.put(
      Uri.parse('$baseUrl/atualizarDadosPet/$id'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response.statusCode == 200;
  }
}
