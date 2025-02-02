import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:marino_barber_salon_flutter/Account/recensione.dart';


class ListaRecensioniViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;

  List<Recensione> _listaRecensioni = [];
  bool _isLoading = true;

  List<Recensione> get listaRecensioni => _listaRecensioni;
  bool get isLoading => _isLoading;


  ListaRecensioniViewModel() {
    caricaListaRecensioni();
  }

  Future<void> caricaListaRecensioni() async {  // Cambiato da void a Future<void>
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _db.collection("recensioni").get();
      _listaRecensioni = snapshot.docs.map((doc) => Recensione.fromMap(doc.data())).toList();
    } catch (e) {
      print("Errore nel caricamento delle recensioni: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> inserisciRecensione(Recensione recensione) async {

    _isLoading = true;
    notifyListeners();

    await _db.collection("recensioni").add({
      'nome': recensione.nome,
      'stelle': recensione.stelle,
      'descrizione': recensione.descrizione,
    }).then((_) {
      caricaListaRecensioni(); // Aggiorna la lista dopo l'inserimento
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Errore nell'inserimento della recensione: $error");
    });
  }
}
