class Pet {
  final int id;
  final String? nome;
  final String? raca;
  final int? idade;
  final String descricao;
  final String? deficiencia;
  final String especie;
  final int statusAdotado;
  final String imagem;

  Pet({
    required this.id,
    required this.nome,
    required this.raca,
    this.idade,
    required this.descricao,
    this.deficiencia,
    required this.especie,
    required this.statusAdotado,
    required this.imagem,
  });

  Map<String, dynamic> toJson() => {  // converte para JSON
    'id': id,
    'nome': nome,
    'raca': raca,
    'idade': idade,
    'descricao': descricao,
    'deficiencia': deficiencia,
    'especie': especie,
    'status_adotado': statusAdotado,
    'imagem': imagem,
  };

  factory Pet.fromJson(Map<String, dynamic> json) => Pet( // construtor
    id: json['id'] as int,
    nome: json['nome'] as String,
    raca: json['raca'] as String,
    idade: json['idade'] as int?,
    descricao: json['descricao'] as String,
    deficiencia: json['deficiencia'] as String?,
    especie: json['especie'] as String,
    statusAdotado: json['statusAdotado'] as int,
    imagem: json['imagem'] as String,
  );
}
