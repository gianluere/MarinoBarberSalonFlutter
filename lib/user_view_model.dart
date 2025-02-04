import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:marino_barber_salon_flutter/Account/prodotto_prenotato.dart';
import 'package:marino_barber_salon_flutter/noti_service.dart';

import 'Home/appuntamento.dart';
import 'Home/user.dart';
import 'Shop/prodotto.dart';

class UserViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _currentUser;
  String? _errorMessage;
  UserFirebase? _dati;
  bool _isLoading = true;
  bool _isLoadingPrenotazioni = true;
  List<Appuntamento>? _listaAppuntamenti;
  List<Map<String, dynamic>> _listaProdottiPrenotati = [];

  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  UserFirebase? get dati => _dati;
  bool get isLoading => _isLoading;
  bool get isLoadingPrenotazioni => _isLoadingPrenotazioni;
  List<Appuntamento>? get listaAppuntamenti => _listaAppuntamenti;
  List<Map<String, dynamic>> get listaProdottiPrenotati => _listaProdottiPrenotati;

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

    await caricaProdottiPrenotati();

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

  // Funzione di registrazione
  Future<void> register(String email, String password, String nome, String cognome, String eta, String telefono) async {
    _isLoading = true;
    notifyListeners();
    try {
      _errorMessage = null;
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = userCredential.user;



      caricaDati();
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
    }
  }




  Future<void> signup({
    required String email,
    required String password,
    required String nome,
    required String cognome,
    int eta = 0,
    required String telefono,
  }) async {
    _errorMessage=null;
    notifyListeners();

    if (email.isEmpty || password.isEmpty) {
      _errorMessage = "Email e password non possono essere vuoti";
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Creazione dell'utente con Firebase Authentication
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = userCredential.user;

      // Ottenere l'email dell'utente appena creato
      String? userEmail = _currentUser?.email;

      if (userEmail != null) {
        // Salvataggio dati utente su Firestore
        await _db.collection("utenti").doc(userEmail).set({
          "nome": nome,
          "cognome": cognome,
          "email": email,
          "eta": eta,
          "telefono": telefono,
          "appuntamenti" : <DocumentReference>[]
        });


        await caricaDati();
        _isLoading = false;
        notifyListeners();

      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Errore Firebase: ${e.code}");
      Map<String, String> firebaseErrorMessages = {
        "email-already-in-use": "L'email è già in uso.",
        "invalid-email": "L'email inserita non è valida.",
        "weak-password": "La password è troppo debole.",
        "operation-not-allowed": "Registrazione tramite email e password non consentita.",
      };

      _errorMessage = firebaseErrorMessages[e.code] ?? "Errore sconosciuto.";
      _isLoading = false;
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


      final DocumentReference<Map<String, dynamic>> utenteRiferimento =
      _db.collection("utenti").doc(currentUser!.email);



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



      await _db.runTransaction((transaction) async {
        final appuntamentoSnapshot = await transaction.get(appuntamentoPath);
        final occupatiSnapshot = await transaction.get(occupatiPath);
        final totaleSnapshot = await transaction.get(totalePath);
        final chiave = "$orarioInizio-$orarioFine";

        print("Chiave : $chiave");



        // Aggiungi appuntamento
        if (appuntamentoSnapshot.exists) {
          print("Documento appuntamento già esistente");
          transaction.set(
            appuntamentoPath.collection("app").doc(chiave),
            appuntamento
          );
        } else {

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
      final String mess = 'Hai un appuntamento oggi alle $orarioInizio per il servizio $servizioNome.';
      NotiService().scheduleNotification(
          id: 1,
          title: 'Promemoria appuntamento',
          body: mess,
          hour: 23,
          minute: 14
      );

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
          _isLoadingPrenotazioni = true;
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
          _isLoadingPrenotazioni = false;
          notifyListeners();
        }
      }, onError: (error) {
        debugPrint("Errore Firestore: $error");
      });
    }

  }


  Future<void> annullaPrenotazione(
      Appuntamento appuntamento,
      VoidCallback errore
      ) async {

    _isLoading = true;
    if (_currentUser == null) {
      _isLoading = false;
      notifyListeners();
      errore();
      debugPrint("Errore: Utente non autenticato.");
      return;
    }

    final String emailUtente = _currentUser!.email ?? '';
    final DocumentReference appuntamentoPath =
    _db.collection("appuntamenti").doc(appuntamento.data);
    final DocumentReference occupatiPath =
    _db.collection("occupati").doc(appuntamento.data);
    final DocumentReference utenteRiferimento =
    _db.collection("utenti").doc(emailUtente);
    final DocumentReference totalePath =
    appuntamentoPath.collection("totale").doc("count");

    final String chiave = "${appuntamento.orarioInizio}-${appuntamento.orarioFine}";
    final DocumentReference appuntamentoReference =
    appuntamentoPath.collection("app").doc(chiave);

    try {
      await _db.runTransaction((transaction) async {
        final appuntamentoSnapshot = await transaction.get(appuntamentoPath);
        final occupatiSnapshot = await transaction.get(occupatiPath);
        final totaleSnapshot = await transaction.get(totalePath);
        final userSnapshot = await transaction.get(utenteRiferimento);

        // Cancella l'appuntamento se esiste
        if (appuntamentoSnapshot.exists) {
          transaction.delete(appuntamentoReference);
        }

        // Aggiorna il documento "occupati" rimuovendo la chiave
        if (occupatiSnapshot.exists) {
          transaction.update(occupatiPath, {chiave: FieldValue.delete()});
        }

        // Rimuove il riferimento appuntamento dall'utente
        if (userSnapshot.exists) {
          transaction.update(
              utenteRiferimento,
              {"appuntamenti": FieldValue.arrayRemove([appuntamentoReference])}
          );
        }

        // Aggiorna il conteggio nella collezione "totale"
        if (totaleSnapshot.exists) {
          final int currentCount = (totaleSnapshot.get("count") ?? 0) as int;
          if (currentCount > 0) {
            transaction.update(totalePath, {"count": currentCount - 1});
          } else {
            transaction.update(totalePath, {"count": 0});
          }
        } else {
          // Se il documento non esiste, lo crea con count = 0
          transaction.set(totalePath, {"count": 0});
        }
      });

      _isLoading = false;
      notifyListeners();
      debugPrint("Prenotazione annullata con successo e totale aggiornato.");
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      errore();
      debugPrint("Errore durante l'annullamento della prenotazione: $e");
    }
  }



  Future<void> caricaProdottiPrenotati() async {

    _isLoading = true;
    notifyListeners();

    List<Map<String, dynamic>> listaProdottiAssociati = [];

    try {
      // Ottieni l'email dell'utente loggato
      String? email = FirebaseAuth.instance.currentUser?.email;
      if (email == null) {
        _isLoading = false;
        notifyListeners();

        return;
      }

      DocumentReference userReference = _db.collection("utenti").doc(email);

      // Recupera i prodotti prenotati dallo stato "attesa"
      QuerySnapshot prodottiPrenotatiSnapshot = await _db.collection("prodottiPrenotati")
          .where("utente", isEqualTo: userReference)
          .where("stato", isEqualTo: "attesa")
          .get();

      List<Future<void>> tasks = [];

      for (var doc in prodottiPrenotatiSnapshot.docs) {
        // Converti il documento in un oggetto ProdottoPrenotato
        ProdottoPrenotato prodottoPrenotato = ProdottoPrenotato.fromMap(doc.data() as Map<String, dynamic>);
        print("Prenotato: ${prodottoPrenotato.quantita}");

        DocumentReference? prodottoRef = prodottoPrenotato.prodotto;
        // Carica il prodotto associato
        Future<void> task = prodottoRef.get().then((prodottoDoc) {
          if (prodottoDoc.exists) {
            Prodotto prodotto = Prodotto.fromFirestore(prodottoDoc);
            print("Prodotto associato: ${prodotto.nome}");

            listaProdottiAssociati.add({
              "prodottoPrenotato": prodottoPrenotato,
              "prodotto": prodotto,
            });
          }
        });

        tasks.add(task);
            }

      // Attendi il completamento di tutti i task
      await Future.wait(tasks);

      // Ordina i prodotti per nome
      listaProdottiAssociati.sort(
              (a, b) => a["prodotto"].nome.compareTo(b["prodotto"].nome));

      _listaProdottiPrenotati = listaProdottiAssociati;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Errore nel caricamento dei prodotti prenotati: $e");
    }
  }


  Future<void> annullaPrenotazioneProdotto(ProdottoPrenotato prodottoPren) async {
    try {

      _isLoading = true;
      notifyListeners();

      // Trova il documento da eliminare
      QuerySnapshot querySnapshot = await _db
          .collection("prodottiPrenotati")
          .where("prodotto", isEqualTo: prodottoPren.prodotto)
          .where("quantita", isEqualTo: prodottoPren.quantita)
          .where("utente", isEqualTo: prodottoPren.utente)
          .where("data", isEqualTo: prodottoPren.data)
          .where("stato", isEqualTo: prodottoPren.stato)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var document in querySnapshot.docs) {
          await document.reference.delete();
        }
      }

      // Aggiorna la quantità del prodotto SENZA transazione
      DocumentReference prodottoReference = prodottoPren.prodotto;

      DocumentSnapshot snapshot = await prodottoReference.get();
      if (snapshot.exists) {
        int quantitaAttuale = (snapshot["quantita"] as num?)?.toInt() ?? 0;
        int nuovaQuantita = quantitaAttuale + prodottoPren.quantita;

        await prodottoReference.update({"quantita": nuovaQuantita});
      }

      // Dopo l'aggiornamento ricarica la lista dei prodotti prenotati
      await caricaProdottiPrenotati();


      print("Aggiornamento completato con successo.");
        } catch (e) {
      _isLoading = false;
      notifyListeners();
      print("Errore: ${e.toString()}");
    }
  }





}
