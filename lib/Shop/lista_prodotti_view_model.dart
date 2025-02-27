import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marino_barber_salon_flutter/Shop/prodotto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListaProdottiViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SupabaseClient _supabaseClient = Supabase.instance.client;


  List<Prodotto> _listaProdotti = [];
  Prodotto _prodotto = Prodotto(
    nome: '',
    descrizione: '',
    prezzo: 0.00,
    quantita: 0,
    immagine: '',
    categoria: '',
  );
  bool _isLoading = true;

  List<Prodotto> get listaProdotti => _listaProdotti;
  Prodotto get prodotto => _prodotto;
  bool get isLoading => _isLoading;

  //Carica lista prodotti in base alla categoria
  Future<void> caricaListaProdotti(String categoria) async {
    try {
      _isLoading = true;
      notifyListeners();
      QuerySnapshot result = await _db.collection("prodotti").get();

      List<Prodotto> lista = result.docs.map((doc) => Prodotto.fromFirestore(doc)).toList();


      lista = lista
          .where((prod) => prod.categoria.toLowerCase() == categoria.toLowerCase())
          .toList();

      lista.sort((a, b) => a.nome.compareTo(b.nome));


      _listaProdotti = lista;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Errore nel caricamento prodotti: $e");
    }
  }



  // Prenota un prodotto
  Future<void> prenotaProdotto(Prodotto prodotto, int quantita, VoidCallback onSuccess, VoidCallback onFailed) async {
    _isLoading = true;
    notifyListeners();
    try {
      QuerySnapshot query = await _db.collection("prodotti").where("nome", isEqualTo: prodotto.nome).limit(1).get();
      if (query.docs.isEmpty) {
        onFailed();
        return;
      }

      DocumentReference prodRef = _db.collection("prodotti").doc(query.docs.first.id);
      DocumentReference userRef = _db.collection("utenti").doc(_auth.currentUser?.email);

      String data = DateFormat("dd/MM/yyyy", "it_IT").format(DateTime.now());

      Map<String, dynamic> prenotazioneProd = {
        "prodotto": prodRef,
        "utente": userRef,
        "quantita": quantita,
        "prezzo_totale": prodotto.prezzo * quantita,
        "stato": "attesa",
        "data": data,
      };

      await _db.runTransaction((transaction) async {
        DocumentSnapshot userSnapshot = await transaction.get(userRef);
        DocumentSnapshot prodottoSnapshot = await transaction.get(prodRef);

        if (prodottoSnapshot.exists) {
          transaction.update(prodRef, {"quantita": (prodotto.quantita - quantita)});
          print("Aggiornata quantità: ${prodotto.quantita - quantita}");
        }

        if (userSnapshot.exists) {
          DocumentReference nuovoDocRef = _db.collection("prodottiPrenotati").doc();
          transaction.set(nuovoDocRef, prenotazioneProd);
          print("Prenotazione registrata!");
        }
      });
      _isLoading = false;
      notifyListeners();
      onSuccess();
    } catch (e) {
      print("Errore nella prenotazione: $e");
      _isLoading = false;
      notifyListeners();
      onFailed();
    }
  }


  //Ottieni URL firmato da Supabase
  String getSignedUrl(String filePath, {int expiresInSeconds = 3600}) {
    final storage = _supabaseClient.storage;
    return storage.from("photos").getPublicUrl("photos/$filePath");
  }
}

