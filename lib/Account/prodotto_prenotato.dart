import 'package:cloud_firestore/cloud_firestore.dart';

class ProdottoPrenotato{

  DocumentReference prodotto;
  int quantita;
  String stato;
  DocumentReference utente;
  String data;

  ProdottoPrenotato({
    required this.prodotto,
    required this.quantita,
    required this.stato,
    required this.data,
    required this.utente
  });

  factory ProdottoPrenotato.fromMap(Map<String, dynamic> map) {
    return ProdottoPrenotato(
        prodotto: map['prodotto'] ?? [],
        quantita: (map['quantita'] as num?)?.toInt() ?? 0,
        stato: map['stato'] ?? '',
        utente: map['utente'] ?? '',
        data: map['data'] ?? ''
    );
  }


}