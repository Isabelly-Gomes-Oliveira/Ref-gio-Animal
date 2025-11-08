// usuario.dart
class Usuario {
  final String cpf;
  final String nome;
  final String? email;
  final String telefone;

  Usuario({
    required this.cpf,
    required this.nome,
    this.email,
    required this.telefone,
  });

  // Converte para JSON (caso precise enviar algum dia)
  Map<String, dynamic> toJson() => {
        'CPF': cpf,
        'nome': nome,
        'email': email,
        'telefone': telefone,
      };

  // Factory corrigida para lidar com nulls e campos ausentes
  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        cpf: json['CPF'] ?? '', 
        nome: json['nome'] ?? 'Sem nome',
        email: json['email'] as String?,
        telefone: json['telefone'] ?? 'Telefone não informado',
      );
}
