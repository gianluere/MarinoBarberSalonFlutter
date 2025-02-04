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


}