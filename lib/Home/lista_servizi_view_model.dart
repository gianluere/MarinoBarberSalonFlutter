import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Servizio{
  String? nome;
  String? descrizione;
  String? tipo;
  int? durata;
  double? prezzo;

  Servizio(
      {
        required this.nome,
        required this.descrizione,
        required this.tipo,
        required this.durata,
        required this.prezzo
      }
    );

  factory Servizio.fromMap(Map<String, dynamic> map) {
    return Servizio(
      nome: map['nome'] ?? '',
      descrizione: map['descrizione'] ?? '',
      tipo : map['tipo'] ?? '',
      durata: (map['durata'] as num?)?.toInt(),
      prezzo: (map['prezzo'] as num?)?.toDouble(),
    );
  }

}

class ListaServiziViewModel extends ChangeNotifier{

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Servizio> _listaServizi = [];
  List<Servizio> get listaServizi => _listaServizi;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  ListaServiziViewModel() {
    getListaServizi();
  }

  Future<void> getListaServizi() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection("servizi").get();

      //Converte i documenti Firebase in una lista di oggetti `Servizio`
      _listaServizi = snapshot.docs.map((doc) {
        final servizio = Servizio.fromMap(doc.data());

        //Rimuove spazi multipli nella descrizione
        if (servizio.descrizione != null) {
          servizio.descrizione = servizio.descrizione!.replaceAll(RegExp(r'\s+'), ' ');
        }
        return servizio;
      }).toList();
    } catch (e) {
      print("Errore durante il caricamento dei servizi: $e");
    }

    _isLoading = false;
    notifyListeners();
  }


}

