import 'package:cloud_firestore/cloud_firestore.dart';

class Appuntamento{

  String servizio;
  String descrizione;
  double prezzo;
  DocumentReference cliente;
  String orarioInizio;
  String orarioFine;
  String data;

  Appuntamento({
    required this.servizio,
    required this.descrizione,
    required this.prezzo,
    required this.cliente,
    required this.orarioFine,
    required this.orarioInizio,
    required this.data
  });

  factory Appuntamento.fromMap(Map<String, dynamic> map) {
    return Appuntamento(
      servizio: map['servizio'] ?? '',
      descrizione: map['descrizione'] ?? '',
      prezzo: (map['prezzo'] as num?)?.toDouble() ?? 0.0,
      cliente: map['cliente'] ?? [],
      orarioInizio: map['orarioInizio'] ?? '',
      orarioFine: map['orarioFine'] ?? '',
      data: map['data'] ?? '',
    );
  }
}