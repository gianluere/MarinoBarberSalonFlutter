import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'Home/appuntamento.dart';
import 'Home/user.dart';

class UserViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _currentUser;
  String? _errorMessage;
  UserFirebase? _dati;
  bool _isLoading = true;
  List<Appuntamento>? _listaAppuntamenti;

  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  UserFirebase? get dati => _dati;
  bool get isLoading => _isLoading;
  List<Appuntamento>? get listaAppuntamenti => _listaAppuntamenti;

  UserViewModel() {

    _auth.authStateChanges().listen((User? user) {
      _currentUser = user; // Aggiorna l'utente corrente
      if (_currentUser != null) {
        init(); // Ricarica i dati quando cambia l'utente
      } else {
        _dati = null; // Resetta i dati se l'utente è disconnesso
        _isLoading = false;
        notifyListeners();
      }
    });

    // Inizializza lo stato dell'utente all'avvio
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      init();
    } else {
      _isLoading = false;
    }

  }

  Future<void> init() async{
    _isLoading = true;
    notifyListeners();
    _dati = await caricaDati();
    sincronizzaPrenotazioni();

    print("Nome: ${_dati?.nome}");
    print("Cognome: ${_dati?.cognome}");

    _isLoading = false;
    notifyListeners();
  }

  // Funzione di login
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _errorMessage = null;
      print("Inizio");
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = userCredential.user;
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Funzione di logout
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Funzione di registrazione (opzionale)
  Future<void> register(String email, String password) async {
    try {
      _errorMessage = null;
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = userCredential.user;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }


  Future<UserFirebase?> caricaDati() async {
    try {
      // Recupera il documento dall'email dell'utente corrente
      DocumentSnapshot doc = await _db.collection('utenti').doc(_currentUser?.email).get();

      if (doc.exists) {
        // Converte i dati del documento in una mappa
        var data = doc.data() as Map<String, dynamic>;

        // Crea un'istanza di UserFirebase utilizzando i dati mappati
        var user = UserFirebase(
          nome: data['nome'] ?? '',            // Default a stringa vuota se null
          cognome: data['cognome'] ?? '',      // Default a stringa vuota se null
          email: data['email'] ?? '',          // Default a stringa vuota se null
          eta: data['eta'] ?? 0,               // Default a 0 se null
          telefono: data['telefono'] ?? '',    // Default a stringa vuota se null
          appuntamenti: data['appuntamenti'] ?? [], // Default a lista vuota se null
        );

        return user; // Restituisci l'istanza dell'utente
      } else {
        // Documento non trovato, ritorna null
        print("Documento non trovato per l'email: ${_currentUser?.email}");
        return null;
      }
    } catch (e) {
      // Gestione errori
      print("Errore durante il caricamento dei dati: $e");
      return null;
    }
  }


  // Aggiorna lo stato dell'utente
  void updateUserState(User? user) {
    _currentUser = user;
    notifyListeners();
  }


  Future<void> aggiungiAppuntamento({
    required String servizio,
    required String orarioInizio,
    required String orarioFine,
    required String dataSel,
    required Function onSuccess,
    required Function onFailed
  }) async {

    _isLoading = true;
    notifyListeners();

    try {
      final data = dataSel.replaceAll('/', '-');
      print("Servizio: $servizio");

      // Ottieni il servizio dalla collezione "servizi"
      final QuerySnapshot<Map<String, dynamic>> results = await _db
          .collection("servizi")
          .where("nome", isEqualTo: servizio)
          .limit(1)
          .get();

      if (results.docs.isEmpty) {
        throw Exception("Servizio non trovato");
      }

      final servizioNome = results.docs[0].get("nome");
      final descrizione = results.docs[0].get("descrizione");
      final prezzo = results.docs[0].get("prezzo").toDouble();

      print("Problema 1");
      final DocumentReference<Map<String, dynamic>> utenteRiferimento =
      _db.collection("utenti").doc(currentUser!.email);

      print("Problema 2");

      final appuntamento = {
        "cliente": utenteRiferimento,
        "orarioInizio": orarioInizio,
        "orarioFine": orarioFine,
        "data": data,
        "servizio": servizioNome,
        "descrizione": descrizione,
        "prezzo": prezzo,
      };

      final appuntamentoPath = _db.collection("appuntamenti").doc(data);
      final occupatiPath = _db.collection("occupati").doc(data);
      final totalePath = appuntamentoPath.collection("totale").doc("count");

      print("Problema 3");

      await _db.runTransaction((transaction) async {
        final appuntamentoSnapshot = await transaction.get(appuntamentoPath);
        final occupatiSnapshot = await transaction.get(occupatiPath);
        final totaleSnapshot = await transaction.get(totalePath);
        final chiave = "$orarioInizio-$orarioFine";

        print("Chiave : $chiave");

        print("Problema 4");

        // Aggiungi appuntamento
        if (appuntamentoSnapshot.exists) {
          print("Documento appuntamento già esistente");
          transaction.set(
            appuntamentoPath.collection("app").doc(chiave),
            appuntamento
          );
        } else {
          print("aaa");
          transaction.set(appuntamentoPath, <String, dynamic>{});
          transaction.set(
            appuntamentoPath.collection("app").doc(chiave),
            appuntamento,
          );
        }



        // Aggiorna la collezione "totale" incrementando il conteggio
        if (totaleSnapshot.exists) {
          final currentCount = totaleSnapshot.get("count") ?? 0;
          transaction.update(totalePath, {"count": currentCount + 1});
        } else {
          transaction.set(totalePath, {"count": 1});
        }

        print("Problema 5");

        // Gestisci la collezione occupati
        if (occupatiSnapshot.exists) {
          final occupatiMap = occupatiSnapshot.data();
          if (occupatiMap != null && occupatiMap.containsKey(chiave)) {
            throw FirebaseException(
              plugin: "cloud_firestore",
              message: "Lo slot $orarioInizio-$orarioFine è già occupato",
            );
          } else {
            transaction.update(occupatiPath, {chiave: "occupato"});
          }
        } else {
          transaction.set(occupatiPath, {chiave: "occupato"});
        }

        print("Problema 6");

        // Aggiorna il riferimento utente
        transaction.update(
          utenteRiferimento,
          {
            "appuntamenti": FieldValue.arrayUnion([
              appuntamentoPath.collection("app").doc(chiave),
            ])
          },
        );
      });

      await caricaDati();
      _isLoading = false;
      notifyListeners();
      onSuccess();
      print("Prenotazione aggiunta con successo e totale aggiornato");
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      onFailed();
      print("Errore durante l'aggiunta dell'appuntamento: $e");
    }
  }

  Future<void> updateDati(
      String nome,
      String cognome,
      int eta,
      String telefono,
      )
  async {

    if (_currentUser != null){
      final daAggiornare = {
        "nome": nome,
        "cognome": cognome,
        "eta": eta,
        "telefono": telefono,
      };

      _isLoading = true;
      notifyListeners();

      _db.collection("utenti")
          .doc(_currentUser?.email)
          .update(daAggiornare)
          .then((_) async {
        _currentUser = _auth.currentUser;
        await caricaDati();
        _isLoading = false;
        notifyListeners();

      }).catchError((error) {
        debugPrint("Errore nell'aggiornamento: $error");
      });
    }


  }


  Future<List<Appuntamento>> _recuperaDocumenti(List<DocumentReference> listaAppuntamenti) async {
    List<Appuntamento> appuntamenti = [];

    for (var document in listaAppuntamenti) {
      var result = await document.get();
      if (result.exists) {
        var appuntamento = Appuntamento.fromMap(result.data() as Map<String, dynamic>);
        appuntamenti.add(appuntamento);
      }
    }

    return appuntamenti;
  }

  Future<void> sincronizzaPrenotazioni() async {

    if (_currentUser != null){
      _db.collection("utenti")
          .doc(currentUser?.email)
          .snapshots()
          .listen((snapshot) async {
        if (!snapshot.exists) return;

        final List<dynamic>? appuntamentiList = snapshot.data()?["appuntamenti"] as List<dynamic>?;

        if (appuntamentiList != null) {
          _isLoading = true;
          notifyListeners();
          List<Appuntamento> listApp = await _recuperaDocumenti(appuntamentiList.cast<DocumentReference>());

          // Rimozione spazi extra nella descrizione
          for (var app in listApp) {
            app.descrizione = app.descrizione.replaceAll(RegExp(r'\s+'), " ");
          }

          // Formattazione e ordinamento delle date
          final dateFormatter = DateFormat("dd-MM-yyyy");
          final timeFormatter = DateFormat("HH:mm");

          listApp.sort((a, b) {
            final dateA = dateFormatter.parse(a.data);
            final dateB = dateFormatter.parse(b.data);

            if (dateA != dateB) {
              return dateB.compareTo(dateA); // Ordina per data decrescente
            }

            final timeA = timeFormatter.parse(a.orarioInizio);
            final timeB = timeFormatter.parse(b.orarioInizio);
            return timeB.compareTo(timeA); // Ordina per ora decrescente
          });

          _listaAppuntamenti = listApp;
          _currentUser = _auth.currentUser;
          _dati = await caricaDati();
          _isLoading = false;
          notifyListeners();
        }
      }, onError: (error) {
        debugPrint("Errore Firestore: $error");
      });
    }

  }





}
