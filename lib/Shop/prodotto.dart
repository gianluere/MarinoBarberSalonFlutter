import 'package:cloud_firestore/cloud_firestore.dart';

class Prodotto {
  String nome;
  String descrizione;
  double prezzo;
  int quantita;
  String immagine;
  String categoria;


  Prodotto({
    required this.nome,
    required this.descrizione,
    required this.prezzo,
    required this.quantita,
    required this.immagine,
    required this.categoria,
  });

  factory Prodotto.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Prodotto(
      nome: data["nome"] ?? "",
      descrizione: data["descrizione"] ?? "",
      prezzo: (data["prezzo"] as num?)!.toDouble(),
      quantita: (data["quantita"] as num?)!.toInt(),
      immagine: data["immagine"] ?? "",
      categoria: data["categoria"] ?? "",
    );
  }
}
