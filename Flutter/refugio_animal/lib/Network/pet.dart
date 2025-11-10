class Pet {
  final int id;
  final String nome;
  final String raca;
  final int? idade;
  final String descricao;
  final String? deficiencia;
  final String especie;
  final String statusAdotado;
  final String imagem;
  final String cpfDoador; 

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
    required this.cpfDoador,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
        id: json['id'] ?? 0,
        nome: json['nome'] ?? 'Sem nome',
        raca: json['raca'] ?? 'Raça N/A',
        idade: json['idade'] as int?,
        descricao: json['descricao'] ?? 'Sem descrição',
        deficiencia: json['deficiencia'] as String?,
        especie: json['especie'] ?? 'Espécie N/A',
        statusAdotado: json['status_adotado'] ?? 'desconhecido',
        imagem: json['imagem'] ?? '',
        cpfDoador: json['CPF_Doador'] ?? '', // pega o CPF do dono
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'raca': raca,
        'idade': idade,
        'descricao': descricao,
        'deficiencia': deficiencia,
        'especie': especie,
        'status_adotado': statusAdotado,
        'imagem': imagem,
        'CPF_Doador': cpfDoador,
      };
}
