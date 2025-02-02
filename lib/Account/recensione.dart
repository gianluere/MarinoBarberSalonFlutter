class Recensione{
  String nome;
  double stelle;
  String descrizione;

  Recensione({
    required this.nome,
    required this.stelle,
    required this.descrizione
  });

  factory Recensione.fromMap(Map<String, dynamic> map) {
    return Recensione(
      nome: map['nome'] ?? '',
      stelle: (map['stelle'] as num?)?.toDouble() ?? 0.0,
      descrizione: map['descrizione'] ?? ''

    );
  }
}