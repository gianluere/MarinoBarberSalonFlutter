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

  // Carica lista prodotti in base alla categoria
  Future<void> caricaListaProdotti(String categoria) async {
    try {
      _isLoading = true;
      notifyListeners();
      QuerySnapshot result = await _db.collection("prodotti").get();
      print("fatto 0");
      List<Prodotto> lista = result.docs.map((doc) => Prodotto.fromFirestore(doc)).toList();
      print("fatto 1");

      lista = lista
          .where((prod) => prod.categoria.toLowerCase() == categoria.toLowerCase())
          .toList();

      print("fatto 2");

      lista.sort((a, b) => a.nome.compareTo(b.nome));

      print("fatto 3");

      _listaProdotti = lista;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Errore nel caricamento prodotti: $e");
    }
  }

  // Trova un prodotto per nome
  Future<Prodotto?> _trovaProd(String nome) async {
    try {

      _isLoading = true;
      notifyListeners();
      QuerySnapshot query = await _db.collection("prodotti").where("nome", isEqualTo: nome).get();
      if (query.docs.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return Prodotto.fromFirestore(query.docs.first);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Errore nel trovare il prodotto: $e");
    }
    return null;
  }

  void trovaProdotto(String nome) async {
    _isLoading = true;
    notifyListeners();
    Prodotto? trovato = await _trovaProd(nome);
    if (trovato != null) {
      _prodotto = trovato;
      _isLoading = false;
      notifyListeners();
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


  Future<void> prenProdotto({
    required String nomeProdotto,
    required int quantita,
    required Function() onSuccess,
    required Function() onFailed,
  }) async {

    try {

      _isLoading = true;
      notifyListeners();

      // Trova il prodotto in Firestore
      QuerySnapshot prodSnapshot = await _db.collection("prodotti")
          .where("nome", isEqualTo: nomeProdotto)
          .limit(1)
          .get();

      if (prodSnapshot.docs.isEmpty) {
        print("Prodotto non trovato");
        _isLoading = false;
        notifyListeners();
        onFailed();
        return;
      }

      // Referenze ai documenti
      DocumentReference prodRef = _db.collection("prodotti").doc(prodSnapshot.docs.first.id);
      DocumentReference userRef = _db.collection("utenti").doc(_auth.currentUser?.email);

      String data = DateFormat("dd/MM/yyyy", "it_IT").format(DateTime.now());

      // Dati per la prenotazione
      Map<String, dynamic> prenotazioneProd = {
        "prodotto": prodRef,
        "utente": userRef,
        "quantita": quantita,
        "stato": "attesa",
        "data": data,
      };

      // Esegui la transazione
      await _db.runTransaction((transaction) async {
        DocumentSnapshot userSnapshot = await transaction.get(userRef);
        DocumentSnapshot prodottoSnapshot = await transaction.get(prodRef);

        if (prodottoSnapshot.exists) {
          int quantitaAttuale = (prodottoSnapshot.data() as Map<String, dynamic>)["quantita"] ?? 0;
          if (quantitaAttuale >= quantita) {
            transaction.update(prodRef, {"quantita": quantitaAttuale - quantita});
            print("Quantità aggiornata: ${quantitaAttuale - quantita}");
          } else {
            print("Quantità insufficiente!");
            _isLoading = false;
            notifyListeners();
            onFailed();
            return;
          }
        }

        if (userSnapshot.exists) {
          DocumentReference nuovoDocumentoRef = _db.collection("prodottiPrenotati").doc();
          transaction.set(nuovoDocumentoRef, prenotazioneProd);
          print("Prenotazione inserita!");
        }

        _isLoading = false;
        notifyListeners();
        onSuccess();
      });
    } catch (e) {
      print("Errore: $e");
      _isLoading = false;
      notifyListeners();
      onFailed();
    }
  }



  // Ottieni URL firmato da Supabase
  String getSignedUrl(String filePath, {int expiresInSeconds = 3600}) {
    final storage = _supabaseClient.storage;
    return storage.from("photos").getPublicUrl("photos/$filePath");
  }
}

