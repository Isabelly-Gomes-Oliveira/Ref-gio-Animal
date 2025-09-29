import 'dart:convert'; // para converter entre objetos Dart e JSON (string)        
import 'package:http/http.dart' as http; 
import 'usuario.dart';         
import 'pet.dart';         

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000'; 





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




  // POST /cadastroUsuario
  static Future<bool> cadastrarUsuario(Usuario user, String senha) async {
    final body = jsonEncode({                        
      'cpfUser': user.cpf,
      'nomeUser': user.nome,
      'emailUser': user.email,
      'senhaUser': senha,
      'telefoneUser': user.telefone,
    }); // monta o corpo da requisição em JSON

    final response = await http.post(
      Uri.parse('$baseUrl/cadastroUsuario'),              
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

    if(response.statusCode == 200){
      return response.statusCode == 200;
    }
    else{
      throw Exception('Erro ao realizar login!');
    }                  
  }
  



  // DELETE /deletarUsuario/:cpf
  static Future<bool> deletarUsuario(String cpf) async {
    final response = await http.delete(Uri.parse('$baseUrl/deletarUsuario/$cpf'));  // requisição DELETE
    
    if(response.statusCode == 200){
      return response.statusCode == 200;
    }
    else{
      throw Exception('Erro ao deletar usuário!');
    }
  }




  // PUT /atualizarDadosUser/:cpf
  static Future<bool> atualizarUsuario(String cpf, {String? email, String? senha, String? telefone}) async { 
    final body = jsonEncode({
      'emailAtualizar': email,
      'senhaAtualizar': senha,
      'telefoneAtualizar': telefone,
    }); // monta o corpo da requisição JSON

    final response = await http.put(
      Uri.parse('$baseUrl/atualizarDadosUser/$cpf'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    ); // requisição PUT

    if(response.statusCode == 200){
      return response.statusCode == 200;
    }
    else{
      throw Exception('Erro ao atualizar dados do usuário!');
    }

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
    }); // monta o corpo da requisição JSON

    final response = await http.put(
      Uri.parse('$baseUrl/atualizarDadosPet/$id'),
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
