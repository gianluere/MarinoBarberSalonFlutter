import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';



class ListaGiorniViewModel extends ChangeNotifier{

  final List<DateTime> giorniFestivi = [
    DateTime(2024, 1, 1),  // Capodanno
    DateTime(2024, 12, 25), // Natale
    DateTime(2024, 12, 26), // Santo Stefano
    DateTime(2024, 4, 25),  // Festa della Liberazione
    DateTime(2024, 8, 15)   // Ferragosto
  ];

  final FirebaseFirestore db = FirebaseFirestore.instance;
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  List<Map<DateTime, List<Map<String, String>>>> _listaGiorni = [];
  List<Map<DateTime, List<Map<String, String>>>> _listaGiorniOccupati = [];
  List<Map<DateTime, List<Map<String, String>>>> _listaGiorniAggiornata = [];

  List<Map<DateTime, List<Map<String, String>>>> get listaGiorniAggiornata =>
      _listaGiorniAggiornata;



  Future<void> initialize(DateTime oggi, int giorniTotali, int durataServizio) async {
    try {
      _isLoading = true;
      notifyListeners();

      //Genera la lista dei giorni
      _listaGiorni = _generateListaDate(oggi, giorniTotali, giorniFestivi);
      _listaGiorniAggiornata = List.from(_listaGiorni);

      //Genera la lista degli orari occupati da Firestore
      _listaGiorniOccupati = await _generaListaOccupati(oggi, giorniTotali);
      /*
      print(_listaGiorniOccupati.length);
      for (var mappa in _listaGiorniOccupati) {
        for (var entry in mappa.entries) {
          DateTime giorno = entry.key;
          List<Map<String, String>> listaOccupati = entry.value;

          print("Giorno: $giorno");

          for (var occupato in listaOccupati) {
            print("  Dettagli:");
            occupato.forEach((chiave, valore) {
              print("    $chiave: $valore");
            });
          }
        }
      }

       */

      //Aggiorna la lista dei giorni con quelli occupati
      _listaGiorniAggiornata =
          _aggiornaListaOccupati(_listaGiorni, _listaGiorniOccupati);

      //Se il servizio dura più di 30 minuti, aggiorna gli slot
      if (durataServizio > 30) {
        _listaGiorniAggiornata =
            _aggiornaSlotdaSessanta(_listaGiorniAggiornata);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Errore durante l\'inizializzazione: $e');
    }
  }

  ///Generazione della lista di date
  ///ogni slot è da 30 minuti
  List<Map<DateTime, List<Map<String, String>>>> _generateListaDate(
      DateTime oggi, int giorniTotali, List<DateTime> giorniFestivi) {
    final List<Map<DateTime, List<Map<String, String>>>> giorniDisponibili = [];

    final orarioInizio = TimeOfDay(hour: 9, minute: 0);
    final orarioFine = TimeOfDay(hour: 20, minute: 0);
    final durataSlot = Duration(minutes: 30);

    for (int i = 0; i <= giorniTotali; i++) {
      final giornoCorrente = normalizedDate(oggi.add(Duration(days: i)));


      // Escludo domenica, lunedì e giorni festivi
      if (giornoCorrente.weekday == DateTime.sunday ||
          giornoCorrente.weekday == DateTime.monday ||
          giorniFestivi.contains(giornoCorrente)) {
        giorniDisponibili.add({giornoCorrente: []});
      } else {
        final slotOrari = <Map<String, String>>[];
        var orarioCorrente = i == 0 && TimeOfDay.now().hour >= orarioInizio.hour
            ? _primoOrarioDisponibile(TimeOfDay.now())
            : orarioInizio;

        while (orarioCorrente.hour < orarioFine.hour ||
            (orarioCorrente.hour == orarioFine.hour &&
                orarioCorrente.minute < orarioFine.minute)) {
          final orarioSuccessivo = _addTime(orarioCorrente, durataSlot);
          slotOrari.add({
            "inizio": _formatTime(orarioCorrente),
            "fine": _formatTime(orarioSuccessivo)
          });
          orarioCorrente = orarioSuccessivo;
        }
        giorniDisponibili.add({giornoCorrente: slotOrari});
      }
    }

    return giorniDisponibili;
  }

  //Recupera la lista degli orari occupati da Firestore
  Future<List<Map<DateTime, List<Map<String, String>>>>> _generaListaOccupati(
      DateTime oggi, int giorniTotali) async {
    final List<Map<DateTime, List<Map<String, String>>>> listaOccupati = [];
    final oggiFormatted = normalizedDate(oggi);
    final ultimoFormatted = normalizedDate(oggi.add(Duration(days: giorniTotali)));

    try {
      final giorni = await db.collection('occupati').get();

      for (var giorno in giorni.docs) {
        final giornoCorrente = normalizedDate(DateFormat('dd-MM-yyyy').parse(giorno.id));

        if (giornoCorrente.isAtSameMomentAs(oggiFormatted) ||
            (giornoCorrente.isAfter(oggiFormatted) && giornoCorrente.isBefore(ultimoFormatted)) ||
            giornoCorrente.isAtSameMomentAs(ultimoFormatted)) {

          final slotOrari = <Map<String, String>>[];
          final dati = giorno.data();
          //non vengono recuperati in ordine cronologico, quindi li ordino qui
          final orariOrdinati = dati.keys.toList()..sort((a, b) {
            final orarioInizioA = DateFormat('HH:mm').parse(a.split('-')[0].trim());
            final orarioInizioB = DateFormat('HH:mm').parse(b.split('-')[0].trim());
            return orarioInizioA.compareTo(orarioInizioB);
          });

          //verifico la presenza di slot da 60 che trasformo in due slot da 30
          for (var key in orariOrdinati) {
            final orarioInizio = DateFormat('HH:mm').parse(key.split('-')[0].trim());
            final orarioFine = DateFormat('HH:mm').parse(key.split('-')[1].trim());

            final durataSlot = orarioFine.difference(orarioInizio).inMinutes;

            if (durataSlot >= 60) { //divido in due slot da 30 minuti
              final primoSlotFine = orarioInizio.add(Duration(minutes: 30));
              slotOrari.add({
                "inizio": DateFormat('HH:mm').format(orarioInizio),
                "fine": DateFormat('HH:mm').format(primoSlotFine),
              });
              slotOrari.add({
                "inizio": DateFormat('HH:mm').format(primoSlotFine),
                "fine": DateFormat('HH:mm').format(orarioFine),
              });
            } else {
              // Aggiungo lo slot originale
              slotOrari.add({
                "inizio": DateFormat('HH:mm').format(orarioInizio),
                "fine": DateFormat('HH:mm').format(orarioFine),
              });
            }
          }
          listaOccupati.add({giornoCorrente: slotOrari});
        }
      }
    } catch (e) {
      debugPrint('Errore durante l\'accesso a Firestore: $e');
    }

    return listaOccupati;
  }


  // Aggiorna la lista degli orari occupati
  List<Map<DateTime, List<Map<String, String>>>> _aggiornaListaOccupati(
      List<Map<DateTime, List<Map<String, String>>>> listaOrari,
      List<Map<DateTime, List<Map<String, String>>>> listaOccupati) {
    return listaOrari.map((giorno) {
      //Prendo la data corrente dalla mappa (c'è solo una chiave per ogni mappa)
      final data = giorno.keys.first;

      //Prendo gli orari disponibili per quella data
      final orariDisponibili = giorno[data] ?? [];

      //uso normalizedDate per confrontare le date senza tener conto dell'orario
      final occupatiPerQuestaData = listaOccupati.firstWhere(
            (item) => normalizedDate(item.keys.first) == normalizedDate(data),
        orElse: () => {data: []},
      )[data];

      // Filtra gli orari disponibili escludendo quelli che coincidono con gli orari occupati
      final orariAggiornati = orariDisponibili
          .where((orario) =>
      !(occupatiPerQuestaData?.any((occupato) =>
      occupato["inizio"] == orario["inizio"] &&
          occupato["fine"] == orario["fine"]) ??
          false)) // Se occupatiPerQuestaData è null, il valore di default è false
          .toList();

      return {data: orariAggiornati};
    }).toList();
  }

  // Aggiorna gli slot da 60 minuti
  List<Map<DateTime, List<Map<String, String>>>> _aggiornaSlotdaSessanta(
      List<Map<DateTime, List<Map<String, String>>>> lista) {
    return lista.map((giorno) {
      final data = giorno.keys.first;
      final orari = giorno[data] ?? [];

      final nuoviOrari = <Map<String, String>>[];

      for (int i = 0; i < orari.length - 1; i++) {
        final orarioCorrente = orari[i];
        final orarioSuccessivo = orari[i + 1];

        //Controlla se l'inizio del secondo orario corrisponde alla fine del primo
        if (orarioCorrente['fine'] == orarioSuccessivo['inizio']) {
          final nuovoOrario = {
            "inizio": orarioCorrente['inizio']!,
            "fine": orarioSuccessivo['fine']!
          };
          nuoviOrari.add(nuovoOrario);
        }
      }

      return {data: nuoviOrari};
    }).toList();
  }


  // Helper methods
  TimeOfDay _primoOrarioDisponibile(TimeOfDay currentTime) {
    final nextMinute = currentTime.minute % 30 == 0 ? currentTime.minute : (currentTime.minute ~/ 30 + 1) * 30;
    final nextHour = currentTime.hour + nextMinute ~/ 60;
    return TimeOfDay(hour: nextHour, minute: nextMinute % 60);
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  TimeOfDay _addTime(TimeOfDay time, Duration duration) {
    final totalMinutes = time.hour * 60 + time.minute + duration.inMinutes;
    return TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
  }

  DateTime normalizedDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }


}