import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'appuntamento.dart';



class NotificheViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _prenotazioniSubscription;
  int _notifichePrenotazioni = 0;

  int get notifichePrenotazioni => _notifichePrenotazioni;


  NotificheViewModel() {

    _startListenerPrenotazioni();

    //in casi di logout e nuovi accessi
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
       _startListenerPrenotazioni();
      } else {
        stopListenerPrenotazioni();
        _notifichePrenotazioni = 0;
        notifyListeners();
      }
    });



  }

  //notifiche per la bottomBar e pagina account
  void _startListenerPrenotazioni() {
    final user = _auth.currentUser;
    if (user == null) return;

    _prenotazioniSubscription = _db.collection("utenti").doc(user.email).snapshots().listen((snapshot) async {
      if (snapshot.exists) {
        final List<DocumentReference>? appuntamentiList =
        (snapshot.data()?["appuntamenti"] as List<dynamic>?)
            ?.cast<DocumentReference>();

        if (appuntamentiList != null) {
          //debugPrint("Appuntamenti trovati: ${appuntamentiList.length}");

          final appuntamenti = await _recuperaDocumenti(appuntamentiList);
          //debugPrint("Appuntamenti validi: ${appuntamenti.length}");

          _calcolaNotifiche(appuntamenti);
        }
      } else {
        debugPrint("Errore: Documento utente non trovato.");
      }
    });
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

  void _calcolaNotifiche(List<Appuntamento> appuntamenti) {
    final oggi = DateTime.now();
    int totale = 0;

    for (var appuntamento in appuntamenti) {

      DateTime giornoApp = DateFormat("dd-MM-yyyy HH:mm").parse("${appuntamento.data} ${appuntamento.orarioInizio}");


      if (oggi.isBefore(giornoApp)) {
        totale++;
      }
    }

    _notifichePrenotazioni = totale;
    notifyListeners();
  }

  //elimina il listener
  void stopListenerPrenotazioni() {
    _prenotazioniSubscription?.cancel();
    _prenotazioniSubscription = null;
  }

}
