import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'appuntamento.dart';



class NotificheViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int notifichePrenotazioni = 0;

  NotificheViewModel() {
    _startListenerPrenotazioni();
  }

  void _startListenerPrenotazioni() {
    final user = _auth.currentUser;
    if (user == null) return;

    _db.collection("utenti").doc(user.email).snapshots().listen((snapshot) async {
      if (snapshot.exists) {
        final List<DocumentReference>? appuntamentiList =
        (snapshot.data()?["appuntamenti"] as List<dynamic>?)
            ?.cast<DocumentReference>();

        if (appuntamentiList != null) {
          debugPrint("Appuntamenti trovati: ${appuntamentiList.length}");

          final appuntamenti = await _recuperaDocumenti(appuntamentiList);
          debugPrint("Appuntamenti validi: ${appuntamenti.length}");

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

    notifichePrenotazioni = totale;
    notifyListeners();
  }
}
