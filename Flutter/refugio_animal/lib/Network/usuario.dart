class Usuario {
  final String cpf;
  final String nome;
  final String? email;
  final String senha;
  final String telefone;

  Usuario({
    required this.cpf,
    required this.nome,
    this.email,
    required this.senha,
    required this.telefone,
  });


  Map<String, dynamic> toJson() => { // converte para JSON
    'CPF': cpf,
    'nome': nome,
    'email': email,
    'senha': senha,
    'telefone': telefone,
  }; 

  factory Usuario.FromJson(Map<String, dynamic> json) => Usuario( // contrutor
    cpf: json['cpf'] as String,
    nome: json['nome'] as String,
    email: json['email'] as String?,
    senha: json['senha'] as String,
    telefone: json['telefone'] as String,
  );
}